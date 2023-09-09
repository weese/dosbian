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

umount_all() {
  # Find partions using losetup and remove old mappings
  LDEVS=`losetup | grep $(basename $1) | cut -d " " -f 1 | cut -d / -f3`
  for LDEV in $LDEVS; do
    echo "[*] UNMAP LOOP DEVICE $LDEV"
    execute "kpartx -d /dev/$LDEV || true"
  done
  execute "losetup -D || true"
}

umount_image() {
  # Umount everything
  execute "umount $2/{dev/pts,dev,sys,proc,boot,dosbian}"
  # Find loop device using losetup
  LDEV=`losetup | grep $(basename $1) | cut -d " " -f 1 | cut -d / -f3`
  echo "UNMAP LOOP DEVICE $LDEV"
  if [ -n "${LDEV}" ]; then
    # Remove mappings
    execute "kpartx -d /dev/$LDEV || true"
    execute "losetup -D || true"
  fi
  echo "IMAGES:"
  losetup
}

mount_image() {
  # Check the mounted dir is clean
  MNTDIRCLEANCOUNT=$(ls $2 | wc -l)
  if [ $MNTDIRCLEANCOUNT != 0 ] ; then
    echo "ERROR: Mount dir [$1] is not empty [$MNTDIRCLEANCOUNT], perhaps something is mounted on it?"
    exit 1
  fi

  # Map image
  execute "kpartx -a -v -s $1"
  LDEV=`losetup | grep $(basename $1) | cut -d " " -f 1 | cut -d / -f3`
  echo "MAP LOOP DEVICE $LDEV"
  # Mount partitions
  execute "mount /dev/mapper/${LDEV}p2 $2"
  execute "mount /dev/mapper/${LDEV}p1 $2/boot"
  execute "mount --bind /dev $2/dev/"
  execute "mount --bind /sys $2/sys/"
  execute "mount --bind /proc $2/proc/"
  execute "mount --bind /dev/pts $2/dev/pts"
  execute "mkdir -p $2/dosbian"
  execute "mount --bind /dosbian $2/dosbian"
}

resize_image() {
  # Map image
  execute "kpartx -a -v -s $1"
  LDEV=`losetup | grep $(basename $1) | cut -d " " -f 1 | cut -d / -f3`
  echo "MAP LOOP DEVICE $LDEV"
  # Resize fs
  execute "growpart /dev/$LDEV 2"
  execute "kpartx -d /dev/$LDEV || true"
  execute "losetup -d /dev/$LDEV || true"
  execute "kpartx -a -v -s $1"
  execute "e2fsck -y -f /dev/mapper/${LDEV}p2"
  execute "resize2fs /dev/mapper/${LDEV}p2"
  # Unmap image
  echo "UNMAP LOOP DEVICE $LDEV"
  execute "kpartx -d /dev/$LDEV || true"
  execute "losetup -d /dev/$LDEV || true"
}