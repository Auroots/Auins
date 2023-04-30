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
      <img src="https://img.shields.io/badge/QQ%E7%BE%A4 @auroot -204097403-success?style=flat-square&logo=appveyor">
  </a>
</p>
<h1 align="center">
  <a href="https://github.com/Auroots/Auins" alt="logo" ><img src="https://gitee.com/auroot/Auins/raw/master/local/Auins.png" width="1000"/></a>
  <br>
</h1>
<h3>
当前版本：v4.5.2 请使用最新的archiso镜像
<a href="https://github.com/Auroots/Auins/blob/main/doc/update-zh.md">
    <img src="https://img.shields.io/badge/journal-%E6%9B%B4%E6%96%B0%E6%97%A5%E5%BF%97-brightgreen?style=flat-square&logo=appveyor">
</a>
</h3>




使用`curl` 下载`auin.sh` 其他脚本我会内置到主体Script中，可以大大缩短你的安装时间：

更新速度：github -> gitee -> auroot.cn 

- 稳定版：`http://auroot.cn/auin.sh`
- 测试版：`http://auroot.cn/auin_test.sh`
- 脚本配置文件（<font color='blue'>可修改 </font>，仅已开放接口）：```./local/script.conf```；
- 安装信息文件（<font color='red'>不可修改 </font>）：```./local/auins.info```；

#### 💾 快速上手

```bash
# auroot.cn (推荐)
curl -fsSL http://auins.auroot.cn > auin.sh  
#Gitee
curl -fsSL https://gitee.com/auroot/Auins/raw/master/auin.sh > auin.sh
# Github
curl -fsSL https://raw.githubusercontent.com/Auroots/Auins/main/auin.sh > auin.sh
# 执行
chmod +x auin.sh && bash auin.sh
```

#### :rocket:  使用方法   [使用方法视频教程](https://www.bilibili.com/video/BV18V411x7ee/)

```
(1)  更新源
(2)  网络配置
(3)  SSH配置
(4)  二级菜单
(4->1)  分区挂载      可跳过，自行分区，执行(4->2)
(4->2)  系统安装      需挂载根分区后，即可执行;
(4->3)  系统配置	  需系统安装后，即可执行;
(4->4)  桌面安装      需设置普通用户后，即可执行;
(4->11) 驱动安装      需系统安装后，即可执行;
(4->22) 虚拟化工具安装 需系统安装后，即可执行;
(4->0)  Chroot      需系统安装后，即可执行;
```

#### 💻 其他功能

```bash
Auins is a script for ArchLinux installation and deployment.
usage: auins [-h] [-V] command ...
    Optional arguments:
       -m | --mirror    配置源;
       -w | --cwifi     配置wifi;
       -s | --openssh   配置并开启ssh服务; 
      -ec --conf    	编辑配置文件 (./local/profile.conf);
           -vc      	查看脚本配置文件 (profile.conf);
          --info    	查看脚本生成的信息(auins.info);
           -ds      	删除脚本和其他缓存;
       -h | --help      帮助;
       -v | --version   版本;
       
    Optional Installation:
            -vm        安装并配置vm-tools;
            -fo        安装 Fonts;
            -fc        安装 Fcitx;
            -vcd       安装显卡驱动 (Nvidia\Amdgpu);
```

**由于ArchLinux经常更新，安装方式也随之改变，导致脚本无法与之匹配，发生在某阶段出现错误，如果您发现问题，或以加以改进，可以创建Pull Request 提交脚本.**

###  📃 下一个版本 v4.5.3 更新什么？

- [x] ☁️ 脚本更新进度比较慢，如果您在使用过程中，发现问题，并向我报备，我会优先为您处理；
- [ ] ⏳  尝试加入Wayland的桌面环境，比如：Sway，Plasma-Wayland等等；
- [ ] ⏳  会继续尝试DWM桌面环境；
- [ ] ⏳  会尝试维护Openbox桌面环境；
- [ ] ☁️  脚本：[v5.0]Beta `s2arch.sh` Archlinux can be installed on VPS;
- [x] 🗔 Script：At startup, print information first，eg：CPU，LiveCD，network，disk...
- [ ] ⚙️ 检查reflector报错的问题(不影响正常使用)



### :sparkles: 特性 [安装图文教程](https://blog.csdn.net/weixin_42871436/article/details/105126833)，[Desktop效果图](https://gitee.com/auroot/Auins/blob/master/doc/Picture.md)

- ⏳ Script首页显示当前是否处于 `Chroot 模式` 开[ON]/关[OFF]；
- 🔗 Script首页显示IP地址(Wifi/有线)，以及连接SSH服务命令；
- 🔗 一键配置 SSH服务 镜像源；
- 🔗 网络配置：WIFI、以太网；
- 📦 auin.sh -vm 可根据硬件信息，安装与之对应的虚拟化工具包 `[virtualbox/vmware]`；
- 🙎 自动配置普通用户及权限；
- 💻 可选三种内核: `linux` 、 `linux-lts` 、`linux-zen`；
- 🖴   可选九种文件系统：`ext2/3/4`、`btrfs`、`jfs`、`vfat`、`ntfs-3g`、`f2fs`、`reiserfs`；
- 🗔 可选八种桌面环境：`Plasma` `Gnome` `Deepin` `Xfce` `mate` `lxde` `Cinnamon` `i3wm` ；
- 🗔 可选桌面管理器：`sddm` `gdm` `lightdm` `lxdm`；或默认(default)，可任意搭配；
- 💻 自动配置 I/O，音频，蓝牙；
- 💻 可选安装 `Intel` `AMD` `Nvidia`，安装完成自动配置；
- 💿 根据硬件自动安装 `UEFI`  或  `Boot Legacy` ；
- 💿 自定义多分区挂载，一部到位；

 