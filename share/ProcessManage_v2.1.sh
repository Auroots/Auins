#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Process Manages v2.1 
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x
for i in "$@"; do
    num=$((num + 1))
    Value[$num]="$i"
done
if [ "${#Value[@]}" -eq 3 ];then
    _Bool_value=0
else
    _Bool_value=1
fi 

# 启动 重启 停止 查看状态
readonly _Exec_status_="${Value[1]}"   
# 脚本 或者 进程
 _APP_EXEC_="${Value[2]}" 
# 日志存放地址 可选
readonly _Journal_File_="${Value[3]}"
# 找出主程序绝对地址
Program_dir=$(echo "${_APP_EXEC_}" | awk -F " " '{print $1}')
# 找出主程序名称
Main_program=$(echo "${Program_dir}" | awk -F "/" '{print $NF}')
# 找出脚本名称
Script_Name=$(echo "${_APP_EXEC_}" | awk -F " " '{print $NF}' | awk -F "/" '{print $NF}')
if echo "${Main_program}" | grep -E '[bash | python | lua]' > /dev/null ; 
then 
    _APP_EXEC_="${Script_Name}"
fi
# 找出相关PID进程
Script_PID=$(pgrep -f "${0}")
whole_PID=$(pgrep -f "${_APP_EXEC_}" | awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}')

# @屏蔽Script PID及Script周边的PID，防止引发错误(没有办法中的办法)
# @发现使用Script获取某进程PID，会将Script的PID也显示出来。
DEL_VALUE_14=$((Script_PID + 14))
DEL_VALUE_15=$((Script_PID + 15))
DEL_VALUE_16=$((Script_PID + 16))
DEL_VALUE_17=$((Script_PID + 17))
DEL_VALUE_18=$((Script_PID + 18))
DEL_VALUE_21=$((Script_PID + 21))
Arr_ID=("$Script_PID" "$DEL_VALUE_14" "$DEL_VALUE_15" "$DEL_VALUE_16" "$DEL_VALUE_17" "$DEL_VALUE_18" "$DEL_VALUE_21")
function func_exclude_components(){
	for((i=0; i<${#Arr_ID[@]}; i++)); do
		whole_PID=(${whole_PID[@]/${Arr_ID[i]}})
	done
}
func_exclude_components
Process_PID="${whole_PID[*]}"

# @脚本颜色变量
function Set_Color_Variable(){
    r='\033[1;31m'  #---红
    g='\033[1;32m'  #---绿
    y='\033[1;33m'  #---黄
    w='\033[1;37m'  #---白
    h='\033[0m'     #---后缀
    # 提示 白 红 绿 黄
    PSW=$(echo -e "${w} ::${h}")
    PSR=$(echo -e "${r} ::${h}")
    PSG=$(echo -e "${g} ::${h}")
    PSY=$(echo -e "${y} ::${h}")
}

# @输入错误，提示如何使用
function usage() {
    printf "Case: sh run.sh \n\t[start|stop|restart|status] [\"Command\"]\nor\n"
    printf "\t[start|stop|restart|status] [Journal File] [\"Command\"]\n"
    printf "\t  [stop | stops] Ordinary and Compulsory.\n"
    printf "\t  [\"Command\"] Must be in double quotation marks: \" \".\n"
    printf "\t  (Optional) Journal File.\n"
    exit 1
}

# @判断程序是否正在运行, 如果正在运行，即找出PID
function isExist(){
    if [ -z "${Process_PID}" ]; then
        return 1
    else
        return 0
    fi    
}
# @启动
function start(){
    if  isExist ; then
        printf "$PSG This is the \"%s\" script. \n" "${Main_program}"
        printf "$PSG Is already running: %s. \n" "${_APP_EXEC_}" 
        printf "$PSG This is PID: %s. \n" "${Process_PID}" 
    else
        # 调用 Shell 的三种方式：fork, source, exec
        exec ${_APP_EXEC_} > /dev/null 2>&1 &
        printf "$PSG This is PID: %s. \n" "${Process_PID}" 
        printf "$PSG Start success: %s. \n" "${_APP_EXEC_}"
        printf "$PSG This is the \"%s\" script. \n" "${Main_program}" 
    fi    
}
# @停止
function stop(){
    if isExist ; then
        # SIGTERM：此信号请求一个进程停止运行。此信号是可以被忽略的。进程可以用一段时间来正常关闭，一个程序的正常关闭一般需要一段时间来保存进度并释放资源。换句话说，它不是强制停止。
        # SIGKILL：此信号强制进程立刻停止运行。程序不能忽略此信号，而未保存的进度将会丢失。
        # "-9"代表着SIGKILL信号。
        # "-15"代表着SIGTERM信号。
        # kill -l 得到指定信号的数值 is Ended
        if [ "$1" != "force" ]; then
            kill -15 ${Process_PID}
        else
            kill -9 ${Process_PID}
        fi
        printf "$PSG This is the \"%s\" script. \n" "${Main_program}"
    else
        printf "$PSY Is Not running: $g%s$h. \n" "${_APP_EXEC_}" 
    fi    
}
# @查看状态
function status(){ 
    if isExist ; then
        printf "$PSG This is the \"%s\" script. \n" "${Main_program}"
        printf "$PSG Is running: %s. \n$PSG Pid: %s.\n" "${_APP_EXEC_}" "${Process_PID}"
    else
        printf "$PSW Is not running: %s.\n" "${_APP_EXEC_}"
    fi  
}
# @重启
function restart(){
    stop 2>&1
    start 2>&1
    if ! isExist ; then
        printf "$PSR Restart fail: %s.\n" "${_APP_EXEC_}"
    else
        printf "$PSG Restart success: %s.\n" "${_APP_EXEC_}" 
    fi  
}

# 日志 使用方法 printf_ligs [日志存放路径] [$(函数) 或 commd]
print_logs(){
    local Times
    Times="$(date '+%Y年%m月%d日 %T')"
    # 只显示第一行，并排除空格
    # local address=$(echo "${@}" | awk '{print $1}')
    # 不显示第一行，并排除空格
    # local output=$(echo "${@}" | awk '{$1=" ";print $0}' | tr -s ' ' ' ')
    if [ $_Bool_value -eq 0 ]; then
        printf "%s\n" "${1}"
        printf "\n%s : %s.\n" "${Times}" "${1}" >> "${_Journal_File_}" 
    else 
        return 0;
    fi
}
# @执行函数
function main(){
    Set_Color_Variable
    # isExist
    case ${_Exec_status_} in
        "start")
            print_logs "$(start)";
        ;;
        "stop")
            print_logs "$(stop)";
        ;;
        "stops")
            print_logs "$(stop force)";
        ;;
        "status")
            status
        ;;
        "restart")
            print_logs "$(restart)";
        ;;
        *)
            usage;
        ;;
    esac   
}

# clear;
main "${_Exec_status_}" # 1.状态 2.可执行文件











