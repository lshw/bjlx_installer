#/bin/bash

if [ "`which xz`" ] ; then
  gz=.xz
  gzrun=xz
else
  if [ "`which bzip2`" ] ; then
    gz=.bz2
    gzrun=bzip2
  else
    gz=.gz
    gzrun=gzip
  fi
fi

dst_file="loongson64_`date +%F`.tar$gz"
cd /
echo make /$dst_file
if [ "`which pv`" ] ; then
  tar cp --exclude=/proc --exclude=/mnt --exclude=/tmp  --exclude=/lost+found --exclude=/sys --exclude=/media --exclude=/run --exclude=$dst_file * |pv|$gzrun >$dst_file
else
 tar cpv --exclude=/proc --exclude=/mnt --exclude=/tmp  --exclude=/lost+found --exclude=/sys --exclude=/media --exclude=/run --exclude=$dst_file * |$gzrun >$dst_file
fi
