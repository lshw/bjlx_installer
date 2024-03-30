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

if [ "`uname -m`" != "mips64" ] ; then

if ! [ -x /usr/bin/efibootmgr ] ; then
  apt-get -y install efibootmgr
fi

fi

cd initrd.tmp
ker_ver=$(ls /lib/modules/)
if [ "`echo $ker_ver |awk '{print $2}'`" ] ; then
echo "请选择内核版本："
select ker in $ker_ver; do
    ker_ver="$ker"
    break
done
fi

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
cat file_add.list $( uname -m )/file_add.list |\
while read fname
do
  if ! [ "$fname" ] ; then
    continue
  fi
  echo add /$fname
  dir=`dirname $fname`
  mkdir -p initrd.tmp/$dir
  cp -a /$fname initrd.tmp/$dir
done

cp -a etc scripts make_initrd.sh initrd.tmp
cd initrd.tmp
echo "                      `date +%F\ %T`" > scripts/build_time
mkdir -p lib/modules/$ker_ver/kernel
find /lib/modules/$ker_ver -name  vfat.ko* -exec cp {} lib/modules/$ker_ver/kernel \;
find /lib/modules/$ker_ver -name  nls_cp437.ko* -exec cp {} lib/modules/$ker_ver/kernel \;
find /lib/modules/$ker_ver -name  nls_utf8.ko* -exec cp {} lib/modules/$ker_ver/kernel \;
find /lib/modules/$ker_ver -name  ext4.ko* -exec cp {} lib/modules/$ker_ver/kernel \;
chroot . depmod $ker_ver
echo 打包为 install.img
./make_initrd.sh "$gz"
cd ..
mv install.img udisk
cp /boot/vmlinu*$ker_ver udisk/vmlinuz
cp boot.cfg udisk
ls -l udisk
echo ok
