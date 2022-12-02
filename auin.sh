#!/usr/bin/env bash
# Author/Wechat: Auroot
# Script name: Auins (ArchLinux User Installation Scripts) 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
# set -eu
echo &>/dev/null

# @ script source
# auroot  |  gitee  |  github  |  test
SCRIPTS_SOURCE="test"

# @待解决的问题 
: << EOF
    - [ ] 检查reflector报错的问题(不影响正常使用);
    - [ ] 新增: 快照备份软件(timeshift);
EOF
# @可能有用的文件
# /proc/cmdline

# sed -i.bak 's/^aaa=yes/aaa=no/' [file] # 替换并备份
# @脚本初始化
function Script_Variable_init(){
    Version="ArchLinux User Install Scripts v4.5.3" 
    Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
    [ "$Auins_Dir" = "/" ] && Auins_Dir=""
    Share_Dir="${Auins_Dir}/share" 
    Local_Dir="${Auins_Dir}/local" 
    Auins_Config="${Local_Dir}/profile.conf"  
    Auins_record="${Local_Dir}/auins.info"  
    Mirrorlist_Script="${Share_Dir}/Mirrorlist_Manage.sh"
    Users_Script="${Share_Dir}/Users_Manage.sh"
    Partition_Script="${Share_Dir}/Partition_Manage.sh"
    Process_Script="${Share_Dir}/Process_Manage.sh"
    System_Root="/mnt"
    Livecd_Version_Route="/run/archiso/airootfs/version"
    # entries_Boot="/sys/firmware/efi/efivars"  # discern: UEFI
    if [ ! -d "${Local_Dir}" ]; then mkdir -p "${Local_Dir}"; fi
    if [ ! -d "${Share_Dir}" ]; then mkdir -p "${Share_Dir}"; fi
}
# @输出所需信息 
function Printf_Info(){
    function logos(){
        clear;  echo -e "
${white}        _             _       _     _                     ${suffix}
${green}       / \   _ __ ___| |__   | |   (_)_ __  _   ___  __   ${suffix}
${blue}      / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /    ${suffix}
${yellow}     / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   ${suffix}
${red}    /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\     ${suffix}
${red}----------------------------------------------------------${suffix}
${green} Script Name: ${Version}.${suffix}
${green} Boot Mode:   ${white}[${blue}${Boot_Type}${white}] ${red}- ${white}[${blue}${Disk_Type}${white}]${suffix}      
${green} Patterns:    ${ChrootPatterns_Print} ${red}-${suffix} ${StartPatterns}${suffix}
${green} Ethernet:    ${blue}${Local_Ethernet_IP:-No network.} ${red}- ${white}[${green}${Ethernet_Name:-No}${white}]${suffix}
${green} WIFI:        ${blue}${Local_Wifi_IP:-No network.} ${red}- ${white}[${green}${Wifi_Name:-No}${white}] ${suffix}
${green} SSH:         ${white}ssh ${blue}$USER@${blue}${Local_Ethernet_IP:-${Local_Wifi_IP}}${suffix}
${green} CPU Info:    ${blue}${CPU_Name}${suffix}  
${red}==========================================================${suffix}"   
    }
    function NormalHomeList(){
        echo -e "
${outB} \t${green}Configure Mirrorlist     ${white}[${blue}1${white}]${suffix}
${outB} \t${green}Configure Network        ${white}[${blue}2${white}]${suffix}
${outG} \t${green}Configure SSH            ${white}[${blue}3${white}]${suffix}
${outY} \t${green}Installation Desktop.    ${white}[${blue}4${white}]${suffix}
${outY} \t${green}Installation Drive.      ${white}[${blue}5${white}]${suffix}
${outY} \t${green}Install virtual tools.   ${white}[${blue}6${white}]${suffix}
${outY} \t${green}Delete scripts & caches. ${white}[${red}D${white}] ${suffix}
${outG} \t${green}Exit Script              ${white}[${red}Q${white}] ${suffix}"   
    }
    function LivecdHomeList(){ 
        echo -e "
${outB} \t${green}Configure Mirrorlist   ${white}[${blue}1${white}]${suffix}
${outB} \t${green}Configure Network      ${white}[${blue}2${white}]${suffix}
${outG} \t${green}Configure SSH          ${white}[${blue}3${white}]${suffix}
${outY} \t${green}Install System         ${white}[${blue}4${white}]${suffix}
${outG} \t${green}Exit Script            ${white}[${red}Q${white}] ${suffix}"   
    }
    function Livecd_System_Module_List(){
        echo -e "
\n\t${white}*** ${red}Install System Module ${white}***${suffix}  
--------------------------------------------
${outY} ${green}   Disk Partition.        ${red}**  ${white}[1]  ${suffix}
${outY} ${green}   Install System Files.  ${red}**  ${white}[2]  ${suffix}
${outY} ${green}   Configurt System.      ${red}**  ${white}[3]  ${suffix}
${outG} ${green}   Installation Desktop.  ${blue}*   ${white}[4]  ${suffix}
${outG} ${green}   Installation Drive.    ${blue}*   ${white}[11] ${suffix}
${outY} ${green}   Install virtual tools. ${blue}*   ${white}[22] ${suffix}" 
    }
    function DesktopEnvList(){
        echo -e "
\n\t   ${white}***${suffix} ${blue}Install Desktop${suffix} ${white}***${suffix}    
------------------------------------------------
${outB} ${green}   KDE plasma.      ${blue}[1]   ${blue}  default: sddm     ${suffix}
${outB} ${green}   Gnome.           ${white}[2]  ${white}   default: gdm      ${suffix}
${outB} ${green}   Deepin.          ${blue}[3]   ${blue}  default: lightdm  ${suffix}  
${outB} ${green}   Xfce4.           ${white}[4]  ${white}   default: lightdm  ${suffix}
${outB} ${green}   i3wm.            ${blue}[5]   ${blue}  default: sddm     ${suffix}
${outB} ${green}   lxde.            ${blue}[6]   ${blue}  default: lxdm     ${suffix}
${outB} ${green}   Cinnamon.        ${white}[7]  ${white}   default: lightdm  ${suffix}
${outB} ${green}   Mate.            ${blue}[8]   ${blue}  default: lightdm  ${suffix}
${outB} ${green}   Plasma_Wayland.  ${blue}[9]   ${blue}  default: sddm     ${suffix}
${outB} ${green}   Openbox.         ${blue}[10]  ${blue}  default: sddm     ${suffix}
------------------------------------------------\n"  
    }
    function DesktopManagerList(){
        echo -e "
----------------------------
${outB} ${green}sddm.            ${white}[1]${suffix}
${outB} ${green}gdm.             ${white}[2]${suffix}
${outB} ${green}lightdm.         ${white}[3]${suffix}  
${outB} ${green}lxdm.            ${white}[4]${suffix} 
${outB} ${green}default.         ${white}[*]${suffix}
============================"
    }
    function InstallSystemInfo(){
        sleep 1; echo -e "\n
${wg}#======================================================#${suffix}
${wg}#::  System components installation completed.         #${suffix}
${wg}#::  Entering chroot mode.                             #${suffix}
${wg}#::  Execute in 3 seconds.                             #${suffix}
${wg}#::  Later operations are oriented to the new system.  #${suffix}
${wg}#======================================================#${suffix}"
    }
    function ConfigSystemInfo(){
        echo -e "
${ws}#======================================================#${suffix}
${ws}#::                 Exit in 3/s                        #${suffix}
${ws}#::  When finished, restart the computer.              #${suffix}
${ws}#::  If there is a problem during the installation     #${suffix}
${ws}#::  please contact me. QQ:2763833502                  #${suffix}
${ws}#======================================================#${suffix}"
    }
    function usage() {
        echo -e "
usage: ${0##*/} [-h] [-V] command ...
    Options:
    -m --mirror   Automatically configure mirrorlist file and exit.
    -w --cwifi    Connect to a WIFI and exit.
    -s --openssh  Open SSH service (default password: 123456) and exit.
    -vm --virtual Install Vmware/Virtualbox Tools and exit.
    -ec --conf    Edit (./local/profile.conf), Command(vim).
         -vc      View (profile.conf).
        --info    View (auins.info).
         -ds      Delete scripts and other caches.       
    -h --help     Show this help message and exit. 
    -v --version  Show the conda version number and exit.
:: Auins is a script for ArchLinux installation and deployment. \n"
    }
    function version(){    
        echo -e "
${wg}${Version}${suffix}
Copyright (C) 2022 Auroot.
URL GitHub: https://github.com/Auroots/Auins
URL Gitee : https://gitee.com/auroot/Auins\n"
    }     
    case ${1} in
        "version") version ;; # Script版本信息
        "usage"  ) usage   ;; # Auins的帮助文档 Auin_help
        "logos"  ) logos   ;; # Script首页信息
        "LivecdHomeList" ) LivecdHomeList ;; # LiveCD环境下，首页会显示的列表
        "NormalHomeList" ) NormalHomeList ;; # 正常(Normal)环境下，首页会显示的列表
        "DesktopEnvList" ) DesktopEnvList ;; # 桌面环境的选择列表
        "DesktopManagerList") DesktopManagerList ;; # 桌面管理器的选择列表
        "Livecd_System_Module_List" ) Livecd_System_Module_List;; # 首选项 [4] 的列表
        "InstallSystemInfo"  ) InstallSystemInfo ;; # 系统安装成功, 直奔加入chroot的提示信息
        "ConfigSystemInfo"     ) ConfigSystemInfo    ;; # 完成系统配置成功, 可重启的提示信息
    esac
}
# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
function Config_File_Manage(){ 
    local format=" = "; parameter="$3"; content="$4";
    case "$1" in
        INFO) local Files="$Auins_record" ;;
        CONF) local Files="$Auins_Config" ;;
    esac
    case "$2" in
        Read )   grep -w "$parameter" < "$Files" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' ;;
        Write) 
                List_row=$(grep -nw "$parameter" < $Files | awk -F ":" '{print $1}';)
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" $Files 2>/dev/null \
                        ||  case $Normals in [Yy]*) 
                                echo -e "\n${out_ERROR} ${white}You don't have permission.${suffix}"
                                echo -e "${out_WARNING} ${white}Please use ${yellow}\"command: sudo\"${white} or ${yellow}\"user: root\"${white} to execute.${suffix}\n"
                                exit 4;
                            esac
                fi
    esac 
}
# @install Programs 安装包
function Install_Program() {
    # arch-chroot ${MNT_DIR} bash -c "$COMMAND"
    set +e
    IFS=' '; PACKAGES=("$@");
    for VARIABLE in {1..3}
    do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        if ! bash -c "$COMMAND" ; then break; else sleep 3; break; fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}
