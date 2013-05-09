#!/bin/bash

# Construct an automatic install image from mini.iso
# Platforms: i386 amd64
# Syntax:
#     rebuild-image.sh original.iso new.iso preseed.cfg image.patch
#
# Patch is applied to the image with -p 1.

ORIGDIR=`pwd`
IMGDIR=`mktemp -d`
SRCIMG="$1"
DSTIMG="$2"
PRESEED="$3"
IMGPATCH="$4"
SCRIPTDIR="$( dirname "${BASH_SOURCE[0]}" )"

if [ ! -f "${SRCIMG}" ]; then
	echo "Error: ISO file ${SRCIMG} does not exist or is not a file"
	exit
fi

if [ ! -f "${PRESEED}" ]; then
	echo "Error: preseed file ${PRESEED} does not exist or is not a file"
	exit
fi

if [ ! -f "${IMGPATCH}" ]; then
	echo "Error: patch file ${IMGPATCH} does not exist or is not a file"
	exit
fi

echo "Source image: ${SRCIMG}"
echo "Preseed file: ${PRESEED}"
echo
echo "Rebuilding image in ${IMGDIR}..."
echo "== Extracting original image =="
osirrox -dev "$SRCIMG" -extract / "$IMGDIR"
if [ $? -ne 0 ]; then
	echo "Error: image extraction failed"
	exit
fi

# Grant ourselves permission to write to all files
chmod -R u+w "$IMGDIR"

# Sanity check for presence of initrd.gz
INITRD="${IMGDIR}/initrd.gz"
if [ ! -f "${INITRD}" ]; then
	echo "Error: image does not contain initrd.gz"
	exit
fi

echo "== Rebuilding initrd =="
fakeroot "${SCRIPTDIR}/rebuild-initrd.sh" "$INITRD" "$PRESEED"

# Patch the image file
echo "== Patching image =="
patch -d "$IMGDIR" -p 1 < "$IMGPATCH"

echo "== Assembling ISO image =="
mkisofs -r -V "build image" -J -l -b isolinux.bin -c boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table -o "$DSTIMG" "$IMGDIR"
if [ $? -ne 0 ]; then
	echo "Error: image extraction failed"
	exit
fi

echo "Removing image from ${IMGDIR}"
rm -rf "$IMGDIR"

