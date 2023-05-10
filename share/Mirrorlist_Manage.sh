#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure Mirrorlist -> auin V4.6 r8
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
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
# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
function Config_File_Manage(){ 
    local Files; format=" = "; parameter="$3"; content="$4"; itself=$(echo "$0" | awk -F"/" '{print $NF}')
    case "$1" in
        INFO) Files="$Auins_Infofile" ;;
        CONF) Files="$Auins_Profile" ;;
        *) Files="$1" ;;
    esac
    case "$2" in
        Read ) 
                read_info=$(grep -wE "^$parameter" < "$Files") # 在文件中查找匹配的值
                if [ -n "$read_info" ]; then 
                    echo "$read_info" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' 
                else
                    warn "\033[1;37m$itself \033[1;33mRead file: \033[1;37m$Files\033[1;33m missing value: [\033[1;37m $parameter  \033[1;33m]."
                    sleep 1
                fi
         ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';) # 在文件中查找匹配的值, 并打印行号
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "\033[1;37m$itself \033[1;33mWrite file: \033[1;37m$Files\033[1;33m missing value: [\033[1;37m $parameter  \033[1;33m] + [\033[1;37m $content \033[1;33m]."
                    sleep 1
                fi
    esac 
}

echo &>/dev/null
# bash "${Share_Dir}/Partition.sh" "config" "info";
Auins_Profile=${1}
Auins_Infofile=${2}
Pacman_conf_file="/etc/pacman.conf"
MirrorList_file="/etc/pacman.d/mirrorlist"
# 备份的文件夹
Source_Backup_Dir="/etc/pacman.d/backup"
Exec_Time=$(date +%k:%M-%Y:%m:%d)
INFO_Country_Name=$(Config_File_Manage INFO Read Country_Name)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; sleep 1; exit 255; } 
function feed_status(){ 
    if [ $? = 0 ]; then 
        echo -e "\033[1;37m:: $(tput bold; tput setaf 2)=> \033[1;32m${1}\033[0m$(tput sgr0)"; 
        sleep 1;
    else 
        err "$2"
    fi
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
    # pacman.conf的设置
    [[ "$(Config_File_Manage CONF Read VerbosePkgLists)" == 'yes' ]] && sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' $Pacman_conf_file
    [[ "$(Config_File_Manage CONF Read UseSyslog)" == 'yes' ]] &&  sed -i 's/#UseSyslog/UseSyslog/g' $Pacman_conf_file
    [[ "$(Config_File_Manage CONF Read Color)" == 'yes' ]] && sed -i 's/#Color/Color/g' $Pacman_conf_file
    [[ "$(Config_File_Manage CONF Read NoProgressBar)" == 'yes' ]] && sed -i 's/#NoProgressBar/NoProgressBar/g' $Pacman_conf_file
    [[ "$(Config_File_Manage CONF Read RemoteFileSigLevel)" == 'yes' ]] && sed -i 's/#RemoteFileSigLevel/RemoteFileSigLevel/g' $Pacman_conf_file

    if [[ "$(Config_File_Manage CONF Read ParallelDownloads)" == 'yes' ]]; then
        sed -i 's/#ParallelDownloads/ParallelDownloads/g' $Pacman_conf_file
        Config_File_Manage  $Pacman_conf_file Write ParallelDownloads "$(Config_File_Manage CONF Read ParallelDownloads_quantity)"
    fi
    if [[ "$(Config_File_Manage CONF Read multilib)" == 'yes' ]]; then
        sed -i 's/#\[multilib\]/\[multilib\]/g' $Pacman_conf_file
        modify_row "\[multilib\]"

    fi
    # 将所需的其他镜像源添加到 /etc/pacman.conf
    if [[ "$(Config_File_Manage CONF Read "Arch4edu")" = "yes" ]]; then
        if ! grep -E "^\[arch4edu\]" $Pacman_conf_file &>/dev/null ; then
            echo  "$arch4edu_source" >> "$Pacman_conf_file"
        fi
    fi
    if [[ "$(Config_File_Manage CONF Read "Archlinucn")" = "yes" ]]; then
        if ! grep -E "^\[archlinuxcn\]" $Pacman_conf_file &>/dev/null ; then
            echo "$archlinuxcn_source" >> "$Pacman_conf_file" 
            pacman -Sy --needed --noconfirm archlinuxcn-keyring
            pacman-key --populate archlinuxcn
        fi
    fi
}

# 写入新的镜像源 reflector真他妈慢
function reflector_update(){
    # reflector --country "$INFO_Country_Name"  --protocol http --protocol https
    [ ! -e /usr/bin/reflector ] && pacman -Sy --needed --noconfirm reflector
    reflector --country "$INFO_Country_Name" > $MirrorList_file
    feed_status "Mirrorlist write successful." "Mirrorlist write failed."
    cat $MirrorList_file | grep "$INFO_Country_Name" &> /dev/null
    feed_status "$INFO_Country_Name...." "Mirrorlist write failed."
}

# 使用arch官方的api获取mirrorlist, 速度快,[推荐]
function arch_api_update() {
    # 读取auins.info中的国家简称[CN] [US] ...
    country="country=$(Config_File_Manage INFO Read Country)"
    # 读取profile.conf中的设置，可以选择性的开启 
    [[ "$(Config_File_Manage CONF Read mirrorlist_http)" == 'yes' ]] && http='&protocol=http' 
    [[ "$(Config_File_Manage CONF Read mirrorlist_https)" == 'yes' ]] && https='&protocol=https'
    [[ "$(Config_File_Manage CONF Read mirrorlist_ip_v4)" == 'yes' ]] && ip_version_4='&ip_version=4'
    [[ "$(Config_File_Manage CONF Read mirrorlist_ip_v6)" == 'yes' ]] && ip_version_6='&ip_version=6'
    _mirrorlist_curl="https://archlinux.org/mirrorlist/?${country}${http}${https}${ip_version_4}${ip_version_6}"

    curl -fsSL "$_mirrorlist_curl" > $MirrorList_file
    feed_status "Mirrorlist write successful." "Mirrorlist write failed."
    sed -i 's/#S/S/g'  $MirrorList_file
    cat $MirrorList_file | grep "$INFO_Country_Name" &> /dev/null
    feed_status "$INFO_Country_Name...." "Mirrorlist write failed."
}


function main(){
    # 备份原本的源
    [ ! -d "$Source_Backup_Dir" ] &&  mkdir "$Source_Backup_Dir" 2> /dev/null 
    cp "$Pacman_conf_file" "$Source_Backup_Dir/pacman.conf.$Exec_Time" 2> /dev/null
    cp "$MirrorList_file" "$Source_Backup_Dir/mirrorlist.$Exec_Time" 2> /dev/null
    # 根据profile.con中的设置，获取mirrorlist
    case "$(Config_File_Manage CONF Read update_method)" in 
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

main