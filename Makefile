# Legacy (Raspberry Pi OS - Debian 10 Buster)
# IMG_BASE=2021-05-07-raspios-buster-arm64-lite
# IMG_URL=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-05-28/2021-05-07-raspios-buster-arm64-lite.zip

# Previous (Raspberry Pi OS - Debian 11 Bullseye)
# IMG_BASE=2023-05-03-raspios-bullseye-arm64-lite
# IMG_URL=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz

# Latest (Raspberry Pi OS - Debian 12 Bookworm) - required for libsdl1.2-compat (required for Dosbox-SVN/ECE as surface output won't scale)
IMG_BASE=2023-10-10-raspios-bookworm-arm64-lite
IMG_URL=https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-10-10/2023-10-10-raspios-bookworm-arm64-lite.img.xz

IMG=Dosbian-X-2.1.0
DOCKERFILE=Dockerfile
EXECUTE=docker run --rm \
		--name build-image-dosbian \
		--volume ${PWD}:/dosbian \
		--volume ${PWD}/images:/images \
		--privileged \
		build-image-dosbian \
		/bin/bash -c

all: images/${IMG}.img

clean:
	-rm images/${IMG}*.img

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

images/${IMG}-step1.img: images/${IMG_BASE}.img
	${EXECUTE} " \
		cp /$< /$@; \
		scripts/grow-image.sh /$@ 2600M; \
		scripts/execute.sh /$@ /dosbian/scripts/install-dosboxes.sh"

images/${IMG}.img: images/${IMG}-step1.img
	${EXECUTE} " \
		cp /$< /$@; \
		scripts/grow-image.sh /$@ 3G; \
		scripts/execute.sh /$@ /dosbian/scripts/customise-distro.sh"

.PHONY: step%
step%: images/${IMG}-step%.img

.PHONY: final
final: images/${IMG}.img

# Debug into the container
#docker run -ti --rm --name build-image-dosbian --volume ${PWD}:/dosbian --volume ${PWD}/images:/images \
--privileged build-image-dosbian /bin/bash -c "scripts/execute.sh /images/Dosbian-X-2.1.0.img /bin/bash"

# Mount network share
#sudo mount.cifs -o user=weese //192.168.1.1/public/Software/Games dosbian/perseus
