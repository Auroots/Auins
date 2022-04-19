#!/usr/bin/env bash
# Author/Wechat: Auroot
# Script name：Auins (ArchLinux User Installation Scripts) 
# Arch Image: archlinux-2022.5.01-x86_64.iso
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# Home URL: : https://www.auroot.cn
# set -xe
echo &>/dev/null
# @初始化变量
function Script_init_Variable(){
# The contents of the variable are customizable
    Version="ArchLinux user installation scripts V4.3.5" 
    Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
    [ "$Auins_Dir" = "/" ] && Auins_Dir=""
    Share_Dir="${Auins_Dir}/share" # The script module directory
    Local_Dir="${Auins_Dir}/local" # Temp Directory
    Auins_Config="${Local_Dir}/install.conf"  # Configure file
    Auins_record="${Local_Dir}/auins.info"  # Info file
    entries_a="/run/archiso/bootmnt/loader/entries/01-archiso-x86_64.conf"  # Uefi test
    entries_b="/run/archiso/bootmnt/loader/entries/01-archiso-x86_64-linux.conf"  # Boot test
    # Module URL: Default settings
    local Branch="master"  # master: 稳定 preview: 测试(暂无)
    local User="auroot"
    local Giturl="https://gitee.com/${User}"
    Auins_Home="${Giturl}/Auins/raw/${Branch}"
    Auins_Share="${Auins_Home}/share"
    Auins_Local="${Auins_Home}/local"
}
# @读取配置文件 local/install.conf
function Read_Config(){ 
    # 头部参数 $1 , 地址 $2（如果是查install.conf，可以不用写）（如果是auins.info，必须写INFO）  
    if [[ $2 == "INFO" ]]; then
        local Files="$Auins_record"
    else
        local Files="${Auins_Config}"
    fi 
    grep -w "${1}" < ${Files} | awk -F "=" '{print $2}'; 
    # grep -w "${1}" < ${Files} | awk -F "=" '{print $2}' | awk -F " " '{print $1}'; 
}
# @写入信息文件 local/auins.info
function Write_Data(){
    # 头部参数 $1 , 修改内容 $2    
    format=" = "
    List_row=$(grep -nw "${1}" < ${Auins_record} | awk -F ":" '{print $1}';)
    sed -i "${List_row:-Not}c ${1}${format}${2}" "${Auins_record}" 2>/dev/null
}
function Printf_Info(){
    function Logos(){
        #----------------------------------------------------------------------------
        ECHOA=$(echo -e "${w}          _             _       _     _                    ${h}") 
        ECHOB=$(echo -e "${g}         / \   _ __ ___| |__   | |   (_)_ __  _   ___  __  ${h}")
        ECHOC=$(echo -e "${b}        / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /  ${h}")
        ECHOD=$(echo -e "${y}       / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   ${h}")
        ECHOE=$(echo -e "${r}      /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\  ${h}")
        echo -e "$ECHOA\n$ECHOB\n$ECHOC\n$ECHOD\n$ECHOE" | lolcat 2>/dev/null || echo -e "$ECHOA\n$ECHOB\n$ECHOC\n$ECHOD\n$ECHOE"
        echo -e "${b}||============================================================||${h}"
        echo -e "${b}|| Script Name:    ${Version}.                                  ${h}"
        echo -e "${g}|| Patterns:        ${ChrootPatterns}                           ${h}"
        echo -e "${g}|| Ethernet:       ${Ethernet_ip:-No_network..} - [${Ethernet_Name:- }]${h}"
        echo -e "${g}|| WIFI:           ${Wifi_ip:-No_network.} - [${Wifi_Name:-No}] ${h}"
        echo -e "${g}|| SSH:            ssh $USER@${Ethernet_ip:-IP_Addess.}         ${h}"
        echo -e "${g}|| SSH:            ssh $USER@${Wifi_ip:-IP_Addess.}             ${h}"
        echo -e "${g}||============================================================||${h}"

        echo -e "${PSB} ${g}Configure Mirrorlist   [1]${h}"
        echo -e "${PSB} ${g}Configure Network      [2]${h}"
        echo -e "${PSG} ${g}Configure SSH          [3]${h}"
        echo -e "${PSY} ${g}Install System         [4]${h}"
        echo -e "${PSG} ${g}Exit Script            [Q]${h}"
    }
    # @Auins的帮助文档 Auin_help
function usage() {
  cat <<EOF
    usage: ${0##*/} [-h] [-V] command ...
      Options:
        -m --mirror   Automatically configure mirrorlist file and exit."
        -w --cwifi    Connect to a WIFI and exit."
        -s --openssh  Open SSH service (default password: 123456) and exit."
        -vm --virtual Install Vmware/Virtualbox Tools and exit."
        -i --info     View the computer information of script record, file: ./local/auins.info"
        -h --help     Show this help message and exit. "
        -V --version  Show the conda version number and exit."
    :: Auins is a script for ArchLinux installation and deployment.
EOF
}
    # @Auins版本号，Stript Version
    function Version(){    
        echo -e "${wg}${Version}${h}"
        echo -e "${wg}$(grep "archisolabel=" < "$entries" | grep -v grep | awk '{print $3}')${h}\n"
    }
    # @首选项 [4] 的列表
    function input_System_Module(){    # print list 4
        echo -e "\n     ${w}*** ${r}Install System Module ${w}***${h}  "  
        echo "---------------------------------------------"
        echo -e "${PSY} ${g}   Disk Partition.         ${r}**  ${w}[1]${h}"
        echo -e "${PSY} ${g}   Install System Files.   ${r}**  ${w}[2]${h}"
        echo -e "${PSY} ${g}   Configurt System.       ${r}**  ${w}[3]${h}"
        echo -e "${PSG} ${g}   Installation Desktop.   ${b}*   ${w}[4]${h}"  
        echo -e "${PSG} ${g}   Installation Drive.     ${b}*   ${w}[11]${h}" 
        echo -e "${PSY} ${g}   Install virtual tools.  ${b}*   ${w}[22]${h}"
        echo -e "${PSY} ${g}   arch-chroot /mnt.       ${r}**  ${w}[0]${h}"
        echo -e "---------------------------------------------\n" 
    }
    # @桌面环境选择列表
    function input_Desktop_env(){
        echo -e "\n     ${w}***${h} ${b}Install Desktop${h} ${w}***${h}  "  
        echo "------------------------------------------------"
        echo -e "${PSB} ${g}   KDE plasma.     ${b}[1]  ${b}default: sddm${h}"
        echo -e "${PSB} ${g}   Gnome.          ${w}[2]  ${w}default: gdm${h}"
        echo -e "${PSB} ${g}   Deepin.         ${b}[3]  ${b}default: lightdm${h}"    
        echo -e "${PSB} ${g}   Xfce4.          ${w}[4]  ${w}default: lightdm${h}"  
        echo -e "${PSB} ${g}   i3wm.           ${b}[5]  ${b}default: sddm${h}"
        echo -e "${PSB} ${g}   i3gaps.         ${w}[6]  ${w}default: lightdm${h}"
        echo -e "${PSB} ${g}   lxde.           ${b}[7]  ${b}default: lxdm${h}"
        echo -e "${PSB} ${g}   Cinnamon.       ${w}[8]  ${w}default: lightdm${h}"
        echo -e "${PSB} ${g}   Mate.           ${b}[9]  ${b}default: lightdm${h}"
        # echo -e "${PSB} ${g}   Openbox.        ${b}[10] ${b}default: sddm${h}"
        #echo -e "${PSB} ${g}   Dwm.        ${b}[10] ${b}default: sddm${h}"
        echo -e "------------------------------------------------\n"                          
    }
    # Printf_Info
    case ${1} in
        "Logos")
            Logos
        ;;
        "usage")
            usage
        ;;
        "Version")
            Version
        ;;
        "input_System_Module")
            input_System_Module
        ;; 
    esac
}
# @脚本颜色变量
function Set_Color_Variable(){
    r='\033[1;31m'  #---红
    g='\033[1;32m'  #---绿
    y='\033[1;33m'  #---黄
    b='\033[1;36m'  #---蓝
    w='\033[1;37m'  #---白
    h='\033[0m'     #---后缀
    #-----------------------------#
    # rw='\033[1;41m'  #--红白
    wg='\033[1;42m'  #--白绿
    ws='\033[1;43m'  #--白褐
    # wb='\033[1;44m'  #--白蓝
    # wq='\033[1;45m'  #--白紫
    # wa='\033[1;46m'  #--白青
    # bx='\033[1;4;36m'  #---蓝 下划线
    #-----------------------------#
    # 交互 蓝  红 绿 黄
    JHB=$(echo -e "${b}-=>${h} ")
    # JHR=$(echo -e "${r}-=>${h} ")
    # JHG=$(echo -e "${g}-=>${h} ")
    # JHY=$(echo -e "${y}-=>${h} ")
    #-----------------------------
    # 提示 蓝 红 绿 黄
    PSB=$(echo -e "${b} ::==>${h}")
    PSR=$(echo -e "${r} ::==>${h}")
    PSG=$(echo -e "${g} ::==>${h}")
    PSY=$(echo -e "${y} ::==>${h}")
}
# @脚本自检
function Script_init(){
    # Detect CPU
    CPU_name=$(head -n 5 /proc/cpuinfo | grep "model name" | cut -d" " -f5)
    if lscpu | grep GenuineIntel &>/dev/null ; then
        CPU_Vendor="intel"
    elif lscpu | grep AuthenticAMD &>/dev/null ; then
        CPU_Vendor="amd"
    fi
    Write_Data "CPU_Name" "${CPU_name}"
    Write_Data "CPU_Vendor" "${CPU_Vendor}"
    # Detect Virtualization
    if lspci | grep -i virtualbox &>/dev/null ; then
        Virtualization="virtualbox"
    elif lspci | grep -i vmware &>/dev/null ; then
        Virtualization="vmware"
    fi
    Write_Data "Virtualization" "${Virtualization}"
    # 判断当前模式
    if [ -e /local/Chroot ]; then
        ChrootPatterns="Chroot-ON"
    else
        ChrootPatterns="Chroot-OFF"
    fi
    Write_Data "Patterns" "${ChrootPatterns}"
    # Detect Archiso Version
    if [ -e "$entries_a" ]; then
        entries="$entries_a"
    elif [ -e "$entries_b" ]; then
        entries="$entries_b"
    fi
    Query_Archiso_Version_check=$(Read_Config "Archiso_Version_check" "INFO")
    
    if [ "X$Query_Archiso_Version_check" = "Xno" ] || [ "X$Query_Archiso_Version_check" = "X" ]; then
        Archiso_Version "$entries"
    fi
    ln -sf /usr/share/zoneinfo"$(Read_Config "Area")" /etc/localtime &>/dev/null && hwclock --systohc
}
# @下载所需的脚本模块
function Update_Share(){    
    if [ ! -e "${Share_Dir}/Mirrorlist.sh" ]; then
        curl -fsSL "$Auins_Share/Mirrorlist.sh" > "${Share_Dir}/Mirrorlist.sh" 
        chmod +x "${Share_Dir}/Mirrorlist.sh"
    fi
    if [ ! -e "${Share_Dir}/Useradd.sh" ]; then
        curl -fsSL "$Auins_Share/Useradd.sh" > "${Share_Dir}/Useradd.sh"
        chmod +x "${Share_Dir}/Useradd.sh"
    fi
    if [ ! -e "${Share_Dir}/Partition.sh" ]; then
        curl -fsSL "$Auins_Share/Partition.sh" > "${Share_Dir}/Partition.sh"
        chmod +x "${Share_Dir}/Partition.sh"
    fi
    if [ ! -e "${Share_Dir}/Process_manage.sh" ]; then
        curl -fsSL "$Auins_Share/Process_manage.sh" > "${Share_Dir}/Process_manage.sh"
        chmod +x "${Share_Dir}/Process_manage.sh"
    fi
    if [ ! -e "${Share_Dir}/Edit_Database.sh" ]; then
        curl -fsSL "$Auins_Share/Edit_Database.sh" > "${Share_Dir}/Edit_Database.sh"
        chmod +x "${Share_Dir}/Edit_Database.sh"
    fi
    if [ ! -e "${Auins_Config}" ]; then
        curl -fsSL "${Auins_Local}/install.conf" > "$Auins_Config"
    fi
    if [ ! -e "${Auins_record}" ]; then
        curl -fsSL "${Auins_Local}/auins.info" > "$Auins_record"
    fi
}
# @Auins的其他选项功能
function Auin_Options(){
    local Function_Enter="${1}"
    case ${Function_Enter} in
        -m | --mirror)
            bash "${Share_Dir}/Mirrorlist.sh"
            exit 0;
        ;;
        -w | --cwifi)
            Ethernet INFO;
            Ethernet Conf_wifi;
            exit 0;
        ;;
        -s | --openssh)
            Ethernet INFO;
            Open_SSH;
            exit 0;
        ;;
        -vm | --virtual)
            install_virtualization_service
        ;;
        -i | --info)
            echo "---------------------------------"
            cat "${Auins_record}"
            echo "================================="
            exit 0;
        ;;
        -h | --help)
            Printf_Info usage
            exit 0;
        ;;
        -v | -V | --version)
            clear;
            Printf_Info Version
            exit 0;
        ;;
    esac
}
# @网络部分集合
function Ethernet(){
    # @获取本机IP地址，并储存到$Auins_record， Network Variable
    function Ethernet_info(){    
        local Info_Nic
        for  ((Cycle_number=3;Cycle_number<=10;Cycle_number++)); do
            Info_Nic=$(cut -d":" -f1 /proc/net/dev | sed -n "$Cycle_number",1p | sed 's/^[ ]*//g')
            if echo "$Info_Nic" | grep "en" &>/dev/null ; then 
                Ethernet_Name="$Info_Nic"
                Ethernet_ip=$(ip route list | grep "${Ethernet_Name}" | cut -d" " -f9 | sed -n '2,1p')

                Write_Data "Ethernet_ip" "${Ethernet_ip:-Not}"
                break;
            elif echo "$Info_Nic" | grep "wl" &>/dev/null ; then
                Wifi_Name="$Info_Nic"
                Wifi_ip=$(ip route list | grep "${Wifi_Name}" | cut -d" " -f9 | sed -n '2,1p') 

                Write_Data "Wifi_ip" "${Wifi_ip:-Not}"
                break;
            fi
        done    
    }
    # @配置WIFI，Configure WIFI
    function Configure_wifi() {
        printf "${PSG} ${g} Wifi SSID 'TP-Link...' :${h} %s" "${JHB}"
        read -r WIFI_SSID
        printf "${PSG} ${g} Wifi Password :${h} %s" "${JHB}"
        read -r WIFI_PASSWD
        iwctl --passphrase "$WIFI_PASSWD" station "$Wifi_Name" connect "$WIFI_SSID"
        sleep 2;
        ip address show "${Wifi_Name}"
        if ! ping -c 3 -i 2 -W 5 -w 30 8.8.8.8; then
            echo "Network ping check failed. Cannot continue."
            Process_Management stop "$0"
        fi
    }
    # @配置有线网络，Configure Ethernet.
    function Configure_Ethernet(){
        echo ":: One moment please............"
        ip link set "${Ethernet_Name}" up
        ip address show "${Ethernet_Name}"
        ping -c 3 -i 2 -W 5 -w 30 8.8.8.8
        sleep 1;
    }
    # Ethernet
    case ${1} in
        "INFO")
            Ethernet_info
        ;;
        "Conf_wifi")
            Configure_wifi
        ;;
        "Conf_Eth")
            Configure_Ethernet
        ;;
    esac
}
# @开启SSH服务， Start ssh service  [可优化：1.自定义用户名与密码，2.配置ssh文件]
function Open_SSH(){    
    echo
    echo -e "${y}:: Setting SSH Username / password.${h}" 
    echo "${USER}:$(Read_Config "Password_live")" | chpasswd &>/dev/null 
    echo -e "${g} ||=================================||${h}"
    echo -e "${g}       $ ssh $USER@${Ethernet_ip:-IP_Addess..}  ${h}" 
    echo -e "${g}       $ ssh $USER@${Wifi_ip:-IP_Addess..}      ${h}"
    echo -e "${g}       Username --=>  $USER           ${h}"
    echo -e "${g}       Password --=>  $(Read_Config "Password_live")           ${h}"
    echo -e "${g} ||=================================||${h}"
    systemctl start sshd.service 
    netstat -antp | grep sshd 
}
# @设置root密码 用户  判断/etc/passwd文件中最后一个用户是否大于等于1000的普通用户，如果没有请先创建用户
function ConfigurePassworld(){
    local UserName UserID PasswdFile Query Number CheckingUsers CheckingID 
    UserName=$(Read_Config "Users" "INFO")
    UserID=$(Read_Config "UsersID" "INFO")
    if [ "${UserName}" = "" ]; then
        PasswdFile="/etc/passwd"
        for ((Number=1;Number<=50;Number++))  # 设置变量Number 等于1 ；小于等于50 ； Number 1+1直到50
        do
            Query=$(tail -n "${Number}" "${PasswdFile}" | head -n 1 | cut -d":" -f3)
            if [[ $Query -gt 1000 && $Query -lt 2000 ]]; then
                CheckingUsers=$(grep "$Query" < ${PasswdFile} | cut -d":" -f1)
                CheckingID=$(grep "$Query" < ${PasswdFile} | cut -d":" -f3)
                printf "${PSG} ${g}A normal user already exists, The UserName:${h} ${b}%s${h} ${g}ID: ${b}%s${h}." "${CheckingUsers}" "${CheckingID}"
                break;
            fi
        done
        if [ "${CheckingUsers}" = "" ]; then
            bash "${Share_Dir}/Useradd.sh" "${Local_Dir}" "${Share_Dir}"
            sleep 1;
        fi
    else
        printf "${PSG} ${g}A normal user already exists, The UserName:${h} ${b}%s${h} ${g}ID: ${b}%s${h}." "${CheckingUsers}" "${UserID}"
    fi
}
# @安装系统、内核、基础包等，Install system kernel / base...
function Install_Archlinux(){    
    echo -e "${wg}Update the system clock.${h}"   # update time
    timedatectl set-ntp true
    sleep 2;
    echo -e "\n${PSG} ${g}Install the base packages.${h}\n"
    bash "${Share_Dir}/Mirrorlist.sh"
    if [[ $(Read_Config "Linux_kernel") = "linux" ]]; then
        pacstrap -i /mnt linux linux-headers linux-firmware base base-devel networkmanager net-tools vim 
    elif [[ $(Read_Config "Linux_kernel") = "linux-lts" ]]; then
        pacstrap -i /mnt linux-lts linux-firmware base base-devel networkmanager net-tools vim 
    elif [[ $(Read_Config "Linux_kernel") = "linux-zen" ]]; then
        pacstrap -i /mnt linux-zen linux-zen-headers linux-firmware base base-devel networkmanager net-tools vim
    fi
    sleep 2;
    echo -e "\n${PSG}  ${g}Configure Fstab File.${h}"   # Configure fstab file
    genfstab -U /mnt >> /mnt/etc/fstab  
    LinuxKernel=$(arch-chroot /mnt /usr/bin/uname -a | /usr/bin/cut -d"#" -f1)

    Write_Data "LinuxKernel" "${LinuxKernel}"
    cp -rf "${Local_Dir}" "/mnt/" 
    cp -rf "${Share_Dir}" "/mnt/" 
    cat "$0" > /mnt/auin.sh  && chmod +x /mnt/auin.sh 
    touch /mnt/local/Chroot && echo "Chroot=ON" > /mnt/local/Chroot
}
# @Chroot -> /mnt 
function Auin_chroot(){    
    cat "$0" > /mnt/auin.sh  && chmod +x /mnt/auin.sh
    arch-chroot /mnt /bin/bash -c "/auin.sh"
}
# @桌面管理器选择列表，选择后，自动安装及配置服务；
function Desktop_Manager(){
    echo "---------------------------------"
    echo -e "${PSB} ${g}   sddm.     ${w}[1]${h}"  
    echo -e "${PSB} ${g}   gdm.      ${w}[2]${h}" 
    echo -e "${PSB} ${g}   lightdm.  ${w}[3]${h}"   
    echo -e "${PSB} ${g}   lxdm.     ${w}[4]${h}"  
    echo -e "${PSB} ${g}   default.  ${w}[*]${h}" 
    echo "---------------------------------"
    printf "${PSG} ${y} Please select Desktop Manager: ${h} %s" "${JHB}"
    read -r DM_ID
    case ${DM_ID} in
        1)
            DmS="sddm"
        ;;
        2)
            DmS="gdm"  
        ;;
        3)
            DmS="lightdm"
        ;;
        4)
            DmS="lxdm"
        ;;
        *)
            sleep 1
        ;;
    esac
    echo ${DmS} > "${Local_Dir}/Desktop_Manager"
        if [[ ${DmS} == "sddm" ]] ; then
            Install_Program "sddm sddm-kcm"  # Install SDDM
            systemctl enable sddm
        elif [[ ${DmS} == "gdm" ]] ; then
            Install_Program "gdm"     
            systemctl enable gdm  
        elif [[ ${DmS} == "lightdm" ]] ; then
            Install_Program "lightdm lightdm-gtk-greeter" 
            systemctl enable lightdm
        elif [[ ${DmS} == "lxdm" ]] ; then
            Install_Program "lxdm"
            systemctl enable lxdm 
        fi
        Write_Data "Desktop_Mg" "${DmS}"
}
# @桌面环境安装 $1(桌面名称) $2(xinitrc配置 "exec desktop") $3(包列表)
function Install_DesktopEnv(){
    local Desktop_Name Desktop_Xinit Desktop_Program;
    Desktop_Name=$1
    Desktop_Xinit=$2
    Desktop_Program=$3
    
    echo -e "${PSG} ${g}Configuring desktop environment.${h}"
    sleep 1;
    Install_Program "$(Read_Config P_xorgGroup)"
    Install_Program "$Desktop_Program"
    Install_Program "$(Read_Config P_gui)"
    Desktop_Manager
    Desktop_Env_Config "$Desktop_Name" "$Desktop_Xinit" 
    Write_Data "Desktop_Env" "${Desktop_Name}"
}
# @桌面环境最终安装，在提示中输入序号即可自动安装;
function Set_Desktop_Env(){
    input_Desktop_env
    DESKTOP_ID="0"  
    printf "${PSG} ${y} Please select desktop:${h} %s" "${JHB}"
    read -rp DESKTOP_ID
    case ${DESKTOP_ID} in
        1)
            Install_DesktopEnv plasma startkde "$(Read_Config P_plasma)"
            DmS="sddm"
        ;;
        2)
            Install_DesktopEnv gnome gnome-session "$(Read_Config P_gnome)"
            DmS="gdm"
        ;;
        3)
            Install_DesktopEnv deepin startdde "$(Read_Config P_deepin )"  
            DmS="lightdm"
        ;;
        4)
            Install_DesktopEnv xfce4 startxfce4 "$(Read_Config P_xfce4)"
            DmS="lightdm"
        ;;
        5)
            Install_DesktopEnv i3wm i3 "$(Read_Config P_i3wm)"
            # sed -i 's/i3-sensible-terminal/--no-startup-id termite/g' /home/"${CheckingUsers}"/.config/i3/config  # 更改终端
            DmS="sddm"
        ;;
        6)
            Install_DesktopEnv i3gaps i3 "$(Read_Config P_i3gaps)"
            DmS="lightdm"
        ;;
        7)
            Install_DesktopEnv lxde startlxde "$(Read_Config P_lxde)"
            DmS="lxdm"
        ;;
        8)
            Install_DesktopEnv cinnamon cinnamon-session "$(Read_Config P_cinnamon)"
            DmS="lightdm"
        ;;
        9)
            Install_DesktopEnv mate mate "$(Read_Config P_mate)"
            DmS="lightdm"
        ;;
        10)  
            function openboxManger(){
                local openboxDir openboxTheme
                Desktop_Env_Config "openbox" "openbox-session" #  $1 # Desktop name $2 xinitrc "exec desktop"
                openboxDir="${UserHomeDir}/.config/openbox"
                openboxTheme="${UserHomeDir}/.themes"
                tint2Theme="${UserHomeDir}/.config/tint2/theme"
                mkdir -p "${openboxDir}" &>/dev/null
                rm -rf "${openboxTheme}" &>/dev/null
                rm -rf "${tint2Theme}" &>/dev/null
                cp /etc/xdg/openbox/{rc.xml,menu.xml,autostart,environment} "${openboxDir}" &>/dev/null
                curl -fsSL ${Auins_Local}/Arch_auroot.jpg > "${openboxDir}"/Arch_auroot.jpg
                # openbox-theme
                git clone ${Giturl}/openbox-theme-collections "${openboxTheme}"
                sed -i 's/Clearlooks/Triste-Froly/' "${openboxDir}"/rc.xml
                # .config/openbox/autostart 
                echo -e "tint2 -c ${UserHomeDir}/.config/tint2/theme/minima/minima.tint2rc &\nnitrogen --restore\nfeh --bg-fill ""${openboxDir}""/Arch_auroot.jpg\nxfce4-clipman &" >> "${openboxDir}"/autostart
                # Configure ranager
                curl -fsSL ${Auins_Share}/rangerRc.sh > "$UserHomeDir"/rangerRc.sh
                curl -fsSL ${Auins_Share}/obconf.sh > "$UserHomeDir"/obconf.sh
                echo -e "bash $UserHomeDir/rangerRc.sh ${UserHomeDir} \nsleep 3;" >> "${openboxDir}"/autostart
                echo -e "bash $UserHomeDir/obconf.sh&\nsleep 3;" >> "${openboxDir}"/autostart
                # tint2-theme   tint2 -c /home/"$CheckingUsers"/.config/tint2/theme/minima/minima.tint2rc &
                git clone ${Giturl}/tint2-theme-collections "${tint2Theme}"
                # URxvt-themes
                curl -fsSL ${Giturl}/URxvt-themes/raw/master/smooth-white-blue > /home/"$CheckingUsers"/.Xresources
                chown -R "$CheckingUsers":users "${UserHomeDir}"
                echo -e "sed -i '/obconf\|sed\|rangerRc/d' ${openboxDir}/autostart" >> "${openboxDir}"/autostart
            }
            echo -e "${PSG} ${g}Configuring desktop environment.${h}"
            sleep 1;
            Install_Program "$(Read_Config P_xorgGroup)"
            Install_Program "$(Read_Config P_openbox)"
            Install_Program "$(Read_Config P_gui)"
            sleep 1;
            printf "${PSG} ${g} Using the default Desktop manager:'${b}slim${g}'[Y/*]?${h} %s" "${JHB}"
            read -r slim_ID
            case "$slim_ID" in
                [Yy]*)
                    openboxManger;
                    # /usr/share/slim/themes   /etc/slim.conf }
                    git clone ${Giturl}/slim_themes.git /home/"$CheckingUsers"/slim_themes
                    cp -rf /home/"$CheckingUsers"/slim_themes/themes/* /usr/share/slim/themes  
                    cp -rf /home/"$CheckingUsers"/slim_themes/previews /usr/share/slim/themes  
                    local themesNum numlockNum
                    themesNum=$(sed -n '/current_theme/=' /etc/slim.conf)
                    numlockNum=$(sed -n '/# numlock/=' /etc/slim.conf)
                    sed -i "${numlockNum}s/# numlock/numlock/g" /etc/slim.conf
                    sed -i "${themesNum}s/default/minimal/g" /etc/slim.conf
                    systemctl enable slim
                ;;
                *)
                    Desktop_Manager;
                    openboxManger;
                ;;
            esac
        ;;
        # 11)
        #     Install_DesktopEnv Dwm Dwm "$(Read_Config P_dwm)"
        #     DmS="lightdm"
        # ;;
        *)
            echo -e "${PSR} ${r} Selection error.${h}"    
            Process_Management stop "$0"
        esac 
}
# @桌面环境配置
function Desktop_Env_Config(){
    if [ -e /home/"$CheckingUsers"/.xinitrc ];then
        echo -e "${PSR} ${y}Repeated execution !${h}";sleep 2; 
    else
        xinitrc_file="/etc/X11/xinit/xinitrc"
        startLine=$(sed -n '/twm &/=' $xinitrc_file) #先计算带adc字符串行的行号
        lineAfter=4
        endLine=$(("$startLine" + "$lineAfter"))
        sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec ${2}" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$CheckingUsers"/.xinitrc 
        echo -e "${PSG} ${w}${1} ${g}Desktop environment configuration completed.${h}"  
        sleep 2;   
    fi
}
# @安装字体
function Install_Font(){
    printf "${PSG} ${y}Whether to install the Font. Install[y] No[*]${h} %s" "${JHB}"
    read -r UserInf_Font
    case ${UserInf_Font} in
        [Yy]*)
            Install_Program "$(Read_Config P_fonts)" # install Fonts PKG
        ;;
    esac
}
# @包安装  -- Test
function Install_Program() {
    set +e
    IFS=' ';
    PACKAGES=$(echo "$@" | awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}');
    for VARIABLE in {1..3}
    do
        if ! pacman -Syu --noconfirm --needed "${PACKAGES}"; then
            sleep 2;
        else
            break;
        fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}
# @Install I/O Driver
function Install_Io_Driver(){
    echo -e "${PSG} ${g}Installing Audio driver.${h}"  
    Install_Program "$(Read_Config P_audioDriver)"
    systemctl enable alsa-state.service
    echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
    echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa
    echo -e "${PSG} ${g}Installing input driver.${h}"  
    Install_Program "$(Read_Config P_inputDriver)"
    echo -e "${PSG} ${g}Installing Bluetooth driver.${h}"  
    Install_Program "$(Read_Config P_bluetoothDriver)"
}
# @Install CPU GPU Driver
function Install_Processor_Driver(){
    echo -e "\n$PSG ${g}Install the cpu ucode and driver.$h"
    if [[ "$CPU_Vendor" = 'intel' ]]; then
        Install_Program "$(Read_Config P_intel)"
    elif [[ "$CPU_Vendor" = 'amd' ]]; then
        Install_Program "$(Read_Config P_amd)"
    else
        printf "${PSG} ${y}Please select: Intel[1] AMD[2].${h} %s" "${JHB}"
        read -r DRIVER_GPU_ID
        case $DRIVER_GPU_ID in
            1)
                Install_Program "$(Read_Config P_intel)"
            ;;
            2)
                Install_Program "$(Read_Config P_amd)"
            ;;
        esac
    fi
    lspci -k | grep -A 2 -E "(VGA|3D)"  
    printf "\n${PSG} ${y}Whether to install the Nvidia driver? [y/N]:${h} %s" "${JHB}"
    read -r DRIVER_NVIDIA_ID
    case $DRIVER_NVIDIA_ID in
        [Yy]*)
            Install_Program "$(Read_Config P_nvidia_A)"
            yay -Sy --needed "$(Read_Config P_nvidia_B)"
            systemctl enable optimus-manager.service 
            rm -f /etc/X11/xorg.conf 2&>/dev/null
            rm -f /etc/X11/xorg.conf.d/90-mhwd.conf 2&>/dev/null
            if [ -e "/usr/bin/gdm" ] ; then  # gdm manager
                Install_Program gdm-prime
                sed -i 's/#.*WaylandEnable=false/WaylandEnable=false/'  /etc/gdm/custom.conf
            elif [ -e "/usr/bin/sddm" ] ; then
                sed -i 's/DisplayCommand/# DisplayCommand/' /etc/sddm.conf
                sed -i 's/DisplayStopCommand/# DisplayStopCommand/' /etc/sddm.conf
            fi
        ;;
        [Nn]* )
            bash "$0"
        ;;
        * )
        Process_Management stop "$0"
        ;;
        esac   
}
# @Install/Configure Grub
function Configure_Grub(){
    echo -e "${wg}Installing grub tools.${h}"  #安装grub工具   UEFI与Boot传统模式判断方式：ls /sys/firmware/efi/efivars  
    if ls /sys/firmware/efi/efivars &>/dev/null ; then    # 判断文件是否存在，存在为真，执行EFI，否则执行 Boot
        #-------------------------------------------------------------------------------#   
        echo -e "\n${PSG} ${w}Your startup mode has been detected as ${g}UEFI${h}.\n"  
        Install_Program "$(Read_Config P_uefi_grub)"
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$(Read_Config "Grub_Hostname")" --recheck
        echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
        echo;
        if efibootmgr | grep "$(Read_Config "Grub_Hostname")" &>/dev/null ; then
            echo -e "${g} Grub installed successfully -=> [Archlinux] ${h}"  
            echo -e "${g}     $(efibootmgr | grep "$(Read_Config "Grub_Hostname")")  ${h}\n"  
        else
            echo -e "${r} Grub installed failed ${h}"
            echo -e "${g}     $(efibootmgr)  ${h}\n"
        fi
    else  
        echo -e "\n${PSG} ${w}Your startup mode has been detected as ${g}Boot Legacy${h}.\n"  
        Install_Program "$(Read_Config P_boot_grub)"
        local Boot_Partition
        Boot_Partition=$(Read_Config "Disk" "INFO") 
        
        grub-install --target=i386-pc --recheck "${Boot_Partition}"
        grub-mkconfig -o /boot/grub/grub.cfg
        echo;
        if echo $? &>/dev/null ; then
                echo -e "${g} Grub installed successfully -=> [Archlinux] ${h}\n"  
        else
                echo -e "${r} Grub installed failed ${h}\n"
        fi
    fi
}
# @配置本地化 时区 主机名 语音等
function Configure_System(){
    echo -e "${PSG} ${w}Configure enable Network.${h}"    
    systemctl enable NetworkManager  
    echo -e "${PSG} ${w}Time zone changed to 'Shanghai'. ${h}"  
    ln -sf /usr/share/zoneinfo"$(Read_Config "Area")" /etc/localtime && hwclock --systohc # 将时区更改为"上海" / 生成 /etc/adjtime
    echo -e "${PSG} ${w}Set the hostname 'ArchLinux'. ${h}"
    Read_Config "Hostname" > /etc/hostname
    # 本地化设置 "英文"
    echo -e "${PSG} ${w}Localization language settings. ${h}"
    sed -i 's/#.*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    echo -e "${PSG} ${w}Write 'en_US.UTF-8 UTF-8' To /etc/locale.gen. ${h}"  
    # 本地化设置 "中文"
    sed -i 's/#.*zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen 
    echo -e "${PSG} ${w}Write 'zh_CN.UTF-8 UTF-8' To /etc/locale.gen. ${h}" 
    locale-gen
    echo -e "${PSG} ${w}Configure local language defaults 'en_US.UTF-8'. ${h}"  
    echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 系统语言 "英文" 默认为英文   
}
# @Install/Configure virtualbox-guest-utils / open-vm-tools
function install_virtualization_service(){
    if [[ "$Virtualization" = "vmware" ]]; then
        pacman -Syu --noconfirm --needed open-vm-tools gtkmm3 gtkmm gtk2 xf86-video-vmware xf86-input-vmmouse
        systemctl enable vmtoolsd.service
        systemctl enable vmware-vmblock-fuse.service
        systemctl start vmtoolsd.service
        systemctl start vmware-vmblock-fuse.service
    else
        pacman -Syu --noconfirm --needed virtualbox-guest-utils
        systemctl enable vboxservice.service
        systemctl start vboxservice.service
    fi 
}
# @Archlive版本提醒，1.30天内不提示，2.超过30天提示更新ISO，3.超过60天提示更新ISO并询问继续使用，4.超过90天提示当前ISO不可以，请更新;
function Archiso_Version(){
    Patterns=$(Read_Config "Patterns" "INFO") 
    
    Archiso_Version_Enter="${1}"
    if [ "$Patterns" = "Chroot-OFF" ]; then
            ArchisoVersion=$(grep "archisolabel=" < "$Archiso_Version_Enter" | grep -v grep | awk '{print $3}' | cut -d"_" -f2)
            Archiso_Time=$((($(date +%s ) - $(date +%s -d "${ArchisoVersion}01"))/86400))
            Write_Data "Archiso_Version_check" "no"
            if [[ "$Archiso_Time" -gt 121 ]]; then
                clear;
                echo -e "\n${PSR} ${r}You haven't updated in more than 120 days Archiso !${h}\n${PSR} ${r}Archiso Version: ${ArchisoVersion}01.${h}"
                echo -e "${PSR} ${r}Please update your archiso !!!  After 10 seconds, Exit(Ctrl+c).${h}"
                sleep 10;
                exit 1;
                Write_Data "Archiso_Version_check" "no"
            elif [[ "$Archiso_Time" -ge 91 ]]; then
                clear;
                echo -e "\n${PSY} ${y}You haven't updated in more than 90 days Archiso !${h}\n${PSY} ${y}Archiso Version: ${ArchisoVersion}01.${h}"
                read -rp "Whether to start the script [Y]: " Version_check
                case $Version_check in
                    [Yy]*)
                        sleep 2;
                    ;;
                    *)
                        echo -e "\n${PSY} ${y}Please update Archiso."
                        exit 1;
                    ;;
                esac
                Write_Data "Archiso_Version_check" "no"
            elif [[ "$Archiso_Time" -ge 61 ]]; then
                clear;
                echo -e "\n${PSY} ${y}You haven't updated in more than 60 days Archiso !${h}\n${PSY} ${y}Archiso Version: ${ArchisoVersion}01.${h}"
                Write_Data "Archiso_Version_check" "yes"
                sleep 2;
            elif [[ "$Archiso_Time" -ge 31 ]]; then

                clear;
                echo -e "\n${PSY} ${y}Please update as soon as possible Archiso !${h}\n${PSY} ${y}Archiso Version: ${ArchisoVersion}01.${h}"
                Write_Data "Archiso_Version_check" "yes"
                sleep 2;
            fi 
    fi
    Write_Data "Archiso_Version_check" "yes"
}
# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    case ${PM_Enter_1} in
        start)
            bash "${Share_Dir}/Process_manage.sh" start "${PM_Enter_2}"
        ;;
        restart)
            bash "${Share_Dir}/Process_manage.sh" restart "${PM_Enter_2}"
        ;;
        stop)
            bash "${Share_Dir}/Process_manage.sh" stop "${PM_Enter_2}"
            echo -e "\n\n${wg}---------Script Exit---------${h}"  
        ;;
    esac
}
# Start Script
Script_init_Variable # 脚本初始化变量
Set_Color_Variable   # 颜色
# Detect File and Directory
if [ ! -d "${Local_Dir}" ]; then
    mkdir -p "${Local_Dir}"
fi
if [ ! -d "${Share_Dir}" ]; then
    mkdir -p "${Share_Dir}"
fi
Update_Share         # 下载其他脚本
Script_init          # 脚本初始化
Set_System_Variable  # 新系统配置变量
Auin_Options "${1}"  # 选项功能 auin.sh [--help]
Ethernet INFO        # 网络信息
if [ "${ChrootPatterns}" = "Chroot-ON" ]; then
    ChrootPatterns="${g}Chroot-ON${h}"
else
    ChrootPatterns="${r}Chroot-OFF${h}"
fi
# 
Printf_Info Logos;   # 显示LOGO
printf "\n${PSG} ${y} Please enter[1,2,3..] Exit[Q]${h} %s" "${JHB}"
read -r principal_variable 
case ${principal_variable} in
    1) 
        bash "${Share_Dir}/Mirrorlist.sh"
        bash "${0}"
    ;;
    2)
        echo -e "\n$w:: Checking the currently available network."; sleep 2;
        echo -e "$w:: Ethernet: ${r}${Ethernet_Name}${h}\n$w:: Wifi:   ${r}${Wifi_Name}${h}"
        printf "${PSG} ${y}Query Network: Ethernet[1] Wifi[2] Exit[3]? ${h}%s" "${JHB}"
        read -r wlink 
        case "$wlink" in
            1) 
                Ethernet Conf_Eth
            ;;
            2) 
                Ethernet Conf_wifi
            ;;
            3) 
                bash "${0}"
            ;;
        esac
    ;;
    3)
        Open_SSH;
    ;;
    4)
        Printf_Info input_System_Module;
        printf "${PSG} ${y} Please enter[1,2,21..] Exit[Q] ${h}%s" "${JHB}"
        read -r Tasks
        case ${Tasks} in
            0) # chroot 进入新系统
                Auin_chroot; 
            ;;
            1) #磁盘分区
                bash "${Share_Dir}/Partition.sh" "${Share_Dir}" "${Local_Dir}" 
                sleep 1
                bash "${0}" 
            ;;
            2) # 安装及配置系统文件
                Root_partition=$(Read_Config "Root_partition" "INFO")    # 查 Root_partition
                
                # 如果"$Local_Dir/auin.info" 文件中Boot_partition存在值 则安装系统
                if [ -n "$Root_partition" ]; then 
                    Install_Archlinux
                else
                    echo -e "${PSR} ${r}The partition is not mounted.${h}"; sleep 3;
                    Process_Management restart "$0"
                fi
                sleep 1;echo -e "\n${wg}#======================================================#${h}"
                echo -e "${wg}#::  System components installation completed.         #${h}"            
                echo -e "${wg}#::  Entering chroot mode.                             #${h}"
                echo -e "${wg}#::  Execute in 3 seconds.                             #${h}"
                echo -e "${wg}#::  Later operations are oriented to the new system.  #${h}"
                echo -e "${wg}#======================================================#${h}"
                sleep 3
                echo    # Chroot到新系统中完成基础配置，第一步配置
                cp -rf /etc/pacman.conf /mnt/etc/pacman.conf 
                cp -rf /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
                Auin_chroot;
            ;;
            3) # 进入系统后的配置
                LinuxKernel=$(Read_Config "LinuxKernel" "INFO")
                if [ -n "$LinuxKernel" ]; then 
                    echo;Configure_Grub
                    Configure_System
                    ConfigurePassworld    # 引用：设置密码
                    #---------------------------------------------------------------------------#
                    Install_Program "$(Read_Config P_common)" # install Common tools Package
                    Install_Program "$(Read_Config P_fs)"     # install System File Package
                    Install_Font  # 安装字体
                    echo -e "${ws}#======================================================#${h}" #本区块退出后的提示
                    echo -e "${ws}#::                 Exit in 3/s                        #${h}" 
                    echo -e "${ws}#::  When finished, restart the computer.              #${h}"
                    echo -e "${ws}#::  If there is a problem during the installation     #${h}"
                    echo -e "${ws}#::  please contact me. QQ:2763833502                  #${h}"
                    echo -e "${ws}#======================================================#${h}"
                    sleep 3
                else
                    echo -e "${PSR} ${r}The system is not installed. Exec: 4->2 ${h}";sleep 3;
                    
                    Process_Management restart "$0"
                fi
            ;;
            4) # Installation Desktop. 桌面环境
                ConfigurePassworld    # 引用：设置密码
                # Prompt to install desktop environment
                UserName=$(Read_Config "Users" INFO)
                UserHomeDir="/home/${UserName}"
                if [ -n "$UserName" ]; then 
                    Set_Desktop_Env  # Install Desktop
                    # Prompt to install driver    
                    printf "${PSG} ${y}Whether to install Common Drivers? [y/N]:${h}%s" "${JHB}"
                    read -r CommonDrive
                    case ${CommonDrive} in
                        [Yy]*)
                            Install_Io_Driver  # 安装驱动
                        ;;
                        [Nn]* )
                            Process_Management stop "$0"
                        ;;
                    esac
                else
                    echo -e "${PSR} ${r}The user is not settings.${h}"; sleep 3;
                    Process_Management restart "$0"
                fi
            ;;
            11) # Installation Drive. 驱动, 配置驱动
                Install_Io_Driver   # 安装驱动
                Install_Processor_Driver # CPU GPU驱动安装
            ;;
            22) # Installation VM. open-vm-tools
                echo;install_virtualization_service
                sleep 3; bash "$0"
            ;;
            esac
    ;;
    [Rr]*)
        bash "$0"
    ;;
    [Qq]*)
        Process_Management stop "$0"
    ;;
    [Ss]* )
        bash;
    ;;
    test)
    echo;
    # ConfigurePassworld
    ;;
esac
