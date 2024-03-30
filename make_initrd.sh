#!/bin/bash
path=`pwd|tr -d "\r\n"`
gz="xz -9"

if [ "a$1" != "a" ] ; then
  if [ $( which $1 ) ] ; then
    gz="$1"
  fi
fi
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

find . \( -path ./1 -o -path ./2 -o -path ./3 -o -path ./initrd.tmp -o -path ./var/cache/fontconfig -o -path ./udisk \) -prune -o -print |cpio -H newc -o >/tmp/initrd.img 2>/dev/null
pv /tmp/initrd.img |$gz >$ofile
rm -f /tmp/initrd.img
