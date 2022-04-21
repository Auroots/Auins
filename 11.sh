#!/bin/bash



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
    function Logos(){
        echo -e "
${white}          _             _       _     _                    ${suffix}
${green}         / \   _ __ ___| |__   | |   (_)_ __  _   ___  __  ${suffix}
${blue}        / _ \ | '__/ __| '_ \  | |   | | '_ \| | | \ \/ /  ${suffix}
${yellow}       / ___ \| | | (__| | | | | |___| | | | | |_| |>  <   ${suffix}
${red}      /_/   \_\_|  \___|_| |_| |_____|_|_| |_|\__,_/_/\_\  ${suffix}

${blue}||============================================================||${suffix}
${blue}|| Script Name:    ${Version}.                                  ${suffix}
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

Set_Color_Variable
Logos