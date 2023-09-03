#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root (sudo)"
  exit 1
fi

if [ $# != 3 ] ; then
  echo "Usage: ./<cmd> YES [fat32 root] [ext4 root]"
  exit 1
fi

#####################################################################
# Vars

if [[ $2 != "" ]] ; then
  DESTBOOT=$2
else
  DESTBOOT="/boot"
fi

if [[ $3 != "" ]] ; then
  DEST=$3
else
  DEST=""
fi

KERNEL=${KERNEL:-'kernel'}

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

#####################################################################
# LOGIC!
echo "INSTALL KERNEL.."

execute "cd linux"
execute "cp ../config /images/"

execute "cp $DESTBOOT/$KERNEL.img $DESTBOOT/$KERNEL-backup.img"
if [[ "$KERNEL" == "kernel8" ]] ; then
execute "cp ../pi/Image.gz $DESTBOOT/$KERNEL.img"
else
execute "cp ../pi/zImage $DESTBOOT/$KERNEL.img"
fi
# execute "rm $DESTBOOT/overlays/*"
execute "cp ../pi/*.dtb $DESTBOOT/"
execute "cp ../pi/overlays/*.dtb* $DESTBOOT/overlays/"
execute "cp ../pi/overlays/README $DESTBOOT/overlays/"

execute "rsync -avh --delete ../modules/lib/modules/* $DEST/lib/modules/"

#####################################################################
# DONE
echo "DONE!"
