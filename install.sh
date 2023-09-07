#!/bin/bash

# 
# This file originates from Dosbian project.
# Author: davomat (David Weese)
# 
# THIS HEADER MUST REMAIN WITH THIS FILE AT ALL TIMES
#
# This firmware is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This firmware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this repo. If not, see <http://www.gnu.org/licenses/>.
#

if [ "$EUID" -ne 0 ]
  then echo "Please run as root (sudo)"
  exit 1
fi

if [ $# -lt 1 ] || [ $# -gt 5 ]; then
  echo "Usage: ./<cmd> YES [branch] [fat32 root] [ext4 root]"
  exit 1
fi

#####################################################################
# Vars

if [[ $3 != "" ]] ; then
  DESTBOOT=$3
else
  DESTBOOT="/boot"
fi

if [[ $4 != "" ]] ; then
  DEST=$4
else
  DEST=""
fi

GITHUBPROJECT="Dosbian"
GITHUBURL="https://github.com/weese/$GITHUBPROJECT"
REPODIR="/build"
# USER="pi"
USER=1000
POSTINSTALL="/usr/local/sbin/post-install.sh"

if [[ $2 != "" ]] ; then
  BRANCH=$2
else
  BRANCH="master"
fi

#####################################################################
# Functions
execute() { #STRING
  if [ $# != 1 ] ; then
    echo "ERROR: No args passed"
    exit 1
  fi
  cmd=$1
  
  echo "[*] EXECUTE: [$cmd]"
  eval "$cmd"
  ret=$?
  
  if [ $ret != 0 ] ; then
    echo "ERROR: Command exited with [$ret]"
    exit 1
  fi
  
  return 0
}

post-execute() { #STRING
  if [ $# != 1 ] ; then
    echo "ERROR: No args passed"
    exit 1
  fi

  if [[ $DEST != "" ]] ; then
    if ! exists $DEST/$POSTINSTALL ; then
      echo "#!/bin/bash" > $DEST/$POSTINSTALL
      echo "set -e" >> $DEST/$POSTINSTALL
      chmod a+x $DEST/$POSTINSTALL
    fi
    echo "$1" >> $DEST/$POSTINSTALL
  else
    execute "$1"
  fi
}

install() { #STRING
  if [ $# != 1 ] ; then
    echo "ERROR: No args passed"
    exit 1
  fi

  if [[ $DEST != "" ]] ; then
    # We cannot simply extract as in the following command, because avrdude or something connected
    # causes kernel panics with the latest RetroPie 4.8
    # execute "dpkg -x $BINDIR/$1 $DEST/"
    #
    # Instead we install in a chroot which only works on ARM based hosts, e.g. Macbook M1 or RaspberryPi
    execute "sudo chroot $DEST dpkg -i /home/pi/$GITHUBPROJECT/$1"
  else
    execute "sudo dpkg -i $BINDIR/$1"
  fi
}

post-install() { #STRING
  if [ $# != 1 ] ; then
    echo "ERROR: No args passed"
    exit 1
  fi

  if [[ $DEST != "" ]] ; then
    if ! exists $DEST/$POSTINSTALL ; then
      echo "#!/bin/bash" > $DEST/$POSTINSTALL
      echo "set -e" >> $DEST/$POSTINSTALL
      chmod a+x $DEST/$POSTINSTALL
    fi
    echo "dpkg -i /home/pi/$GITHUBPROJECT/$1" >> $DEST/$POSTINSTALL
  else
    execute "sudo dpkg -i $BINDIR/$1"
  fi
}

exists() { #FILE
  if [ $# != 1 ] ; then
    echo "ERROR: No args passed"
    exit 1
  fi
  
  file=$1
  
  if [ -f $file ]; then
    echo "[i] FILE: [$file] exists."
    return 0
  else
    echo "[i] FILE: [$file] does not exist."
    return 1
  fi
}

#####################################################################
# LOGIC!
echo "INSTALLING.."

execute "chroot $DEST systemctl enable getty@tty1.service"

#####################################################################
# Copy all files
execute "rsync -av --exclude=.* $REPODIR/fs/ $DEST/"
execute "cp $REPODIR/fs/home/pi/.profile $DEST/home/pi/"
execute "chown -R 1000:1000 $DEST/home/pi"
execute "chmod -R a+x $DEST/usr/local/bin"

# Enable /ramdisk as a tmpfs (ramdisk)
if [[ $(grep '/ramdisk' $DEST/etc/fstab) == "" ]] ; then
  execute "echo 'tmpfs    /ramdisk    tmpfs    defaults,noatime,nosuid,size=100k    0 0' >> $DEST/etc/fstab"
fi

execute "chroot $DEST systemctl enable dosbian-splashscreen.service"
execute "chroot $DEST systemctl enable ipxbox.service"

# # Install Dosbox-X
# execute "cd $REPODIR/dosbox-x; make install"

# Install Dosbox versions
execute "cp /usr/local/bin/* $DEST/usr/local/bin/"
execute "cp -P /usr/local/lib/*.so* $DEST/usr/local/lib/"
execute "cp -rP /usr/local/share/dosbox* $DEST/usr/local/share"
execute "mkdir $DEST/build"
execute "cp -rP /build/dos* /build/SDL* /build/munt /build/openglide /build/fluidsynth $DEST/build"
df -h
execute "chroot $DEST ldconfig"

# Install ipxbox
execute "cp $REPODIR/go/bin/ipxbox $DEST/usr/local/bin/"

# Install Dosbox-X dependencies
execute "chroot $DEST apt-get update"
execute "chroot $DEST apt-get install -y \
  libsdl1.2debian libsdl-net1.2 libpcap0.8 \
  libslirp0 libavdevice58 libavformat58 libavcodec-dev \
  libavcodec-extra libavcodec-extra58 libswscale5 libfreetype6 \
  libopusfile0 libspeexdsp1 \
  libpng16-16 zlib1g libsdl-sound1.2 \
  libncurses5 fbi dialog mc sox \
  libsndfile1 libflac8"
execute "chroot $DEST apt-get clean"

execute "chroot $DEST systemctl disable bluetooth.service avahi-daemon.service dhcpcd.service dhcpcd5.service \
  systemd-timesyncd.service rpi-display-backlight.service keyboard-setup.service wifi-country.service \
  triggerhappy.service rsync.service hciuart.service console-setup.service \
  nfs-client.target remote-fs.target apt-daily-upgrade.timer apt-daily.timer triggerhappy.socket"

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
cat << EOF >> $DESTBOOT/config.txt
disable_splash=1
boot_delay=0
dtoverlay=sdtweak,overclock_50=100
gpu_mem=64
EOF

# Use 1080p
cat << EOF >> $DESTBOOT/config.txt
hdmi_group=1
hdmi_mode=16
EOF

# disable terminal on serial
# execute "sed -i 's/console=serial0,115200//' $DESTBOOT/cmdline.txt"

#####################################################################
# DONE
echo "DONE!"
