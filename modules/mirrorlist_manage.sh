#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Configure Mirrorlist -> Auins v4.7.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
# 列出需要包含的配置文件或模块
function include(){
    set +e
    declare -a argu=("$@")
    # declare -p argu
    export config_File info_File
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    Tools_modules="${argu[2]}"
    set -e
}
#==============-------------archlinuxcn----------------==============
# 南京大学(nju) 北京外国语(bfsu) 阿里云(aliyun) 华为源(huaweicloud) 中科大(ustc) 清华源(tuna) 腾讯云(tencent)
# 可信的(Optional), 信任所有(TrustAll), 仅受信任(TrustedOnly)
archlinuxcn_source="
[archlinuxcn]
# SigLevel = Optional TrustedOnly
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.wsyu.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.nju.edu.cn/archlinuxcn/\$arch
# Server = http://mirrors.aliyun.com/archlinuxcn/\$arch
# Server = https://repo.huaweicloud.com/archlinuxcn/\$arch
# Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.cloud.tencent.com/archlinuxcn/\$arch
"
# #==============-------------blackarch----------------==============
# blackarch_source="
# [blackarch]
# SigLevel = Optional TrustAll
# Server = https://mirrors.nju.edu.cn/blackarch/$repo/os/$arch
# # Server = https://mirrors.bfsu.edu.cn/blackarch/$repo/os/$arch
# # Server = http://mirrors.aliyun.com/blackarch/$repo/os/$arch
# # Server = https://mirrors.ustc.edu.cn/blackarch/$repo/os/$arch
# # Server = https://mirrors.cloud.tencent.com/blackarch/$repo/os/$arch
# # Server = https://mirrors.tuna.tsinghua.edu.cn/blackarch/$repo/os/$arch
# "
#==============-------------arch4edu----------------==============
arch4edu_source="
[arch4edu] 
# SigLevel = TrustAll 
Server = https://mirrors.bfsu.edu.cn/arch4edu/\$arch
# Server = https://mirrors.tuna.tsinghua.edu.cn/arch4edu/\$arch
# Server = https://mirrors.nju.edu.cn/arch4edu/\$arch
# Server = http://mirrors.aliyun.com/arch4edu/\$arch
# Server = https://mirrors.cloud.tencent.com/arch4edu/\$arch
"
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 小型重复性高的模块调用管理器
function run_tools(){
    bash "$Tools_modules" "$config_File" "$info_File" "$1" "$2" "$3" "$4" "$5"
}

# 根据profile.conf设置pacman.conf
# https://archlinux.org/mirrorlist/all/
# https://archlinux.org/mirrorlist/?country=CN&protocol=https&ip_version=4
function pacman-conf-update(){
    function modify_row() {
        temp_row_number=$(grep -Eno "$1" < $Pacman_conf_file | awk -F':' '{print $1}')
        row_number=$(("$temp_row_number" + 1))
        sed -i "${row_number} d" $Pacman_conf_file
        sed -i "${row_number} i\Include = /etc/pacman.d/mirrorlist" $Pacman_conf_file
    }
    function find_replace() {
        [[ $2 == "" ]] && replace=$1 || replace=$2
        case $(run_tools file_rw CONF Read "$1") in 
            [Yy]*) sed -i "s/#$replace/$replace/g" $Pacman_conf_file ;;
            [Nn]*) sed -i "s/$replace/#$replace/g" $Pacman_conf_file
        esac
    }
    # pacman.conf的设置
    find_replace VerbosePkgLists
    find_replace UseSyslog
    find_replace Color
    find_replace NoProgressBar
    find_replace RemoteFileSigLevel

    find_replace ParallelDownloads && \
    grep -E "^ParallelDownloads" "$Pacman_conf_file" &> /dev/null && \
    run_tools file_rw  $Pacman_conf_file Write ParallelDownloads "$(run_tools file_rw CONF Read ParallelDownloads_quantity)"

    find_replace multilib "\[multilib\]" && modify_row "\[multilib\]"

    # 将所需的其他镜像源添加到 /etc/pacman.conf
    case "$(run_tools file_rw CONF Read "Arch4edu")" in 
        [Yy]*)  if ! grep -E "^\[arch4edu\]" $Pacman_conf_file &>/dev/null ; then
                    echo  "$arch4edu_source" >> "$Pacman_conf_file"
                fi
    esac
    case "$(run_tools file_rw CONF Read "Archlinucn")" in 
        [Yy]*)  if ! grep -E "^\[archlinuxcn\]" $Pacman_conf_file &>/dev/null ; then
                    echo "$archlinuxcn_source" >> "$Pacman_conf_file" 
                    pacman -Sy --needed --noconfirm archlinuxcn-keyring
                    pacman-key --populate archlinuxcn
                fi
    esac
    sed -i 's/##/#/g' "$Pacman_conf_file" # 清理配置后产生的多余符号(#)
}

