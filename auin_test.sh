#!/usr/bin/env bash
# Author/Wechat: Auroot
# Script name：Auins (ArchLinux User Installation Scripts) 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe

echo &>/dev/null
function Script_init_Variable(){
    Version="ArchLinux user installation scripts V4.3.5" 
    Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
    [ "$Auins_Dir" = "/" ] && Auins_Dir=""
    Share_Dir="${Auins_Dir}/share" 
    Local_Dir="${Auins_Dir}/local" 
    Auins_Config="${Local_Dir}/install.conf"  
    Auins_record="${Local_Dir}/auins.info"  
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
function Read_Config(){ 
    # 头部参数 $1 , 地址 $2（如果是查install.conf，可以不用写）（如果是auins.info，必须写INFO）  
    if [[ $2 == "INFO" ]]; then
        local Files="$Auins_record"
    else
        local Files="${Auins_Config}"
    fi 
    grep -w "${1}" < ${Files} | awk -F "=" '{print $2}'; 
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
        echo -e "
${white}          _             _       _     _                     ${suffix}
${green}         / \   _ __ ___| |__   | |   (_)_ __  _   ___  __   ${suffix}
${blue}        / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /    ${suffix}
${yellow}       / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   ${suffix}
${red}      /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\     ${suffix}

${blue}||============================================================|| ${suffix}
${blue}|| Script Name:    ${Version}.                                   ${suffix}
${green}|| Patterns:        ${ChrootPatterns}                           ${suffix}
${green}|| Ethernet:       ${Ethernet_ip:-No_network..} - [${Ethernet_Name:- }]${suffix}
${green}|| WIFI:           ${Wifi_ip:-No_network.} - [${Wifi_Name:-No}] ${suffix}
${green}|| SSH:            ssh $USER@${Ethernet_ip:-IP_Addess.}         ${suffix}
${green}|| SSH:            ssh $USER@${Wifi_ip:-IP_Addess.}             ${suffix}
${green}||============================================================||${suffix}

${outB} ${green}Configure Mirrorlist   [1]${suffix}
${outB} ${green}Configure Network      [2]${suffix}
${outG} ${green}Configure SSH          [3]${suffix}
${outY} ${green}Install System         [4]${suffix}
${outG} ${green}Exit Script            [Q]${suffix}"
}
    # @Auins的帮助文档 Auin_help
    function usage() {
        echo -e "
    usage: ${0##*/} [-h] [-V] command ...
      Options:
        -m --mirror   Automatically configure mirrorlist file and exit.
        -w --cwifi    Connect to a WIFI and exit.
        -s --openssh  Open SSH service (default password: 123456) and exit.
        -vm --virtual Install Vmware/Virtualbox Tools and exit.
        -i --info     View the computer information of script record, file: ./local/auins.info
        -h --help     Show this help message and exit. 
        -V --version  Show the conda version number and exit.
    :: Auins is a script for ArchLinux installation and deployment."
}
    # @Auins版本号，Stript Version
    function Version(){    
        echo -e "${wg}${Version}${suffix}"
        echo -e "${wg}$(grep "archisolabel=" < "$entries" | grep -v grep | awk '{print $3}')${suffix}\n"
    }
    # @首选项 [4] 的列表
    function input_System_Module(){    # print list 4
        echo -e "
\t${white}*** ${red}Install System Module ${white}***${suffix}  
--------------------------------------------
${outY} ${green}   Disk Partition.         ${red}**  ${white}[1]  ${suffix}
${outY} ${green}   Install System Files.   ${red}**  ${white}[2]  ${suffix}
${outY} ${green}   Configurt System.       ${red}**  ${white}[3]  ${suffix}
${outG} ${green}   Installation Desktop.   ${blue}*   ${white}[4] ${suffix}
${outG} ${green}   Installation Drive.     ${blue}*   ${white}[11]${suffix}
${outY} ${green}   Install virtual tools.  ${blue}*   ${white}[22]${suffix}
${outY} ${green}   arch-chroot /mnt.       ${red}**  ${white}[0]  ${suffix}
--------------------------------------------\n" 
}
    # @桌面环境选择列表
    function input_Desktop_env(){
        echo -e "
\t   ${white}***${suffix} ${blue}Install Desktop${suffix} ${white}***${suffix}    
------------------------------------------------
${outB} ${green}   KDE plasma.     ${blue}[1]  ${blue}default: sddm     ${suffix}
${outB} ${green}   Gnome.          ${white}[2]  ${white}default: gdm    ${suffix}
${outB} ${green}   Deepin.         ${blue}[3]  ${blue}default: lightdm  ${suffix}  
${outB} ${green}   Xfce4.          ${white}[4]  ${white}default: lightdm${suffix}
${outB} ${green}   i3wm.           ${blue}[5]  ${blue}default: sddm     ${suffix}
${outB} ${green}   i3gaps.         ${white}[6]  ${white}default: lightdm${suffix}
${outB} ${green}   lxde.           ${blue}[7]  ${blue}default: lxdm     ${suffix}
${outB} ${green}   Cinnamon.       ${white}[8]  ${white}default: lightdm${suffix}
${outB} ${green}   Mate.           ${blue}[9]  ${blue}default: lightdm  ${suffix}
${outB} ${green}   Openbox.        ${blue}[10] ${blue}default: sddm     ${suffix}
------------------------------------------------\n"                       
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
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     
    #-----------------------------#
    # rw='\033[1;41m'  #--红白
    wg='\033[1;42m'  #--白绿
    ws='\033[1;43m'  #--白褐
    # wb='\033[1;44m'  #--白蓝
    # wq='\033[1;45m'  #--白紫
    # wa='\033[1;46m'  #--白青
    # bx='\033[1;4;36m'  #---蓝 下划线
    #-----------------------------#
    # 交互 蓝  红 绿 黄 in_J
    inB=$(echo -e "${blue}-=>${suffix} ")
    # inR=$(echo -e "${red}-=>${suffix} ")
    # inG=$(echo -e "${green}-=>${suffix} ")
    # inY=$(echo -e "${yellow}-=>${suffix} ")
    #-----------------------------
    # 提示 蓝 红 绿 黄
    outB=$(echo -e "${blue} ::==>${suffix}")
    outR=$(echo -e "${red} ::==>${suffix}")
    outG=$(echo -e "${green} ::==>${suffix}")
    outY=$(echo -e "${yellow} ::==>${suffix}")
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
        printf "${outG} ${green} Wifi SSID 'TP-Link...' :${suffix} %s" "${inB}"
        read -r WIFI_SSID
        printf "${outG} ${green} Wifi Password :${suffix} %s" "${inB}"
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
# @开启SSH服务， Start ssh service 
function Open_SSH(){    
    echo -e "\n
${yellow}:: Setting SSH Username / password.              ${suffix}
${USER}:$(Read_Config "Password_live") | chpasswd &>/dev/null 
${green} ---------------------------------                ${suffix}
${green}    $ ssh $USER@${Ethernet_ip:-IP_Addess..}       ${suffix}
${green}    $ ssh $USER@${Wifi_ip:-IP_Addess..}           ${suffix}
${green}    Username --=>  $USER                          ${suffix}
${green}    Password --=>  $(Read_Config "Password_live") ${suffix}
${green} =================================                ${suffix}"
    systemctl start sshd.service 
    netstat -antp | grep sshd 
}
# @设置root密码 用户 
function ConfigurePassworld(){
    local UserName UserID PasswdFile Query Number CheckingUsers CheckingID 
    UserName=$(Read_Config "Users" "INFO")
    UserID=$(Read_Config "UsersID" "INFO")
    if [ "${UserName}" = "" ]; then
        PasswdFile="/etc/passwd"
        for ((Number=1;Number<=50;Number++))  
        do
            Query=$(tail -n "${Number}" "${PasswdFile}" | head -n 1 | cut -d":" -f3)
            if [[ $Query -gt 1000 && $Query -lt 2000 ]]; then
                CheckingUsers=$(grep "$Query" < ${PasswdFile} | cut -d":" -f1)
                CheckingID=$(grep "$Query" < ${PasswdFile} | cut -d":" -f3)
                printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}." "${CheckingUsers}" "${CheckingID}"
                break;
            fi
        done
        if [ "${CheckingUsers}" = "" ]; then
            bash "${Share_Dir}/Useradd.sh" "${Local_Dir}" "${Share_Dir}"
            sleep 1;
        fi
    else
        printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}." "${CheckingUsers}" "${UserID}"
    fi
}
# @安装系统、内核、基础包等，Install system kernel / base...
function Install_Archlinux(){    
    echo -e "${wg}Update the system clock.${suffix}"   # update time
    timedatectl set-ntp true
    sleep 2;
    echo -e "\n${outG} ${green}Install the base packages.${suffix}\n"
    bash "${Share_Dir}/Mirrorlist.sh"
    if [[ $(Read_Config "Linux_kernel") = "linux" ]]; then
        pacstrap -i /mnt linux linux-headers linux-firmware base base-devel networkmanager net-tools vim 
    elif [[ $(Read_Config "Linux_kernel") = "linux-lts" ]]; then
        pacstrap -i /mnt linux-lts linux-firmware base base-devel networkmanager net-tools vim 
    elif [[ $(Read_Config "Linux_kernel") = "linux-zen" ]]; then
        pacstrap -i /mnt linux-zen linux-zen-headers linux-firmware base base-devel networkmanager net-tools vim
    fi
    sleep 2;
    echo -e "\n${outG}  ${green}Configure Fstab File.${suffix}"  
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
echo -e "
----------------------------
${outB} ${green}sddm.            ${white}[1]${suffix}
${outB} ${green}gdm.             ${white}[2]${suffix}
${outB} ${green}lightdm.         ${white}[3]${suffix}  
${outB} ${green}lxdm.            ${white}[4]${suffix} 
${outB} ${green}default.         ${white}[*]${suffix}
============================"
    printf "${outG} ${yellow} Please select Desktop Manager: ${suffix} %s" "${inB}"
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
    
    echo -e "${outG} ${green}Configuring desktop environment.${suffix}"
    sleep 1;
    Install_Program "$(Read_Config P_xorgGroup)"
    Install_Program "$Desktop_Program"
    Install_Program "$(Read_Config P_gui)"
    Desktop_Manager
    Desktop_Env_Config "$Desktop_Name" "$Desktop_Xinit" 
    Write_Data "Desktop_Env" "${Desktop_Name}"
}
# @选择桌面环境
function Set_Desktop_Env(){
    input_Desktop_env
    DESKTOP_ID="0"  
    printf "${outG} ${yellow} Please select desktop:${suffix} %s" "${inB}"
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
            echo -e "${outG} ${green}Configuring desktop environment.${suffix}"
            sleep 1;
            Install_Program "$(Read_Config P_xorgGroup)"
            Install_Program "$(Read_Config P_openbox)"
            Install_Program "$(Read_Config P_gui)"
            sleep 1;
            printf "${outG} ${green} Using the default Desktop manager:'${blue}slim${green}'[Y/*]?${suffix} %s" "${inB}"
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
            echo -e "${outR} ${red} Selection error.${suffix}"    
            Process_Management stop "$0"
        esac 
}
# @configure desktop environment
function Desktop_Env_Config(){
    if [ -e /home/"$CheckingUsers"/.xinitrc ];then
        echo -e "${outR} ${yellow}Repeated execution !${suffix}";sleep 2; 
    else
        xinitrc_file="/etc/X11/xinit/xinitrc"
        startLine=$(sed -n '/twm &/=' $xinitrc_file) 
        lineAfter=4
        endLine=$(("$startLine" + "$lineAfter"))
        sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec ${2}" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$CheckingUsers"/.xinitrc 
        echo -e "${outG} ${white}${1} ${green}Desktop environment configuration completed.${suffix}"  
        sleep 2;   
    fi
}
# @install fonts 
function Install_Font(){
    printf "${outG} ${yellow}Whether to install the Font. Install[y] No[*]${suffix} %s" "${inB}"
    read -r UserInf_Font
    case ${UserInf_Font} in
        [Yy]*)
            Install_Program "$(Read_Config P_fonts)" # install Fonts PKG
        ;;
    esac
}
# @install Programs 
function Install_Program() {
    set +e
    IFS=' ';
    PACKAGES=("$@");
    for VARIABLE in {1..3}
    do
        if ! pacman -Syu --noconfirm --needed ${PACKAGES[@]} ; then
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
    echo -e "${outG} ${green}Installing Audio driver.${suffix}"  
    Install_Program "$(Read_Config P_audioDriver)"
    systemctl enable alsa-state.service
    echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
    echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa
    echo -e "${outG} ${green}Installing input driver.${suffix}"  
    Install_Program "$(Read_Config P_inputDriver)"
    echo -e "${outG} ${green}Installing Bluetooth driver.${suffix}"  
    Install_Program "$(Read_Config P_bluetoothDriver)"
}
# @Install CPU GPU Driver
function Install_Processor_Driver(){
    echo -e "\n${outG} ${green}Install the cpu ucode and driver.${suffix}"
    if [[ "$CPU_Vendor" = 'intel' ]]; then
        Install_Program "$(Read_Config P_intel)"
    elif [[ "$CPU_Vendor" = 'amd' ]]; then
        Install_Program "$(Read_Config P_amd)"
    else
        printf "${outG} ${yellow}Please select: Intel[1] AMD[2].${suffix} %s" "${inB}"
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
    printf "\n${outG} ${yellow}Whether to install the Nvidia driver? [y/N]:${suffix} %s" "${inB}"
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
    echo -e "${wg}Installing grub tools.${suffix}"  
    if ls /sys/firmware/efi/efivars &>/dev/null ; then   
        #-------------------------------------------------------------------------------#   
        echo -e "\n${outG} ${white}Your startup mode has been detected as ${green}UEFI${suffix}.\n"  
        Install_Program "$(Read_Config P_uefi_grub)"
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$(Read_Config "Grub_Hostname")" --recheck
        echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
        echo;
        if efibootmgr | grep "$(Read_Config "Grub_Hostname")" &>/dev/null ; then
            echo -e "${green} Grub installed successfully -=> [Archlinux] ${suffix}"  
            echo -e "${green}     $(efibootmgr | grep "$(Read_Config "Grub_Hostname")")  ${suffix}\n"  
        else
            echo -e "${red} Grub installed failed ${suffix}"
            echo -e "${green}     $(efibootmgr)  ${suffix}\n"
        fi
    else  
        echo -e "\n${outG} ${white}Your startup mode has been detected as ${green}Boot Legacy${suffix}.\n"  
        Install_Program "$(Read_Config P_boot_grub)"
        local Boot_Partition
        Boot_Partition=$(Read_Config "Disk" "INFO") 
        
        grub-install --target=i386-pc --recheck "${Boot_Partition}"
        grub-mkconfig -o /boot/grub/grub.cfg
        echo;
        if echo $? &>/dev/null ; then
                echo -e "${green} Grub installed successfully -=> [Archlinux] ${suffix}\n"  
        else
                echo -e "${red} Grub installed failed ${suffix}\n"
        fi
    fi
}
# @配置本地化 时区 主机名 语音等
function Configure_System(){
    echo -e "${outG} ${white}Configure enable Network.${suffix}"    
    systemctl enable NetworkManager  
    echo -e "${outG} ${white}Time zone changed to 'Shanghai'. ${suffix}"  
    ln -sf /usr/share/zoneinfo"$(Read_Config "Area")" /etc/localtime && hwclock --systohc # 将时区更改为"上海" / 生成 /etc/adjtime
    echo -e "${outG} ${white}Set the hostname 'ArchLinux'. ${suffix}"
    Read_Config "Hostname" > /etc/hostname
    echo -e "${outG} ${white}Localization language settings. ${suffix}"
    sed -i 's/#.*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    echo -e "${outG} ${white}Write 'en_US.UTF-8 UTF-8' To /etc/locale.gen. ${suffix}"  
    sed -i 's/#.*zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen 
    echo -e "${outG} ${white}Write 'zh_CN.UTF-8 UTF-8' To /etc/locale.gen. ${suffix}" 
    locale-gen
    echo -e "${outG} ${white}Configure local language defaults 'en_US.UTF-8'. ${suffix}"  
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
# @Archlive update tips 
function Archiso_Version(){
    Patterns=$(Read_Config "Patterns" "INFO") 
    Archiso_Version_Enter="${1}"
    if [ "$Patterns" = "Chroot-OFF" ]; then
            ArchisoVersion=$(grep "archisolabel=" < "$Archiso_Version_Enter" | grep -v grep | awk '{print $3}' | cut -d"_" -f2)
            Archiso_Time=$((($(date +%s ) - $(date +%s -d "${ArchisoVersion}01"))/86400))
            Write_Data "Archiso_Version_check" "no"
            if [[ "$Archiso_Time" -gt 121 ]]; then
                clear;
                echo -e "\n${outR} ${red}You haven't updated in more than 120 days Archiso !${suffix}\n${outR} ${red}Archiso Version: ${ArchisoVersion}01.${suffix}"
                echo -e "${outR} ${red}Please update your archiso !!!  After 10 seconds, Exit(Ctrl+c).${suffix}"
                sleep 10;
                exit 1;
                Write_Data "Archiso_Version_check" "no"
            elif [[ "$Archiso_Time" -ge 91 ]]; then
                clear;
                echo -e "\n${outY} ${yellow}You haven't updated in more than 90 days Archiso !${suffix}\n${outY} ${yellow}Archiso Version: ${ArchisoVersion}01.${suffix}"
                read -rp "Whether to start the script [Y]: " Version_check
                case $Version_check in
                    [Yy]*)
                        sleep 2;
                    ;;
                    *)
                        echo -e "\n${outY} ${yellow}Please update Archiso."
                        exit 1;
                    ;;
                esac
                Write_Data "Archiso_Version_check" "no"
            elif [[ "$Archiso_Time" -ge 61 ]]; then
                clear;
                echo -e "\n${outY} ${yellow}You haven't updated in more than 60 days Archiso !${suffix}\n${outY} ${yellow}Archiso Version: ${ArchisoVersion}01.${suffix}"
                Write_Data "Archiso_Version_check" "yes"
                sleep 2;
            elif [[ "$Archiso_Time" -ge 31 ]]; then

                clear;
                echo -e "\n${outY} ${yellow}Please update as soon as possible Archiso !${suffix}\n${outY} ${yellow}Archiso Version: ${ArchisoVersion}01.${suffix}"
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
            echo -e "\n\n${wg}---------Script Exit---------${suffix}"  
        ;;
    esac
}

