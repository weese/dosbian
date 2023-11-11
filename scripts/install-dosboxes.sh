#!/bin/bash
set -e

SDL2_BRANCH=release-2.28.4
SDL2_NET_BRANCH=release-2.2.0
SDL2_IMAGE_BRANCH=release-2.6.3
FLUIDSYNTH_BRANCH=v2.3.4
DOSBOX_SVN_VERSION=RELEASE_0_74_3
DOSBOX_ECE_VERSION=r4482
DOSBOX_X_BRANCH=dosbox-x-v2023.10.06
DOSBOX_STAGING_BRANCH=v0.80.1

export DEBIAN_FRONTEND=noninteractive
export CFLAGS="-march=armv8-a+fp+crc+simd -mcpu=cortex-a53 -mtune=cortex-a53"
export CXXFLAGS="-march=armv8-a+fp+crc+simd -mcpu=cortex-a53 -mtune=cortex-a53 -I/usr/local/include/openglide/"

# Add docker DNS if necessary
if [ ! -f /etc/resolv.conf ]; then
cat << EOF > /etc/resolv.conf
# DNS requests are forwarded to the host. DHCP DNS options are ignored.
nameserver 192.168.65.7
EOF
fi

# Add source repos
. /etc/os-release
if [ "$VERSION_ID" == "12" ]; then
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
# Uncomment deb-src lines below then 'apt-get update' to enable 'apt-get source'
deb-src http://deb.debian.org/debian bookworm main contrib non-free
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free
deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free
EOF
elif [ "$VERSION_ID" == "11" ]; then
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
# Uncomment deb-src lines below then 'apt-get update' to enable 'apt-get source'
deb-src http://deb.debian.org/debian bullseye main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free
EOF
elif [ "$VERSION_ID" == "10" ]; then
cat << EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian buster main contrib non-free
deb http://deb.debian.org/debian buster-backports main contrib non-free
deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb http://deb.debian.org/debian buster-updates main contrib non-free
# Uncomment deb-src lines below then 'apt-get update' to enable 'apt-get source'
deb-src http://deb.debian.org/debian buster main contrib non-free
deb-src http://deb.debian.org/debian buster-backports main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://deb.debian.org/debian buster-updates main contrib non-free
EOF
fi

LIB_FREETYPE=libfreetype-dev
if [ "$VERSION_ID" == "12" ]; then
    AV_VERSION=59
    rm -f /boot/initrd.img-*-arm64
else
    AV_VERSION=58
    if [ "$VERSION_ID" == "10" ]; then
        LIB_FREETYPE=libfreetype6-dev
    fi
fi

mv /usr/sbin/update-initramfs /usr/sbin/update-initramfs.bak
ln -s /bin/echo /usr/sbin/update-initramfs

apt clean
apt-get update
apt-get -y upgrade
apt install -y \
    git bc bison flex libssl-dev python3 make kmod libc6-dev libncurses5-dev \
    vim wget kpartx fdisk rsync sudo util-linux cloud-guest-utils \
    ca-certificates \
    automake gcc g++ make libncurses-dev nasm libsdl1.2-compat libsdl1.2-compat-dev libpcap-dev \
    libslirp-dev libavdevice$AV_VERSION libavformat-dev libavcodec-dev \
    libavcodec-extra libavcodec-extra$AV_VERSION libswscale-dev $LIB_FREETYPE \
    libopusfile-dev libspeexdsp-dev meson p7zip \
    libpng-dev zlib1g-dev dos2unix cmake curl libtool \
    libsndfile1-dev libflac-dev subversion \
    libdrm-dev libgbm-dev \
    libncurses5 fbi dialog mc sox \
    libxkbfile-dev fluidsynth libfluidsynth-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-net-dev \
    libopengl0 kmscube libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev


apt build-dep -y libsdl2
apt clean

mkdir -p /build
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

#####################################################################
# UNCOMMENT LINE IF SOURCES SHOULDN'T BECOME PART OF THE IMAGE
# mount -t tmpfs -o size=2048M tmpfs /build

