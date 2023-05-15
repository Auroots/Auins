#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Mini Module Manager -> Auins v4.7.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x

function include(){
    declare -a argu=("$@")
    export config_File info_File local_Dir
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    local_Dir="${argu[2]}"
    main_option="${argu[3]}"
    other_option_1="${argu[4]}"
    other_option_2="${argu[5]}"
    other_option_3="${argu[6]}"
    other_option_4="${argu[7]}"

    Auins_api_file="${local_Dir}/api.json" 
}

set -e
# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run(){ echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip(){ echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }
# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white(){ printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# Tips output colour: yellow
function tips_yellow(){ printf "\033[1;37m:: $(tput bold; tput setaf 7)\033[1;33m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# feedback successfully info
function feed_status(){ 
    if [ $? = 0 ]; then 
        echo -e "\033[1;37m:: $(tput bold; tput setaf 2)=> \033[1;32m${1}\033[0m$(tput sgr0)"; 
    else 
        err "$2"
    fi
}

# check for root privilege
function check_priv(){
  if [ "$(id -u)" -ne 0 ]; then
    # err "you must be root"
    err "Please use command: \033[1;33m\"sudo\"\033[1;31m or user: \033[1;33m\"root\"\033[1;31m to execute.\033[0m"
  fi
}

# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
function File_RW_Manage(){
    local format=" = "; parameter="$3"; content="$4"; itself=$(echo "$0" | awk -F"/" '{print $NF}')
    case "$1" in
        CONF) local Files="$config_File" ;;
        INFO) local Files="$info_File" ;;
    esac
    case "$2" in
        Read ) 
                read_info=$(grep -w "$parameter" < "$Files") # 在文件中查找匹配的值
                if [ -n "$read_info" ]; then 
                    echo "$read_info" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' 
                else
                    warn "\033[1;37m${itself} \033[1;33mRead file: \033[1;37m${Files}\033[1;33m missing value: [\033[1;37m ${parameter}  \033[1;33m]."
                    sleep 1.5
                fi
         ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';) # 在文件中查找匹配的值, 并打印行号
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "\033[1;37m${itself} \033[1;33mWrite file: \033[1;37m${Files}\033[1;33m missing value: [\033[1;37m ${parameter}  \033[1;33m] + [\033[1;37m $content \033[1;33m]."
                    sleep 1.5
                fi
    esac 
}

# @输出磁盘表及UUID
function showDisk(){ echo; lsblk -o+UUID;}

# @检查磁盘名是否合法
function testDisk(){ 
    local Disk_name=$1 Disk_Test_Status="" 
    if echo "${Disk_name}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^vd[a-z]$|^nvme[0-9]n[0-9]$|^mmcblk[0-9]$" &> /dev/null; then
        Disk_name=$(echo "${Disk_name}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^vd[a-z]$|^nvme[0-9]n[0-9]$|^mmcblk[0-9]$")
    else 
        Disk_Test_Status="ERROR"
    fi
    if [ -e "/dev/${Disk_name}" ]; then
        Disk_name=$(echo "${Disk_name}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^vd[a-z]$|^nvme[0-9]n[0-9]$|^mmcblk[0-9]$")
    else 
        Disk_Test_Status="ERROR"
    fi
    if [[ "$Disk_Test_Status" != "ERROR" ]]; then
        echo "$Disk_name"
    else 
        echo "$Disk_Test_Status"
    fi 
}

# @检查分区名是否合法
function testPartition(){ 
    local Partition_name=$1 Partition_Test_Status="" 
    if echo "${Partition_name}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]$|^vd[a-z][1-9]$|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$" &> /dev/null; then
        Partition_name=$(echo "${Partition_name}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]$|^vd[a-z][1-9]$|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$")
    else 
        Partition_Test_Status="ERROR"
    fi
    if [ -e "/dev/${Partition_name}" ]; then
        Partition_name=$(echo "${Partition_name}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]$|^vd[a-z][1-9]$|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$")
    else 
        Partition_Test_Status="ERROR"
    fi
    if [[ "$Partition_Test_Status" != "ERROR" ]]; then
        echo "$Partition_name"
    else 
        echo "$Partition_Test_Status"
    fi 
}

