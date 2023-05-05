#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure GPU Driver -> auin V4.6 r5
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

# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    PM_Enter_3=${3}
    case ${PM_Enter_1} in
        start)   bash "$Process_Manage" start "${PM_Enter_2}" "${PM_Enter_3}" ;;
        restart) bash "$Process_Manage" restart "${PM_Enter_2}" "${PM_Enter_3}" ;;
        stop)    bash "$Process_Manage" stop "${PM_Enter_2}" "${PM_Enter_3}"
    esac
}

# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white() { printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run() { echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip() { echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }

# 红 绿 黄 蓝 白 后缀
# red='\033[1;31m'; 
green='\033[1;32m'  
yellow='\033[1;33m'; blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m'     

# @Install GPU Driver 安装显卡驱动
function Install_GPU_Driver(){
    lspci -k | grep -A 2 -E "(VGA|3D)"  
    CONF_PGK_Nvidia_Driver=$(Config_File_Manage CONF Read "PGK_Nvidia_Driver")
    tips_white "Whether to install the Nvidia driver? [Y/n]?"
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