# @脚本自检
function Script_init(){
    # Read Profile.conf
    CONF_Hostname=$(Config_File_Manage CONF Read Hostname)
    CONF_Password_SSH=$(Config_File_Manage CONF Read "Password_SSH")
    CONF_Service_SSH=$(Config_File_Manage CONF Read "Service_SSH")
    # Detect CPU
    CPU_Name=$(head -n 5 /proc/cpuinfo | grep "model name" | awk -F ": " '{print $2}')
    if lscpu | grep GenuineIntel &>/dev/null  ; then CPU_Vendor="intel";
    elif lscpu | grep AuthenticAMD &>/dev/null; then CPU_Vendor="amd";
    fi
    Config_File_Manage INFO Write CPU_Name "$CPU_Name"
    Config_File_Manage INFO Write CPU_Vendor "$CPU_Vendor"
    # Detect Host_Environment
    if   lspci | grep -i virtualbox &>/dev/null; then Host_Environment="virtualbox";
    elif lspci | grep -i vmware &>/dev/null    ; then Host_Environment="vmware"; 
    else Host_Environment="Computer";
    fi
    Config_File_Manage INFO Write Host_Environment "$Host_Environment";
    # 判断当前模式
    if [ -e /local/Chroot ]; then  ChrootPatterns="Chroot-ON"; else ChrootPatterns="Chroot-OFF"; fi
    Config_File_Manage INFO Write Patterns "$ChrootPatterns";
    
    # Detect boot   
    if [ -d /sys/firmware/efi ]; then
        Boot_Type="UEFI" Disk_Type="GPT"
    else
        Boot_Type="BIOS" Disk_Type="MBR"
    fi
    Config_File_Manage INFO Write Boot_Type ${Boot_Type}
    Config_File_Manage INFO Write Disk_Type ${Disk_Type}
    INFO_Boot_way=$(Config_File_Manage INFO Read "Boot_Type")
    
    # 本地化地区
    Timezone=$(Config_File_Manage INFO Read "Timezone")
    if [ -z  "$Timezone" ] ; then
        API=$(curl -fsSL --fail https://ipapi.co/json)
        Timezone=$(echo "$API" | grep -w "timezone" | awk '{print $2}' | sed 's#",##' | sed 's#"##') && Config_File_Manage INFO Write Timezone "$Timezone";
        Public_IP=$(echo "$API" | grep -w "ip" | awk '{print $2}' | sed 's#",##' | sed 's#"##')      && Config_File_Manage INFO Write Public_IP "$Public_IP";
        Country=$(echo "$API" | grep -w "country" | awk '{print $2}' | sed 's#",##' | sed 's#"##')   && Config_File_Manage INFO Write Country "$Country";
        Country_Name=$(echo "$API" | grep -w "country_name" | awk '{print $2}' | sed 's#",##' | sed 's#"##')  && Config_File_Manage INFO Write Country_Name "$Country_Name";
    fi
    ln -sf /usr/share/zoneinfo/"$Timezone" /etc/localtime &>/dev/null && hwclock --systohc
    CONF_Archiso_Version_check=$(Config_File_Manage CONF Read "Archiso_Version_check");
    case "$ChrootPatterns" in  
        Chroot-OFF) 
            # 根据配置文件, 判断是否开启SSH远程服务, Chroot下不执行
            case $CONF_Service_SSH in [Yy]*) Open_SSH; sleep 5; esac
            # Detect Archiso Version 检查 LiveCD 版本 并提醒更新
            # entries_livecd="/run/archiso/airootfs"  # discern: liveCD
            if [ -d /run/archiso/airootfs ]; then 
                # Home list (LiveCD_Model \ Normal_Model)
                echo "Yes" > ${Local_Dir}/LiveCD 2> /dev/null
                case $CONF_Archiso_Version_check in [Yy]*) Archiso_Version_Testing "$Livecd_Version_Route"; esac
            else 
                Normals="yes"; 
                CONF_Archiso_Version_check="no"
            fi
    esac
}
# @下载所需的脚本模块
function Update_Share(){     
    # 根据配置文件选择源, 将其作为脚本的下载源 Module URL: Default settings
    case ${SCRIPTS_SOURCE} in
    gitee ) 
        source="https://gitee.com/auroot/Auins/raw/master" ;;
    github)  
        source="https://raw.githubusercontent.com/Auroots/Auins/main";;
    auroot)
        source="http://auins.auroot.cn" ;;
    test)
        source="http://test.auroot.cn" 
    esac
    Source_Share="${source}/share"
    Source_Local="${source}/local"
    
    if [ ! -e "$Mirrorlist_Script" ]; then curl -fsSL "$Source_Share/Mirrorlist_Manage.sh" > "$Mirrorlist_Script"  && chmod +x "$Mirrorlist_Script"; fi
    if [ ! -e "$Users_Script"    ]; then curl -fsSL "$Source_Share/Users_Manage.sh"    > "$Users_Script"     && chmod +x "$Users_Script"; fi
    if [ ! -e "$Partition_Script"  ]; then curl -fsSL "$Source_Share/Partition_Manage.sh"  > "$Partition_Script"   && chmod +x "$Partition_Script"; fi
    if [ ! -e "$Process_Script"    ]; then curl -fsSL "$Source_Share/Process_Manage.sh" > "$Process_Script" && chmod +x "$Process_Script"; fi
    # if [ ! -e "${Share_Dir}/Edit_Database.sh" ]; then  curl -fsSL "$Source_Share/Edit_Database.sh" > "${Share_Dir}/Edit_Database.sh" && chmod +x "${Share_Dir}/Edit_Database.sh"; fi
    if [ ! -e "${Auins_Config}" ]; then curl -fsSL "${Source_Local}/profile.conf" > "$Auins_Config"; fi
    if [ ! -e "${Auins_record}" ]; then curl -fsSL "${Source_Local}/auins.info" > "$Auins_record"; fi
}
# @该死的颜色
function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     
    #-----------------------------#
    # rw='\033[1;41m'  #--红白
    wg='\033[1;42m'; ws='\033[1;43m'      #白绿 \ 白褐
    #wb='\033[1;44m'; wq='\033[1;45m'    #白蓝 \ 白紫
    # wa='\033[1;46m'; bx='\033[1;4;36m'  #白青 \ 蓝 下划线
    #-----------------------------#
    # 交互: 蓝  红 \ 绿 黄
    inB=$(echo -e "${blue}-=>${suffix} "); # inR=$(echo -e "${red}-=>${suffix} ")
    # inG=$(echo -e "${green}-=>${suffix} "); inY=$(echo -e "${yellow}-=>${suffix} ")
    #-----------------------------
    # 提示 蓝 红 绿 黄
    outB="${white}::${blue} =>${suffix}"; # outR="${white}::${red} =>${suffix}"
    outG="${white}::${green} =>${suffix}"; outY="${white}::${yellow} =>${suffix}"

    out_SKIP="${white}::${yellow} [Skip] =>${suffix}"
    out_WARNING="${white}::${yellow} [Warn] =>${suffix}"
    out_EXEC="${white}::${blue} [Exec] =>${suffix}"
    out_WELL="${white}::${green} [Well] =>${suffix}"
    out_ERROR="${white}::${red} [Error] =>${suffix}"
}
# @网络部分集合
function Network(){
    # @获取本机IP地址，并储存到$Auins_record， Network Variable
    function ethernet_info(){    
        local Info_Nic
        for  ((Cycle_number=3;Cycle_number<=10;Cycle_number++)); do
            Info_Nic=$(cut -d":" -f1 /proc/net/dev | sed -n "$Cycle_number",1p | sed 's/^[ ]*//g')
            if echo "$Info_Nic" | grep "en" &>/dev/null ; then 
                Ethernet_Name="$Info_Nic"
                Local_Ethernet_IP=$(ip route list | grep "${Ethernet_Name}" | cut -d" " -f9 | sed -n '2,1p')
                Config_File_Manage INFO Write Local_Ethernet_IP "${Local_Ethernet_IP:-Not}"; break;
            elif echo "$Info_Nic" | grep "wl" &>/dev/null ; then
                Wifi_Name="$Info_Nic"
                Local_Wifi_IP=$(ip route list | grep "${Wifi_Name}" | cut -d" " -f9 | sed -n '2,1p') 
                Config_File_Manage INFO Write Local_Wifi_IP "${Local_Wifi_IP:-Not}"; break;
            fi
        done    
    }
    # @配置WIFI，Configure WIFI
    function configure_wifi() {
        printf "${outG} ${green} Wifi SSID 'TP-Link...' :${suffix} %s" "$inB"
        read -r WIFI_SSID
        printf "${outG} ${green} Wifi Password :${suffix} %s" "$inB"
        read -r WIFI_PASSWD
        iwctl --passphrase "$WIFI_PASSWD" station "$Wifi_Name" connect "$WIFI_SSID"
        sleep 2; ip address show "${Wifi_Name}"
        if ! ping -c 3 gitee.com; then
            echo -e "${out_ERROR} ${red}Network ping check failed. Cannot continue.${suffix}"
            Process_Management stop "$0"
        fi
    }
    # @配置有线网络，Configure Ethernet.
    function configure_ethernet(){
        echo ":: One moment please............"
        ip link set "${Ethernet_Name}" up
        ip address show "${Ethernet_Name}"
        ping -c 3 gitee.com
        sleep 1;
    }
    # @配置网络
    function configure_all(){
        echo -e "\n${white}:: Checking the currently available network."; sleep 2;
        echo -e "${white}:: Ethernet: ${red}${Ethernet_Name}${suffix}\n${white}:: Wifi:   ${red}${Wifi_Name}${suffix}"
        printf "${outG} ${yellow}Query Network: Ethernet[1] Wifi[2] Exit[3]? ${suffix}%s" "$inB"
        read -r wlink 
        case "$wlink" in
            1 ) configure_ethernet ;;
            2 ) configure_wifi ;;
            3 ) bash "${0}" ;;
        esac
    }
    # Ethernet
    case ${1} in
        INFO     ) ethernet_info ;;
        Conf_wifi) configure_wifi ;;
        Conf_Eth ) configure_ethernet ;;
        Conf_all ) configure_all
    esac
}
# @开启SSH服务， Start ssh service 
function Open_SSH(){   
    Network INFO; 
    echo "${USER}:${CONF_Password_SSH}" | chpasswd &>/dev/null 
    echo -e "\n
${yellow}:: Setting SSH Username / password.        ${suffix}
${green} ---------------------------------          ${suffix}
${green}    $ ssh $USER@${Local_Ethernet_IP:-${Local_Wifi_IP}}  ${suffix}
${green}    Username --=>  $USER                    ${suffix}
${green}    Password --=>  $CONF_Password_SSH       ${suffix}
${green} =================================          ${suffix}"
    systemctl start sshd.service 
    netcap | grep sshd 
}
# @设置root密码 用户 
function ConfigurePassworld(){
    local PasswdFile Number
    export INFO_UserName UsersID CheckingID CheckingUsers
    INFO_UserName=$(Config_File_Manage INFO Read "Users")
    CheckingUsers=""
    if [ -z "$INFO_UserName" ]; then
        PasswdFile="/etc/passwd"
        for Number in {1..30}; do  
            Query=$(tail -n "${Number}" "${PasswdFile}" | head -n 1 | cut -d":" -f3)
            if [ "$Query" -gt 999 ] && [ "$Query" -lt 1050 ]; then
                CheckingID=$(grep "$Query" < ${PasswdFile} | cut -d":" -f3)
                CheckingUsers=$(id -un "$CheckingID" 2> /dev/null)
                Config_File_Manage INFO Write Users "$CheckingUsers"
                Config_File_Manage INFO Write UsersID "$CheckingID"
                break;
            fi
        done
        if [ -z "$CheckingUsers" ] ; then
            bash "$Users_Script" "$Auins_Config" "$Auins_record"; sleep 1;
        fi
    fi
}
# @安装系统、内核、基础包等，Install system kernel / base...
function Install_Archlinux(){    
    CONF_Linux_kernel=$(Config_File_Manage CONF Read "Linux_kernel")
    echo -e "\n${out_EXEC} ${green}Update the system clock.${suffix}"   # update time
    timedatectl set-ntp true
    echo -e "${out_EXEC} ${green}Install the Kernel base packages.${suffix}\n" 
    sleep 2;
    # bash "$Mirrorlist_Script" "${Auins_Config}" "${Auins_record}"
    case "$CONF_Linux_kernel" in 
        linux    ) pacstrap "$System_Root" base base-devel linux-firmware vim unzip linux linux-headers ;;
        linux-lts) pacstrap "$System_Root" base base-devel linux-firmware vim unzip linux-lts ;; 
        linux-zen) pacstrap "$System_Root" base base-devel linux-firmware vim unzip linux-zen linux-zen-headers ;;
    esac
    sleep 2; echo -e "\n${out_EXEC} ${green}Configure Fstab File.${suffix}"  
    genfstab -U $System_Root >> $System_Root/etc/fstab  

    LinuxKernel=$(arch-chroot $System_Root /usr/bin/uname -a | /usr/bin/cut -d"#" -f1  | awk -F " " '{print $3}')
    Config_File_Manage INFO Write LinuxKernel "$LinuxKernel";
    cp -rf "${Local_Dir}" "$System_Root" 
    cp -rf "${Share_Dir}" "$System_Root" 
    cat "$0" > $System_Root/auin.sh  && chmod +x $System_Root/auin.sh 
    touch $System_Root/local/Chroot && echo "Chroot=ON" > $System_Root/local/Chroot
}
# @Chroot -> $System_Root
function Auin_chroot(){    
    cat "$0" > $System_Root/auin.sh  && chmod +x $System_Root/auin.sh
    cp -rf "$Share_Dir" $System_Root 2> /dev/null
    cp -rf "$Local_Dir" $System_Root 2> /dev/null
    rm -rf $System_Root/local/LiveCD 2> /dev/null
    echo "No" > $System_Root/local/LiveCD_OFF 2> /dev/null
    arch-chroot $System_Root /bin/bash -c "/auin.sh"
}
# @选择桌面环境
function Set_Desktop_Env(){
    Printf_Info DesktopEnvList;
    DESKTOP_ID="0"  
    printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n" "${CheckingUsers:-$INFO_UserName}" "${CheckingID:-$INFO_UsersID}"
    printf "${outG} ${yellow} Please select desktop:${suffix} %s" "$inB"
    read -r DESKTOP_ID
    case ${DESKTOP_ID} in
        1)  Default_DM="sddm";    Install_DesktopEnv plasma startkde      "$(Config_File_Manage CONF Read "PGK_Plasma")";;
        2)  Default_DM="gdm";     Install_DesktopEnv gnome  gnome-session "$(Config_File_Manage CONF Read "PGK_Gnome")";;
        3)  Default_DM="lightdm"; Install_DesktopEnv deepin startdde      "$(Config_File_Manage CONF Read "PGK_Deepin")";;
        4)  Default_DM="lightdm"; Install_DesktopEnv xfce4  startxfce4    "$(Config_File_Manage CONF Read "PGK_Xfce4")";;
        5)  Default_DM="sddm";    Install_DesktopEnv i3wm   i3            "$(Config_File_Manage CONF Read "PGK_I3wm")" ;;
        6)  Default_DM="lxdm";    Install_DesktopEnv lxde   startlxde     "$(Config_File_Manage CONF Read "PGK_Lxde")" ;;
        7)  Default_DM="lightdm"; Install_DesktopEnv cinnamon cinnamon-session "$(Config_File_Manage CONF Read "PGK_Cinnamon")";;
        8)  Default_DM="lightdm"; Install_DesktopEnv mate   mate          "$(Config_File_Manage CONF Read "PGK_Mate")" ;;
        # 9)  Default_DM="sddm"; Install_DesktopEnv "Plasma & Wayland"  ""  "$(Config_File_Manage CONF Read "P_plasma_Wayland")" ;;
        # 10)  bash "${Share_Dir}/Install_openbox.sh" ;;
        *)
            echo -e "${out_ERROR} ${red} Selection error.${suffix}"    
            Process_Management stop "$0" ;;
        esac 
}
# @桌面环境安装 $1(桌面名称) $2(xinitrc配置 "exec desktop") $3(包列表)
function Install_DesktopEnv(){
    local Desktop_Name Desktop_Xinit Desktop_Program;
    Desktop_Name=$1
    Desktop_Xinit=$2
    Desktop_Program=$3
    CONF_PGK_Xorg=$(Config_File_Manage CONF Read "PGK_Xorg")
    CONF_PGK_Gui_Package=$(Config_File_Manage CONF Read "PGK_Gui_Package")
    
    Config_File_Manage INFO Write Desktop_Environment "$Desktop_Name"
    echo -e "\n${out_EXEC} ${green}Configuring desktop environment ${white}[$Desktop_Name].${suffix}"; sleep 1;
    Install_Program "$CONF_PGK_Xorg"
    Install_Program "$Desktop_Program"
    Install_Program "$CONF_PGK_Gui_Package"
    Desktop_Manager
    Desktop_Xorg_Config "$Desktop_Name" "$Desktop_Xinit" 
    Install_Fcitx
}
# @桌面管理器选择列表，选择后，自动安装及配置服务；
function Desktop_Manager(){
    Printf_Info DesktopManagerList
    printf "${outG} ${yellow} Please select Desktop Manager: ${suffix} %s" "$inB"
    read -r DM_ID
    case ${DM_ID} in
        1) DmS="sddm" ;;
        2) DmS="gdm"  ;;
        3) DmS="lightdm" ;;
        4) DmS="lxdm" ;;
        *) DmS="$Default_DM" ;;
    esac
    echo -e "\n${out_EXEC} ${green}Configuring desktop display manager ${white}[$DmS].${suffix}"; sleep 1;
    echo "$DmS" > "${Local_Dir}/Desktop_Manager"
    case ${DmS} in
        sddm)
            Install_Program "sddm sddm-kcm" && systemctl enable sddm ;;
        gdm)
            Install_Program "gdm" && systemctl enable gdm ;;
        lightdm)
            Install_Program "lightdm lightdm-gtk-greeter" && systemctl enable lightdm ;;
        lxdm)
            Install_Program "lxdm" && systemctl enable lxdm ;;
    esac
    echo -e "\n${out_WELL} ${green} Desktop manager installed successfully -=> ${white}[ $DmS ] ${suffix}\n"
    Config_File_Manage INFO Write Desktop_Display_Manager "$DmS"
    sleep 5;
}
# @configure desktop environment
function Desktop_Xorg_Config(){
    if [ -e /home/"$CheckingUsers"/.xinitrc ];then
        echo -e "${out_WARNING} ${yellow}Repeated execution !${suffix}";sleep 2; 
    else
        # xinitrc_file="/etc/X11/xinit/xinitrc"
        # startLine=$(sed -n '/twm &/=' $xinitrc_file) 
        # lineAfter=4
        # endLine=$(("$startLine" + "$lineAfter"))
        # sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec ${2}" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$CheckingUsers"/.xinitrc 
        echo -e "${out_WELL} ${white}${1} ${green}Desktop environment configuration completed.${suffix}"  
    fi
}
# @install fonts 安装所有字体
function Install_Font(){
    CONF_PGK_FONTS=$(Config_File_Manage CONF Read "PGK_Fonts")
    CONF_PGK_FONTS_ADOBE=$(Config_File_Manage CONF Read "PGK_Fonts_Adobe")
    
    CONF_Install_Font_Common=$(Config_File_Manage CONF Read "Install_Font_Common")
    CONF_Install_Font_Adobe=$(Config_File_Manage CONF Read "Install_Font_Adobe")
    CONF_Install_Font_JetBrains_Fira=$(Config_File_Manage CONF Read "Install_Font_JetBrains_Fira")
    
    function InstallJetBrainsFira(){
        wget -P ${Local_Dir} http://auins.auroot.cn/local/JetBrains_Fira_Fonts.zip
        mkdir -p /usr/share/fonts
        unzip -d /usr/share/fonts "${Local_Dir}/JetBrains_Fira_Fonts.zip"
        fc-cache
    }
    case $CONF_Install_Font_Common in
        [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Common fonts].${suffix}" 
                Install_Program "$CONF_PGK_FONTS" ;; 
            *)  printf "${outG} ${yellow}Whether to install [Common fonts]. Install[y] No[*]${suffix} %s" "$inB"
                read -r UserInf_Font
                case ${UserInf_Font} in
                    [Yy]*) Install_Program "$CONF_PGK_FONTS" ;;
                        *) echo -e "${out_SKIP} ${white}[Common fonts].${suffix}\n"
                esac
    esac   
    case $CONF_Install_Font_Adobe in
        [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Adobe fonts].${suffix}" 
                Install_Program "$CONF_PGK_FONTS_ADOBE" ;;
            *)  printf "${outG} ${yellow}Whether to install [Adobe fonts]. Install[y] No[*]${suffix} %s" "$inB"
                read -r UserInf_Adobe_Font
                case ${UserInf_Adobe_Font} in
                    [Yy]*) Install_Program "$CONF_PGK_FONTS_ADOBE" ;;
                        *) echo -e "${out_SKIP} ${white}[Adobe fonts].${suffix}\n"
                esac
    esac
    case $CONF_Install_Font_JetBrains_Fira in
        [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [JetBrains / Fira fonts].${suffix}" 
                InstallJetBrainsFira ;;
            *)  printf "${outG} ${yellow}Whether to install [JetBrains / Fira fonts]. Install[y] No[*]${suffix} %s" "$inB"
                read -r UserInf_JF_Font
                case ${UserInf_JF_Font} in
                    [Yy]*) InstallJetBrainsFira ;;
                    *) echo -e "${out_SKIP} ${white}[JetBrains / Fira fonts].${suffix}\n"
                esac
    esac 
}
# @install fcitx 
function Install_Fcitx(){
    Fcitx_Config="
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
"
    CONF_Install_Fcitx=$(Config_File_Manage CONF Read "Install_Fcitx")
    CONF_PKG_Fcitx=$(Config_File_Manage CONF Read "PKG_Fcitx")
    case $CONF_Install_Fcitx in
    [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Fcitx].${suffix}" 
            Install_Program "$CONF_PKG_Fcitx" 
            echo "$Fcitx_Config" >> /etc/environment;; 
        *)  printf "${outG} ${yellow}Whether to install [Fcitx]. Install[y] No[*]${suffix} %s" "$inB"
            read -r UserInf_Fcitx
            case ${UserInf_Fcitx} in
                [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Fcitx].${suffix}" 
                        Install_Program "$CONF_PKG_Fcitx" 
                        echo "$Fcitx_Config" >> /etc/environment;;
                    *) echo -e "${out_SKIP} ${white}[Fcitx].${suffix}\n"
            esac
    esac 
}
# @Install I/O Driver 安装驱动
function Install_Io_Driver(){
    # 读取配置 
    CONF_Driver_Audio=$(Config_File_Manage CONF Read "Install_Driver_Audio")
    CONF_Driver_input=$(Config_File_Manage CONF Read "Install_Driver_Input")
    CONF_Driver_Bluez=$(Config_File_Manage CONF Read "Install_Driver_Bluetooth")
    # 读取包名
    CONF_PKG_INTEL=$(Config_File_Manage CONF Read "PGK_Intel")
    CONF_PKG_AMD=$(Config_File_Manage CONF Read "PGK_Amd")
    CONF_PGK_Audio_Driver="$(Config_File_Manage CONF Read "PGK_Audio_Driver")"
    CONF_PGK_Input_Driver="$(Config_File_Manage CONF Read "PGK_Input_Driver")"
    CONF_PGK_Bluez_Driver="$(Config_File_Manage CONF Read "PGK_Bluetooth_Driver")"
    # CPU
    case $CPU_Vendor in
    intel)  echo -e "\n${out_EXEC} ${green}Install the Intel driver.${suffix}"
            Install_Program "$CONF_PKG_INTEL";;
      amd)  echo -e "\n${out_EXEC} ${green}Install the Amd driver.${suffix}"
            Install_Program "$CONF_PKG_AMD";;
        *)  printf "${outG} ${yellow}Please select: Intel[1] AMD[2].${suffix} %s" "$inB"
            read -r DRIVER_GPU_ID
            case $DRIVER_GPU_ID in
                1) Install_Program "$CONF_PKG_INTEL" ;;
                2) Install_Program "$CONF_PKG_AMD" ;;
            esac
    esac
    # 安装音频驱动 
    case $CONF_Driver_Audio in 
        yes) echo -e "${out_EXEC} ${green}Installing Audio driver.${suffix}"  
             Install_Program "$CONF_PGK_Audio_Driver"
             systemctl enable alsa-state.service ;;
        *)   echo -e "${out_SKIP} ${green}Installing audio driver.${suffix}"
    esac
    # 安装 I/O 驱动 
    case $CONF_Driver_input in 
        yes) echo -e "${out_EXEC} ${green}Installing input driver.${suffix}" 
             Install_Program "$CONF_PGK_Input_Driver" ;;
        *)   echo -e "${out_SKIP} ${green}Installing audio driver..${suffix}"
    esac 
    # 安装蓝牙驱动
    case $CONF_Driver_Bluez in 
        yes) echo -e "${out_EXEC} ${green}Installing Bluetooth driver.${suffix}"  
             Install_Program "$CONF_PGK_Bluez_Driver"
             echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
             echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa ;;
        *)   echo -e "${out_SKIP} ${green}Installing bluetooth driver.${suffix}"
    esac 
}

