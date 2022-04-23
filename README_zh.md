<h1 align="center">
  <br>
  Auins (ArchLinux User install scripts)
  <br>
</h1>
<p align="center">
  <a href="https://jq.qq.com/?_wv=1027&k=yASMQyjM">
      <img src="https://img.shields.io/badge/Language-chinese-brightgreen?style=flat-square&logo=appveyor">
  </a><a href="https://github.com/Auroots/Auins/blob/main/README.md">
      <img src="https://img.shields.io/badge/Language-english-brightgreen?style=flat-square&logo=appveyor">
  </a>
</p>
<p align="center">
    <img src="https://img.shields.io/badge/Type-bash-important?style=flat-square&logo=appveyor">
<img src="https://img.shields.io/badge/environment-Linux%20%7C%20VPS-blue?style=flat-square&logo=appveyor">
     <a href="https://jq.qq.com/?_wv=1027&k=yASMQyjM">
      <img src="https://img.shields.io/badge/QQ%E7%BE%A4 @auroot -204097403-success?style=flat-square&logo=appveyor">
  </a>
</p>
<h1 align="center">
  <a href="https://github.com/Auroots/Auins" alt="logo" ><img src="https://gitee.com/auroot/Auins/raw/master/local/Auins.png" width="1000"/></a>
  <br>
</h1>
<h3>
当前版本：v4.3 请使用最新的archiso镜像
<a href="https://github.com/Auroots/Auins/blob/main/doc/update.md">
    <img src="https://img.shields.io/badge/journal-%E6%9B%B4%E6%96%B0%E6%97%A5%E5%BF%97-brightgreen?style=for-the-badge&logo=appveyor">
</a>
</h3>

使用`curl` 下载`auin.sh` 其他脚本我会内置到主体Script中，可以大大缩短你的安装时间：

更新速度：github -> gitee -> auroot.cn 

- 稳定版：`http://auroot.cn/auin.sh`
- 测试版：`http://auroot.cn/auin_test.sh`
- 脚本配置文件（<font color='blue'>可修改 </font>，仅已开放接口）：```./local/install.conf```；
- 安装信息文件（<font color='red'>不可修改 </font>）：```./local/auins.info```；



#### 💾 wget与curl工具的使用方法

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
    1. 更新源  (1)
    2. 网络配置(2)
    3. SSH配置 (3)
    4. 二级菜单(4)
    5. 分区挂载(4->1)  可跳过，自行分区，执行(4->2)
    6. 系统安装(4->2)  需挂载根分区后，即可执行;
    7. 系统配置(4->3)  需系统安装后，即可执行;
    8. 桌面安装(4->4)  需设置普通用户后，即可执行;
    9. 驱动安装(4->11) 需系统安装后，即可执行;
    10.虚拟化工具安装(4->22) 需系统安装后，即可执行;
    11.Chroot(4->0)    需系统安装后，即可执行;
```



#### 💻 单项功能

```bash
Auins is a script for ArchLinux installation and deployment.
usage: auin [-h] [-V] command ...
    Optional arguments:
       -m | --mirror    配置源;
       -w | --cwifi     配置wifi;
       -s | --openssh   配置并开启ssh服务;
      -vm | --virtual   安装并配置vm-tools;
       -i | --info      查看脚本记录的计算机信息;
       -h | --help      帮助;
       -v | --version   版本;
```

**由于ArchLinux经常更新，安装方式也随之改变，导致脚本无法与之匹配，发生在某阶段出现错误，如果您发现问题，或以加以改进，可以创建Pull Request 提交脚本.**



###  📃 下一个版本 v4.3.5 更新什么？

- [x] ⚙️ 优化代码；
- [ ] ⚙️ ~~继续优化模块化，有些东西可能还会转C；~~
- [x] ⚙️ 拓展 `install.conf` 接口；
- [ ] 🗔 可能新增`Dwm`；
- [ ] 🗔 对某一个桌面环境做 `Wayland` 的支持；
- [ ] 🔗 自动检查网络，网速，磁盘，环境，服务等信息；
- [ ] ☁️ 新增可以在`VPS`上安装`Archlinux`的功能；



### :sparkles: 特性 [安装图文教程](https://blog.csdn.net/weixin_42871436/article/details/105126833)，[Desktop效果图](https://gitee.com/auroot/Auins/blob/master/doc/Picture.md)

- ⏳ 许多重要提示，以及错误提示，熟悉脚本后10分钟内即可安装完毕，小白最好慢慢来，看清楚每个输入提示！
- ⏳ 首页可看当前是否处于 Chroot 模式 开[ON]/关[OFF]；
- [x] 🔗 Script启动主页显示IP地址(Wifi/有线)，提示：连接SSH服务命令；
- [x] 🔗 一键配置 SSH服务 镜像源；
- [x] 🔗（<font color='blue'>待优化 </font>）网络配置：Wifi(绕iwctl，使用NetworkManager连接wifi网络)、有线；
- [x] 📦 auin.sh -vm 可根据硬件信息，安装与之对应的虚拟化工具包 `[virtualbox/vmware]`；
- [x] 🙎 自动配置普通用户及权限；
- [x] 🖴 文件系统格式：`ext2/3/4`、`btrfs`、`jfs`、`vfat`、`ntfs-3g`、`f2fs`、`reiserfs`
- [x] 🗔 桌面环境：`Plasma(Min)` `Gnome` `Deepin` `Xfce` `mate` `lxde` `Cinnamon` `i3wm` `Openbox(slim)` `Dwn(待续)`；
- [x] 🗔 可选桌面管理器：`sddm` `gdm` `lightdm` `lxdm`；或默认(default)，可任意搭配,搭配时可以去网上搜一下,找最适合的搭配方案；
- [x] 💻（<font color='blue'>待优化 </font>）自动配置 I/O，音频，蓝牙；
- [x] 💻（<font color='blue'>待优化 </font>）可选安装 `Intel` `AMD` `Nvidia`，安装完成自动配置；
- [x] 💿 可 ```UEFI```与```Boot Legacy```模式，“自动判断”；
- [x] 💿 自定义多分区挂载，一部到位；

 