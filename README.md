基于debian的initrd.img文件  
改装成linux系统快速安装程序 
可以把tar打包的系统目录树，覆盖到sda  
实现快速安装系统  
程序会自动把 /var 和 /home 放到独立分区  
跟 / 分区分开，这是因为这2个目录，文件会频繁变化  
将它们独立后，可以提高 / 目录的鲁棒性，系统即使突然断电，文件系统也不会炸  
另外，本安装程序，还可以进入shell环境  
shell环境带了 fdisk,cfdisk , mkfs.ext234 , mkfs.vfat , fsck.ext234 , bootstrap.等应急工具 
在龙芯派下测试可以工作。  
执行 build.sh  会生成install.img  
然后配合vmlinuz  就可以用来快速安装linux系统了  

udisk目录下，就是做好的龙芯2K，龙芯3的安装程序，可以复制到U盘直接使用.  
linux系统的tar包， 可以在 https://mirrors.tuna.tsinghua.edu.cn/loongson/install 下载  
也可以自行打包， 只要文件命名为 loongson*20*.tar.* ， 就可以被识别使用  
比如 loongson-2k-debian10-20191105.tar.xz    
