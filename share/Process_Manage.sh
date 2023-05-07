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
# feedback successfully info
function feed_status(){ 
    if [ $? = 0 ]; then 
        echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${1}\033[0m$(tput sgr0)"; 
    else 
        err "$2"
    fi
}

function Stript_Process_Management(){
    Exec_status="$1"   # 启动 重启 停止
    Process_Path="$2"  # 脚本 或者 进程
    Output_Info="$3"    # 需要输出的错误信息
    case ${Exec_status} in
        start   )   
                    bash "$Process_Path" \
                    && feed_status "Start running: [\033[1;37m $Process_Path \033[1;32m]." "Run failed: [\033[1;37m $Process_Path \033[1;31m]."
                ;;
        restart )   
                    kill "$(pgrep -f "$Process_Path" | sed "s/$$//g")" &> /dev/null
                    sleep 0.1; clear
                    bash "$Process_Path" || "$Process_Path" \
                    && feed_status "Restart running: [\033[1;37m $Process_Path \033[1;32m]." "Run failed: [\033[1;37m $Process_Path \033[1;31m]."
                ;;
        stop    )   
                    kill "$(pgrep -f "$Process_Path" | sed "s/$$//g")" &> /dev/null
                    sleep 0.1; clear
                    warn "\033[1;37m\"$Process_Path\"\033[1;33m has been Stopped.\033[0m"
                    [[ $Output_Info == "" ]] && echo &>/dev/null || err "$Output_Info";
                ;;
        *       ) 
                    exit 1
    esac    
}

Stript_Process_Management "$1" "$2" "$3" # 1.状态 2.可执行文件 3.需要输出的错误信息