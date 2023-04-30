**[[English](https://github.com/Auroots/Auins/blob/main/README_en.md) | [简体中文](https://github.com/Auroots/Auins/blob/main/README.md)]** 
<h1 align="center">
  <br>
  Auins (ArchLinux User install scripts)
  <br>
</h1>
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
<a href="https://github.com/Auroots/Auins/blob/main/doc/update.md">
    <img src="https://img.shields.io/badge/journal-%E6%9B%B4%E6%96%B0%E6%97%A5%E5%BF%97-brightgreen?style=flat-square&logo=appveyor">
</a>
</h3>

📦 It is recommended to use `curl` download script `auin.sh`

- stable：`http://auroot.cn/auin.sh`
- beta：`http://auroot.cn/auin_test.sh`
- script configuration file（<font color='blue'>Modifiable </font>）：```./local/script.conf```；
- installation info file（<font color='red'>Not editable </font>）：```./local/auins.info```；

### 💾 Quick start

```bash
# auroot.cn 
curl -fsSL http://auins.auroot.cn > auin.sh  
#Gitee
curl -fsSL https://gitee.com/auroot/Auins/raw/master/auin.sh > auin.sh
# Github
curl -fsSL https://raw.githubusercontent.com/Auroots/Auins/main/auin.sh > auin.sh
# exec
chmod +x auin.sh && bash auin.sh
```

### :rocket:  How to use ？

```
1. (1) Update source  
2. (2) Configure the network 
3. (3) Openssh and  Configure
4. (4) Secondary menu
5. (4-> 1) partition mount:   skippable
6. (4-> 2) Install system:    (4-> 1)after;
7. (4-> 3) configure system   (4-> 2)after;
8. (4-> 4) install desktop    (4-> 3)after;
9. (4->11) install driver 	  (4-> 2)after;
10.(4->22) install Virtualization tools  (Vmware/Virtual);
11.(4-> 0) Chroot             (4-> 2)after;
```

### 💻 Other options

```bash
:: Auins is a script for ArchLinux installation and deployment.
usage: auins [-h] [-V] command ...
    Optional arguments:
        -m | --mirror  Automatically configure mirrorlist file and exit.
        -w | --cwifi   Connect to a WIFI and exit.
        -s | --openssh Open SSH service (default password: 123456) and exit.
        -ec|--conf     Edit (./local/profile.conf), Command(vim).
             -vc       View (profile.conf).
            --info     View (auins.info).
             -ds       Delete scripts and other caches.       
        -h --help      Show this help message and exit. 
        -v --version   Show the conda version number and exit. 
        
    Optional Installation:
            -vm        Install Vmware/Virtualbox Tools and exit.
            -fo        Install Fonts.
            -fc        Install Fcitx.
            -vcd       Install Video card driver (Nvidia\Amdgpu).
```



## :sparkles: Features  [Desktop renderings](https://gitee.com/auroot/Auins/blob/master/doc/Picture.md)

- ⏳ The script homepage can check whether it is currently in `Chroot` model `[ON] / [OFF]`.
- 🔗 Script homepage shows `IP address`，Tip: Connect SSH service command.
- 🔗 One-click configuration `SSH service`, `mirror` source.
- 🔗（<font color='blue'>To be optimised </font>）Network configuration: `WIFI`、`Ethernet`.
- 📦  `auin.sh -vm`  according to your hardware installation `virtualbox` or `vmware-tools`.
- 🙎 Automatically configure common users and permissions.
- 🖴  File system：`ext2/3/4`、`btrfs`、`jfs`、`vfat`、`ntfs-3g`、`f2fs`、`reiserfs`.
- 🗔  Desktop environment：`Plasma(Min)` `Gnome` `Deepin` `Xfce` `mate` `lxde` `Cinnamon` `i3wm` `Openbox(slim)` .
- 🗔  Desktop Manager：`sddm` `gdm` `lightdm` `lxdm`, can be chosen arbitrarily.
- 💻（<font color='blue'>To be optimised </font>）Automatic configuration of I/O, audio, bluetooth；
- 💻（<font color='blue'>To be optimised </font>）Optional install `Intel` `AMD` `Nvidia`.
- 💿 Automatically install according to hardware  `UEFI` or `Boot Legacy` .
- 💿 Custom multi-partition mount.

 