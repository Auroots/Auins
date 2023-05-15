**[[English](https://github.com/Auroots/Auins/blob/main/README_en.md) | [简体中文](https://github.com/Auroots/Auins/blob/main/README.md)]** 

<h1 align="center">
  <br>
  Auins (ArchLinux User install scripts)
  <br>
</h1>
<p align="center">
<img src="https://img.shields.io/badge/Bash-red?style=flat-square&logo=shell">
<img src="https://img.shields.io/badge/OS-ArchLinux-blue?style=flat-square&logo=arch-linux">
     <a href="https://jq.qq.com/?_wv=1027&k=yASMQyjM">
      <img src="https://img.shields.io/badge/QQ%E7%BE%A4 @auroot -346952836-success?style=flat-square&logo=appveyor">
  </a>
</p>
<h1 align="center">
  <a href="https://github.com/Auroots/Auins" alt="logo" ><img src="https://raw.githubusercontent.com/Auroots/Auins/main/local/Auins.jpg" width="1200"/></a>
  <br>
</h1>
<h4>
📦 请使用最新的archiso镜像
<a href="https://github.com/Auroots/Auins/blob/main/doc/update-zh.md">
    <img src="https://img.shields.io/badge/journal-%E6%9B%B4%E6%96%B0%E6%97%A5%E5%BF%97-brightgreen?style=flat-square&logo=appveyor">
</a>
</h4>

>   使用以下推荐方式获取`auins`，可以大大缩短你的安装时间：
>
>   更新速度：`auroot.cn  >  github  >  gitee`

- 稳定版：`http://auins.auroot.cn/auins`
- 测试版：`http://test.auroot.cn/auins`
- 脚本配置文件（<font color='blue'>可修改 </font>，仅已开放接口）：```./local/profile.conf```；
- 安装信息文件（<font color='red'>不可修改 </font>）：```./local/auins.info```；

## 💾 快速上手

```bash
# auroot.cn (推荐)
curl -fsSL http://auins.auroot.cn > auins 
#Gitee
curl -fsSL https://gitee.com/auroot/Auins/raw/main/auin.sh > auin.sh
# Github
curl -fsSL https://raw.githubusercontent.com/Auroots/Auins/main/auin.sh > auin.sh
# 执行
chmod +x auin.sh && bash auin.sh
```

## :rocket:  使用方法   [使用方法视频教程](https://www.bilibili.com/video/BV18V411x7ee/)

```bash
# LiveCD mode: 此模式只会在archiso中自动打开
[1] 配置源(Mirrorlist) 
[2] 网络配置
[3] 配置远程连接(SSH)
[4] 系统安装: 跳转至二级菜单
[4->1] 磁盘分区     	# 可跳过，自行分区
[4->2] 安装基本系统  	 # 需挂载根分区后
[4->3] 配置系统 			# 需系统安装后
[4->4] 配置用户				# 需系统安装后
[4->5] 安装桌面	    	# 需设置普通用户后
[4->11] 驱动安装    	# 需系统安装后
[4->22] 虚拟化工具安装 # 需系统安装后
[4->0]  Chroot       # 需系统安装后

# Normal Mode: 此模式只会在系统安装完成或新系统中自动打开
[1] 配置源(Mirrorlist)  
[2] 配置网络    
[3] 配置远程连接(SSH)
[4] 安装用户
[5] 安装桌面
[5] 安装字体
[11] 安装驱动    
[22] 安装虚拟机工具(Vmware / VirturlBox) 
[D] 清除Auins和缓存  
[Q] 退出 Auins 
```

## 💻 选项

```bash
:: Auins is a script for ArchLinux installation and deployment.
usage: auins [-h] [-V] command ...

    安装命令: ("-R = 卸载"):
        font    安装字体, 选项: 全部[all], 常用[common], [adobe], [code]
        fcitx   自动安装并配置 'fcitx' 输入法, 卸载选项: [-R]
        ibus    自动安装并配置 'ibus-rime' 输入法, 卸载选项: [-R]
        axel    自动安装并配置 'Axel' (Pacman 多线程下载), 卸载选项: [-R]
        inGpu   自动安装并配置显卡驱动 ( "Nvidia" \ "Amdgpu" )
        inVmt   自动安装虚拟化工具 ( "Vmware" \ "Virtualbox" )
        black   在ArchLinux上安装BlackArch (https://blackarch.org/strap.sh)

    设置选项:
        -m, --mirror        更新并配置mirrorlist
        -w, --wifi          连接wifi
        -s, --openssh       配置远程连接ssh (默认密码: 123456)
             
    全局选项:
            --update        实时更新auins和模块, 选项: 开启[enable], 关闭[disable].
            --iso-check     auins版本检查开关, 选项: 开启[enable], 关闭[disable].
        -e, --edit-conf     编辑 ("local/profile.conf").
        -f, --show-conf     查看 ("local/profile.conf").
        -i, --show-info     查看 ("local/auins.info").
        -c, --clean-cache   清理auins和缓存
        -h, --help          查看帮助信息
        -v, --version       查看auins版本
```

**由于ArchLinux经常更新，安装方式也随之改变，导致脚本无法与之匹配，发生在某阶段出现错误，如果您发现问题，或以加以改进，可以创建Pull Request 提交脚本.**

## :sparkles: 特性

>   [安装图文教程](https://blog.csdn.net/weixin_42871436/article/details/105126833)
>
>   [Desktop效果图](https://gitee.com/auroot/Auins/blob/main/doc/Picture.md)

- ⏳  Script首页显示当前是否处于 `Chroot 模式` 开[ON]/关[OFF]；
- 🔗  Script首页显示IP地址(Wifi/有线)，以及连接SSH服务命令；
- 🔗  一键配置 SSH服务、镜像源；
- 🔗  网络配置：WIFI、以太网；
- 📦  可根据硬件信息，安装与之对应的虚拟化工具包 `[virtualbox/vmware]`；
- 🙎  自动配置普通用户及权限；
- 💻  可选三种内核: `linux` 、 `linux-lts` 、`linux-zen`；
- 📦  可选九种文件系统：`ext2/3/4`  `btrfs`  `jfs`  `vfat`  `ntfs-3g`  `f2fs`  `reiserfs`
- 📦  可选八种桌面环境：`Plasma(Min)` `Gnome` `Deepin` `Xfce` `mate` `lxde` `Cinnamon` `i3wm` `Openbox(slim)` 
- 📦  可选桌面管理器：`sddm` `gdm` `lightdm` `lxdm`，或默认(default)，可任意搭配；
- 💻  自动配置 I/O、音频、蓝牙等驱动；
- 💻  可选安装 `Intel` `AMD` `Nvidia`，安装完成自动配置；
- 💿  根据硬件自动安装 `UEFI`  或  `Boot Legacy` ；
- 💿  自定义多分区挂载，一部到位；

 