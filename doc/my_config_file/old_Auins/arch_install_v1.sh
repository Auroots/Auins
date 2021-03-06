#!/bin/bash
#
#========变量值
null="/dev/null"
ECHOA=`echo -e "    _             _       _     _                  "`  
ECHOB=`echo -e "   / \   _ __ ___| |__   | |   (_)_ __  _   ___  _        "` 
ECHOC=`echo -e "  / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /         "` 
ECHOD=`echo -e " / ___ \| | | (__| | | | | |___| | | | | |_| |>  <           "`  
ECHOE=`echo -e "/_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\                "`
echo -e "$ECHOA\n$ECHOB\n$ECHOC\n$ECHOD\n$ECHOE" | lolcat 2> ${null} || echo -e "$ECHOA\n$ECHOB\n$ECHOC\n$ECHOD\n$ECHOE"
#
tmps=/tmp/arch_tmp
#systemctl start dhcpcd &> ${null}
PWDS=`pwd`
KENDEYA="arch_install2.sh"
LIST_IN=`echo "${PWDS}/${KENDEYA}"`
PASS="orange"
#========网络变量
ETHERNET=`ip link | grep 'enp[0-9]s[0-9]' | grep -v 'grep' | awk '{print $2}' | cut -d":" -f1`  #有线
WIFI=`ip link | grep 'wlp[0-9]s[0-9]' | grep -v 'grep' | awk '{print $2}' | cut -d":" -f1`   #无线
#WIFI_IP=`ifconfig ${WIFI} &> $null || echo "--.--.--.--" && ifconfig ${WIFI} | grep ./a"inet " |  awk '{print $2}'`
#ETHERNET_IP=`ifconfig ${ETHERNET} &> $null || echo "--.--.--.--" && ifconfig ${ETHERNET} | grep "inet " |  awk '{print $2}'`

ETHERNET_IP=`ip route | grep "${ETHERNET}" &> ${null} && ip route list | grep "${ETHERNET}" | cut -d" " -f9 | sed -n '2,1p'`  
WIFI_IP=`ip route | grep ${WIFI} &> ${null} && ip route list | grep ${WIFI} |  cut -d" " -f9 | sed -n '2,1p'`

#========Arch 源'
region='## China'
ustc='Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch'
netease='Server = https://mirrors.163.com/archlinux/$repo/os/$arch'
tsinghua='Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch'
mirrorlist='/etc/pacman.d/mirrorlist'
sedname=`sed -n '7,1p' $mirrorlist`
sedserver=`sed -n '8,1p' ${mirrorlist}`
#====脚本颜色变量
r='\033[1;31m'	#---红
g='\033[1;32m'	#---绿
y='\033[1;33m'	#---黄
b='\033[1;36m'	#---蓝
w='\033[1;37m'	#---白
rw='\033[1;41m'    #--红白
wg='\033[1;42m'    #--白绿
ws='\033[1;43m'    #--白褐
wb='\033[1;44m'    #--白蓝
wq='\033[1;45m'    #--白紫
wa='\033[1;46m'    #--白青
wh='\033[1;46m'    #--白灰
h='\033[0m'		 #---后缀
bx='\033[1;4;36m' #---蓝 下划线
sp=" "
#No_IP_Addess=" "
wy='\033[1;41m' h='\033[0m'
#========选项
echo -e "#=======================================================#"
echo -e "# ${b}Script Name:        Arch Linux Script${h}"  
echo -e "# ${b}Author:             Basierl${h}"
echo -e "# ${b}GitHub:	      ${bx}https://github.com/BaSierL/arch_install${h}"
echo -e "# ${g}Ethernet:           ${ETHERNET_IP:-No_network}${h}"
echo -e "# ${g}WIFI:	              ${WIFI_IP:-No_network}${h}"
echo -e "# ${g}SSH:                ssh root@${ETHERNET_IP:-IP_Addess}${h}"
echo -e "# ${g}SSH:                ssh root@${WIFI_IP:-IP_Addess}${h}"
echo -e "#=======================================================#"
echo;
echo -e "${w}:: ==>> Configure Mirrorlist   [1]${h}"
echo -e "${w}:: ==>> Configure Network      [2]${h}"
echo -e "${w}:: ==>> Install System !!!     [3]${h}"
echo -e "${w}:: ==>> Configure SSH          [4]${h}"
echo -e "${w}:: ==>> Exit Script            [Q]${h}"
echo;
echo -e "\033[1;33m:: ==>> What are the tasks[1,2,3..]? ${h}"
read -p ':: ==>> : ' principal_variable
#
#========ArchLinux Mirrorlist
echo;
if [[ ${principal_variable} == 1 ]]; then
    read -p ":: ==>> Tsinghua(https)[1] 163(https)[2] Ustc(https)[3] Query[4] Exit[4]?: " mirror_variable
        case $mirror_variable in
            1)      
                echo;
                sed -i "s@$sedname@$region@" ${mirrorlist}
                sed -i "s@$sedserver@$tsinghua@" ${mirrorlist}
                sed -n '7,8p' ${mirrorlist}
                sleep 3
                echo;
                pacman -Syy || ls /usr/bin/lolcat &> $null && echo "y" |  pacman -S lolcat 
                echo;
                echo;
                bash ${LIST_IN}
                ;;
            2)      
                echo;
                sed -i "s@$sedname@$region@" ${mirrorlist}
                sed -i "s@$sedserver@$netease@" ${mirrorlist}
                sed -n '7,8p' ${mirrorlist}
                sleep 3
                echo;
                pacman -Syy || ls /usr/bin/lolcat &> $null && echo "y" |  pacman -S lolcat 
                echo;
                echo;
                bash ${LIST_IN}
                ;;
            3)
                echo;
                sed -i "s@$sedname@$region@" ${mirrorlist}
                sed -i "s@$sedserver@$ustc@" ${mirrorlist}
                sed -n '7,8p' ${mirrorlist}   
                sleep 3    
                echo;
                pacman -Syy || ls /usr/bin/lolcat &> $null && echo "y" |  pacman -S lolcat   
                echo;
                echo; 
                sleep 3     
                bash ${LIST_IN}
                ;;
            4)
                head -n 8 ${mirrorlist}
                echo;
                echo;
                sleep 3
                bash ${LIST_IN}
                ;;
            5) 
                bash ${LIST_IN}
                ;;
        esac