# Start Script
Script_init_Variable 
Set_Color_Variable   
# Detect File and Directory
if [ ! -d "${Local_Dir}" ]; then
    mkdir -p "${Local_Dir}"
fi
if [ ! -d "${Share_Dir}" ]; then
    mkdir -p "${Share_Dir}"
fi

Update_Share        
Script_init         
Set_System_Variable  
Auin_Options "${1}"  
Ethernet INFO       
if [ "${ChrootPatterns}" = "Chroot-ON" ]; then
    ChrootPatterns="${green}Chroot-ON${suffix}"
else
    ChrootPatterns="${red}Chroot-OFF${suffix}"
fi
# 
Printf_Info Logos;   
printf "\n${outG} ${yellow} Please enter[1,2,3..] Exit[Q]${suffix} %s" "${inB}"
read -r principal_variable 
case ${principal_variable} in
    1) 
        bash "${Share_Dir}/Mirrorlist.sh"
        bash "${0}"
    ;;
    2)
        echo -e "\n${white}:: Checking the currently available network."; sleep 2;
        echo -e "${white}:: Ethernet: ${red}${Ethernet_Name}${suffix}\n${white}:: Wifi:   ${red}${Wifi_Name}${suffix}"
        printf "${outG} ${yellow}Query Network: Ethernet[1] Wifi[2] Exit[3]? ${suffix}%s" "${inB}"
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
        printf "${outG} ${yellow} Please enter[1,2,21..] Exit[Q] ${suffix}%s" "${inB}"
        read -r Tasks
        case ${Tasks} in
            0) # chroot 
                Auin_chroot; 
            ;;
            1) #磁盘分区
                bash "${Share_Dir}/Partition.sh" "${Share_Dir}" "${Local_Dir}" 
                sleep 1
                bash "${0}" 
            ;;
            2) # 安装及配置系统文件
                Root_partition=$(Read_Config "Root_partition" "INFO")  
                if [ -n "$Root_partition" ]; then 
                    Install_Archlinux
                else
                    echo -e "${outR} ${red}The partition is not mounted.${suffix}"; sleep 3;
                    Process_Management restart "$0"
                fi
                sleep 1; echo -e "\n
