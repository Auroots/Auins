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
📦 Please use the latest archiso
<a href="https://github.com/Auroots/Auins/blob/main/doc/update-zh.md">
    <img src="https://img.shields.io/badge/journal-%E6%9B%B4%E6%96%B0%E6%97%A5%E5%BF%97-brightgreen?style=flat-square&logo=appveyor">
</a>
</h4>


>   Using the following recommended method to obtain `auins` can greatly shorten your installation time:

- stable：`http://auins.auroot.cn/auins`
- beta：`http://test.auroot.cn/auins`
- script configuration file（<font color='blue'>Modifiable </font>）：```./local/profile.conf```；
- installation info file（<font color='red'>Not editable </font>）：```./local/auins.info```；

## 💾 Quick start

```bash
# auroot.cn 
curl -fsSL http://auins.auroot.cn > auins
#Gitee
curl -fsSL https://gitee.com/auroot/Auins/raw/main/auin.sh > auins
# Github
curl -fsSL https://raw.githubusercontent.com/Auroots/Auins/main/auin.sh > auins
# exec
chmod +x auin.sh && bash auin.sh
```

## :rocket:  How to use ？

```
# LiveCD mode: Automatically open only in archiso
[1] Configure Mirrorlist
[2] Configure Netword
[3] Configure SSH
[4] Installation System (Secondary Menu)
[4->1] Disk Partition
[4->2] Installation Base System
[4->3] Configure System
[4->4] Configure Users
[4->5] Installation Desktop
[4->11] Installation Drive
[4->22] Install virtualization tools
[4->0]  arch-chroot /mnt

# Normal Mode: Automatically open only after system installation is completed or in a new system.
[1] Configure Mirrorlist
[2] Configure Netword
[3] Configure SSH
[4] Configure Users
[5] Installation Desktop
[5] Installation Fonts
[11] Installation Drive
[22] Install virtualization tools (Vmware / VirturlBox) 
[D] Delete auins & caches  
[Q] Exit Auins 
```

## 💻 Options

```bash
:: Auins is a script for ArchLinux installation and deployment.
usage: auins [-h] [-V] command ...

    Install Commands: ("-R = uninstall"):
        font    Install Fonts, Options: [all], [common], [adobe], [code].
        fcitx   Automatic installation 'fcitx' input method, Other options: [-R].
        ibus    Automatic installation 'ibus-rime' input method, Other options: [-R].
        axel    Automatic installation 'Axel' (Pacman multi threaded download), Other options: [-R].
        inGpu   Install Video card driver: ( "Nvidia" \ "Amdgpu" ).
        inVmt   Install Virtualization Tools: ( "Vmware" \ "Virtualbox" ).
        black   Installing BlackArch on ArchLinux. (https://blackarch.org/strap.sh)

    Settings Options:
        -m, --mirror        Automatically configure mirrorlist file.
        -w, --wifi          Connect to a WIFI.
        -s, --openssh       Open SSH service (password: 123456).
             
    Global Options:
            --update        Auins and modules are updated in real time, Options: [enable], [disable].
            --iso-check     Switch for auins version check, Options: [enable], [disable].
        -e, --edit-conf     Edit ("local/profile.conf").
        -f, --show-conf     Show ("local/profile.conf").
        -i, --show-info     Show ("local/auins.info").
        -c, --clean-cache   Delete auins and other caches.
        -h, --help          Show help message.
        -v, --version       Show the auins version.
```



## :sparkles: Features

>    [Desktop renderings](https://gitee.com/auroot/Auins/blob/main/doc/Picture.md)

- ⏳  The script homepage can check whether it is currently in `Chroot` model `[ON] / [OFF]`
- 🔗  Script homepage shows `IP address`，Tip: Connect SSH service command
- 🔗  One-click configuration `SSH service`, `mirror` source
- 🔗  Network configuration: `WIFI`、`Ethernet`
- 📦  `auin.sh -vm`  according to your hardware installation `virtualbox` or `vmware-tools`
- 🙎  Automatically configure common users and permissions
- 📦  File system：`ext2/3/4`  `btrfs`  `jfs`  `vfat`  `ntfs-3g`  `f2fs`  `reiserfs`
- 📦  Desktop environment：`Plasma(Min)` `Gnome` `Deepin` `Xfce` `mate` `lxde` `Cinnamon` `i3wm` `Openbox(slim)` 
- 📦  Desktop Manager：`sddm` `gdm` `lightdm` `lxdm`, can be chosen arbitrarily
- ## 💻  Automatic configuration of I/O, audio, bluetooth
- 💻  Optional install `Intel` `AMD` `Nvidia`
- 💿  Automatically install according to hardware  `UEFI` or `Boot Legacy` 
- 💿  Custom multi-partition mount

 