fi
#========检查网络  2
if [[ ${principal_variable} == 2 ]]; then
    echo;
    echo ":: Checking the currently available network."
    sleep 2
    echo -e ":: Ethernet: ${r}${ETHERNET}${h}" 2> $null
    echo -e ":: Wifi:   ${r}${WIFI}${h}" 2> $null 
read -p ":: ==>> Query Network: Ethernet[1] Wifi[2] Configure[3] Exit[4]?: " wlink
case $wlink in
    1) 
        clear;
        ifconfig ${ETHERNET} 2> /dev/null || echo "Please configure the network first." &&  ping -I ${ETHERNET} -c 3 14.215.177.38 
        sleep 1
        bash ${LIST_IN}      
    ;;
    2) 
        echo;
        echo ":: The following WiFi is available: "
        iwlist ${WIFI} scan | grep "ESSID:"
    ;;
    3) 
        read -p ":: Configure Network WIFI[1] ETHERNET[2]?: " SNET
            case ${SNET} in
                1) 
                    echo ":: 请稍等！"
                    ls /usr/bin/ifconfig &> $null && echo ":: Install net-tools" ||  echo "y" |  pacman -S ifconfig
                    ip link set ${ETHERNET} up
                    ifconfig ${ETHERNET} up
                    systemctl enable dhcpcd &> $null
                    bash ${LIST_IN}
                    sleep 1
                ;;
                2)
                    wifi-menu
                    sleep 2
                    bash ${LIST_IN}
                ;;
                3)
                    sleep 2
                    bash ${LIST_IN}
                ;;
            esac
    ;; 
    4) 
        bash ${LIST_IN}
    ;;
esac
fi
#
##========开启SSH 4
if [[ ${principal_variable} == 4 ]]; then
    ls /usr/bin/ssh &> $null && echo "Install Openssh" ||  echo "y" |  pacman -S openssh 
    systemctl start sshd.service  &> $null
    netstat -antp | grep sshd
    echo;
    echo ":: 正在设置密码."
    echo ${USER}:${PASS} | chpasswd &> $null
    clear
    echo -e "\033[1;42m#=================================#${h}"
    echo -e "\033[1;42m#:: User: ${USER}                    #${h}"
    echo -e "\033[1;42m#:: Password: ${PASS}              #${h}"
    echo -e "\033[1;42m#=================================#${h}"
    echo;
    bash ${LIST_IN}
fi

##======== 配置ArchLinux 3 ==========================================
if [[ ${principal_variable} == 3 ]];then
    echo
    echo -e "${r}      Configure Arch Linux OS${h}"
    echo "-----------------------------------"
    echo -e "${w}:: ==>> Configure System      [1]${h}"
    echo -e "${w}:: ==>> Install Drive       [2]${h}"
    echo -e "${w}:: ==>> Install Desktop       [3]${h}"
    echo -e "${w}:: ==>> Configure System Services     [4]${h}"
    echo "-----------------------------------"
echo;
    echo -e "\033[1;33m:: ==>> What are the tasks[1,2,3..] Exit [Q]? ${h}"
    read -p ':: ==>> : ' tasks

