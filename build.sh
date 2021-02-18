#!/bin/bash
rm -rf initrd.tmp install.img
mkdir initrd.tmp udisk -p
if ! [ -x /sbin/hdparm ] ; then
	apt-get -y install hdparm
fi
if ! [ -x /usr/bin/pv ] ; then
	apt-get -y install pv
fi
if ! [ -x /usr/sbin/debootstrap ] ; then
	apt-get -y install debootstrap
fi
cd initrd.tmp

echo "请选择内核版本："
select ker in $(ls /lib/modules/);do
    ker_ver="$ker"
    break
done

echo 展开 /boot/initrd.img-$ker_ver 到临时目录 initrd.tmp
pv /boot/initrd.img-$ker_ver |unxz|cpio -i
if [ $? != 0 ] ;then
pv /boot/initrd.img-$ker_ver |lzma -dc|cpio -i
if [ $? != 0 ] ;then
pv /boot/initrd.img-$ker_ver |gunzip|cpio -i
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
done < file_add.list

ls |grep -v initrd.tmp |grep -v install.img |while read fname
do
  echo ./$fname
  cp -a $fname initrd.tmp | true
done
cd initrd.tmp
echo "                      `date +%F\ %T`" > scripts/build_time
echo 打包为 install.img
./make_initrd.sh
cd ..
mv install.img udisk
cp boot.cfg udisk
ls -l udisk
echo ok