# @Install GPU Driver 安装显卡驱动
function Install_Processor_Driver(){
    lspci -k | grep -A 2 -E "(VGA|3D)"  
    CONF_PGK_Nvidia_Driver=$(Config_File_Manage CONF Read "PGK_Nvidia_Driver")
    printf "\n${outG} ${yellow}Whether to install the Nvidia driver? [y/N]:${suffix} %s" "$inB"
    read -r DRIVER_NVIDIA_ID
    case $DRIVER_NVIDIA_ID in
        [Yy]*)
            Install_Program "$CONF_PGK_Nvidia_Driver"
            # yay -Sy --needed "$(Config_File_Manage CONF Read "PGK_Nvidia_Manager")"
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
        [Nn]* ) bash "$0" ;;
            * ) Process_Management stop "$0" ;;
        esac   
}

# function Configure_Systemd_boot(){
#     PGK_SYSTEMD_BOOT="$(Config_File_Manage CONF Read "PGK_SYSTEMD_BOOT")"
#     Install_Program "$PGK_SYSTEMD_BOOT"
#     bootctl install
#     echo "options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/nvme0n1p2) rw" >> /boot/loader/entries/arch.conf
#     bootctl update
#     systemctl enable fstrim.timer
# }

# @Install/Configure Grub, 安装并配置Grub
function Configure_Grub(){
    echo -e "\n${out_EXEC} ${green}Install grub tools.${suffix}\n"  
    echo -e "${out_WELL} ${white}Your startup mode has been detected as ${green}$INFO_Boot_way${suffix}.\n"   
    CONF_PKG_GRUB_UEFI="$(Config_File_Manage CONF Read "PGK_GRUB_UEFI")"
    CONF_PKG_GRUB_BOOT="$(Config_File_Manage CONF Read "PGK_GRUB_BOOT")"
    sleep 2;
    case "$INFO_Boot_way" in 
        UEFI)
            Install_Program "$CONF_PKG_GRUB_UEFI"
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$CONF_Hostname" --recheck
            echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
            if efibootmgr | grep "$CONF_Hostname" &>/dev/null ; then
                echo -e "\n${out_WELL} ${green} Grub installed successfully -=> [$CONF_Hostname] ${suffix}"  
                echo -e "${green}     $(efibootmgr | grep "$CONF_Hostname")  ${suffix}\n"  
            else
                echo -e "\n${out_ERROR} ${red}Grub installed failed ${suffix}"
                echo -e "${green}     $(efibootmgr)  ${suffix}\n"
            fi
        ;;
        BIOS)
            Install_Program "$CONF_PKG_GRUB_BOOT"
            local INFO_Boot_partition
            INFO_Boot_partition=$(Config_File_Manage INFO Read "Boot_partition") 
            grub-install --target=i386-pc --recheck --force "$INFO_Boot_partition"
            grub-mkconfig -o /boot/grub/grub.cfg
            if echo $? &>/dev/null ; then
                echo -e "\n${out_WELL} ${green} Grub installed successfully -=> [Archlinux] ${suffix}\n"  
            else
                echo -e "\n${out_ERROR} ${red} Grub installed failed ${suffix}\n"
            fi
    esac  
}
# @配置本地化 时区 主机名 语音等  
function Configure_Language(){
        echo -e "${out_EXEC} ${white}Configure enable Network.${suffix}"    
    systemctl enable NetworkManager  
        echo -e "${out_EXEC} ${white}Time zone changed to 'Shanghai'. ${suffix}"  
    ln -sf /usr/share/zoneinfo"$Timezone" /etc/localtime && hwclock --systohc # 将时区更改为"上海" / 生成 /etc/adjtime
        echo -e "${out_EXEC} ${white}Set the hostname \"$CONF_Hostname\". ${suffix}"
    echo "$CONF_Hostname" > /etc/hostname
        echo -e "${out_EXEC} ${white}Localization language settings. ${suffix}"
    sed -i 's/#.*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        echo -e "${out_EXEC} ${white}Write 'en_US.UTF-8 UTF-8' To /etc/locale.gen. ${suffix}"  
    sed -i 's/#.*zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen 
        echo -e "${out_EXEC} ${white}Write 'zh_CN.UTF-8 UTF-8' To /etc/locale.gen. ${suffix}" 
    locale-gen
        echo -e "${out_EXEC} ${white}Configure local language defaults 'en_US.UTF-8'. ${suffix}"  
    echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 系统语言 "英文" 默认为英文   
    sleep 3;
}
# @Install/Configure virtualbox-guest-utils / open-vm-tools, 安装虚拟化插件
function install_virtualization_service(){
    CONF_PKG_VMWARE="$(Config_File_Manage CONF Read "PGK_Vmware")"
    CONF_PKG_VIRTUALBOX="$(Config_File_Manage CONF Read "PGK_VirtualBox")"
    case "$1" in
        vmware)
            Install_Program "$CONF_PKG_VMWARE"
            systemctl enable vmtoolsd.service
            systemctl enable vmware-vmblock-fuse.service
            systemctl start vmtoolsd.service
            systemctl start vmware-vmblock-fuse.service
        ;;
        virtualbox)
            Install_Program "$CONF_PKG_VIRTUALBOX"
            systemctl enable vboxservice.service
            systemctl start vboxservice.service
        ;;
        *) echo -e "\n${out_ERROR} ${white}This computer is not virtualized.${suffix}"
    esac
}
# @Archlive update tips 
function Archiso_Version_Testing(){
    Version_Route="${1}"
    Time_Archiso=$(sed 's/\./-/g' "$Version_Route")
    Time_interval=$((($(date +%s) - $(date -d "$Time_Archiso 00:00:00" +%s)) / 2605391 ))
    Config_File_Manage INFO Write Livecd_version "${Time_Archiso:- }";
    case $Time_interval in
        [0])    ;;
        [1])    printf "\n${out_WARNING} ${white}Please update as soon as possible Livecd ! \n${out_WARNING} ${white}Livecd Version: %s.\n${suffix}" "$Time_Archiso"; sleep 3 ;;
        [2])    printf "\n${out_WARNING} ${white}You haven't updated in more than 2 month Livecd ! \n${out_WARNING} ${white}Livecd Version: %s.\n${suffix}" "$Time_Archiso"; sleep 3 ;;
        [3])    printf "\n${out_WARNING} ${white}You haven't updated in more than 3 month Livecd ! \n${out_WARNING} ${white}Livecd Version: %s.\n${suffix}" "$Time_Archiso";
                printf "\n${outY} ${yellow} Whether to start the script [Y/n]:${suffix} %s" "$inB"
                read -r Version_check
                    case $Version_check in
                        [Yy]*)  sleep 1 ;;
                            *)  clear; echo -e "${out_WARNING} ${white}Please update Livecd.${suffix}"; exit 30 ;;
                    esac ;;
        *)      printf "\n${out_ERROR} ${white}You haven't updated Livecd for a long time ! \n${out_WARNING} ${white}Livecd Version: %s.\n${suffix}" "$Time_Archiso"
                echo -e "${out_WARNING} ${white}Please update your Livecd!!! After 10 seconds Exit(Ctrl+c).${suffix}"; sleep 10; exit 1 ;;
    esac
}


# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    case ${PM_Enter_1} in
        start  ) bash "$Process_Script" start   "${PM_Enter_2}" ;;
        restart) bash "$Process_Script" restart "${PM_Enter_2}" ;;
        stop   ) bash "$Process_Script" stop    "${PM_Enter_2}" ;;
    esac
}
# @安装系统
function Installation_System(){
    INFO_Root_partition=$(Config_File_Manage INFO Read "Root_partition")  
    if [ -n "$INFO_Root_partition" ]; then  # 后续待修改部分
        Install_Archlinux
    else
        echo -e "${out_WARNING} ${white}The partition is not mounted.${suffix}"; 
        sleep 3; Process_Management restart "$0"
    fi
    Printf_Info InstallSystemInfo
    sleep 3; echo;    # Chroot到新系统中完成基础配置
    cp -rf /etc/pacman.conf $System_Root/etc/pacman.conf 
    cp -rf /etc/pacman.d/mirrorlist $System_Root/etc/pacman.d/mirrorlist
    echo "No" > $System_Root/local/Config_System
    Auin_chroot
}
# @配置系统
function Configure_System(){
    Disk_Kernel=$(cat /usr/src/linux/version)
    INFO_Install_Kernel=$(Config_File_Manage INFO Read "LinuxKernel")
    CONF_PGK_Terminal_Tools=$(Config_File_Manage CONF Read "PGK_Terminal_Tools")
    CONF_PKG_SystemctlFile=$(Config_File_Manage CONF Read "PKG_SystemctlFile")
    CONF_PGK_Common_Package=$(Config_File_Manage CONF Read "PGK_Common_Package")
    if [ -n "$INFO_Install_Kernel" ] || [ -n "$Disk_Kernel" ] ; then 
        Configure_Grub
        #---------------------------------------------------------------------------#
        echo -e "${out_EXEC} ${green}Install the Terminal tools packages.${suffix}" && sleep 1;
        Install_Program "$CONF_PGK_Terminal_Tools"
        echo -e "${out_EXEC} ${green}Install the System file package.${suffix}" && sleep 1;
        Install_Program "$CONF_PKG_SystemctlFile" 
        echo -e "${out_EXEC} ${green}Install the Other common package.${suffix}" && sleep 1;
        Install_Program "$CONF_PGK_Common_Package" 
        Configure_Language
        ConfigurePassworld
        INFO_UserName=$(Config_File_Manage INFO Read "Users")
        INFO_UsersID=$(id -u "$INFO_UserName" 2> /dev/null)
        printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n" "${CheckingUsers:-$INFO_UserName}" "${CheckingID:-$INFO_UsersID}"
        rm -rf ${Local_Dir}/Config_System; # 删除这个文件，才能进 Normal_Model  
        Install_Font
        if [ "$(Config_File_Manage CONF Read "Archlinucn")" = "yes" ]; then Install_Program archlinuxcn-keyring; fi
        if [ "$(Config_File_Manage CONF Read "Blackarch")" = "yes" ]; then Install_Program blackarch-keyring; fi
        Printf_Info ConfigSystemInfo; sleep 3
    else
        echo -e "${out_ERROR} ${red}The system is not installed. Exec: 4->2 ${suffix}";sleep 3;
        Process_Management restart "$0"
    fi
    rm -rf ${Local_Dir}/Config_System 2> /dev/null
}
# @磁盘分区
function Disk_Partition(){
    bash "$Partition_Script" "${Auins_Config}" "${Auins_record}"; 
    sleep 1; bash "${0}"
}
# @安装桌面
function Installation_Desktop(){
    ConfigurePassworld    
    INFO_UserName=$(Config_File_Manage INFO Read "Users")
    INFO_UsersID=$(id -u "$INFO_UserName" 2> /dev/null)
    if [ -n "$INFO_UserName" ]; then 
        Set_Desktop_Env 
        printf "${outG} ${yellow}Whether to install Common Drivers? [y/N]:${suffix}%s" "$inB"
        read -r CommonDrive
        case ${CommonDrive} in
            [Yy]*) Install_Io_Driver ;;
            [Nn]*) Process_Management stop "$0" ;;
        esac
    else
        echo -e "${out_ERROR} ${white}User has no settings.${suffix}"; sleep 3;
        Process_Management restart "$0"
    fi
}
# @删除脚本和缓存
function Delete_Script(){
    echo -e "${out_WARNING} ${yellow}Deleting scripts and cache!${suffix}"; sleep 1
    sudo pacman -Scc
    rm -rf "$Share_Dir"
    rm -rf "$Local_Dir"
    echo -e "\n${out_WELL} ${green} ʕ ᵔᴥᵔ ʔ Bye-bye~ ${suffix}\n"
    rm -rf "$0" && sleep 10;
}     
# @ Archiso LiveCD 下自动启用
function LiveCD_Model(){
    Printf_Info logos;
    Printf_Info LivecdHomeList;   
    echo -e "\n${Chroot_status:- }"
    printf "${outG} ${yellow} Please enter[1,2,3..] Exit[Q]${suffix} %s" "$inB"
    read -r principal_variable 
    case ${principal_variable} in
        1)  bash "$Mirrorlist_Script" "${Auins_Config}" "${Auins_record}" ; bash "${0}" ;; # 配置源
        2)  Network Conf_all;; # 配置网络
        3)  Open_SSH ;; # 配置SSH
        4) # 二级列表 隐
            Printf_Info Livecd_System_Module_List;
            echo -e "${input_System_Module_Chroot:- \n}"
            printf "${outG} ${yellow} Please enter[1,2,21..] Exit[Q] ${suffix}%s" "$inB"
            read -r Tasks
            case ${Tasks} in
                0)  Auin_chroot ;;
                1)  Disk_Partition ;; # 磁盘分区 隐
                2)  Installation_System ;; # 安装系统 隐 
                3)  Configure_System ;; # 配置系统 隐
                4)  Installation_Desktop ;; # 安装桌面
                11) Install_Io_Driver; Install_Processor_Driver ;;  # 安装驱动
                22) install_virtualization_service "$Host_Environment"; sleep 3; bash "$0" ;; # 安装Vm tools
                esac ;;
        [Rr]*) bash "$0" ;;
        [Qq]*) Process_Management stop "$0" ;;
        [Ss]*) bash ;;
    esac
}
# @ 安装完Archlinux后 正常可用情况下自动启用
function Normal_Model(){
    Printf_Info logos;
    Printf_Info NormalHomeList;   
    echo -e "\n${Chroot_status:- }"
    printf "${outG} ${yellow} Please enter[1,2,3..] Exit[Q]${suffix} %s" "$inB"
    read -r principal_variable 
    case ${principal_variable} in
        1)  bash "$Mirrorlist_Script" "${Auins_Config}" "${Auins_record}" ; bash "${0}" ;; # 配置源
        2)  Network Conf_all;; # 配置网络
        3)  Open_SSH ;; # 配置SSH
        4)  Installation_Desktop ;; # 安装桌面
        5)  Install_Io_Driver; Install_Processor_Driver ;; # 安装驱动
        6)  install_virtualization_service "$Host_Environment"; sleep 3; bash "$0" ;; # 安装Vm tools
        [Dd]) Delete_Script ;;
        [Rr]*) bash "$0" ;;
        [Qq]*) Process_Management stop "$0" ;;
        [Ss]*) bash ;;
    esac
}

