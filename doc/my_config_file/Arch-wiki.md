## ArchLinux script Installer (脚本视图)

![脚本截图信息](https://gitee.com/auroot/arch_wiki/raw/master/Img/archlinux/img1.png?raw=true)
-------------------------------------------------------------------------------------------------

# Arch Linux + Desktop 攻略

## **连引导都进不去？ **

进入引导界面选择启动项，按e： 

```shell
    nouveau.modeset=0    # 屏蔽开源 对独显有效
    acpi_osi=! acpi_osi="Windows 2009"  # 欺骗BIOS以Windows 2009启动，对ACPI错误有效
    driver=intel acpi_osi=! acpi_osi='Windows 2009'    
```

## **安装方法1 手动安装：**

[ArchLinux_Wiki - 安装教程](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

### 一、验证启动模式

```shell
[auroot@Archlinux ~]# ls /sys/firmware/efi/efivars
```

### 二、检查网络

[ArchLinux_Wiki - Network](https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

``` Shell
ip link                     #查看网卡设备
ip link set [网卡] up       #开启网卡设备
systemctl start dhcpcd      #开启DHCP服务
wifi-menu                   #连接wifi
```

### 三、配置 Mirrort

``` shell
** 阿里云源
sed -i "6i Server = http://mirrors.aliyun.com/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist
** 网易云163 **
sed -i "6i Server = https://mirrors.163.com/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist
** 清华大学
sed -i "6i Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch" /etc/pacman.d/mirrorlist

更新一下
sudo pacman -Sy
```

### 四、磁盘分区

**分区命令**
[ArchLinux_Wiki - fdisk(分区工具)](https://wiki.archlinux.org/index.php/Fdisk_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
cfdisk /dev/sda  # 指定磁盘
```

**格式化命令**
[ArchLinux_Wiki - File systems](https://wiki.archlinux.org/index.php/File_systems_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
mkfs.vfat  /dev/sda[0-9]   # efi/esp  fat32  # 指定分区
mkfs.ext4 /dev/sda[0-9]    # ext4     # 指定分区
mkfs.ext3 /dev/sda[0-9]    # ext3     # 指定分区
mkswap /dev/sda[0-9]       # swap     # 指定分区

# 如果你想用其他 File System
# btrfs (/)  需要安装这个包：btrfs-progs
mkfs.btrfs -L [NAME] -f [/dev/DISK]
# f2fs 需要安装这个包：f2fs-tools
mkfs.f2fs [/dev/DISK]
# jfs 需要安装这个包：jfsutils
mkfs.jfs [/dev/DISK]
# reiserfs 需要安装这个包：reiserfsprogs
mkfs.reiserfs [/dev/DISK]
```

### 五、挂载分区

```shell
swapon /dev/sd[a-z][0-9]         # 挂着swap 卸载:swapoff
mount /dev/sd[a-z][0-9] /mnt     # 挂着根目录
mkdir -p /mnt/boot/EFI           # 创建efi引导目录
mount /dev/sda1 /mnt/boot/EFI    # 挂着efi分区
```

### 六、安装系统

```shell
pacstrap /mnt base base-devel linux linux-firmware ntfs-3g networkmanager os-prober net-tools
```

```shell
genfstab -U /mnt >> /mnt/etc/fstab     # 创建fstab分区表，记得检查
arch-chroot /mnt /bin/bash             # chroot 进入创建好的系统
```

### 七、配置系统

**设置时区**

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime     # 上海

hwclock --systohc       #运行 hwclock 以生成 /etc/adjtime
```

**本地化**

```shell
sed  -i "24i en_US.UTF-8 UTF-8" /etc/locale.gen
sed  -i "24i zh_CN.UTF-8 UTF-8" /etc/locale.gen

locale-gen             # 生成 locale
```

**系统语言**

```shell
echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 英文
echo "LANG=zh_CN.UTF-8" > /etc/locale.conf       # 中文
```

**主机名**

```shell
echo "Archlinux" > /etc/hostname  #主机名
passwd                 #给root设置密码
mkinitcpio -p linux    
```

**创建用户**

```shell
useradd -m -g users -G wheel -s /bin/bash 用户名

passwd 用户名           #给用户设置密码
```

需要开启的服务:

```
systemctl enable NetworkManager    #网络服务,不开没网
systemctl start NetworkManager

systemctl enable sshd.service      #SSH远程服务,随意
systemctl start sshd.service
```

**配置GRUB**
[ArchLinux_Wiki - GRUB](https://wiki.archlinux.org/index.php/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

执行passwd 给root设置一个密码。
安装grub工具，到这一步，一定要看清楚。

```shell
pacman -S vim grub efibootmgr
# 最后
#  UEFI分区
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Archlinux
#  Boot 分区
grub-install --target=i386-pc /dev/sdX(Boot分区地址)
# 以上二选一后,执行下面的命令!
grub-mkconfig -o /boot/grub/grub.cfg
```

### 弄完重启

```shell
exit
swapoff /dev/sd[a-z][0-9]      #卸载swap
umount -R /mnt && reboot now   #卸载 根分区、efi分区
```

## 安装方法2 **免指令脚本**

[Bilibili - 详细视频讲解](https://www.bilibili.com/video/av88989589)

```shell
wget archfi.sf.net/archfi    # 获取archfi
chmod +x archfi              # 增加脚本的可执行权限
./archfi                     # 运行脚本
```

-------------------------------------------------------------------------------

## 安装驱动

**intel 显示驱动**
[ArchLinux_Wiki - Intel显卡](https://wiki.archlinux.org/index.php/Intel_graphics_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
pacman -S xf86-video-intel mesa-libgl libva-intel-driver libvdpau-va-gl
```

**触摸板驱动**

```shell
sudo pacman -S xf86-input-libinput xf86-input-synaptics 
```

**蓝牙**
[ArchLinux_Wiki - 蓝牙](https://wiki.archlinux.org/index.php/Bluetooth_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
sudo pacman -S bluez bluez-utils blueman  bluedevil

sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service
```

**音频**

```shell
sudo pacman -S pulseaudio-bluetooth alsa-utils
sudo vim /etc/pulse/system.pa

load-module module-bluetooth-policy
load-module module-bluetooth-discover
```

- 所有Video 驱动:

```
xf86-video-amdgpu                   
xf86-video-ati                      
xf86-video-dummy                    
xf86-video-fbdev                    
xf86-video-intel                    
xf86-video-nouveau                  
xf86-video-openchrome               
xf86-video-sisusb                   
xf86-video-vesa                     
xf86-video-vmware                   
xf86-video-voodoo                   
xf86-video-qxl
```

**安装I\O驱动**

```shell
sudo pacman -S xf86-input-keyboard xf86-input-mouse xf86-input-synaptics
```

- 其他I\O驱动

```
xf86-input-elographics                     
xf86-input-evdev                           
xf86-input-libinput                        
xf86-input-synaptics    
xf86-input-vmmouse      (VMWare)           
xf86-input-void                            
xf86-input-wacom                           
```

#### 打印机驱动

[ArchLinux_Wiki - CUPS](https://wiki.archlinux.org/index.php/CUPS_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

CUPS 是苹果公司为Mac OS® X 和其他类 UNIX® 的操作系统开发的基于标准的、开源的打印系统.
首先要安装这5个包```sudo pacman -S cups ghostscript gsfonts gutenprint cups-usblp```

- ```samba```        如果系统用的 Samba 使用网络打印机，或者要作为打印服务器向其它windows客户端提供服务，你还需要安装
- ```cups```         就是传说中的CUPS软件```
- ```ghostscript```  Postscript语言的解释器```
- ```gsfonts```      Ghostscript标准Type1字体```
- ```hpoj```         HP Officejet, 你应该再安装这个包```

#### 手机文件系统支持

```
sudo pacman -S mtpaint mtpfs libmtp 
Gnome ： gvfs-mtp 
Kde ：kio-extras
```

-------------------------------------------------------------------------------

#### **Nvidia 显示驱动**

- [Optimus-switch - 解决方案](https://github.com/dglt1)

- [Optimus-manager-qt - 解决方案(自用推荐)](https://github.com/Shatur95/optimus-manager-qt)

- 可能需要开启AUR源 
- 可能需要开启软件源 [multilib]

```
sudo rm -f /etc/X11/xorg.conf
sudo rm -f /etc/X11/xorg.conf.d/90-mhwd.conf
sudo systemctl disable bumblebeed.service   #如果正在使用bumblebee,请禁用守护进程

# gdm管理器
yaourt -S gdm-prime         
sudo vim /etc/gdm/custom.conf
    #WaylandEnable=false        前面的#去掉 Gnomoe的显示管理器就是gdm(Gnome xorg模式)

# sddm管理器
sudo vim /etc/sddm.conf     
    DisplayCommand              #找到这行，注释#
    DisplayStopCommand          #找到这行，注释#

#安装NVidia及主程序
sudo pacman -S nvidia nvidia-utils opencl-nvidia lib32-nvidia-utils lib32-opencl-nvidia mesa lib32-mesa-libgl xf86-video-intel
sudo pacman -S optimus-manager optimus-manager-qt   #安装optimus-manager

sudo systemctl enable optimus-manager.service       #开启进程 
```

----------------------------------------------------------------------------------------------

**查看n卡的BusID**

```
$ lspci | egrep 'VGA|3D'
出现如下格式：
----------------------------------------------------------------------
00:02.0 VGA compatible controller: Intel Corporation UHD Graphics 630 (Desktop)
01:00.0 VGA compatible controller: NVIDIA Corporation GP107M [GeForce GTX 1050 Ti Mobile] (rev a1)
————————————————
```

**解决画面撕裂问题**

```
[auroot@Arch ~]# vim /etc/mkinitcpio.conf
----------------------------------------------------------------------
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
----------------------------------------------------------------------

[auroot@Arch ~]# vim /etc/default/grub                                              # 此处必须是grub引导，其他引导自行百度
----------------------------------------------------------------------
GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1"               #此处加nvidia-drm.modeset=1参数
----------------------------------------------------------------------

[auroot@Arch ~]# grub-mkconfig -o /boot/grub/grub.cfg                           
```

**nvidia升级时自动更新initramfs**

```
[auroot@Arch ~]# sudo mkdir /etc/pacman.d/hooks
[auroot@Arch ~]# sudo vim /etc/pacman.d/hooks/nvidia.hook
-----------------------------------------------------------------
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
```

**安装测试软件  在图形界面下**

```
[auroot@Arch ~]# sudo pacman -S virtualgl
[auroot@Arch ~]# optirun glxspheres64

#查看NVIDIA显卡是否已经启动
[auroot@Arch ~]# nvidia-smi
```

**安装字体**
[ArchLinux_Wiki - 字体](https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

- 全部安装：'MesloLGS NF', 'monospace', monospace dd

```shell
sudo pacman -S noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk 

sudo pacman -S ttf-ubuntu-font-family wqy-microhei wqy-zenhei ttf-dejavu
sudo pacman -S adobe-source-han-sans-cn-fonts
sudo pacman -S ttf-fira-code ttf-fira-mono ttf-fira-sans woff-fira-code woff2-fira-code

git clone https://gitee.com/auroot/ubuntu-mono-powerline-ttf.git ~/.fonts/ubuntu-mono-powerline-ttf
fc-cache -vf
# WPS 中文字体
sudo pacman -S wps-office-mui-zh-cn
```

-------------------------------------------------------------------------------

## 桌面安装

### Sway  [ Wayland ]

```bash
# 安装 
sudo pacman -S wlroots sway qt5-wayland glfw-wayland
# tty中执行
sway
# sway的配置
cp /etc/sway/config ~/.config/sway/
vim ~/.config/sway/config
	# 设置屏幕和桌面壁纸
	output * bg <你自己的桌面壁纸图片路径> fill
```

**兼容 X11**

```bash
xwayland enabled
# 安装 Xwayland
sudo pacman -S xorg-xwayland 
# 检测 XWayland
sudo pacman -S xorg-xlsclients
> xlsclients
```

**使用vulkan做渲染后端**

```bash
sudo pacman -S vulkan-validation-layers
# 设置启动环境(如果不设置可以用，可以不用设置，我没设置)
vim ~/.pam_environment
	WLR_RENDERER=vulkan
# tty中执行 进入sway(vulkan)桌面
sway
# 如果使用vulkan中遇到问题可以试试这个
vim ~/.pam_environment
	WLR_RENDERER=gles2
```

**免密码登录 service**

```bash
sudo mkdir /etc/systemd/system/getty@tty1.service.d

sudo vim /etc/systemd/system/getty@tty1.service.d/override.conf :
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin <你的用户名> --noclear %I $TERM
Type=idle
```

**日常软件**

```bash
# 原生支持
firefox、alacritty、mpv、waybar、imv、uget、fcitx5、fcitx5-rime、KDE的dolphin、ark和kate、以及PS1模拟器duckstaion
# 可以用但需要xwayland的应用
WPS Office、网易云音乐、steam平台及其下游戏、proton等，兼容性很不错，没遇到过启动不了的问题，使用过程中也没发现什么明显的bug，只是在高分辨率屏幕下会比较糊。
# 启动应用的软件(二选一)
sudo pacman -S wofi
# sudo pacman -S bemenu-wayland

vim ~/.config/sway/config ：
    ### Key bindings
    bindsym $mod+p exec wofi --show run
    # bindsym $mod+p exec bemenu-run
# firefox
vim ~/.pam_environment ：
	MOZ_ENABLE_WAYLAND=1
# fcitx5输入法`
vim ~/.config/sway/config ：
### Auto start
exec --no-startup-id fcitx5 -d
vim ~/.pam_environment ：

GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=@im=fcitx
INPUT_METHOD  DEFAULT=fcitx
SDL_IM_MODULE DEFAULT=fcitx
# mpv播放器
vim .config/mpv/mpv.conf ：

vo=gpu
gpu-api=vulkan（或opengl）
gpu-context=waylandvk（或wayland）
spirv-compiler=shaderc
vulkan-swap-mode=fifo
vulkan-async-transfer=yes
vulkan-async-compute=yes
# 屏幕亮度、音量调节
sudo pacman -S acpilight（用于Intel核显）
sudo pacman -S alsa-utils alsa-plugins
# 配置
vim ~/.config/sway/config ：
# Set Volumn
bindsym $mod+F1 exec amixer -qM set Speaker toggle
bindsym $mod+F2 exec amixer -qM set Master 2%- unmute
bindsym $mod+F3 exec amixer -qM set Master 2%+ unmute
bindsym $mod+F4 exec amixer -qM set Headphone toggle

# Set Backlight
bindsym $mod+F5 exec xbacklight -dec 1
bindsym $mod+F6 exec xbacklight -inc 1

# 状态栏waybar，类似于X11下的polybar
sudo pacman -S waybar otf-font-awesome

vim ~/.config/sway/config :
bar {
    position top
    swaybar_command waybar
        
    #status_command while date +'%Y-%m-%d %I:%M:%S %p'; do sleep 1; done

    #colors {
        #statusline #ffffff
        #background #323232
        #inactive_workspace #32323200 #32323200 #5c5c5c
    #}
}
```



### Deepin [ Xorg \ Wayland ]

https://images.gitee.com/uploads/images/2020/0216/212915_593e4787_5700645.jpeg

[ArchLinux_Wiki - DEEPIN](https://wiki.archlinux.org/index.php/Deepin_Desktop_Environment_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```bash
sudo pacman -S xorg xorg-server xorg-xinit mesa deepin deepin-extra lightdm
vim /etc/lightdm/lightdm.conf

  greeter-session=example-gtk-gnome       # 用VIM 找到这个
  greeter-session=lightdm-deepin-greeter  # 替换为这个

sudo systemctl enable lightdm             # 加入开机自启
vim /etc/X11/xinit/xinitrc  # 配置这个文件

  exec startdde     # 添加这个
  
cp /etc/X11/xinit/xinitrc /home/用户名/.xinitrc
systemctl start lightdm     # 开启桌面 
```

-------------------------------------------------------------------------------



### Kde  [ Xorg \ Wayland ]

https://images.gitee.com/uploads/images/2020/0316/214433_1f1a068a_5700645.png

[ArchLinux_Wiki - KDE](https://wiki.archlinux.org/index.php/KDE_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))  

```bash
sudo pacman -S xorg xorg-server xorg-xinit	# xorg  
sudo pacman -S sddm sddm-kcm plasma mesa    # 安装软件包 
sudo pacman -S plasma-desktop plasma-meta konsole  # 安装桌面
sudo pacman -S kde-applications-meta        # 全部加游戏，什么都有，臃肿（不建议装这个）
sudo systemctl enable sddm          		# 加入开机自启 
echo "exec startkde" >> /etc/X11/xinit/xinitrc  
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
sudo pacman -S                		# KDE终端
```

-------------------------------------------------------------------------------



### Gnome  [ Xorg \ Wayland ]

https://images.gitee.com/uploads/images/2020/0302/152750_9d75eb84_5700645.png

[ArchLinux_Wiki - GNOME](https://wiki.archlinux.org/index.php/GNOME_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```bash
gnome-extra 额外包，可不装。
sudo pacman -S xorg xorg-server xorg-xinit	# xorg
sudo pacman -S mesa gnome gdm 				# 安装桌面
sudo systemctl enable gdm 					# 加入开机自启 
echo "exec gnome=session" >> /etc/X11/xinit/xinitrc
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
```

进入登录界面后，设置为以 GNOME no Xorg模式登入（推荐）

```bash
美化地址：https://www.pling.com/s/Gnome
         https://www.opencode.net/explore/projects
安装插件需要的软件：
sudo pacman -S gnome-tweaks gnome-shell-extensions
```

**Gnome 插件**

```bash
Arch Linux Updates Indicator    archlinux软件更新检测插件,需要配合pacman-contrib使用
Caffeine                        防止自动挂起
Clipboard Indicator             一个剪贴板
Coverflow Alt-Tab               更好的窗口切换
Dash to Dock                    把dash栏变为一个dock
Dynamic Top Bar                 顶栏透明化
Extension Update Notifier       gnome插件更新提示
GnomeStatsPro                   一个系统监视器
system-monitor                  又一个系统监视器
Night Light Slider              调节gnome夜间模式的亮度情况
OpenWeather                     天气插件
Proxy Switcher                  代理插件
Random Wallpaper                自动切换壁纸,
Simple net speed                网速监测
Sound Input & Output Device Chooser 声音设备选择
Status Area Horizontal Spacing  让顶栏更紧凑
Suspend Button                  添加一个休眠按钮
TopIcons Plus                   把托盘图标放到顶栏
Window Is Ready - Notification Remover      去除烦人的window is ready提醒
```

-------------------------------------------------------------------------------

## Aur源 \ Backarch源

###### **[ArchLinux_Wiki - AUR安装](https://wiki.archlinux.org/index.php/AUR_helpers_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))**

###### **[AUR工具 - yay](https://github.com/Jguer/yay)**

###### **[科学上网 - electron-ssr](https://gitee.com/auroot/arch_wiki/releases/electron-ssr)**

- ###  中科大

```
echo '' >> /etc/pacman.conf
echo '[archlinuxcn]' >> /etc/pacman.conf
echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
echo 'Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
```

- ###  清华

```
echo '' >> /etc/pacman.conf
echo '[archlinuxcn]' >> /etc/pacman.conf
echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch' >> /etc/pacman.conf
```

- ### 163

```
echo '' >> /etc/pacman.conf
echo '[archlinuxcn]' >> /etc/pacman.conf
echo 'SigLevel = Optional TrustedOnly' >> /etc/pacman.conf
echo 'Server = http://mirrors.163.com/archlinux-cn/$arch' >> /etc/pacman.conf
```

### Blackarch

- ###  清华

```
echo '' >> /etc/pacman.conf
echo '[blackarch]' >> /etc/pacman.conf
echo 'SigLevel = Optional TrustAll' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/blackarch/$repo/os/$arch' >> /etc/pacman.conf
```

```
    sudo pacman -Syu yaourt yay
    sudo pacman -Syu archlinuxcn-keyring
```

-------------------------------------------------------------------------------

## 常用软件

```bash
pacman -S vim git wget zsh  dosfstools man-pages-zh_cn create_ap p7zip file-roller unrar neofetch openssh linux-headers

sudo pacman -S google-chrome        # 谷歌浏览器
sudo pacman -S firefox              # 火狐浏览器
sudo pacman -S bash-complete        # 增强自动补全功能
sudo pacman -S xpdf                 # 安装pdf阅读器
sudo pacman -Sy yaourt              # 另外一个包管理工具
sudo pacman -S cowsay               # 牛的二进制图形（/usr/share/cows）
sudo yaourt -S vundle-git           # 安装vim的插件管理器
sudo pacman -S deepin.com.qq.office # TIM
sudo yaourt -S deepin-wechat        # 微信
sudo pacman -S deepin-movie         # 深度影院
sudo pacman -S deepin-screenshot    # Deepin 截图
sudo pacman -S deepin-image-viewer  # Deepin 图片浏览器      
sudo pacman -S netease-cloud-music  # 网易云音乐
sudo pacman -S iease-music          # 第三方网易云音乐
sudo pacman -S virtualbo            # virtualbox 虚拟机
sudo pacman -S vmware-workstation   # vmware 虚拟机
sudo pacman -S wps-office           # wps
sudo pacman -S remmina              # 好用远程工具
sudo pacman -S filelight            # 可视化 磁盘使用情况
https://github.com/xtuJSer/CoCoMusic/releases   # QQ音乐  CoCoMusic
sudo pacman -S virtualbox-guest-utils   # VirtualBox 拓展
sudo mandb                          	# 中文的man手册，更新关键词搜索需要的缓存
```

-------------------------------------------------------------------------------

### **TIM - KDE**

**1、安装TIM**

```shell
sudo pacman -S deepin.com.qq.office 
```

**2、第二个包很重要**

```shell
sudo pacman -S gnome-settings-daemon
```

**3、打开TIM，自启gsd-xsettings （推荐），只对TIM有效。**

**方法一**

```shell
sudo vim /usr/share/applications/deepin.com.qq.office.desktop

注释： Exec=“/opt/deepinwine/apps/Deepin-TIM/run.sh” -u %u
加入：Exec=/usr/lib/gsd-xsettings || /opt/deepinwine/apps/Deepin-TIM/run.sh
```



**方法二** @ [Geogra](https://gitee.com/geogra) 
使用方法一 gnome-settings-daemon 会破坏KDE的字体设置和更改KDE的文件选择框什么的。
所以建议使用 xsettingsd 替代 gnome-settings-daemon
使用方式和使用 gnome-settings-daemon 的方式一样，但推荐将 xsettingsd 添加到开机启动项里。

```shell
ln -s /usr/bin/xsettingsd .config/autostart-scripts/
```

**TIM无法显示图片**

```
sudo vim /etc/sysctl.conf

# IPv6 disabled
net.ipv6.conf.all.disable_ipv6 =1
net.ipv6.conf.default.disable_ipv6 =1
net.ipv6.conf.lo.disable_ipv6 =1

sudo sysctl -p
重新打开TIM
```

-------------------------------------------------------------------------------

### **sogou输入法**

[ArchLinux_Wiki - Fcitx](https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

- 安装搜狗输入法及其依赖

```shell
    # 安装搜狗输入法及其依赖
sudo pacman -S fcitx fcitx-im fcitx-configtool fcitx-libpinyin kcm-fcitx fcitx-sogoupinyin
    # 这是一个很重要的包，如果没有，你的搜狗输入法无法使用。
git clone https://gitee.com/auroot/arch_config.git
cd arch_config
sudo pacman -U qtwebkit-2.3.4-7-x86_64.pkg.tar.xz
sudo pacman -U qtwebkit-bin-2.3.4-9-x86_64.pkg.tar.xz  # 覆盖
sudo pacman -U fcitx-qt4-4.2.9.6-1-x86_64.pkg.tar.xz
-----------------------------------------------------------------------------------
如果执行完上面的，加了配置环境，还是不行，就执行下面的
yay -S qtwebkit-bin  # 如果发现下载很慢的时候，就终止，下载下面的包
cp -rf ./qtwebkit-2.3.4-7-x86_64.pkg.tar.xz ~/.cache/yay/qtwebkit-bin/
cp -rf ./qtwebkit-bin-2.3.4-9-x86_64.pkg.tar.xz ~/.cache/yay/qtwebkit-bin/
yay -S qtwebkit-bin # 在执行这条命令
```

- 配置环境 把下面的加入到`/.xporfile

```shell
sudo vim /etc/profile 

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export LC_CTYPE=zh_CN.UTF-8
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
fcitx -d -r --enable sogou-qimpanel
```

```shell
[auroot@Arch ~]# sudo vim /etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx

```

- 终端运行qtconfig-qt4找到interface选项,在下面的Defult Input Method改为fcitx然后保存退出 source /etc/profile 重启。

## 网易云音乐无法输入中文的问题：

[下载地址](http://t.cn/A6wYa0Cr) T:```arch```

```shell
unzip netease-data.zip
sudo pacman -U qcef-1.1.6-1-x86_64.pkg.tar.xz
sudo pacman -U netease-cloud-music-1.2.1-2-x86_64.pkg.tar.xz
```

-------------------------------------------------------------------------------

## 隐藏grub引导菜单

如果使用了其他引导，可以隐藏linux的grub引导菜单，修改下面文件：

```
sudo vim /etc/default/grub
```

```bash
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_OS_PROBER=true
```

更新grub：

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## rEFInd 引导双系统

如果你的电脑支持UEFI启动引导又嫌弃默认的启动界面丑，你可以使用rEFInd来管理你的启动项，推荐一个主题Minimal. 引导设置可参考rEFInd引导Win10+Ubuntu14双系统.
我的启动界面截图：

```bash
rEFInd：https://github.com/EvanPurkhiser/rEFInd-minimal
rEFInd引导Win10+Ubuntu：https://www.cnblogs.com/shishiteng/p/5760345.html
```

-------------------------------------------------------------------------------

## Fstab配置文件

```bash
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>

# /dev/sdb2
UUID=ID     /               ext4        rw,relatime     0   1

# /dev/sdb1
UUID=ID     /boot/efi       vfat         rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro   0   2

# /dev/sdb3
UUID=ID     none            swap        defaults        0   0

#/dev/nvme0n1p2  Windows file ntfs 
UUID=ID     /mnt/c          ntfs,ntfs-3g        defaults,auto,uid=1000,gid=985,umask=002,iocharset=utf8     0   0

#/dev/sda3  Win D file  ntfs  
UUID=ID     /mnt/d          ntfs,ntfs-3g        defaults,auto,uid=1000,gid=985,umask=002,iocharset=utf8     0   0
```

## ZSH

#### 自动补全(不推荐)

```bash
https://mimosa-pudica.net/zsh-incremental.html
chmod 777 ～/.oh-my-zsh/plugins/incr/incr-0.2.zsh
source ~/.oh-my-zsh/plugins/incr/incr-0.2.zsh
```

####  autojump

插件使你能够快速切换路径，再也不需要逐个敲入目录，只需敲入目标目录，就可以迅速切换目录。

```bash
git clone https://github.com/wting/autojump.git
./install.py  
# 在～/.zshrc文件中加入此句
[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh  
```

#### 自动补全

zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
plugins=(zsh-autosuggestions)
```

#### 设置命令正确绿色高亮,错误红色高亮b

```bash
git clone https://github.com/jimmijj/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
plugins=(zsh-syntax-highlighting)
```

#### 加强zsh的补全功能实现tab自动纠错

```bash
vim ~/.oh-my-zsh/lib/completion.zsh
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate
```

## 命令行代理（git，yay）

**[proxychains ](https://github.com/haad/proxychains )** 

[proxychains-ng](https://github.com/rofl0r/proxychains-ng)

我们需要`proxychains`，`ssr（github) 

**Qv2ray V2.70** 

``` bash
# 这里我使用的是 Qv2ray-v2.7.0-linux-x64.AppImage
# https://github.com/Qv2ray/Qv2ray
# 使用前需要一个依赖
sudo pacman -S libxcrypt-compat

# Qv2ray 代理地址
    `socks5://127.0.0.1:1089`
    `http://127.0.0.1:8889`
```

**安装配置 proxychains**

```bash
sudo pacman -S proxychains

# 配置文件 
vim /etc/proxychains.conf
# 最后一行改为, 后面那个数字要和本地端口一致
	[ProxyList]
    socks4 	127.0.0.1 1089
    http	127.0.0.1 8889
```

`yay`还不能走代理，github上有对应的  **[issue](https://github.com/Jguer/yay/issues/951)**

solution：

```bash
yay -S gcc-go (replace go)yay -S yay (or yay-git)
# 以后直接
proxychains yay -S package
```

```
proxychains git clone https://xxxxxxx.git
```

**浏览器代理插件**

[proxy switchyOmega插件](https://microsoftedge.microsoft.com/addons/detail/proxy-switchyomega/fdbloeknjpnloaggplaobopplkdhnikc?hl=zh-CN)







-------------------------------------------------------------------------------

# 待续....

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------