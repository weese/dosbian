# Latest (Raspberry Pi OS - Debian 11 Bullseye)
IMG_BASE=2023-05-03-raspios-bullseye-arm64-lite
IMG_URL=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz
IMG=Dosbian-X-2.1.0
BRANCH=rpi-6.1.y
DOCKERFILE=Dockerfile
EXECUTE=docker run --rm \
		--name build-image-dosbian \
		--volume ${PWD}/images:/images \
		--privileged \
		build-image-dosbian \
		/bin/bash -c

all: db step1

clean:
	rm images/${IMG}*.img

.PHONY: docker-build
docker-build db:
	DOCKER_BUILDKIT=1 \
		docker build \
		--file ${DOCKERFILE} \
		--progress=plain \
		-t build-image-dosbian \
		.

images/${IMG_BASE}.img:
	mkdir -p images
	cd images; \
	curl ${IMG_URL} -o ${IMG_BASE}.img.xz; \
	xz -d ${IMG_BASE}.img.xz

# images/${IMG_BASE}.img:
# 	mkdir -p images
# 	curl ${IMG_URL} -o images/${IMG_BASE}.img.zip
# 	unzip -p images/${IMG_BASE}.img.zip > $@
# 	rm images/${IMG_BASE}.img.zip

images/${IMG}-step0.img: images/${IMG_BASE}.img
	${EXECUTE} "cp /$< /$@; scripts/resize-image.sh /$@"

images/${IMG}-step1.img: images/${IMG}-step0.img
	${EXECUTE} "cp /$< /$@; scripts/execute.sh /$@ /dosbian/scripts/install-dosboxes.sh"

images/${IMG}.img: images/${IMG}-step1.img
	${EXECUTE} "cp /$< /$@; scripts/execute.sh /$@ /dosbian/scripts/customise-distro.sh"

.PHONY: step0
step0: images/${IMG}-step0.img

.PHONY: step1
step1: images/${IMG}.img