# Install mt32emu (Roland MT-32 support)
cd /build
git clone --depth=1 https://github.com/munt/munt.git
mkdir -p munt/build
cd /build/munt/build
cmake -Dmunt_WITH_MT32EMU_SMF2WAV=OFF -Dmunt_WITH_MT32EMU_QT=OFF ..
make -j4 install

# Compile SDL2 manually to fix problems with direct framebuffer rendering
cd /build
git clone --depth=1 https://github.com/libsdl-org/SDL.git -b $SDL2_BRANCH
cd /build/SDL
./configure --enable-video-kmsdrm --enable-video-opengles --enable-video-directfb
make -j4 install

# Compile SDL_net
cd /build
git clone --depth=1 https://github.com/libsdl-org/SDL_net.git -b $SDL2_NET_BRANCH
cd /build/SDL_net
./configure
make -j4 install

# Compile SDL_image
cd /build
git clone --depth=1 https://github.com/libsdl-org/SDL_image.git -b $SDL2_IMAGE_BRANCH
cd /build/SDL_image
./configure
make -j4 install

# Install OpenGlide (emulates Voodoo graphics card)
cd /build
git clone --depth=1 https://github.com/voyageur/openglide.git
cd /build/openglide
./bootstrap
./configure
make -j 4 install

# # Install FluidSynth (SoundFont Synthesizer)
# cd /build
# git clone --depth=1 https://github.com/FluidSynth/fluidsynth.git -b $FLUIDSYNTH_BRANCH
# mkdir -p fluidsynth/build
# cd /build/fluidsynth/build
# cmake ..
# make -j4 install

# Update the dynamic linker cache
ldconfig

# Compile Dosbox-SVN
cd /build
svn checkout https://svn.code.sf.net/p/dosbox/code-0/dosbox/tags/$DOSBOX_SVN_VERSION dosbox-svn
cd /build/dosbox-svn
./autogen.sh
./configure
make -j4 install
mv /usr/local/bin/dosbox /usr/local/bin/dosbox-svn

# Compile Dosbox-ECE
mkdir /build/dosbox-ece
cd /build/dosbox-ece
wget -O dosbox-ece.7z "https://yesterplay.net/dosboxece/download/DOSBox%20ECE%20$DOSBOX_ECE_VERSION%20(source).7z"
p7zip -d dosbox-ece.7z
find . -type f -exec dos2unix {} \;
chmod a+x autogen.sh
./autogen.sh
./configure
make -j4 install
mv /usr/local/bin/dosbox /usr/local/bin/dosbox-ece

# Compile Dosbox-Staging
cd /build
git clone --depth=1 https://github.com/dosbox-staging/dosbox-staging -b $DOSBOX_STAGING_BRANCH
cd /build/dosbox-staging
sed -i -e "s@'>= 0.57.0'@\'>= 0.56.0'@" meson.build
meson setup build/release
meson compile -C build/release
cd /build/dosbox-staging/build/release
meson install
mv /usr/local/bin/dosbox /usr/local/bin/dosbox-staging

# Compile Dosbox-X
cd /build
git clone --depth=1 https://github.com/joncampbell123/dosbox-x.git -b $DOSBOX_X_BRANCH
cd /build/dosbox-x
# sed -i -e 's@--prefix=/usr@--prefix=/usr/local@g' build-debug-sdl2
# ./build-debug-sdl2
./autogen.sh
./configure --enable-debug=heavy --prefix=/usr/local --enable-sdl2
make -j4
make install

# Compile IPXBOX
wget https://go.dev/dl/go1.17.linux-arm64.tar.gz
tar -C /usr/local -xzf go1.17.linux-arm64.tar.gz
export PATH="/usr/local/go/bin:${PATH}"
export GOPATH=/build/go
go env -w GO111MODULE=off
go get github.com/fragglet/ipxbox > /dev/null
go build github.com/fragglet/ipxbox

cd /
umount /build || true