# 写入新的镜像源 reflector真他妈慢
function reflector_update(){
    # reflector --country "$INFO_Country_Name"  --protocol http --protocol https
    [ ! -e /usr/bin/reflector ] && pacman -Sy --needed --noconfirm reflector
    reflector --country "$INFO_Country_Name" > $MirrorList_file
    run_tools feed "Mirrorlist write successful." "Mirrorlist write failed."
    cat $MirrorList_file | grep "$INFO_Country_Name" &> /dev/null
    run_tools feed "$INFO_Country_Name...." "Mirrorlist write failed."
}

# 使用arch官方的api获取mirrorlist, 速度快,[推荐]
function arch_api_update() {
    # 读取auins.info中的国家简称[CN] [US] ...
    country="country=$(run_tools file_rw INFO Read Country)"
    # 读取profile.conf中的设置，可以选择性的开启 
    [[ "$(run_tools file_rw CONF Read mirrorlist_http)" == 'yes' ]] && http='&protocol=http' 
    [[ "$(run_tools file_rw CONF Read mirrorlist_https)" == 'yes' ]] && https='&protocol=https'
    [[ "$(run_tools file_rw CONF Read mirrorlist_ip_v4)" == 'yes' ]] && ip_version_4='&ip_version=4'
    [[ "$(run_tools file_rw CONF Read mirrorlist_ip_v6)" == 'yes' ]] && ip_version_6='&ip_version=6'
    _mirrorlist_curl="https://archlinux.org/mirrorlist/?${country}${http}${https}${ip_version_4}${ip_version_6}"

    curl -fsSL "$_mirrorlist_curl" > $MirrorList_file
    run_tools feed "Mirrorlist write successful." "Mirrorlist write failed."
    sed -i 's/#S/S/g'  $MirrorList_file
    cat $MirrorList_file | grep "$INFO_Country_Name" &> /dev/null
    run_tools feed "$INFO_Country_Name...." "Mirrorlist write failed."
    sed -i "$(grep -n 'aliyun.com' < $MirrorList_file | awk -F':' '{print $1}') d" $MirrorList_file
}

function main(){
    # 备份的文件夹
    Source_Backup_Dir="/etc/pacman.d/backup"
    Exec_Time=$(date "+%Y:%m:%d-%k:%M")
    # 备份原本的源
    [ ! -d "$Source_Backup_Dir" ] &&  mkdir "$Source_Backup_Dir" 2> /dev/null 
    cp "$Pacman_conf_file" "$Source_Backup_Dir/pacman.conf.$Exec_Time" 2> /dev/null
    cp "$MirrorList_file" "$Source_Backup_Dir/mirrorlist.$Exec_Time" 2> /dev/null
    # 根据profile.con中的设置，获取mirrorlist
    case "$(run_tools file_rw CONF Read update_method)" in 
         api)
            arch_api_update
    ;;
         ref)
            reflector_update
    ;;
    esac 

    pacman-conf-update
    pacman -Sy --needed --noconfirm archlinux-keyring
    pacman-key --init
    pacman-key --populate archlinux 
    echo "$(date -d "2 second" +"%Y-%m-%d %H:%M:%S")  mirrorlist=yes" >> /tmp/Arch_install.log
}

echo &>/dev/null
include "$@"
Pacman_conf_file="/etc/pacman.conf"
MirrorList_file="/etc/pacman.d/mirrorlist"
INFO_Country_Name=$(run_tools file_rw INFO Read Country_Name)
main