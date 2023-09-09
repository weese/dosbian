#!/bin/bash
set -e

source $(dirname $0)/common.sh

OUTFILE=$1; shift

# Sanity check IMG
if ! exists $OUTFILE ; then
  echo "ERROR: IMG [$OUTFILE] doesn't exist"
  exit 1
fi

#####################################################################
# Resize image
echo "RESIZE IMAGE [$OUTFILE] ..."

umount_all $OUTFILE
execute "cp $IMG $OUTFILE"
execute "truncate --size=+2048M $OUTFILE"
resize_image $OUTFILE

#####################################################################
# DONE
echo "SUCCESS: Image [$OUTFILE] has been resized!"
