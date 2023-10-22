# Dosbian-X - Boot directly into a 486DX on your Raspberry Pi

## Dosbian-X

After eagerly waiting for Dosbian 2.0, I've decided to continue the development of the great
[Dosbian](https://cmaiolino.wordpress.com/dosbian) on my own and release it here.
Dosbian-X is based on the original Dosbian image created by Carmelo Maiolino.
I extended it with the latest Raspberry Pi OS Lite (64-bit) and all common DOSBox emulators.

Dosbian-X includes:

- all common DOSBox emulators
  - [DOSBox-X](https://dosbox-x.com/) - modern and accurrate successor of Dosbox
  - [DOSBox-Staging](https://dosbox-staging.github.io/) lots of enhancements (Shaders, Roland MT-32, FluidSynth)
  - [DOSBox-ECE](https://yesterplay.net/dosboxece/) - Enhanced Community Edition (3Dfx Voodoo, Roland MT-32, FluidSynth)
  - [DOSBox-SVN](https://sourceforge.net/projects/dosbox/) - the original
- latest Raspberry Pi OS Lite (64-bit)
- support for all 64-bit Raspberry Pi models (3B, 3B+, 3A+, 4, 400, CM3, CM3+, CM4, Zero 2 W)
- build-pipeline to build the SD card image

If you have problems, fixes, comments please create an [issue](https://github.com/weese/dosbian-x/issues), [pull request](https://github.com/weese/dosbian-x/pulls) or start a [discussion](https://github.com/weese/dosbian-x/discussions).
Have fun and enjoy the 90s with your Raspberry Pi. More updates will follow...

If you like to support the development, you can buy me a [coffee](https://ko-fi.com/davomat).

## Installation

To use Dosbian-X, download the latest release from [here](https://github.com/weese/dosbian-x/releases) and burn it on a microSD card, e.g. with [balenaEtcher](https://www.balena.io/etcher).

To connect your Raspberry Pi to your Wifi or enable the SSH server, put `ssh` or `wpa_supplicant.conf` files to your boot folder (the FAT32 partition of the microSD card) or start `raspi-config` on the Pi. More details can be found [here](https://www.raspberrypi.com/documentation/computers/configuration.html#boot-folder-contents).

## Custom Build

You can build your own SD image of Raspbian for the Dosbian-X on your local ARM compatible machine (tested on Macbook M1) using [Docker Desktop](https://www.docker.com/get-started).
After installing Docker, you should tune it a bit to speed up the build process:

 - increase resources to e.g. 8 CPUs
 - enable Experimental Features -> Enable VirtuoFS accelerated directory sharing

Then create the requried docker image with:

```
make docker-build
```

and after that build the Dosbian-X image with

```
make
```

The final image will be written into the folder `images` and is has a filename that includes a recent UTC date
`Dosbian-x.y.img`. Simply burn that image to a microSD card using [balenaEtcher](https://www.balena.io/etcher) and boot.

## The original Dosbian image

Dosbian-X is based on the original Dosbian image created by Carmelo Maiolino:
Web page: https://cmaiolino.wordpress.com/dosbian
Facebook: www.facebook.com/groups/Dosbian
