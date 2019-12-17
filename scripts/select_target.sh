#!/bin/bash
select_txt="please select target disk:["
for dst in a b c d e f g h i j k l m n o p q r s t u v w x y z
do
 if ! [ -e /dev/sd$dst ] ; then
  continue
 fi
 if [ -e src_dev ] ;then ##有这个源path文件
  if [ "`grep sd$dst src_dev`" ] ;then ##跳过
   continue
  fi
 fi
 echo " $dst=/dev/sd$dst `hdparm -i /dev/sd$dst |grep Model|awk -F, '{print $1" "$3}'`"
 select_txt="$select_txt$dst"
done
echo "${select_txt}]"
read select_disk
if [ -e /dev/sd$select_disk ] ; then
 echo target disk=/dev/sd$select_disk
 echo "sd$select_disk" >dst_disk
else
 echo not find /dev/sd$select_disk
fi
