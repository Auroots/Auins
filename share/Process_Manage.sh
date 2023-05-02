#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Process Management. -> auin V4.6
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x
out_WARNING="\033[1;37m::\033[1;33m [ Warning ] =>\033[0m"
function Kill_Process(){
    Restart_shell_file=$1
    Scrips=$2
    Process_PID_List=$(/usr/bin/ps -ef | grep "${Restart_shell_file}" | grep -v grep | grep -v "$Scrips" | awk '{print $2}')

    echo "$Process_PID_List" | while read -r Kill_Process_PID
    do
        kill "$Kill_Process_PID" 2> /dev/null
    done 
}
function Stript_Process_Management(){
    Exec_status="$1"   # 启动 重启 停止
    Process_Path="$2"  # 脚本 或者 进程
    Scrips="$3"
    case ${Exec_status} in
        start   )   bash "${Process_Path}"; echo -e "\033[1;33m${Process_Path}\033[1;32m has been Start.\033[0m" ;;
        restart )   Kill_Process "$Process_Path" "$Scrips";
                    bash "${Process_Path}" || "${Process_Path}"
                    echo -e "\033[1;33m${Process_Path}\033[1;32m has been Start.\033[0m" ;;
        stop    )   Kill_Process "$Process_Path" "$Scrips"
                    echo -e "\n${out_WARNING}  \033[1;37m\"${Process_Path}\"\033[1;32m\033[1;32m has been Stopped.\033[0m";;
        *       )   exit 1
    esac    
}

Stript_Process_Management "$1" "$2" "$0" # 1.状态 2.可执行文件

