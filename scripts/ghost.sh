#/bin/bash
aptitude clean
ver=`cat /etc/debian_version|tr -d "\r\n "`
ver=${ver%/*}
echo $ver
find /  | grep -v \
 -e "^/proc/" \
 -e "^/1/" \
 -e "^/2/" \
 -e "^/3/" \
 -e "^/4/" \
 -e "^/mnt/" \
 -e "^/tmp/" \
 -e "^/dev/" \
 -e "^lost+found/" \
 -e "^/sys/" \
 -e "^/media/" \
 -e "^/run/" \
 -e "^/root/" \
 -e "^/home/mips" \
 -e "^/home/loongson/" \
 -e "^/home1/" \
 -e "^/var/tmp/" \
 -e "^/var/lib/mysql/" \
 -e "^/var/log/mysql/" \
 -e "^/var/log/apache2/" \
 -e "^/var/log/journal/" \
  > /tmp/all.list
find /root/.ssh >> /tmp/all.list
cd /
mach=$( uname -m )
which zstd
if [ $? == 0 ] ;then
	gzip=zstd
        dst_file="${mach}_debian_${ver}_`date +%Y%m%d`.tar.zst"
else
	gzip=gzip
        dst_file="${mach}_debian_${ver}_`date +%Y%m%d`.tar.gz"
fi
echo make home/$dst_file
if [ "`which pv`" ] ; then
  tar c --no-recursion -T /tmp/all.list |pv|$gzip >/home/$dst_file
else
 tar cv --no-recursion -T /tmp/all.list |$gzip >/home/$dst_file
fi
