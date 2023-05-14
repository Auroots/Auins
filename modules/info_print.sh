#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：INFO Print -> Auins v4.7.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
echo &>/dev/null

# 列出需要包含的配置文件或模块
function include(){
    set +e
    declare -a argu=("$@")
    # declare -p argu
    export config_File info_File option other_option_1 other_option_2 other_option_3
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    Tools_modules="${argu[2]}"
    option="${argu[3]}"
    other_option_1="${argu[4]}"
    other_option_2="${argu[5]}"
    set -e
}
# 小型重复性高的模块调用管理器
function run_tools(){
    bash "$Tools_modules" "$config_File" "$info_File" "$1" "$2" "$3" "$4" "$5"
}

# 网络部分
NET_LIST(){
    for ((VARIABLE=1;VARIABLE<=$(echo "$2" | grep -o '|' | wc -l);VARIABLE++)) 
    do 
        list=$(echo "$2" | awk -F'|' '{print $test}' test="$VARIABLE" | sed 's/^[ ]*//g')
        list_ip=$(echo "$list" | awk -F':' '{print $2}')
        if [[ $list_ip != "" ]]; then 
            PRINT_NET_NAME=$(echo "$list" | awk -F':' '{print $1}')
            PRINT_NET_IP=$list_ip
            case $1 in 
                Ethernet)   
                        echo -e "${green} Ethernet_${VARIABLE}: \t\033[1;37m[ \033[1;32m${PRINT_NET_NAME} \033[1;37m] - \033[1;36m${PRINT_NET_IP} \033[1;31m"
            ;;  Wifi)   
                        echo -e "${green} Wifi_Net_${VARIABLE}: \t\033[1;37m[ \033[1;32m${PRINT_NET_NAME} \033[1;37m] - \033[1;36m${PRINT_NET_IP} \033[1;31m"
            ;;  Print_IP)
                        echo -e "${green} SSH_connect: \t${white}ssh $USER@$PRINT_NET_IP${suffix}" 
            esac
        fi 
    done
} 

# @Auins首页信息, 需要接收: 1=Chroot状态, 2=脚本开启模式
function logos(){
    Auins_version=$(run_tools file_rw INFO Read Auins_version) 
    Archiso_version=$(run_tools file_rw INFO Read Archiso_version)

    Chroot_Patterns_Print="$1"
    case "${Chroot_Patterns_Print}" in 
        Chroot-OFF) Chroot_Patterns_Print="$(echo -e "${white}[${red} Chroot-OFF ${white}]${suffix}")" ;;
        Chroot-ON ) Chroot_Patterns_Print="$(echo -e "${white}[${green} Chroot-ON ${white}]${suffix}")"
    esac
    Start_Patterns="$2"
    case "${Start_Patterns}" in 
        LiveCD ) Start_Patterns=$(echo -e "${white}[${green} LiveCD ${white}]${suffix}") ;;
        Normal ) Start_Patterns=$(echo -e "${white}[ Normal ]${suffix}")
    esac
    
    Ethernet_IP=$(NET_LIST Print_IP "$INFO_Ethernet")
    # Ethernet_IP=$(echo "$tmp_Ethernet_IP" | sed 's/or//g')
    WIFI_IP=$(NET_LIST "Print_IP" "$INFO_Wifi")
    SSH_IP="${Ethernet_IP:-$WIFI_IP}"

    # CPU_Temp="$(($(if [ -e /sys/class/thermal/thermal_zone1/temp ]; then cat /sys/class/thermal/thermal_zone1/temp; else echo '00'; fi)/1000))°C"
    printf "
