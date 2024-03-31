#!/bin/bash
path=`pwd|tr -d "\r\n"`
gz="zstd -19"

if [ "a$1" != "a" ] ; then
  if [ $( which $1 ) ] ; then
    gz="$1"
  fi
fi

ofile=../install.img

find . \( -path ./1 -o -path ./2 -o -path ./3 -o -path ./initrd.tmp -o -path ./var/cache/fontconfig -o -path ./udisk \) -prune -o -print |cpio -H newc -o >/tmp/initrd.img 2>/dev/null
pv /tmp/initrd.img |$gz >$ofile
rm -f /tmp/initrd.img
