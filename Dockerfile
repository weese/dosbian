FROM debian:bullseye AS base

ARG SDL2_BRANCH=release-2.28.3
ARG SDL2_NET_BRANCH=release-2.2.0
ARG SDL2_IMAGE_BRANCH=release-2.6.3
ARG FLUIDSYNTH_BRANCH=v2.3.2
ARG DOSBOX_SVN_VERSION=RELEASE_0_74_3
ARG DOSBOX_ECE_VERSION=r4482
ARG DOSBOX_X_BRANCH=dosbox-x-v2023.09.01
ARG DOSBOX_STAGING_BRANCH=v0.79.1
ENV DEBIAN_FRONTEND=noninteractive

COPY build/sources.list /etc/apt/sources.list
RUN apt clean && apt-get update && \
    apt install -y kpartx fdisk rsync sudo util-linux cloud-guest-utils

# RUN apt clean && apt-get update && \
#     apt install -y \
#     git bc bison flex libssl-dev python3 make kmod libc6-dev libncurses5-dev \
#     vim wget kpartx fdisk rsync sudo util-linux cloud-guest-utils \
#     ca-certificates \
#     automake gcc g++ make libncurses-dev nasm libsdl1.2-dev libsdl-net1.2-dev libpcap-dev \
#     libslirp-dev libavdevice58 libavformat-dev libavcodec-dev \
#     libavcodec-extra libavcodec-extra58 libswscale-dev libfreetype-dev \
#     libopusfile-dev libspeexdsp-dev meson p7zip \
#     libpng-dev zlib1g-dev libsdl-sound1.2-dev dos2unix cmake curl libtool \
#     libsndfile1-dev libflac-dev subversion \
#     libdrm-dev libgbm-dev
# RUN apt build-dep -y libsdl2
# RUN apt purge -y libsdl2-2.0-0

    # crossbuild-essential-armhf \
    # crossbuild-essential-arm64 \

RUN mkdir /build
RUN mkdir -p /mnt/fat32
RUN mkdir -p /mnt/ext4

# ENV CFLAGS="-march=armv8-a+fp+crc+simd -mcpu=cortex-a53 -mtune=cortex-a53"
# ENV CXXFLAGS="-march=armv8-a+fp+crc+simd -mcpu=cortex-a53 -mtune=cortex-a53 -I/usr/local/include/openglide/"

# # Install mt32emu (Roland MT-32 support)
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/munt/munt.git
# RUN mkdir -p munt/build
# WORKDIR /build/munt/build
# RUN cmake -Dmunt_WITH_MT32EMU_SMF2WAV=OFF -Dmunt_WITH_MT32EMU_QT=OFF ..
# RUN make -j4 install

# # Compile SDL2 manually to fix problems with direct framebuffer rendering
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/libsdl-org/SDL.git -b $SDL2_BRANCH
# WORKDIR /build/SDL
# RUN ./configure --enable-video-kmsdrm --enable-video-opengles --enable-video-directfb
# RUN make -j4 install

# # Compile SDL_net
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/libsdl-org/SDL_net.git -b $SDL2_NET_BRANCH
# WORKDIR /build/SDL_net
# RUN ./configure
# RUN make -j4 install

# # Compile SDL_image
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/libsdl-org/SDL_image.git -b $SDL2_IMAGE_BRANCH
# WORKDIR /build/SDL_image
# RUN ./configure
# RUN make -j4 install

# # Install OpenGlide (emulates Voodoo graphics card)
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/voyageur/openglide.git
# WORKDIR /build/openglide
# RUN ./bootstrap
# RUN ./configure
# RUN make -j 4 install
# RUN ldconfig

# # Install FluidSynth (SoundFont Synthesizer)
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/FluidSynth/fluidsynth.git -b $FLUIDSYNTH_BRANCH
# RUN mkdir -p fluidsynth/build
# WORKDIR /build/fluidsynth/build
# RUN cmake ..
# RUN make -j4 install

# # Compile Dosbox-SVN
# WORKDIR /build
# RUN svn checkout https://svn.code.sf.net/p/dosbox/code-0/dosbox/tags/$DOSBOX_SVN_VERSION dosbox-svn
# WORKDIR /build/dosbox-svn
# RUN ./autogen.sh
# RUN ./configure
# RUN make -j4 install
# RUN mv /usr/local/bin/dosbox /usr/local/bin/dosbox-svn

# # Compile Dosbox-ECE
# RUN mkdir /build/dosbox-ece
# WORKDIR /build/dosbox-ece
# RUN wget -O dosbox-ece.7z "https://yesterplay.net/dosboxece/download/DOSBox%20ECE%20$DOSBOX_ECE_VERSION%20(source).7z"
# RUN p7zip -d dosbox-ece.7z
# RUN find . -type f -exec dos2unix {} \;
# RUN chmod a+x autogen.sh
# RUN ./autogen.sh
# RUN ./configure
# RUN make -j4 install
# RUN mv /usr/local/bin/dosbox /usr/local/bin/dosbox-ece

# # Compile Dosbox-Staging
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/dosbox-staging/dosbox-staging -b $DOSBOX_STAGING_BRANCH
# WORKDIR /build/dosbox-staging
# RUN meson setup build/release
# RUN meson compile -C build/release
# WORKDIR /build/dosbox-staging/build/release
# RUN meson install
# RUN mv /usr/local/bin/dosbox /usr/local/bin/dosbox-staging

# # Compile Dosbox-X
# WORKDIR /build
# RUN git clone --depth=1 https://github.com/joncampbell123/dosbox-x.git -b $DOSBOX_X_BRANCH
# WORKDIR /build/dosbox-x
# # RUN sed -i -e 's@--prefix=/usr@--prefix=/usr/local CPPFLAGS="-march=armv8-a+simd+crypto+crc+sb -mtune=cortex-a53"@g' build-debug-sdl2
# RUN ./autogen.sh
# RUN ./configure --enable-debug=heavy --prefix=/usr/local --enable-sdl2
# RUN make -j4
# RUN make install

# # Compile IPXBOX
# RUN wget https://go.dev/dl/go1.17.linux-arm64.tar.gz
# RUN tar -C /usr/local -xzf go1.17.linux-arm64.tar.gz
# ENV PATH="/usr/local/go/bin:${PATH}"
# ENV GOPATH=/build/go
# RUN go env -w GO111MODULE=off
# RUN go get github.com/fragglet/ipxbox > /dev/null
# RUN go build github.com/fragglet/ipxbox

WORKDIR /build

CMD ["bash"]


# Extend image for Dosbian
FROM base AS build-image
VOLUME /images

COPY . /build
WORKDIR /build/build

CMD ["bash"]