${white}         _             _       _     _                           
${green}        / \   _ __ ___| |__   | |   (_)_ __  _%s   
${blue}       / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /    
${yellow}      / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   
${red}     /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\ 
${bx}-----------------------  Auins Info  ------------------------${suffix}
${green} Script_Name:\t%s
${green} CPU & Mem:  \t%s
${green} GPU_Info:   \t%s
${green} Timezone:   \t%s
${green} Boot_Type:  \t%s ${red}- %s
${green} Patterns:   \t%s ${red}- %s
%s
%s
%s
${red}--=--*--=--*--=--*--=--*--=--=*=--=--*--=--*--=--*--=--*--=--${suffix}" \
"${Archiso_version:-  _ __  __}" \
"$Auins_version" \
"$(echo -e "$(run_tools file_rw INFO Read CPU) ${whites}& ${green}$(run_tools file_rw INFO Read Memory)MB")" \
"$(run_tools file_rw INFO Read GPU)" \
"$(run_tools file_rw INFO Read Timezone)" \
"$(echo -e "${white}[ ${blue}$(run_tools file_rw INFO Read Boot_Type)${white} ]${suffix}")" \
"$(echo -e "${white}[ ${blue}$(run_tools file_rw INFO Read Disk_Type)${white} ]${suffix}")" \
"$Chroot_Patterns_Print" "$Start_Patterns" \
"$(NET_LIST "Ethernet" "$INFO_Ethernet")" \
"$(NET_LIST "Wifi" "$INFO_Wifi")" \
"$SSH_IP"
}
  
# @正常(Normal)环境下，首页会显示的列表
function normal_home_list(){
    echo -e "\n
${outB}\t${white}[${blue}1${white}]${green}  Configure Mirrorlist  ${suffix}
${outB}\t${white}[${blue}2${white}]${green}  Configure Network     ${suffix}
${outG}\t${white}[${blue}3${white}]${green}  Configure SSH         ${suffix}
${outY}\t${white}[${blue}4${white}]${green}  Configure Users       ${suffix}
${outY}\t${white}[${blue}5${white}]${green}  Installation Desktop  ${suffix}
${outY}\t${white}[${blue}6${white}]${green}  Installation Fonts    ${suffix}
${outY}\t${white}[${blue}11${white}]${green} Installation Drive    ${suffix}
${outY}\t${white}[${blue}22${white}]${green} Install virtualization tools ${suffix}
${outY}\t${white}[${red}D${white}]${green}  Delete auins & caches  ${suffix}
${outR}\t${white}[${red}Q${white}]${green}  Exit Auins             ${suffix}"   
}

# @LiveCD环境下，首页会显示的列表
function livecd_home_list(){ 
    echo -e "
${outB}\t${white}[${blue}1${white}]${green} Configure Mirrorlist ${suffix}
${outB}\t${white}[${blue}2${white}]${green} Configure Network    ${suffix}
${outG}\t${white}[${blue}3${white}]${green} Configure SSH        ${suffix}
${outY}\t${white}[${blue}4${white}]${green} Installation System  ${suffix}
${outR}\t${white}[${red}Q${white}]${green} Exit Script           ${suffix}"
} 

# @首选项 [4] 的列表
function livecd_system_module_list(){
    echo -e "
\n\t${white}*** ${red}Install System Module ${white}***${suffix}  
---------------------------------------------
${outY} \t${white}[${blue}1${white}]${green}  Disk Partition                \t${red}**${suffix}
${outY} \t${white}[${blue}2${white}]${green}  Installation Base System      \t${red}**${suffix}
${outY} \t${white}[${blue}3${white}]${green}  Configurt System              \t${red}**${suffix}
${outY} \t${white}[${blue}4${white}]${green}  Configure Users               \t${red}**${suffix}
${outG} \t${white}[${blue}5${white}]${green}  Installation Desktop          \t${blue}*${suffix}
${outG} \t${white}[${blue}11${white}]${green} Installation Drive            \t${blue}*${suffix}
${outY} \t${white}[${blue}22${white}]${green} Install virtualization tools  \t${blue}*${suffix}" 
}

# @系统安装成功, 直奔加入chroot的提示信息
function install_system_info(){
    sleep 1; echo -e "\n
${wg}+-====================================================-+${suffix}
${wg}|  System components installation completed.           |${suffix}
${wg}|  Entering chroot mode.                               |${suffix}
${wg}|  Execute in 3 seconds.                               |${suffix}
${wg}|  Later operations are oriented to the new system.    |${suffix}
${wg}+-====================================================-+${suffix}\n"
}

# @完成系统配置成功, 可重启的提示信息
function config_system_info(){
    printf "
${ws}+-====================================================-+${suffix}
${ws}|                  Exit in 3/s                         |${suffix}
${ws}|  When finished, restart the computer.                |${suffix}
${ws}|  If there is a problem during the installation       |${suffix}
${ws}|  Please contact me. QQ:%s or Group:%s |${suffix}
${ws}+-====================================================-+${suffix}\n" "2763833502" "346952836"
}

