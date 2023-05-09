#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure Mirrorlist -> auin V4.5.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

#==============-------------pacman.conf----------------==============
pacman_conf="
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives
#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
#UseDelta     = 0.7
Architecture = auto
#
#IgnoreGroup =
#
#NoUpgrade   =
#NoExtract   =
#
# Misc options
UseSyslog
Color
CheckSpace
VerbosePkgLists
#
# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
RemoteFileSigLevel = Required
#
# NOTE: You must run 'pacman-key --init' before first using pacman; the local
# keyring can then be populated with the keys of all official Arch Linux
# packagers with 'pacman-key --populate archlinux'.
#
# REPOSITORIES
#   - can be defined here or included from another file
#   - pacman will search repositories in the order defined here
#   - local/custom mirrors can be added here or in separate files
#   - repositories listed first will take precedence when packages
#     have identical names, regardless of version number
#
# Repository entries are of the format:
#       [repo-name]
#       Server = ServerName
#       Include = IncludePath
#
# The header [repo-name] is crucial - it must be present and
# uncommented to enable the repo.
#
# 默认情况下，测试存储库被禁用。若要启用，请取消注释
# repo name header and Include lines. You can add preferred servers immediately
# after the header, and they will be used before the default mirrors.
#
#[testing]
#Include = /etc/pacman.d/mirrorlist
#
[core]
Include = /etc/pacman.d/mirrorlist
#
[extra]
Include = /etc/pacman.d/mirrorlist
#
#[community-testing]
#Include = /etc/pacman.d/mirrorlist
#
[community]
Include = /etc/pacman.d/mirrorlist
#
# 如果要在x86_64系统上运行32位应用程序
# 根据需要在此启用多库存储库。
#
#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist
#
[multilib]
Include = /etc/pacman.d/mirrorlist
#
# An example of a custom package repository.  See the pacman manpage for
# tips on creating your own repositories.
# 本地镜像源
#[custom]
#SigLevel = Optional TrustAll
#Server = file:///home/custompkgs
"

#==============-------------archlinuxcn----------------==============
archlinuxcn_source="
# 南京大学(nju) 北京外国语(bfsu) 阿里云(aliyun) 华为源(huaweicloud) 中科大(ustc) 清华源(tuna) 腾讯云(tencent)
# 可信的(Optional), 信任所有(TrustAll), 仅受信任(TrustedOnly)
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.nju.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.bfsu.edu.cn/archlinuxcn/\$arch
# Server = http://mirrors.aliyun.com/archlinuxcn/\$arch
# Server = https://repo.huaweicloud.com/archlinuxcn/\$arch
# Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/\$arch
# Server = https://mirrors.cloud.tencent.com/archlinuxcn/\$arch
"

#==============-------------blackarch----------------==============
blackarch_source="
[blackarch]
SigLevel = Optional TrustAll
Server = https://mirrors.nju.edu.cn/blackarch/\$repo/os/\$arch
# Server = https://mirrors.bfsu.edu.cn/blackarch/\$repo/os/\$arch
# Server = http://mirrors.aliyun.com/blackarch/\$repo/os/\$arch
# Server = https://mirrors.ustc.edu.cn/blackarch/\$repo/os/\$arch
# Server = https://mirrors.cloud.tencent.com/blackarch/\$repo/os/\$arch
# Server = https://mirrors.tuna.tsinghua.edu.cn/blackarch/\$repo/os/\$arch
"

#==============-------------arch4edu----------------==============
arch4edu_source="
[arch4edu] 
SigLevel = TrustAll 
Server = https://mirrors.tuna.tsinghua.edu.cn/arch4edu/\$arch
# Server = https://mirrors.bfsu.edu.cn/arch4edu/\$arch
# Server = https://mirrors.nju.edu.cn/arch4edu/\$arch
# Server = http://mirrors.aliyun.com/arch4edu/\$arch
# Server = https://mirrors.cloud.tencent.com/arch4edu/\$arch
"

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
function Config_File_Manage(){ 
    local format=" = "; parameter="$3"; content="$4"; itself=$(echo "$0" | awk -F"/" '{print $NF}')
    case "$1" in
        INFO) local Files="$Auins_Infofile" ;;
        CONF) local Files="$Auins_Profile" ;;
    esac
    case "$2" in
        Read ) 
                read_info=$(grep -w "$parameter" < "$Files") # 在文件中查找匹配的值
                if [ -n "$read_info" ]; then 
                    echo "$read_info" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' 
                else
                    warn "\033[1;37m$itself \033[1;33mRead file: \033[1;37m$Files\033[1;33m missing value: [\033[1;37m $parameter  \033[1;33m]."
                    sleep 3
                fi
         ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';) # 在文件中查找匹配的值, 并打印行号
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "\033[1;37m$itself \033[1;33mWrite file: \033[1;37m$Files\033[1;33m missing value: [\033[1;37m $parameter  \033[1;33m] + [\033[1;37m $content \033[1;33m]."
                    sleep 3
                fi
    esac 
}

clear;
echo &>/dev/null
# red='\033[1;31m'; green='\033[1;32m'  
# yellow='\033[1;33m'; 
# blue='\033[1;36m'  
# white='\033[1;37m'; 
# suffix='\033[0m'  wg='\033[1;42m'; 

# bash "${Share_Dir}/Partition.sh" "config" "info";
Auins_Profile=${1}
Auins_Infofile=${2}
PacmanConf_file="/etc/pacman.conf"
MirrorList_file="/etc/pacman.d/mirrorlist"
# 备份的文件夹
Source_Backup_Dir="/etc/pacman.d/backup"
Exec_Time=$(date +%k:%M-%Y:%m:%d)


INFO_Country_Name=$(Config_File_Manage INFO Read Country_Name)
CONF_Archlinucn=$(Config_File_Manage CONF Read "Archlinucn")
CONF_Arch4edu=$(Config_File_Manage CONF Read "Arch4edu")

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

function main(){
    # 备份原本的源
    [ ! -d "$Source_Backup_Dir" ] &&  mkdir "$Source_Backup_Dir" 2> /dev/null 
    mv "$PacmanConf_file" "$Source_Backup_Dir/pacman.conf.$Exec_Time" 2> /dev/null
    mv "$MirrorList_file" "$Source_Backup_Dir/mirrorlist.$Exec_Time" 2> /dev/null
    touch "$PacmanConf_file" "$MirrorList_file"
    
    # 写入新的镜像源
    # reflector --country "$INFO_Country_Name"  --protocol http --protocol https
    reflector --country "$INFO_Country_Name" --save $MirrorList_file
    echo -e "$pacman_conf" > "$PacmanConf_file"
    sudo pacman -Sy --needed --noconfirm archlinux-keyring

    # 将所需的其他镜像源添加到 /etc/pacman.conf
    [[ "$CONF_Archlinucn" = "yes" ]] && echo -e "$archlinuxcn_source" >> "$PacmanConf_file" && pacman -Sy --needed --noconfirm archlinuxcn-keyring;
        
    [[ "$CONF_Arch4edu" = "yes" ]] && echo -e "$arch4edu_source" >> "$PacmanConf_file"
}

main && sleep 1
echo "$(date -d "2 second" +"%Y-%m-%d %H:%M:%S")  mirrorlist=yes" >> /tmp/Arch_install.log


# pacman-key --init
# pacman-key --populate archlinux archlinuxcn