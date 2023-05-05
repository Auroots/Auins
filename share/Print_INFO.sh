#!/bin/bash
#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Print INFO -> auin V4.6 r6
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
echo &>/dev/null

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
    # wa='\033[1;46m';  #白青
    bx='\033[1;4;36m' # 蓝 下划线
    #-----------------------------#
    # 提示 蓝 红 绿 黄
    outB="${white}::${blue} =>${suffix}";  outR="${white}::${red} =>${suffix}"
    outG="${white}::${green} =>${suffix}"; outY="${white}::${yellow} =>${suffix}"
    out_WELL="${white}::${green} =>${suffix}"
    out_ERROR="${white}::${red} [ Error ] =>${suffix}"
}

# @Script首页信息, 需要接收: 1=版本号, 2=引导类型, 3=磁盘类型, 4=Chroot状态, 5=脚本开启模式, 6=有线IP, 7=有线网卡名, 8=无线IP, 9=无线网卡名
function logos(){
    Script_Version="${1}" 
    Boot_Type=$(echo -e "${white}[ ${blue}${2}${white} ]${suffix}")
    Disk_Type=$(echo -e "${white}[ ${blue}${3}${white} ]${suffix}")

    Chroot_Patterns_Print="$4"
    case "${Chroot_Patterns_Print}" in 
        Chroot-OFF) Chroot_Patterns_Print="$(echo -e "${white}[${red} Chroot-OFF ${white}]${suffix}")" ;;
        Chroot-ON ) Chroot_Patterns_Print="$(echo -e "${white}[${green} Chroot-ON ${white}]${suffix}")"
    esac
    Start_Patterns="$5"
    case "${Start_Patterns}" in 
        LiveCD ) Start_Patterns=$(echo -e "${white}[${green} LiveCD ${white}]${suffix}") ;;
        Normal ) Start_Patterns=$(echo -e "${white}[ Normal ]${suffix}")
    esac

    Local_Ethernet_IP=$(echo -e "${blue}${6:-No network.}")
    Ethernet_Name=$(echo -e "${white}[${green} ${7:-No} ${white}]${suffix}")

    Local_Wifi_IP=$(echo -e "${blue}${8:-No network.}")
    Wifi_Name=$(echo -e "${white}[${green} ${9:-No} ${white}]${suffix}")

    SSH_IP=$(echo -e "${blue}${Local_Ethernet_IP:-${Local_Wifi_IP}}${suffix}")

    CPU_Name=$(head -n 5 /proc/cpuinfo | grep "model name" | awk -F ": " '{print $2}')
    CPU_Temp="$(($(if [ -e /sys/class/thermal/thermal_zone1/temp ]; then cat /sys/class/thermal/thermal_zone1/temp; else echo '00'; fi)/1000))°C"

    not_intercept_gpu_info=$(lspci | grep -i VGA | awk -F ":" '{print $3}' | sed 's/^[ ]*//g')
    intercept_gpu_info=$(lspci  | grep -i VGA | awk -F ":" '{print $3}' | grep -o '\[.*\]')
    Unrecognized=$(echo -e "${white}Unrecognized${suffix}")
    GPU_Info_0="${intercept_gpu_info:-$not_intercept_gpu_info}"
    GPU_Info="${GPU_Info_0:-$Unrecognized}"

    Memory_Info=$(($(sed -n '1,1p' /proc/meminfo | awk '{print $2}')/1000000))
    clear; printf "
${white}         _             _       _     _                     
${green}        / \   _ __ ___| |__   | |   (_)_ __  _   ___  __   
${blue}       / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /    
${yellow}      / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   
${red}     /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\     
${bx}-----------------------  Script Info  -----------------------${suffix}
${green} Script Name:\t%s.
${green} Boot Mode:\t%s ${red}- %s
${green} Patterns: \t%s ${red}- %s
${green} Ethernet: \t%s ${red}- %s
${green} Wifi_net: \t%s ${red}- %s
${green} SSH:      \t${white}ssh %s@%s
${green} CPU&Temp: \t%s ${white}&${suffix} ${green}%s
${green} GPU_Info: \t%s
${green} Memory:   \t%sG
${red}--=--*--=--*--=--*--=--*--=--=*=--=--*--=--*--=--*--=--*--=--${suffix}" \
"$Script_Version" "$Boot_Type" "$Disk_Type" "$Chroot_Patterns_Print" "$Start_Patterns" \
"$Local_Ethernet_IP" "$Ethernet_Name" "$Local_Wifi_IP" "$Wifi_Name" \
"$USER" "$SSH_IP" "$CPU_Name" "$CPU_Temp" "$GPU_Info" "$Memory_Info" 
}