function Process_Manager(){
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
                    kill "$(pgrep -f "$Process_Path")" &> /dev/null
                ;;
        *       ) 
                    exit 1
    esac    
}

# 创建临时目录,脚本退出后自动删除,正常运行时,cd到目录
# make a temporary directory and cd into
function make_tmp_dir(){
    tmp="$(mktemp -d /tmp/Auins_strap.XXXXXXXX)"
    trap 'rm -rf $tmp' EXIT
    cd "$tmp" || err "Could not enter directory $tmp"
}
# https://ipdata.co/flags/cn.png
# https://api.ip.sb/geoip
# api查询地区 IP 国家等消息, 获取途径不一样,即匹配方式也不一样
ip_api(){
    [ ! -e "$Auins_api_file" ] && curl -fsSL --fail http://ip-api.com/json > "$Auins_api_file"
    case $1 in 
        region  ) show=regionName ;; # 省份
        country ) show=country ;; #国家
        country_code) show=countryCode ;; #国家简写
        timezone) show=timezone ;; # 时区
        proxy) show=proxy ;; # 代理
    esac
    sed 's#,#\n#g' "$Auins_api_file" | sed 's#"##g' | grep -w "$show" | awk -F':' '{print $2}'
}
ipapi(){
    [ ! -e "$Auins_api_file" ] &&  curl -fsSL --fail https://ipapi.co/json > "$Auins_api_file"
    case $1 in 
        ip      ) show=ip ;;
        region  ) show=region ;; # 省份
        country ) show=country_name ;; #国家
        country_code) show=country_code ;; #国家简写
        timezone) show=timezone ;; # 时区null
    esac
    grep -w "$show" "$Auins_api_file" | sed 's#,##g' | sed 's#"##g' | awk -F':' '{print $2}'
}
ipinfo(){ 
    [ ! -e "$Auins_api_file" ] &&  curl -fsSL --fail https://ipinfo.io/json > "$Auins_api_file"
    case $1 in 
        ip      ) show=ip ;;
        country_code) show=country ;; #国家简写
        timezone) show=timezone ;; # 时区
    esac
    grep -w "$show" "$Auins_api_file" | sed 's#,##g' | sed 's#"##g' | awk -F':' '{print $2}'
}
# 获取ip
ipify(){
    curl -fsSL --fail https://api.ipify.org
}

main(){
    main_option=$1
    case $main_option in 
# 警告
        warn) warn "$2" ;;
# 开始运行
        run ) run "$2" ;;
# 跳过
        skip) skip "$2" ;;
# 错误
        err ) err "$2" ;;
# 提示输入-白
        tips_w ) tips_white "$2" ;;
# 提示输入-黄
        tips_y ) tips_yellow "$2" ;;
# 结果提示, 1:正常结束要显示的信息, 2:非正常结束要显示的信息
        feed ) feed_status "$2" "$3" ;;
# 获取用户输入
        read ) Read_user_input "$2" ;;
# 读写文件 
        file_rw ) File_RW_Manage "$2" "$3" "$4" "$5" ;;
# 创建临时目录
        mt_dir ) make_tmp_dir ;;  
# 检查权限,如果非root,则退出
        ck_p ) check_priv ;;
# 输出磁盘表及UUID
        show_Disk ) showDisk ;;
# 检查磁盘名是否合法
        test_Disk ) testDisk "$2";;
# 检查分区名是否合法
        test_Part ) testPartition "$2";;
# 进程管理 1:{start|restart|stop}, 2[进程名], 3:[需要输出的错误信息]
        process ) Process_Manager "$2" "$3" "$4";;
# 使用ip-api.com获取信息
        ip_api) ip_api "$2" ;;
# 使用ipapi.co获取信息
        ipapi) ipapi "$2";;
# 使用https://ipinfo.io获取信息
        ipinfo) ipinfo "$2";;
# 使用https://api.ipify.org获取ip
        ipify) ipify;;
    esac
}

include "$@"
main "$main_option" "$other_option_1" "$other_option_2" "$other_option_3" "$other_option_4"
set +e