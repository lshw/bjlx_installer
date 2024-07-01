#!/bin/bash
rm -rf initrd.tmp install.img
mkdir initrd.tmp udisk -p

if ! [ -x /sbin/hdparm ] \
    || ! [ -x /usr/bin/pv ] \
    || ! [ -x /usr/sbin/debootstrap ] \
    || ! [ -x /usr/sbin/mkfs.vfat ] \
    || ! [ -x /usr/sbin/partprobe ] \
    || ! [ -x /usr/bin/unzstd ] \
    || ! [ -x /usr/sbin/mkfs.ext4 ]
then
    install_dev="y"
    apt update
    apt-get -y install hdparm pv parted e2fsprogs dosfstools debootstrap zstd
fi
arch=$( uname -m )
if [ "$arch" != "mips64" ] ; then
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
gz="zstd -19"
pv /boot/initrd.img-$ker_ver |xz -dc 2>/dev/null |cpio -i  2>/dev/null
if [ $? != 0 ] ;then
pv /boot/initrd.img-$ker_ver |lzma -dc 2>/dev/null |cpio -i 2>/dev/null
if [ $? != 0 ] ;then
pv /boot/initrd.img-$ker_ver |zstd -dc 2>/dev/null |cpio -i 2>/dev/null
if [ $? != 0 ] ;then
gz=gzip
pv /boot/initrd.img-$ker_ver |gzip -dc 2>/dev/null |cpio -i 2>/dev/null
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
cat file_add.list $arch/file_add.list |\
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

cp -a etc boot scripts make_initrd.sh initrd.tmp
cd initrd.tmp
echo "                      `date +%F\ %T`" > scripts/build_time
mkdir -p lib/modules/$ker_ver/kernel
lsmod |awk '{print $1".ko"}' >> ../$arch/modules.list
sort ../$arch/modules.list |uniq > ../$arch/modules.txt
mv ../$arch/modules.txt ../$arch/modules.list
while read mod
do
  echo $mod
find /lib/modules/$ker_ver -name ${mod}* -exec cp {} lib/modules/$ker_ver/kernel \;
done <../$arch/modules.list
find lib/modules/ -name "*.ko.zst" -exec unzstd -d -f --rm {} \;
chroot . depmod $ker_ver
echo 打包为 install.img
./make_initrd.sh "$gz"
cd ..
cp install.img /boot
mv install.img udisk
cp /boot/vmlinu*$ker_ver udisk/vmlinuz
cp -a readme.html /boot/grub udisk
cp grub.cfg udisk/grub
case "$arch" in
  loongarch64)
    efi=grubloongarch64.efi
    ;;
  x86_64)
    efi=grubx86_64.efi
    ;;
esac
if [ "$efi" ] ; then 
grub-mkimage -o udisk/$efi -p '(,gpt1)/grub' --prefix '(,gpt1)/grub' part_gpt part_msdos ntfs ext2 fat exfat serial -O $efi
cp udisk/$efi udisk/install.$arch
fi
ls -l udisk
echo ok
