#!/bin/bash
set -e

REPODIR=/dosbian

# Test for root user
if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root"
  exit 1
fi

# Enable service for auto-login
systemctl enable getty@tty1.service

# Copy files from repo
rsync -av --exclude=.* $REPODIR/fs/ /
if [ -d $REPODIR/fs.extra ]; then
  rsync -av --exclude=.* $REPODIR/fs.extra/ /
fi
cp $REPODIR/fs/home/pi/.profile /home/pi/

# Clone Dosbox Shader Pack
git clone https://github.com/tyrells/dosbox-svn-shaders.git /home/pi/.config/dosbox/glshaders
ln -s /home/pi/.config/dosbox/glshaders /home/pi/.config/dosbox-x/glshaders
ln -s /home/pi/.config/dosbox/glshaders /home/pi/.dosbox/glshaders
ln -s /home/pi/.config/dosbox/mt32-roms /home/pi/.config/dosbox-x/mt32-roms
ln -s /home/pi/.config/dosbox/mt32-roms /home/pi/.dosbox/mt32-roms
ln -s /home/pi/.config/dosbox/soundfonts /home/pi/.config/dosbox-x/soundfonts
ln -s /home/pi/.config/dosbox/soundfonts /home/pi/.dosbox/soundfonts

# Make backup of dosbox config files
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
systemctl disable bluetooth.service avahi-daemon.service dhcpcd.service dhcpcd5.service \
  systemd-timesyncd.service rpi-display-backlight.service keyboard-setup.service wifi-country.service \
  triggerhappy.service rsync.service hciuart.service console-setup.service \
  nfs-client.target remote-fs.target apt-daily-upgrade.timer apt-daily.timer triggerhappy.socket

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
gpu_mem=64
EOF

# Use 1080p
cat << EOF >> /boot/config.txt
hdmi_group=1
hdmi_mode=16
EOF

# disable terminal on serial
# sed -i 's/console=serial0,115200//' /boot/cmdline.txt