# @正常(Normal)环境下，首页会显示的列表
function NormalHomeList(){
    echo -e "
${outB}\t${white}[${blue}1${white}]${green} Configure Mirrorlist   ${suffix}
${outB}\t${white}[${blue}2${white}]${green} Configure Network      ${suffix}
${outG}\t${white}[${blue}3${white}]${green} Configure SSH          ${suffix}
${outY}\t${white}[${blue}4${white}]${green} Installation Desktop   ${suffix}
${outY}\t${white}[${blue}5${white}]${green} Installation Drive     ${suffix}
${outY}\t${white}[${blue}6${white}]${green} Install virtual tools  ${suffix}
${outY}\t${white}[${red}D${white}]${green} Delete scripts & caches ${suffix}
${outR}\t${white}[${red}Q${white}]${green} Exit Script             ${suffix}"   
}

# @LiveCD环境下，首页会显示的列表
function LivecdHomeList(){ 
    echo -e "
${outB}\t${white}[${blue}1${white}]${green} Configure Mirrorlist${suffix}
${outB}\t${white}[${blue}2${white}]${green} Configure Network   ${suffix}
${outG}\t${white}[${blue}3${white}]${green} Configure SSH       ${suffix}
${outY}\t${white}[${blue}4${white}]${green} Install System      ${suffix}
${outR}\t${white}[${red}Q${white}]${green} Exit Script          ${suffix}"   
}

# @首选项 [4] 的列表
function Livecd_System_Module_List(){
    echo -e "
\n\t${white}*** ${red}Install System Module ${white}***${suffix}  
---------------------------------------------
${outY} \t${white}[${blue}1${white}]${green}  Disk Partition         ${red}**${suffix}
${outY} \t${white}[${blue}2${white}]${green}  Install System Files   ${red}**${suffix}
${outY} \t${white}[${blue}3${white}]${green}  Configurt System       ${red}**${suffix}
${outG} \t${white}[${blue}4${white}]${green}  Installation Desktop    ${blue}*${suffix}
${outG} \t${white}[${blue}11${white}]${green}${green} Installation Drive      ${blue}*${suffix}
${outY} \t${white}[${blue}22${white}]${green}${green} Install virtual tools   ${blue}*${suffix}" 
}

# @系统安装成功, 直奔加入chroot的提示信息
function InstallSystemInfo(){
    sleep 1; echo -e "\n
${wg}+-====================================================-+${suffix}
${wg}|::  System components installation completed.         |${suffix}
${wg}|::  Entering chroot mode.                             |${suffix}
${wg}|::  Execute in 3 seconds.                             |${suffix}
${wg}|::  Later operations are oriented to the new system.  |${suffix}
${wg}+-====================================================-+${suffix}"
}

