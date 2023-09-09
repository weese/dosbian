FROM debian:bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt clean && apt-get update && \
    apt install -y kpartx fdisk rsync sudo util-linux cloud-guest-utils

COPY . /dosbian
VOLUME /images
WORKDIR /dosbian

CMD ["bash"]