${wg}#======================================================#${suffix}
${wg}#::  System components installation completed.         #${suffix}          
${wg}#::  Entering chroot mode.                             #${suffix}
${wg}#::  Execute in 3 seconds.                             #${suffix}
${wg}#::  Later operations are oriented to the new system.  #${suffix}
${wg}#======================================================#${suffix}"
                sleep 3
                echo    # Chroot到新系统中完成基础配置
                cp -rf /etc/pacman.conf /mnt/etc/pacman.conf 
                cp -rf /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist
                Auin_chroot;
            ;;
            3) 
                LinuxKernel=$(Read_Config "LinuxKernel" "INFO")
                if [ -n "$LinuxKernel" ]; then 
                    echo;Configure_Grub
                    Configure_System
                    ConfigurePassworld 
                    #---------------------------------------------------------------------------#
                    Install_Program "$(Read_Config P_common)"
                    Install_Program "$(Read_Config P_fs)" 
                    Install_Font  
echo -e "
${ws}#======================================================#${suffix}
${ws}#::                 Exit in 3/s                        #${suffix}
${ws}#::  When finished, restart the computer.              #${suffix}
${ws}#::  If there is a problem during the installation     #${suffix}
${ws}#::  please contact me. QQ:2763833502                  #${suffix}
${ws}#======================================================#${suffix}"
                    sleep 3
                else
                    echo -e "${outR} ${red}The system is not installed. Exec: 4->2 ${suffix}";sleep 3;
                    
                    Process_Management restart "$0"
                fi
            ;;
            4)
                ConfigurePassworld    
                UserName=$(Read_Config "Users" INFO)
                UserHomeDir="/home/${UserName}"
                if [ -n "$UserName" ]; then 
                    Set_Desktop_Env 
                    printf "${outG} ${yellow}Whether to install Common Drivers? [y/N]:${suffix}%s" "${inB}"
                    read -r CommonDrive
                    case ${CommonDrive} in
                        [Yy]*)
                            Install_Io_Driver  
                        ;;
                        [Nn]* )
                            Process_Management stop "$0"
                        ;;
                    esac
                else
                    echo -e "${outR} ${red}The user is not settings.${suffix}"; sleep 3;
                    Process_Management restart "$0"
                fi
            ;;
            11) 
                Install_Io_Driver 
                Install_Processor_Driver 
            ;;
            22) 
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
esac