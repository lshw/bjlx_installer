#!/bin/bash

umount_all() {
umount -f proc dev sys
rmdir proc sys dev
}


if ! [ -x initrd.tmp ] ; then
  ./build.sh
fi
cd initrd.tmp
cp -a ../scripts/install scripts
if ! [ -e dev/sda ] ; then
mkdir -p dev proc sys tmp
mount -t proc none proc
mount -t sysfs none sys
mount -t devtmpfs none dev
fi
trap umount_all EXIT
rm scripts/reinstall
chroot . /scripts/install sde