# @Auins的其他选项功能
function Auin_Options(){
    case "${1}" in
        -m  | --mirror )  bash "$Mirrorlist_Script" "$Auins_Config" "$Auins_record"; exit 0 ;;
        -w  | --cwifi  )   Network Conf_wifi; exit 0 ;;
        -s  | --openssh) 
            case "$CONF_Service_SSH" in
                yes) echo -e "${outG} ${green} activated. ${suffix}"; exit 0 ;;
                *  )  Open_SSH; exit 0 ;;
            esac ;;
        -vm | --virtual) install_virtualization_service "$Host_Environment" ;;
        -ec | --conf   ) vim "${Auins_Config}" ;;
               -vc     ) clear; less "${Auins_Config}"; exit 0 ;;
              --info   ) clear; less "${Auins_record}"; exit 0 ;;
               -ds     ) Delete_Script; exit 0 ;;
        -h  | --help   ) Printf_Info usage; exit 0   ;;
        -v  | --version) clear; Printf_Info version; exit 0 ;;
    esac
}

# Start Script | 从这里开始
# >> >> >> >> >> >> >> >> >> >> >> >> 
Script_Variable_init 
Set_Color_Variable  
Update_Share
Script_init
Network INFO
# 具体的实现
if ! groups "$(whoami)" | grep -i "root" &>/dev/null ; then 
    echo -e "\n${out_ERROR} ${red}There is currently no execute permission.${suffix}" 
    echo -e "${out_ERROR} ${red}Please use ${green}\"command: sudo\"${red} or ${green}\"user: root\"${red} to execute.${suffix}\n"
