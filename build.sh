#!/bin/bash
rm -rf initrd.tmp install.img
mkdir initrd.tmp udisk -p

if ! [ -x /sbin/hdparm ] \
    || ! [ -x /usr/bin/pv ] \
    || ! [ -x /usr/sbin/debootstrap ] \
    || ! [ -x /usr/sbin/mkfs.vfat ] \
    || ! [ -x /usr/bin/unzstd ] \
    || ! [ -x /usr/sbin/mkfs.vfat ]
then
    install_dev="y"
    apt update
    apt-get -y install hdparm pv dosfstools debootstrap
fi

cd initrd.tmp
echo "请选择内核版本："
select ker in $(ls /lib/modules/);do
    ker_ver="$ker"
    break
done

echo 展开 /boot/initrd.img-$ker_ver 到临时目录 initrd.tmp
gz=xz
pv /boot/initrd.img-$ker_ver |unxz 2>/dev/null |cpio -i  2>/dev/null
if [ $? != 0 ] ;then
gz=lzma
pv /boot/initrd.img-$ker_ver |lzma -dc 2>/dev/null |cpio -i 2>/dev/null
if [ $? != 0 ] ;then
gz=gzip
pv /boot/initrd.img-$ker_ver |gunzip 2>/dev/null |cpio -i 2>/dev/null
if [ $? != 0 ] ;then
gz="zstd -19"
pv /boot/initrd.img-$ker_ver |unzstd 2>/dev/null |cpio -i 2>/dev/null
fi
fi
fi
echo 清理文件
cd ..
while read fname
do
  if ! [ "$fname" ] ; then
    continue
  fi
  echo del $fname
  rm -rf initrd.tmp/$fname
done < file_del.list

echo 添加文件
while read fname
do
  if ! [ "$fname" ] ; then
    continue
  fi
  echo add /$fname
  dir=`dirname $fname`
  mkdir -p initrd.tmp/$dir
  cp -a /$fname initrd.tmp/$dir
done < `uname -m`/file_add.list

ls |grep -v initrd.tmp |grep -v install.img |while read fname
do
  echo ./$fname
  cp -a $fname initrd.tmp | true
done
cd initrd.tmp
echo "                      `date +%F\ %T`" > scripts/build_time
echo 打包为 install.img
./make_initrd.sh "$gz"
cd ..
mv install.img udisk
echo cp /boot/vmlinu*$fname udisk/vmlinuz
cp boot.cfg udisk
ls -l udisk
echo ok
