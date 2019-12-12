#/bin/bash

dst_file="loongson64_`date +%Y%m%d`.tar.gz"
echo make home/$dst_file
echo proc/* >/tmp/exclude.list
echo mnt/* >>/tmp/exclude.list
echo tmp/* >>/tmp/exclude.list
echo dev/* >>/tmp/exclude.list
echo lost+found/* >>/tmp/exclude.list
echo sys/* >>/tmp/exclude.list
echo media/* >>/tmp/exclude.list
echo run/* >>/tmp/exclude.list
echo home/$dst_file >>/tmp/exclude.list
cd /
if [ "`which pv`" ] ; then
  tar cp --exclude-from=/tmp/exclude.list * |pv|gzip >/home/$dst_file
else
 tar cpv --exclude-from=/tmp/exclude.list * |gzip >/home/$dst_file
fi
