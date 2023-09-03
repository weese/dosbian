#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root (sudo)"
  exit 1
fi

if [ $# != 2 ] ; then
  echo "Usage: ./<cmd> YES <image.img>"
  exit 1
fi

#####################################################################
# Vars

if [[ $2 != "" ]] ; then
  IMG=$2
fi

MOUNTFAT32="/mnt/fat32"
MOUNTEXT4="/mnt/ext4"

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
echo "BUILDING.."

# Sanity check IMG
if ! exists $IMG ; then
  echo "ERROR: IMG [$IMG] doesn't exist"
  exit 1
fi

OUTFILE=$(basename $IMG .img)"_kernel.img"

# Sanity check OUTFILE
if exists $OUTFILE ; then
  echo "ERROR: OUTFILE [$OUTFILE] exists! Can't create new image"
  exit 1
fi

# Check the mounted dir is clean
MNTDIRCLEANCOUNT=$(ls $MOUNTFAT32 | wc -l)
if [ $MNTDIRCLEANCOUNT != 0 ] ; then
  echo "ERROR: Mount dir [$MOUNTFAT32] is not empty [$MNTDIRCLEANCOUNT], perhaps something is mounted on it?"
  exit 1
fi

# Check the mounted dir is clean
MNTDIRCLEANCOUNT=$(ls $MOUNTEXT4 | wc -l)
if [ $MNTDIRCLEANCOUNT != 0 ] ; then
  echo "ERROR: Mount dir [$MOUNTEXT4] is not empty [$MNTDIRCLEANCOUNT], perhaps something is mounted on it?"
  exit 1
fi

# Copy img to new + name
execute "cp $IMG $OUTFILE"

# Increase image to hold our extras
# execute "truncate --size=+256M $OUTFILE"

# Find partions using kpartx
execute "kpartx -d /dev/loop0 || true"
execute "losetup -d /dev/loop0 || true"
execute "kpartx -a -v -s $OUTFILE"

# # Resize fs
# execute "growpart /dev/loop0 2"
# execute "kpartx -d /dev/loop0 || true"
# execute "losetup -d /dev/loop0 || true"
# execute "kpartx -a -v -s $OUTFILE"
# execute "e2fsck -y -f /dev/mapper/loop0p2"
# execute "resize2fs /dev/mapper/loop0p2"

# Mount partitions
execute "sudo mount /dev/mapper/loop0p1 $MOUNTFAT32"
execute "sudo mount /dev/mapper/loop0p2 $MOUNTEXT4"

# Install built kernel (assumes compile-kernel.sh ran before)
execute "./install-kernel.sh YES $BRANCH $MOUNTFAT32 $MOUNTEXT4"

# Unmount partitions
execute "umount $MOUNTFAT32"
execute "umount $MOUNTEXT4"

# Remove mapped partitions
execute "kpartx -d -v $OUTFILE"

# DONE
echo "SUCCESS: Image [$OUTFILE] has been built!"