fi
Auin_Options "${1}"
case "${ChrootPatterns}" in 
    Chroot-OFF)
        ChrootPatterns_Print="${white}[${red}Chroot-OFF${white}]${suffix}";     
        input_System_Module_Chroot="${outY} ${yellow}   arch-chroot ${System_Root}.      ${red}**  ${white}[0]  ${suffix}\n"
        if [ -e "$System_Root/local/LiveCD_OFF" ]; then # 如果LiveCD_OFF存在于新系统，将自动chroot
            Auin_chroot 2> /dev/null; 
        fi 
        if [ -e ${Local_Dir}/LiveCD ]; then 
            StartPatterns="${white}[${green}LiveCD${white}]${suffix}"
            LiveCD_Model; 
        fi 
        case $Normals in 
            [Yy]*)  StartPatterns="${white}[Normal]${suffix}"
                    Normal_Model; 
        esac
    ;;
    Chroot-ON) 
        ChrootPatterns_Print="${white}[${green}Chroot-ON${white}]${suffix}"
        Chroot_status="${outG}  ${wg}Successfully start: Chroot.${suffix}"
        # Tasks_Auin_chroot="0"
        if [ -e ${Local_Dir}/Config_System ]; then 
            StartPatterns="${white}[${green}LiveCD${white}]${suffix}"
            LiveCD_Model; 
        else 
            StartPatterns="${white}[Normal]${suffix}"
            Normals="yes"
            Normal_Model
        fi
esac
# >> >> >> >> >> >> >> >> >> >> >> >>