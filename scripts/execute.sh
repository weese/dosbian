#!/bin/bash
set -e

source $(dirname $0)/common.sh

OUTFILE=$1; shift
DEST="/mnt"

echo "EXECUTE $1 inside image [$OUTFILE] ..."

# Sanity check OUTFILE
if ! exists $OUTFILE ; then
  echo "ERROR: OUTFILE [$OUTFILE] doesn't exist"
  exit 1
fi

umount_all $OUTFILE
mount_image $OUTFILE $DEST

# Execute inside chroot
execute "chroot $DEST $@"

umount_image $OUTFILE $DEST

#####################################################################
# DONE
echo "SUCCESS: Execution done!"
