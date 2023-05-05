#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Process Management. -> auin V4.6 r7
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x
# Error message wrapper
function err(){ 
    echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; 
    } 
# Warning message wrapper
function warn(){ 
    echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; 
}

function Stript_Process_Management(){
    Exec_status="$1"   # 启动 重启 停止
    Process_Path="$2"  # 脚本 或者 进程
    Print_INFO="$3"    # 需要输出的错误信息
    case ${Exec_status} in
        start   )   
                    bash "$Process_Path"; echo -e "\033[1;33m$Process_Path\033[1;32m has been Start.\033[0m" ;;
        restart )   
                    kill $(pgrep -f "$Process_Path") &> /dev/null
                    bash "$Process_Path" || "$Process_Path"
                    echo -e "\033[1;33m$Process_Path\033[1;32m has been Start.\033[0m" ;;
        stop    )   
                    kill $(pgrep -f "$Process_Path") &> /dev/null
                    err "$Print_INFO"
                    warn "\033[1;37m\"$Process_Path\"\033[1;33m has been Stopped.\033[0m" 
                    sleep 2;;
        *       ) 
                    exit 1
    esac    
}

Stript_Process_Management "$1" "$2" "$3" # 1.状态 2.可执行文件 3.需要输出的错误信息