# @完成系统配置成功, 可重启的提示信息
function ConfigSystemInfo(){
    printf "
${ws}+-====================================================-+${suffix}
${ws}|::                 Exit in 3/s                        |${suffix}
${ws}|:: When finished, restart the computer.               |${suffix}
${ws}|:: If there is a problem during the installation      |${suffix}
${ws}|:: Please contact me. QQ:%s or Group:%s|${suffix}
${ws}+-====================================================-+${suffix}" "2763833502" "346952836"
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

# @输出SSH信息, 需要接收: 1=用户名, 2=用户密码, 3=有线IP, 4=无线IP
function SSH_INFO(){   
    USER=$1
    CONF_Password_SSH=$2
    Local_Ethernet_IP=$3
    Local_Wifi_IP=$4
    if netcap | grep sshd &>/dev/null ; then
        SSH_Port=$(netcap | grep sshd)
        SSH_status=$(echo -e "${out_WELL} ${white}SSH service successfully started.${suffix}")
    else 
        SSH_status=$(echo -e "${out_ERROR} ${white}SSH service startup failed.${suffix}")
    fi 
    echo -e "
${green} -------------${white} Connection method ${green}------------- ${suffix}
[$USER@$HOSTNAME ~]$ ssh $USER@${Local_Ethernet_IP:-${Local_Wifi_IP}}

 Enter username -=> ${white}$USER${suffix}
 Enter password -=> ${white}$CONF_Password_SSH${suffix}
${green} -----------${white} SSH Port Information ${green}------------ ${suffix}
${SSH_Port}
${SSH_status}
${green} --------------------------------------------- ${suffix}"
}

# @Auins的帮助文档 Auin_help
function Auins_usage() {
    echo -e "
:: Auins is a script for ArchLinux installation and deployment.
usage: ${0##*/} [-h] [-V] command ...

    Install Commands: (\"-R = uninstall\"):
        font    Install Fonts, Options: [all], [common], [adobe], [code].
        fcitx   Automatic installation 'fcitx' input method, Other options: [-R].
        ibus    Automatic installation 'ibus-rime' input method, Other options: [-R].
        axel    Automatic installation 'Axel' (Pacman multi threaded download), Other options: [-R].
        inGpu   Install Video card driver ( \"Nvidia\" \ \"Amdgpu\" ).
        inVmt   Install Vmware/Virtualbox Tools and exit.
        
    Settings Options:
        -m, --mirror        Automatically configure mirrorlist file and exit.
        -w, --wifi          Connect to a WIFI and exit.
        -s, --openssh       Open SSH service (default password: 123456) and exit.
             
    Global Options:
        -e, --edit-conf     Edit (\"local/profile.conf\").
        -f, --view-conf     View (\"local/profile.conf\").
        -i, --view-info     View (\"local/auins.info\").
        -c, --clean-cache   Delete scripts and other caches.
        -h, --help          Show this help message and exit.
        -v, --version       Show the conda version number and exit.
        "
}

# @Auins版本信息
function version(){    
    echo -e "${wg} ${Script_Version} ${suffix}
Copyright (C) 2020 - 2023 Auroot.                   
URL GitHub: https://github.com/Auroots/Auins 
URL Gitee : https://gitee.com/auroot/Auins   
                                            
Contact information:                         
            QQ: 2763833502                   
            QQ Group: 346952836              
"
}     

# 具体的实现 >> >> >> >> >> >> >> >> 
Set_Color_Variable
case ${1} in
    # Auins版本信息
    "version"   ) version ;; 
    # Script首页信息, 需要接收: 
    # 1=版本号(Script_Version), 2=引导类型(Boot_Type), 3=磁盘类型(Disk_Type), 4=Chroot状态(Chroot_Patterns_Print) 5=脚本开启模式(Start_Patterns)
    # 6=有线IP(Local_Ethernet_IP), 7=有线网卡名(Ethernet_Name), 8=无线IP(Local_Wifi_IP), 9=无线网卡名(Wifi_Name)
    "logos"     ) logos "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}";; 
    # 输出SSH信息, 需要接收: 1=用户名, 2=用户密码, 3=有线IP, 4=无线IP
    "SSH_INFO"  ) SSH_INFO "$2" "$3" "$4" "$5" "$6" "$7";;
     # Auins的帮助文档 Auin_help
    "Auins_usage"   ) Auins_usage ;;
    # LiveCD环境下，首页会显示的列表
    "LivecdHomeList" ) LivecdHomeList ;; 
    # 正常(Normal)环境下，首页会显示的列表
    "NormalHomeList" ) NormalHomeList ;; 
    # 桌面环境的选择列表
    "DesktopEnvList" ) DesktopEnvList ;; 
    # 桌面管理器的选择列表
    "DesktopManagerList") DesktopManagerList ;; 
    # 首选项 [4] 的列表
    "Livecd_System_Module_List" ) Livecd_System_Module_List;; 
    # 系统安装成功, 直奔加入chroot的提示信息
    "InstallSystemInfo"     ) InstallSystemInfo ;; 
    # 完成系统配置成功, 可重启的提示信息
    "ConfigSystemInfo"      ) ConfigSystemInfo ;; 
    # JetBrainsFira字体安装完成后的使用说明
    "JetBrainsFira_font_usage"  ) JetBrainsFira_font_usage 
esac

# Print_INFO [想要输出的信息] [附加输入的信息]...... 

# 如何查看网卡名
# cat /proc/net/dev | awk '{if($2>0 && NR > 2) print substr($1, 0, index($1, ":") - 1)}'