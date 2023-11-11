#!/bin/bash
set -ex

REPODIR=/dosbian

# Test for root user
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root"
  exit 1
fi

# Enable service for auto-login
systemctl enable getty@tty1.service

# Copy files from repo
rsync -av --exclude=".AppleDouble" --exclude=".DS_Store" $REPODIR/fs/ /
if [ -d $REPODIR/fs.extra ]; then
  rsync -av --exclude=".AppleDouble" --exclude=".DS_Store" $REPODIR/fs.extra/ /
fi
cp $REPODIR/fs/home/pi/.profile /home/pi/

# Make DOSBox-X default
ln -sf dosbox-x /usr/local/bin/dosbox

# Clone Dosbox Shader Pack
git clone https://github.com/tyrells/dosbox-svn-shaders.git /home/pi/.config/dosbox/glshaders
ln -s /home/pi/.config/dosbox/glshaders /home/pi/.config/dosbox-x/glshaders
ln -s /home/pi/.config/dosbox/glshaders /home/pi/.dosbox/glshaders

# Symlink all mt32-roms folders to the same location
ln -s /home/pi/.config/dosbox/mt32-roms /home/pi/.config/dosbox-x/mt32-roms
ln -s /home/pi/.config/dosbox/mt32-roms /home/pi/.dosbox/mt32-roms

# Symlink all soundfounts folders to the system folder
ln -s /usr/share/sounds/sf2/ /home/pi/.config/dosbox/soundfonts
ln -s /usr/share/sounds/sf2/ /home/pi/.config/dosbox-x/soundfonts
ln -s /usr/share/sounds/sf2/ /home/pi/.dosbox/soundfonts

# Install Fluidsynth and SoundFont
apt install -y fluidsynth pulseaudio
if [ ! -f /usr/share/sounds/sf2/ColomboMT32.sf2 ]; then
  curl https://musical-artifacts.com/artifacts/1484/ColomboMT32.sf2 -o /usr/share/sounds/sf2/ColomboMT32.sf2
fi

# Make backup of dosbox config files
mkdir -p /home/pi/.backup
cp /home/pi/.config/dosbox*/dosbox*.conf /home/pi/.backup/
cp /home/pi/.dosbox/dosbox*.conf /home/pi/.backup/

# Fix permissions and ownership
chown -R 1000:1000 /home/pi
chmod -R a+x /usr/local/bin

# Enable /ramdisk as a tmpfs (ramdisk)
if [[ $(grep '/ramdisk' /etc/fstab) == "" ]] ; then
  echo 'tmpfs    /ramdisk    tmpfs    defaults,noatime,nosuid,size=100k    0 0' >> /etc/fstab
fi

# Disable unused services
systemctl enable dosbian-splashscreen.service ipxbox.service
systemctl disable \
  systemd-timesyncd.service rsync.service remote-fs.target \
  apt-daily-upgrade.timer apt-daily.timer

. /etc/os-release
if [ "$VERSION_ID" != "12" ]; then
  systemctl disable \
    avahi-daemon.service bluetooth.service dhcpcd.service dhcpcd5.service \
    rpi-display-backlight.service keyboard-setup.service wifi-country.service \
    triggerhappy.service triggerhappy.socket hciuart.service console-setup.service \
    nfs-client.target
fi

#dbus-fi.w1.wpa_supplicant1.service 

# Only keep a minimal set of services - speeds up the booting and increases stability

# pi@raspberrypi:~ $ systemctl list-unit-files | grep enabled
# autovt@.service                        enabled  
# create_ap.service                      enabled  
# cron.service                           enabled  
# dnsmasq.service                        enabled  
# fake-hwclock.service                   enabled  
# getty@.service                         enabled  
# networking.service                     enabled  
# raspberrypi-net-mods.service           enabled  
# rsyslog.service                        enabled  
# ssh.service                            enabled  
# sshswitch.service                      enabled  
# syslog.service                         enabled  
# dosbian.service                         enabled  


# boot config
cat << EOF >> /boot/config.txt
disable_splash=1
boot_delay=0
dtoverlay=sdtweak,overclock_50=100
gpu_mem=128
EOF

# these are possible additions, if you experience problems with your screen
# cat << EOF >> /boot/config.txt
# hdmi_force_hotplug=1
# hdmi_group=1
# hdmi_mode=82
# hdmi_drive=2
# EOF

# adapt kernel command line
# I had to manually add overscan as my screen was cut off on my TV set
sed -i 's/rootwait/rootwait logo.nologo vt.global_cursor_default=0 loglevel=1 consoleblank=0 splash quiet video=HDMI-A-1:1920x1080M@60,margin_left=40,margin_right=40,margin_top=24,margin_bottom=20/' /boot/cmdline.txt

# WARNING:
# Uncommenting the following lines is not recommended and should only be done if you have problems with audio or video
#
# If you want to use the analog audio output and ALSA (instead of PulseAudio), you can use these settings instead
# sed -i 's/rootwait/rootwait snd_bcm2835.enable_headphones=1 snd_bcm2835.enable_hdmi=1 snd_bcm2835.enable_compat_alsa=0/' /boot/cmdline.txt
#
# However, I've experienced a couple of weird issues with the BCM2835 driver (screen turned off, when sound was used in a game)
# So, I had to at least disable the audio in the KMS driver
# sed -i 's/dtoverlay=vc4-kms-v3d/dtoverlay=vc4-kms-v3d,noaudio/' /boot/config.txt
#
# ... or disable KMS driver completely (then you need to replace output=opengl with output=surface in all dosbox.conf files)
# sed -i 's/dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/' /boot/config.txt

if [ "$VERSION_ID" == "12" ]; then
  rm /etc/resolv.conf
  # From Debian 12 Bookworm on, wpa_supplicant.conf and ssh in the /boot folder is not supported anymore
  # sed -i '$iraspi-config nonint do_wifi_country DE\nraspi-config nonint do_wifi_ssid_passphrase <YOUR_WIFI_SSID> <YOUR_WIFI_PW>\nraspi-config nonint do_audio 1\nraspi-config nonint do_ssh 1' /usr/lib/raspberrypi-sys-mods/firstboot
fi
