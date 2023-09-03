# Dosbian 2.0 RPi image

## Dosbian 2.0

After eagerly waiting for Dosbian 2.0 and due to [Carmelo Maiolino's announcement](https://cmaiolino.wordpress.com/lack-of-raspberry-pi-supplies) of no longer developing any distros for the Raspberry Pis,
I decided to continue the development of [Dosbian](https://cmaiolino.wordpress.com/dosbian) on my own and continue where he left off.
It still includes the nice menus and splash screens and according copyright notes from him. Carmelo, I hope that's ok.

Dosbian 2.0 includes:

- the wonderful [DOSBox-X](https://dosbox-x.com/) emulator (accurrate successor of Dosbox)
- latest Raspberry Pi OS Lite (64-bit)
- support for all 64-bit Raspberry Pi models (3B, 3B+, 3A+, 4, 400, CM3, CM3+, CM4, Zero 2 W)
- build pipeline to build the SD card image

If you have problems, fixes, comments please create an [issue](https://github.com/weese/dosbian/issues), [pull request](https://github.com/weese/dosbian/pulls) or start a [discussion](https://github.com/weese/dosbian/discussions).
Have fun and enjoy the 90s with your Raspberry Pi. More updates will follow...

If you like to support the development, you can buy me a [coffee](https://ko-fi.com/davomat).

## Installation

To use Dosbian 2.0, download the latest release from [here](https://github.com/weese/dosbian/releases) and burn it on a microSD card, e.g. with [balenaEtcher](https://www.balena.io/etcher).

To connect your Raspberry Pi to your Wifi or enable the SSH server, put `ssh` or `wpa_supplicant.conf` files to your boot folder (the FAT32 partition of the microSD card) or start `raspi-config` on the Pi. More details can be found [here](https://www.raspberrypi.com/documentation/computers/configuration.html#boot-folder-contents).

## Custom Build

You can build your own SD image of Raspbian for the Dosbian on your local ARM compatible machine (tested on Macbook M1) using [Docker Desktop](https://www.docker.com/get-started).
After installing Docker, you should tune it a bit to speed up the build process:

 - increase resources to e.g. 8 CPUs
 - enable Experimental Features -> Enable VirtuoFS accelerated directory sharing

Then create the requried docker images with:

```
make docker-build
```

and after that build the images with

```
make all
```

The final image will be written into the folder `images` and is has a filename that includes a recent UTC date
`2023-05-03-raspios-bullseye-arm64-lite_2023xxxx-xxxxxx.img`. Simply burn that image to a microSD card using [balenaEtcher](https://www.balena.io/etcher) and boot.

## The original Dosbian image

DOSBIAN is a Raspberry Pi distro created in 2020 by Carmelo Maiolino.

Keep in the palm of your hand an equivalent 486DX machine of the 90s and 
enjoy playing with your preferite retro software and retro games.


It is compatible with the following Raspberry Pi models:

- Pi 1 (Run with limitations)
- Pi 0/0W (Run with limitations)
- Pi 2B
- Pi 3B
- Pi 3B+
- Pi 3A+
- Pi 4B

THE PROJECT

Web page: https://cmaiolino.wordpress.com/dosbian
Facebook: www.facebook.com/groups/Dosbian

Visit my web page to leave a comment, get the latest news, download new versions of Dosbian.
If you need help on how to start with Dosbian, please feel free to ask support to the Facebook community.

TERMS OF USE

DOSBIAN is a donationware project, this means you can modify, improve, customise it as you like for your
own use. 

IT IS STRICTLY PROHIBITED: 

- USE DOSBIAN FOR COMMERCIAL PURPOSES.

- DIFFUSE YOUR OWN CUSTOMIZED COPY OF DOSBIAN
