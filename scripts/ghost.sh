#/bin/bash
aptitude clean
ver=`cat /etc/debian_version|tr -d "\r\n "`
ver=${ver%/*}
echo $ver
echo 'proc/*' >/tmp/exclude.list
echo 'mnt/*' >>/tmp/exclude.list
echo 'tmp/*' >>/tmp/exclude.list
echo 'dev/*' >>/tmp/exclude.list
echo 'lost+found/*' >>/tmp/exclude.list
echo 'sys/*' >>/tmp/exclude.list
echo 'media/*' >>/tmp/exclude.list
echo 'run/*' >>/tmp/exclude.list
echo 'home/*' >>/tmp/exclude.list
echo 'home1/*' >>/tmp/exclude.list
echo 'var/lib/mysql/*' >>/tmp/exclude.list
echo 'var/log/mysql/*' >>/tmp/exclude.list
echo 'var/log/apache2/*' >>/tmp/exclude.list
echo 'etc/openvpn/*' >>/tmp/exclude.list
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
echo home/$dst_file >>/tmp/exclude.list
if [ "`which pv`" ] ; then
  tar c --exclude-from=/tmp/exclude.list * |pv|$gzip >/home/$dst_file
else
 tar cv --exclude-from=/tmp/exclude.list * |$gzip >/home/$dst_file
fi
