FROM debian:bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && \
    apt-get install -y \
    git bc bison flex libssl-dev python3 make kmod libc6-dev libncurses5-dev \
    crossbuild-essential-armhf \
    crossbuild-essential-arm64 \
    vim wget kpartx fdisk rsync sudo util-linux cloud-guest-utils \
    ca-certificates \
    automake gcc g++ make libncurses-dev nasm libsdl-net1.2-dev libsdl2-net-dev libpcap-dev \
    libslirp-dev fluidsynth libfluidsynth-dev libavdevice58 libavformat-dev libavcodec-dev \
    libavcodec-extra libavcodec-extra58 libswscale-dev libfreetype-dev

RUN mkdir /build
RUN mkdir -p /mnt/fat32
RUN mkdir -p /mnt/ext4

WORKDIR /build

RUN git clone --depth=1 https://github.com/joncampbell123/dosbox-x.git
WORKDIR /build/dosbox-x
RUN sed -i -e 's@--prefix=/usr@--prefix=/mnt/ext4/usr CPPFLAGS="-march=armv8-a+simd+crypto+crc+sb -mtune=cortex-a53"@g' build-debug-sdl2
RUN ./build-debug-sdl2

WORKDIR /build

CMD ["bash"]


# Cross compile kernel
FROM base AS build-kernel
ARG KERNEL
ARG BRANCH
VOLUME /images

WORKDIR /usr/src

RUN --mount=type=cache,target=/usr/src/linux/ \
  rm -rf linux; \
  git clone --depth=1 https://github.com/raspberrypi/linux --branch ${BRANCH}
COPY build/* .
RUN --mount=type=cache,target=/usr/src/linux/ \
  ./compile-kernel.sh $KERNEL -j8 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

CMD ["bash"]


# Extend image for Dosbian
FROM base AS build-image
VOLUME /images

COPY . /build
WORKDIR /build/build

CMD ["bash"]
