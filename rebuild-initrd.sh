#!/bin/sh

# A script which adds the preseed.cfg file into initrd.gz
# The syntax is:
#    fakeroot rebuild-initrd.sh path-to-initrd.gz path-to-preseed.cfg
# Note that fakeroot is necessary.

WORKDIR=`pwd`
TMPDIR=`mktemp -d`
INITRDGZ=`readlink -f "$1"`

cd "$TMPDIR"
mkdir new
cd new
zcat "$INITRDGZ" | cpio -i
cp "$WORKDIR/$2" preseed.cfg
find . -print | cpio -o -H newc > ../initrd
cd ..
gzip initrd
cp initrd.gz "$INITRDGZ"
cd "$WORKDIR"
rm -rf "$TMPDIR"

