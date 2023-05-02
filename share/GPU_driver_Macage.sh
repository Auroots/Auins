#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure GPU Driver -> auin V4.6
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
echo &>/dev/null

Auins_Config=${1}
Auins_record=${2}
# Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
# Share_Dir="${Auins_Dir}"

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';)
                sed -i "${List_row:-Not}c ${parameter}${format}${content}" "$Files" 2>/dev/null
    esac
}
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }


function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    # red='\033[1;31m'; 
    green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     
    #-----------------------------#
    # rw='\033[1;41m'  #--红白
    # wg='\033[1;42m'; ws='\033[1;43m'      #白绿 \ 白褐
    #wb='\033[1;44m'; wq='\033[1;45m'    #白蓝 \ 白紫
    # wa='\033[1;46m'; bx='\033[1;4;36m'  #白青 \ 蓝 下划线
    #-----------------------------#
    # 交互: 蓝  红 \ 绿 黄
    inB=$(echo -e "${blue}-=>${suffix} "); # inR=$(echo -e "${red}-=>${suffix} ")
    # inG=$(echo -e "${green}-=>${suffix} "); inY=$(echo -e "${yellow}-=>${suffix} ")
    #-----------------------------
    # 提示 蓝 红 绿 黄
    # outB="${white}::${blue} =>${suffix}"; # outR="${white}::${red} =>${suffix}"
    outG="${white}::${green} =>${suffix}"; 
    # outY="${white}::${yellow} =>${suffix}"

    # out_SKIP="${white}::${yellow} [Skip] =>${suffix}"
    # out_WARNING="${white}::${yellow} [Warning] =>${suffix}"
    # out_EXEC="${white}::${blue} [Exec] =>${suffix}"
    # out_WELL="${white}::${green} [Well] =>${suffix}"
    # out_ERROR="${white}::${red} [Error] =>${suffix}"
}

Set_Color_Variable
# @Install GPU Driver 安装显卡驱动
function Install_GPU_Driver(){
    lspci -k | grep -A 2 -E "(VGA|3D)"  
    CONF_PGK_Nvidia_Driver=$(Config_File_Manage CONF Read "PGK_Nvidia_Driver")
    printf "\n${outG} ${yellow}Whether to install the Nvidia driver? [y/N]:${suffix} %s" "$inB"
    case $(Read_user_input) in
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