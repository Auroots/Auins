#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Edit Database -> auin V4.3
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

echo &>/dev/null
# set -xe
Auins_record="${1}/auins.info"  # Configure file
Auins_Config="${1}/install.conf"  # Configure file
List_Operations=${2}  # 表操作 -> 读取: _Read_ / 写入: _Write_
File_Options=${3}     # 对那个表进行操作 -> 配置表: _Conf_ / 信息表: _Info_
List_Parameter=${4}   # 头部参数
List_Value=${5}       # 写入时使用，对 “头部参数” 设定值；

case ${File_Options} in
    _Conf_) Specify="${Auins_Config}" ;;
    _Info_) Specify="${Auins_record}" ;;
esac

for i in {5..100}
do
    List=$(sed -n "${i}p" "${Specify}")
    
    if echo "${List}" | grep "${List_Parameter}"  &> /dev/null; then 
        List_row=${i}
        case ${List_Operations} in
            _Read_)
                sed -n "${List_row:-0}p" "${Specify}" | cut -d" " -f3 2>/dev/null; exit 0; 
        ;;
            _Write_)
                format=" = "
                sed -i "${List_row:-Not}c ${List_Parameter}${format}${List_Value}" "${Specify}" 2>/dev/null; exit 0;
        ;;
        esac
    fi
done

# Function usage
# Edit_Database _Write_ _Info_ "Users" "auroot"
# Script Write usage 
# bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "LinuxKernel" "Linux5.123"

# Function usage
# Edit_Database _Read_ _Info_ "Users"

# Script Read usage 
# bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Read_" "_Info_" "LinuxKernel"