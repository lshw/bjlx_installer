#本文件用于昆仑固件启动安装程序， 在3A4000下， 只有昆仑固件， 并且不支持initrd， 所以需要用vmlinuz和initrd.img合一的 install-loongson3, 
#bjlx_install 并不能生成install-loongson3， 需要用linux源码来生成install-loongson3
#initrd fs1:/install.img
run fs1:/install-loongson3 net.ifnames=0 osdevname=0
