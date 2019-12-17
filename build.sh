#!/bin/bash
rm -rf initrd.tmp install.img
mkdir initrd.tmp udisk -p
if ! [ -x /usr/bin/git ] ; then
	apt-get install git
fi
build_time=`date +%F\ %T`
git_url=`git config --get remote.origin.url`
git_commit_id=`git rev-parse --short HEAD`
git_commit_time=`git rev-list --format=format:'%ai' --max-count=1 $git_commit_id |tail -n1`
echo "Loongson Linux Installer   build:$build_time
$git_url Ver:$git_commit_id $git_commit_time
" >version.txt

if ! [ -x /sbin/hdparm ] ; then
	apt-get install hdparm
fi
if ! [ -x /usr/bin/pv ] ; then
	apt-get install pv
fi
if ! [ -x /usr/sbin/debootstrap ] ; then
	apt-get install debootstrap
fi
cd initrd.tmp
echo 展开 /boot/initrd.img-`uname -r` 到临时目录 initrd.tmp
pv /boot/initrd.img-`uname -r` |unxz|cpio -i
if [ $? != 0 ] ;then
pv /boot/initrd.img-`uname -r` |lzma -dc|cpio -i
if [ $? != 0 ] ;then
pv /boot/initrd.img-`uname -r` |gunzip|cpio -i
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

ls |grep -v initrd.tmp |grep -v install.img |grep -v udisk |while read fname
do
  echo ./$fname
  cp -a $fname initrd.tmp
done
cd initrd.tmp
echo 打包为 install.img
./make_initrd.sh
cd ..
mv install.img udisk
cp boot.cfg udisk
ls -l udisk
echo ok