#========== Configure Systemctl 配置系统 ==========
        if [[ ${tasks} == 1 ]];then
            # 设置时区
            echo -e "\033[1;42mUpdate the system clock.${h}"
            ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime # 上海
            hwclock --systohc
            #更新系统时间
            timedatectl set-ntp true
            # 本地化
            sed -i s"@#zh_CN.UTF-8 UTF-8@zh_CN.UTF-8 UTF-8@" /etc/locale.gen
            sed -i s"@#en_US.UTF-8 UTF-8@en_US.UTF-8 UTF-8@" /etc/locale.gen
            echo "LANG=zh_CN.UTF-8" > /etc/locale.conf 
            locale-gen
            # 主机名
            echo "Archlinux" > /etc/hostname
            # 配置GRUB
            pacman -S grub efibootmgr os-prober
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Archlinux && grub-mkconfig -o /boot/grub/grub.cfg
            sleep 3
			# 安装字体
            pacman -S ttf-dejavu \
                      wqy-zenhei \
                      wqy-microhei \
                      ttf-liberation \
                      ttf-dejavu
            # 用户配置
            echo "Useradd: xxxx "
            read -p ':: ==>> : ' ADDUSERS
                useradd -m -g users -G wheel -s /bin/bash $ADDUSERS 
				echo ${ADDUSERS}:${ADDUSERS} | chpasswd &> $null
                sed -i s"@# %wheel ALL=(ALL) NOPSSWD: ALL@%wheel ALL=(ALL) NOPSSWD: ALL@" /etc/sudoers

        fi
fi
#
#========== Configure Drive 安装驱动 ==========
        ##触摸板驱动  #无线AP  #intel #安装声音软件包 
        if [[ ${tasks} == 2 ]];then
            echo -e "${r}      Select Install Desktop ${h}"
            echo "-----------------------------------"
            echo -e "${w}:: ==>> intel input voice AP    [1]${h}"
            echo -e "${w}:: ==>> Install Nvidia          [2]${h}"
            echo -e "${w}:: ==>> Exit                    [3]${h}"
            echo "-----------------------------------"
            echo;
            echo -e "\033[1;33m:: ==>> What are the tasks[1,2,3..] Exit [Q]? ${h}"
                read -p ":: ==>> : " adddrive
                    case $adddrive in
                        1)
                            sudo pacman -S xf86-input-libinput \
                                    xf86-input-synaptics \
                                    create_ap mesa-libgl \
                                    xf86-video-intel \
                                    libva-intel-driver \
                                    libvdpau-va-glmesa-demos \
                                    alsa-utils \
                                    pulseaudio \
                                    pulseaudio-alsa    
                        ;;
                        2)
                            sudo pacman -S nvidia \
                                    nvidia-settings \
                                    xf86-video-nv \
                                    opencl-nvidia \
                                    lib32-nvidia-utils \
                                    lib32-opencl-nvidia \
                                    mesa \
                                    lib32-mesa-libgl \
                                    bumblebee
                        ;;     
                    esac
            fi                 
#    pacman -S alsa-utils pulseaudio pulseaudio-alsa     
#========== Install Desktop 安装桌面环境 ==========
            if [[ ${tasks} == 3 ]];then
                echo -e "$ws Detecting desktop environments. $h"
                    if [ `env | grep DESKTOP_SESSION` != 0]; then
                        echo -e "$wg Desktop in use: $DESKTOP_SESSION $h"
                        echo -e "$y No installation required. $h"
            
                    else
                        echo -e "$wh System no Desktop. $h"
                    fi
                echo
                echo -e "${r}      Select Install Desktop ${h}"
                echo "-----------------------------------"
                echo -e "${w}:: ==>> i3 Desktop         [1]${h}"
                echo -e "${w}:: ==>> KDE Desktop        [2]${h}"
                echo -e "${w}:: ==>> Gnome Desktop      [3]${h}"
                echo -e "${w}:: ==>> Deepin Desktop     [4]${h}"
                echo -e "${w}:: ==>> Exit               [5]${h}"
                echo "-----------------------------------"
                echo;
                echo -e "\033[1;33m:: ==>> What are the tasks[1,2,3..] Exit [Q]? ${h}"
                    read -p ':: ==>> : ' desktoptasks
                        case $desktoptasks in
                        1) #===== i3 桌面  ====#
                            echo "Please look forward to it."
                        ;;
                        2) #===== KDE plasma 桌面  ====#
                            echo "In preparation." 
                            sleep 2
                        ;;
                        3) #===== Gnome 桌面  ====#
                            echo "In preparation."
                            sleep 2
                        ;;
                        4) #===== Deepin 桌面  ====#
                            echo "In preparation."
                            sleep 2
                            sudo pacman -S deepin \
                                    deepin-extra \
                                    lightdm \
                                    xorg-server \
                                    xorg-xinit \
                                    xorg-utils \
                                    xorg-server-utils \
                                    mesa
                            sudo sed -i s"@#greeter-session=example-gtk-gnome@greeter-session=lightdm-deepin-greeter@" /etc/lightdm/lightdm.conf 
                            sudo  echo "exec startdde" >> /etc/X11/xinit/xinitrc
                            sudo  cp /etc/X11/xinit/xinitrc /home/$USER/.xinitrc
                            sudo  systemctl start lightdm 
                        ;;
                        5) #===== 返回  ====#
                            echo;
                            sleep 3
                            bash ${LIST_IN}
                        ;;
                        esac
            fi            
#
##========退出 EXIT
if [[ ${principal_variable} == q || Q || quit || QUIT ]];then
    clear;
    echo;
    echo -e "\033[1;42m#----------------------------------#${h}"
    echo -e "\033[1;42m#:: script is over. Thank.         #${h}"
    echo -e "\033[1;42m#----------------------------------#${h}"
    /usr/bin/bash
    exit 0
fi