# @JetBrainsFira字体安装完成后的使用说明
function JetBrainsFira_font_usage() {
    printf "${outG} Usage of JetBrainsFira font:
    Use ${white}CTRL + SHIFT + P${suffix}, input: ${white}\"user settings.json\"${suffix} to write.
    Or directly write to file ${white}\"%s\"${suffix}
    Please pay attention to the JSON format when writing, such as commas->'${white},${suffix}' and curly braces-> '${white}{}${suffix}'.\n
{
    \"editor.fontLigatures\": true,
    \"editor.fontSize\": 14,
    \"editor.fontWeight\": \"normal\",
    \"editor.fontFamily\": \"JetBrains Mono\",
    \"font-switcher.enableLivePreview\": true,
}\n\n" "/home/$USER/.config/\"vsCode_directory\"/User/settings.json" 
}

# @输出SSH信息
function ssh_info(){   
    Ethernet_IP=$(NET_LIST Print_IP "$INFO_Ethernet" | awk -F'@' '{print $2}')
    WIFI_IP=$(NET_LIST "Print_IP" "$INFO_Wifi" | awk -F'@' '{print $2}')
    CONF_Password_SSH=$(run_tools file_rw CONF Read Password_SSH)

    if netcap | grep sshd &>/dev/null ; then
        SSH_Port=$(netcap | grep sshd)
        SSH_status=$(echo -e "${out_WELL} ${white}SSH service successfully started.${suffix}")
    else 
        SSH_status=$(echo -e "${out_ERROR} ${white}SSH service startup failed.${suffix}")
    fi 
    echo -e "
${green} -------------${white} Connection method ${green}------------- ${suffix}
[$USER@$HOSTNAME ~]$ ssh $USER@${Ethernet_IP:-${WIFI_IP}}

 Enter username -=> ${white}$USER${suffix}
 Enter password -=> ${white}$CONF_Password_SSH${suffix}
${green} -----------${white} SSH Port Information ${green}------------ ${suffix}
${SSH_Port}
${SSH_status}
${green} --------------------------------------------- ${suffix}"
}

