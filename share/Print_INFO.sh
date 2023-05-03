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
    # wa='\033[1;46m'; bx='\033[1;4;36m'  #白青 \ 蓝 下划线
    #-----------------------------#
    # 提示 蓝 红 绿 黄
    outB="${white}::${blue} =>${suffix}"; # outR="${white}::${red} =>${suffix}"
    outG="${white}::${green} =>${suffix}"; outY="${white}::${yellow} =>${suffix}"
}


# @Script首页信息, 需要接收: 1=版本号, 2=引导类型, 3=磁盘类型, 4=Chroot状态, 5=脚本开启模式, 6=CPU名称
function logos(){
    Script_Version="$1" 
    Boot_Type="$2" 
    Disk_Type="$3" 
    ChrootPatterns_Print="$4" 
    StartPatterns="$5" 
    CPU_Name="$6"
    clear;  echo -e "
${white}        _             _       _     _                     ${suffix}
${green}       / \   _ __ ___| |__   | |   (_)_ __  _   ___  __   ${suffix}
${blue}      / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /    ${suffix}
${yellow}     / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   ${suffix}
${red}    /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\     ${suffix}
${red}----------------------------------------------------------${suffix}
${green} Script Name: ${Script_Version}.${suffix}
${green} Boot Mode:   ${white}[${blue}${Boot_Type}${white}] ${red}- ${white}[${blue}${Disk_Type}${white}]${suffix}      
${green} Patterns:    ${ChrootPatterns_Print} ${red}-${suffix} ${StartPatterns}${suffix}
${green} Ethernet:    ${blue}${Local_Ethernet_IP:-No network.} ${red}- ${white}[${green}${Ethernet_Name:-No}${white}]${suffix}
${green} WIFI:        ${blue}${Local_Wifi_IP:-No network.} ${red}- ${white}[${green}${Wifi_Name:-No}${white}] ${suffix}
${green} SSH:         ${white}ssh ${blue}$USER@${blue}${Local_Ethernet_IP:-${Local_Wifi_IP}}${suffix}
${green} CPU Info:    ${blue}${CPU_Name}${suffix}  
${red}==========================================================${suffix}"   
}

# @正常(Normal)环境下，首页会显示的列表
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

# @LiveCD环境下，首页会显示的列表
function LivecdHomeList(){ 
    echo -e "
${outB} \t${green}Configure Mirrorlist   ${white}[${blue}1${white}]${suffix}
${outB} \t${green}Configure Network      ${white}[${blue}2${white}]${suffix}
${outG} \t${green}Configure SSH          ${white}[${blue}3${white}]${suffix}
${outY} \t${green}Install System         ${white}[${blue}4${white}]${suffix}
${outG} \t${green}Exit Script            ${white}[${red}Q${white}] ${suffix}"   
}

# @首选项 [4] 的列表
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

# @系统安装成功, 直奔加入chroot的提示信息
function InstallSystemInfo(){
    sleep 1; echo -e "\n
${wg}#======================================================#${suffix}
${wg}#::  System components installation completed.         #${suffix}
${wg}#::  Entering chroot mode.                             #${suffix}
${wg}#::  Execute in 3 seconds.                             #${suffix}
${wg}#::  Later operations are oriented to the new system.  #${suffix}
${wg}#======================================================#${suffix}"
}

# @完成系统配置成功, 可重启的提示信息
function ConfigSystemInfo(){
    echo -e "
${ws}#======================================================#${suffix}
${ws}#::                 Exit in 3/s                        #${suffix}
${ws}#::  When finished, restart the computer.              #${suffix}
${ws}#::  If there is a problem during the installation     #${suffix}
${ws}#::  Please contact me. QQ:2763833502                  #${suffix}
${ws}#======================================================#${suffix}"
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
    SSH_Port=$(netcap | grep sshd)
    echo -e "
${green} -------------${white} Connection method ${green}------------- ${suffix}
[$USER@$HOSTNAME ~]$ ssh $USER@${Local_Ethernet_IP:-${Local_Wifi_IP}}

 Enter username -=> ${white}$USER${suffix}
 Enter password -=> ${white}$CONF_Password_SSH${suffix}

${green} -----------${white} SSH Port Information ${green}------------ ${suffix}
${SSH_Port}

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
Copyright (C) 2022 Auroot.                   
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
    "version"   ) version ;; # Auins版本信息
    "logos"     ) logos "$2" "$3" "$4" "$5" "$6" "$7";; # Script首页信息, 需要接收: 1=版本号, 2=引导类型, 3=磁盘类型, 4=Chroot状态, 5=脚本开启模式, 6=CPU名称
    "SSH_INFO"  ) SSH_INFO "$2" "$3" "$4" "$5" "$6" "$7";; # 输出SSH信息, 需要接收: 1=用户名, 2=用户密码, 3=有线IP, 4=无线IP
    "Auins_usage"   ) Auins_usage ;; # Auins的帮助文档 Auin_help
    "LivecdHomeList" ) LivecdHomeList ;; # LiveCD环境下，首页会显示的列表
    "NormalHomeList" ) NormalHomeList ;; # 正常(Normal)环境下，首页会显示的列表
    "DesktopEnvList" ) DesktopEnvList ;; # 桌面环境的选择列表
    "DesktopManagerList") DesktopManagerList ;; # 桌面管理器的选择列表
    "Livecd_System_Module_List" ) Livecd_System_Module_List;; # 首选项 [4] 的列表
    "InstallSystemInfo"     ) InstallSystemInfo ;; # 系统安装成功, 直奔加入chroot的提示信息
    "ConfigSystemInfo"      ) ConfigSystemInfo ;; # 完成系统配置成功, 可重启的提示信息
    "JetBrainsFira_font_usage"  ) JetBrainsFira_font_usage # JetBrainsFira字体安装完成后的使用说明
esac

# Print_INFO [想要输出的信息] [附加输入的信息]...... 