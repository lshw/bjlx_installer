#!/bin/bash
path=`pwd|tr -d "\r\n"`
if [ "$path" = "/" ] ; then
  echo run on initrdfs
  umount /1
  mount /dev/sdb1 /1
  if ! [ -x /1/install.img ] ; then
    umount /1
    mount /dev/sdc1 /1
    if ! [ -x /1/install.img ] ; then
      echo not find usb-disk
      exit
    fi
  fi
  ofile=/1/install.img
else
  ofile=../install.img
fi

size=`du -ks .|awk '{printf $1}'`

#find . |cpio -H newc -o 2>/dev/null |pv -s ${size}000|lzma >../install.img
find . \( -path ./1 -o -path ./2 -o -path ./3 -o -path ./initrd.tmp -o -path ./var/cache/fontconfig -o -path ./udisk \) -prune -o -print |cpio -H newc -o 2>/dev/null |pv -s ${size}000|lzma >$ofile