# @Auins的帮助文档 Auin_help
# usage: ${0##*/} [-h] [-V] command ...
function auins_usage() {
    echo -e "
:: Auins is a script for ArchLinux installation and deployment.
usage: auins [-h] [-V] command ...

    Install Commands: (\"-R = uninstall\"):
        font    Install Fonts, Options: [all], [common], [adobe], [code].
        fcitx   Automatic installation 'fcitx' input method, Other options: [-R].
        ibus    Automatic installation 'ibus-rime' input method, Other options: [-R].
        axel    Automatic installation 'Axel' (Pacman multi threaded download), Other options: [-R].
        inGpu   Install Video card driver: ( \"Nvidia\" \ \"Amdgpu\" ).
        inVmt   Install Virtualization Tools: ( \"Vmware\" \ \"Virtualbox\" ).
        black   Installing BlackArch on ArchLinux. (https://blackarch.org/strap.sh)

    Settings Options:
        -m, --mirror        Automatically configure mirrorlist file.
        -w, --wifi          Connect to a WIFI.
        -s, --openssh       Open SSH service (password: 123456).
             
    Global Options:
            --update        Auins and modules are updated in real time, Options: [enable], [disable].
            --iso-check     Switch for auins version check, Options: [enable], [disable].
        -e, --edit-conf     Edit (\"local/profile.conf\").
        -f, --show-conf     Show (\"local/profile.conf\").
        -i, --show-info     Show (\"local/auins.info\").
        -c, --clean-cache   Delete auins and other caches.
        -h, --help          Show help message.
        -v, --version       Show the auins version.
        "
}

# @Auins版本信息
function version(){    
    echo -e "${wg} $(run_tools file_rw INFO Read Auins_version) ${suffix}
Copyright (C) 2020 - 2023 Auroot.                   
URL GitHub: https://github.com/Auroots/Auins 
URL Gitee : https://gitee.com/auroot/Auins   
                                            
Contact information:                         
            QQ: 2763833502                   
            QQ Group: 346952836              
"
}     

# 桌面环境的选择列表
function desktop_env_list(){
        echo -e "
\n\t   ${white}***${suffix} ${blue}Install Desktop${suffix} ${white}***${suffix}    
------------------------------------------------

${outB} \t${blue}[1]${blue}${green}   KDE plasma. \tDefault: ${blue}sddm     ${suffix}
${outB} \t${white}[2]${white}${green}   Gnome.    \tDefault: ${yellow}gdm      ${suffix}
${outB} \t${blue}[3]${blue}${green}   Deepin.     \tDefault: ${green}lightdm  ${suffix}  
${outB} \t${white}[4]${white}${green}   Xfce4.    \tDefault: ${green}lightdm  ${suffix}
${outB} \t${blue}[5]${blue}${green}   i3wm.       \tDefault: ${blue}sddm     ${suffix}
${outB} \t${white}[6]${blue}${green}   lxde.       \tDefault: \033[1;34mlxdm     ${suffix}
${outB} \t${blue}[7]${white}${green}   Cinnamon. \tDefault: ${green}lightdm  ${suffix}
${outB} \t${white}[8]${blue}${green}   Mate.       \tDefault: ${green}lightdm  ${suffix}
${outB} \t${blue}[9]${blue}${green}   Plasma_Wayland. \tDefault: ${blue}sddm     ${suffix}
${outB} \t${white}[10]${blue}${green}  Openbox.    \tDefault: ${blue}sddm     ${suffix}
------------------------------------------------\n"  
}

# 桌面管理器的选择列表
function desktop_manager_list(){
        echo -e "
----------------------------
${outB} ${blue}[1]${green}   sddm.     ${suffix}
${outB} ${yellow}[2]${green}   gdm.     ${suffix}
${outB} ${green}[3]${green}   lightdm.  ${suffix}  
${outB} \033[1;34m[4]${green}   lxdm.     ${suffix} 
${outB} ${white}[*]${green}   default.${suffix}
============================"
}

# @该死的颜色
function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'  
    whites='\033[1;30m';   
    #-----------------------------#
    # rw='\033[1;41m'  #--红白
    wg='\033[1;42m'; ws='\033[1;43m'      #白绿 \ 白褐
    #wb='\033[1;44m'; wq='\033[1;45m'    #白蓝 \ 白紫
    # wa='\033[1;46m';  #白青
    bx='\033[1;4;36m' # 蓝 下划线
    #-----------------------------#
    # 提示 蓝 红 绿 黄
    outB="${white}::${blue} =>${suffix}";  outR="${white}::${red} =>${suffix}"
    outG="${white}::${green} =>${suffix}"; outY="${white}::${yellow} =>${suffix}"
    out_WELL="${white}::${green} =>${suffix}"
    out_ERROR="${white}::${red} [ Error ] =>${suffix}"
}

# 具体的实现 >> >> >> >> >> >> >> >> 
include "$@"
INFO_Ethernet=$(run_tools file_rw INFO Read Ethernet)
INFO_Wifi=$(run_tools file_rw INFO Read Wifi)
Set_Color_Variable
case $option in
    # Auins版本信息
    "version"   ) version ;; 
    # Script首页信息, 需要接收: 1=Chroot状态(Chroot_Patterns_Print) 2=脚本开启模式(Start_Patterns)
    "logos" ) logos "$other_option_1" "$other_option_2";; 
    # 输出SSH信息, 需要接收: [config_File] [info_File]
    "ssh_info" ) ssh_info ;; 
     # Auins的帮助文档 Auin_help
    "auins_usage" ) auins_usage ;;
    # LiveCD环境下，首页会显示的列表
    "livecd_home_list" ) livecd_home_list ;; 
    # 正常(Normal)环境下，首页会显示的列表
    "normal_home_list" ) normal_home_list ;; 
    # 桌面环境的选择列表
    "desktop_env_list" ) desktop_env_list ;; 
    # 桌面管理器的选择列表
    "desktop_manager_list") desktop_manager_list ;; 
    # 首选项 [4] 的列表
    "livecd_system_module_list" ) livecd_system_module_list;; 
    # 系统安装成功, 直奔加入chroot的提示信息
    "install_system_info" ) install_system_info ;; 
    # 完成系统配置成功, 可重启的提示信息
    "config_system_info" ) config_system_info ;; 
    # JetBrainsFira字体安装完成后的使用说明
    "JetBrainsFira_font_usage" ) JetBrainsFira_font_usage 
esac


# Print_INFO [想要输出的信息] [附加输入的信息]......