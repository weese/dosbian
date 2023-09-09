FROM debian:bullseye AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt clean && apt-get update && \
    apt install -y kpartx fdisk util-linux cloud-guest-utils

VOLUME /dosbian
VOLUME /images
WORKDIR /dosbian

CMD ["bash"]
