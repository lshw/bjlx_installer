#!/bin/bash
rm -rf initrd.tmp install.img
mkdir initrd.tmp udisk -p
if ! [ -x /usr/bin/git ] ; then
	apt-get install git
fi
echo -ne "git clone  ">git_commit_id.txt
git config --get remote.origin.url >>git_commit_id.txt
git rev-list --format=format:'%ai' --max-count=1 `git rev-parse HEAD` >>git_commit_id.txt
echo ==============================================>>git_commit_id.txt
if ! [ -x /sbin/hdparm ] ; then
	apt-get install hdparm
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

ls |grep -v initrd.tmp |grep -v install.img |while read fname
do
  echo ./$fname
  cp -a $fname initrd.tmp
done
cd initrd.tmp
echo "build:       `date +%F\ %T`" > scripts/build_time
echo 打包为 install.img
./make_initrd.sh
cd ..
mv install.img udisk
cp boot.cfg udisk
ls -l udisk
echo ok
