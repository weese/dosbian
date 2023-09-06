# Latest (Raspberry Pi OS - Debian 11 Bullseye)
IMG=2023-05-03-raspios-bullseye-arm64-lite
IMG_URL=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz
BRANCH=rpi-6.1.y
DOCKERFILE=Dockerfile

all: build-image

clean:
	rm images/${IMG}_*.img

docker-build db: docker-build-image

.PHONY: docker-build-image
docker-build-image dbi:
	DOCKER_BUILDKIT=1 \
		docker build \
		--file ${DOCKERFILE} \
		--progress=plain \
		--target build-image \
		-t build-image-dosbian \
		.

images/${IMG}.img:
	mkdir -p images
	cd images; \
	curl ${IMG_URL} -o ${IMG}.img.xz; \
	xz -d ${IMG}.img.xz

# images/${IMG}.img:
# 	mkdir -p images
# 	curl ${IMG_URL} -o images/${IMG}.img.zip
# 	unzip -p images/${IMG}.img.zip > $@
# 	rm images/${IMG}.img.zip


.PHONY: build-image bi
build-image bi: images/${IMG}.img
	docker run --rm \
		--name build-image-dosbian \
		--volume ${PWD}/images:/images \
		--privileged \
		build-image-dosbian \
		/bin/bash -c "./build-image.sh YES /images/${IMG}.img && mv ${IMG}_* /images/"
