#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure Partition -> auin V4.5.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
echo &>/dev/null
# bash "${Share_Dir}/Partition.sh" "config" "info";
Auins_Config=${1}
Auins_record=${2}
Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
Share_Dir="${Auins_Dir}"

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

# @Colour 该死的颜色
function facts(){
    r='\033[1;31m'; g='\033[1;32m'
    y='\033[1;33m'; b='\033[1;36m'
    w='\033[1;37m'; h='\033[0m'
    wg='\033[1;42m'  #--白绿
    JHB=$(echo -e "${b}-=>${h} "); JHG=$(echo -e "${g}-=>${h} ")
    PSR=$(echo -e "${r} ::==>${h}"); PSG=$(echo -e "${g} ::==>${h}")
    PSY=$(echo -e "${y} ::==>${h}")
# Detect boot 检查引导, 并赋予引导类型
    if [ -d /sys/firmware/efi ]; then
        Boot_Type="UEFI" Disk_Type="GPT"
    else
        Boot_Type="BIOS" Disk_Type="MBR"
    fi
    # 记录
    Config_File_Manage INFO Write "Boot_Type" "$Boot_Type" 
    Config_File_Manage INFO Write "Disk_Type" "$Disk_Type"
    
}

# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    case ${PM_Enter_1} in
        start)   bash "${Share_Dir}/Process_manage.sh" start "${PM_Enter_2}" ;;
        restart) bash "${Share_Dir}/Process_manage.sh" restart "${PM_Enter_2}" ;;
        stop)    bash "${Share_Dir}/Process_manage.sh" stop "${PM_Enter_2}"
                 echo -e "\n\n${wg}---------Script Exit---------${h}"  ;;
    esac
}
# 磁盘分区
function partition(){
    local read_text_output
    showDisk
    read_text_output=$(echo -e "\n${PSY} ${y}Select disk: ${g}/dev/sdX | sdX ${h}${JHB}")
    read -rp "${read_text_output}"  input_disk  # 输入磁盘名
    partition_facts _disk_ "$input_disk"
    partition_type
    Config_File_Manage INFO Write "Disk" "$input_disk"
    case "$State" in
        true)   cfdisk "/dev/$userinput_disk" ;;
        false)  echo -e "\n${PSR} ${r} [cfdisk] Error: Please input: /dev/sdX | sdX? !!! ${h}"  
                Process_Management stop "$0"
                exit 1;
    esac
}

# @输出磁盘表及UUID
function showDisk(){ echo; lsblk -o+UUID | grep -E "sd..|vd..|nvme|mmc"; }
# @检查磁盘名是否合法
function testDisk(){ echo "${1}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^vd[a-z]|^nvme|^mmc"; }
# @检查分区名是否合法
function testPartition(){ echo "${1}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]|^vd[a-z][1-9]|^nvme*|^mmc*"; }
# 检查输入的值，是否正确; 获取磁盘[\_partition\_], 获取分区[\_partition_root\_], 获取磁盘类型[\_Disk_Type\_], 挂载分区[\_Open_mount\_] [磁盘] [目录].

function partition_facts(){
    disk_options=${1}
    diskName=${2}
    mountDir=${3}
    export userinput_disk
    case ${disk_options} in
        _disk_)  # Detect disk
            State="false"
            if testDisk "${diskName}" &>/dev/null  ; then
                userinput_disk=$(testDisk "${diskName}")
                State="true"
            else
                State="false"
            fi ;;
        _partition_root_)  # Detection partition
            State="false"
            if testPartition "${diskName}"; then
                userinput_disk=$(testPartition "$diskName")
                State="true"
            else
                State="false"
            fi ;;
        _Disk_Type_)  # Detect disk type
            if fdisk -l /dev/"$userinput_disk" | grep "gpt" ; then
                user_Disk_Type="GPT"
            elif fdisk -l /dev/"$userinput_disk" | grep "dos" ; then
                user_Disk_Type="MBR"
            elif fdisk -l /dev/"$userinput_disk" | grep "sgi" ; then
                user_Disk_Type="sgi"
            elif fdisk -l /dev/"$userinput_disk" | grep "sun" ; then
                user_Disk_Type="sun"
            else
                user_Disk_Type="Unformatted Disk"
            fi ;;
        _Open_mount_)  # Mount partition
            if ! mountpoint -q "$mountDir" ; then  # /proc/self/mountinfo
                mount "$diskName" "$mountDir"
            else
                umount -R "$mountDir" &>/dev/null
                mount "$diskName" "$mountDir"
            fi
    esac
}
The partition table does not match the disk bios. Partition table:
# 判断使用的磁盘是否符合当前系统要求，并自定义改变[MBR/GPT]
function partition_type(){
    local read_text_output
    partition_facts _Disk_Type_ "$userinput_disk"
    lsblk | grep -E "^[a-z]d[a-z]|^nvme|^mmc"|grep -v "grep" 
    echo;
    if [[ "$user_Disk_Type" != "$Disk_Type" ]] ; then
        
        echo -e "$PSR ${r} Boot and disk do not match ${b}[ ${Boot_Type}${r} - ${b}${user_Disk_Type} ]${h}${r}.${h}"
        read_text_output=$(echo -e "\n$PSY ${y}Whether to convert Disklabel type -> ${b}[$Disk_Type]${y}? [y/N]:$h $JRY")
        read -rp "${read_text_output}" user_input
        case "$user_input" in
            [Yy]*)
                if [[ "$Disk_Type" = "GPT" ]] ; then
                    Disk_Type="gpt"
                elif [[ "$Disk_Type" = "MBR" ]] ; then
                    Disk_Type="msdos"   
                fi
                parted "/dev/$userinput_disk" mklabel "$Disk_Type" -s
            ;;
            [Nn]*)
                echo -e "\n$PSR ${r} Error: Disklabel type${b}[$user_Disk_Type] ${r}not match and cannot be install System.$h"
                Process_Management stop "$0"
                exit 2;
            ;;
            *)
                if [[ "$Disk_Type" = "GPT" ]] ; then
                    Disk_Type="gpt"
                elif [[ "$Disk_Type" = "MBR" ]] ; then
                    Disk_Type="msdos"   
                fi
                parted /dev/"$userinput_disk" mklabel "$Disk_Type" -s
            ;;
        esac 
    else 
        echo -e "\n${PSG} ${g}Currently booted with ${b}[${Boot_Type}]. ${g}Select disk type: ${b}[${Disk_Type}].${h}"
    fi 
}

# @ 自选文件系统, 并格式化
function Disk_Filesystem_List(){
echo -e "${g}\n\t File System List${h}
------------------------------------
| 1. ext2 | 4. btrfs | 7. jfs      |
------------------------------------
| 2. ext3 | 5. vfat  | 8. ntfs-3g  |
------------------------------------
| 3. ext4 | 6. f2fs  | 9. reiserfs |
------------------------------------
"
    local Disk=$1
    read_output=$(echo -e "$PSG ${g}Select File System. [Default: 3]${h} $JHG")
    read -rp "${read_output}" input_Fs_type
    if [ "$input_Fs_type" = "" ]; then
        Disk_Filesystem 3 "$Disk"
    else
        Disk_Filesystem "$input_Fs_type" "$Disk"
    fi   
}

#其他分区
function partition_other(){
    read_output=$(echo -e "$PSG ${g}Continue to mount directory. [Quit/exit]?${h} $JHG")
        read -rp "${read_output}" Input_mount_dir
        case ${Input_mount_dir} in
            Quit | quit | QUIT | exit | Exit | EXIT) exit 0; echo -e "${wg} ::==>> Partition complete. ${h}"  
        ;;
            *) partition_other_start
        esac
    # @先选择目录, 之后交给: other_Format ;   
    function partition_other_start() {
    echo -e "${g}\n\tMount directory${h} 
---------------------------------------------
| home | opt | usr | var | etc | tmp | proc | 
=============================================
# User defined directory, please enter absolute address."

        read_output=$(echo -e "$PSG ${g}Input directory. [home|usr|...]?${h} $JHG")
        read -rp "${read_output}" Options_mount_dir
        case ${Options_mount_dir} in
            home) other_Format "/home" ;;
            opt)  other_Format "/opt" ;;
            usr)  other_Format "/usr" ;;
            var)  other_Format "/var" ;;
            etc)  other_Format "/etc" ;;
            tmp)  other_Format "/tmp" ;;
            proc) other_Format "/proc" ;;
            Quit | quit | QUIT | exit | Exit | EXIT) exit 0; echo -e "${wg} ::==>> Partition complete. ${h}" ;;
        esac
    }
    # other_Format [path]， 掩盖/mnt前缀，挂载到新系统的根下某目录，例：other_Format /auroot
    function other_Format(){
        local path=${System_Root}${1}
        if ls "${path}" &>/dev/null ; then
            Format "${path}"
        else
            echo -e "${PSY} ${w}Creating directory: ${b}[${path}]${h}${w}.${h}"   
            mkdir -p "${path}"
            Format "${path}" # 在这里获取的[$userinput_disk]
        fi
        partition_facts _Open_mount_ "/dev/$userinput_disk" "${path}" # 万事俱备，挂载
        showDisk  # 最后输出一下分区表
    }

    partition_other # 再运行, 输入exit，即退出
}

# 格式化函数, 输入: /dev/sdX[0-9] | sdX[0-9]
function Format(){
    local read_text_output; Input_Dir=$1; Rename=$2 Input_Dir=${Rename:-$Input_Dir}
    showDisk 
    read_text_output=$(echo -e "\n${PSY} ${y}Directory: [${Input_Dir}] and Partition: ${g}/dev/sdX[0-9] | sdX[0-9] ${h}${JHB}")
    read -rp "${read_text_output}"  input_Disk
    partition_facts _partition_root_ "$input_Disk" # 在这里获取的[$userinput_disk]
    case "$State" in # 格式化
        true)
            if ! Disk_Filesystem_List "/dev/$userinput_disk" ; then
                sleep 1;
            fi 
        ;;
        false)
            echo -e "\n${PSR} ${r} [${Input_Dir}] Error: Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${h}"  
            Process_Management stop "$0"
            exit 3;
    esac
}

# 自定义文件系统格式化
function Disk_Filesystem(){
    local Options=$1
    local Disk=$2
    case ${Options} in
        1) mkfs.ext2 "${Disk}"; Root_SystemFiles="ext2" ;;
        2) mkfs.ext3 "${Disk}"; Root_SystemFiles="ext3" ;;
        3) mkfs.ext4 "${Disk}"; Root_SystemFiles="ext4" ;;
        4)
            read_output=$(echo -e "\n$PSY ${g}Please enter the disk label. [Default: Data]${h} $JHG")
            read -rp "${read_output}" Disk_label
            if [ "$Disk_label" = "" ]; then
                mkfs.btrfs -L Data -f "${Disk}"
            else
                mkfs.btrfs -L "$Disk_label" -f "${Disk}"
            fi
            Root_SystemFiles="btrfs"
        ;;
        5) mkfs.vfat "${Disk}"; Root_SystemFiles="vfat" ;;
        6) mkfs.f2fs "${Disk}"; Root_SystemFiles="f2fs" ;;
        7) mkfs.jfs "${Disk}";  Root_SystemFiles="jfs"  ;;
        8) ntfs-3g "${Disk}";   Root_SystemFiles="ntfs-3g" ;;
        9) mkfs.reiserfs "${Disk}"; Root_SystemFiles="reiserfs" ;;
    esac
}

# 格式化并挂载Root分区, 输入: /dev/sdX[0-9] | sdX[0-9]
function partition_root(){
    System_Root="/mnt"
    umount -R $System_Root* 2>/dev/null
    Format $System_Root "root(/)"
    # "$Directory" 变量来自 (Format /mnt "root(/)")函数
    partition_facts _Open_mount_ "/dev/$userinput_disk" "$System_Root" # 挂载
    
    Config_File_Manage INFO Write Root_partition "/dev/$userinput_disk"
    Config_File_Manage INFO Write Root_SystemFile "$Root_SystemFiles"
    Boot_partition=$(echo "/dev/$userinput_disk" | awk '{sub(/[1-9]*$/,"");print}')
    if [ $Boot_Type = "BIOS" ]; then Config_File_Manage INFO Write Boot_partition "$Boot_partition"; fi
}

# 格式化并挂载 UEFI引导分区，输入: /dev/sdX[0-9] | sdX[0-9]
function partition_booting_UEFI(){
    Boot_Dir="${System_Root}/boot/efi"
    umount -R ${Boot_Dir} 2&>/dev/null
    if ! ls ${Boot_Dir} &>/dev/null ; then
        mkdir -p ${Boot_Dir}
    fi
    local read_text_output
    showDisk 
    read_text_output=$(echo -e "\n${PSY} ${y}Choose your [${Boot_Dir}] partition: ${g}/dev/sdX[0-9] | sdX[0-9] ${h}${JHB}")
    read -rp "${read_text_output}"  input_Disk
    partition_facts _partition_root_ "$input_Disk"

    Disk_Filesystem 5 "/dev/$userinput_disk"
    partition_facts _Open_mount_ "/dev/$userinput_disk" ${Boot_Dir}
    Config_File_Manage INFO Write Boot_partition "/dev/$userinput_disk"
    Config_File_Manage INFO Write Boot_SystemFile "vfat"
}

# 格式化并挂载 BIOS引导分区，输入: /dev/sdX[0-9] | sdX[0-9]
function partition_booting_BOIS(){
    Boot_Dir="${System_Root}/boot"
    umount -R ${Boot_Dir} 2&>/dev/null
    if [ -d ${Boot_Dir} ]; then
        mkdir -p ${Boot_Dir} 2>/dev/null 
    fi
}

# 格式化并挂载虚拟的Swap分区，可自定义大小
function partition_swap(){
    function Swap_File(){
        echo -e "${PSG} ${g}Assigned Swap file Size: ${input_swap} .${h}"
        fallocate -l "${input_swap}" /mnt/swapfile  # 创建指定大小的swap虚拟化文件
        chmod 600 /mnt/swapfile # 设置权限
        mkswap /mnt/swapfile    # 格式化swap文件
        swapon /mnt/swapfile    # 挂载swap文件
        Config_File_Manage INFO Write Swap "/mnt/swapfile"
        Config_File_Manage INFO Write Swap_size "${input_swap}"
    }
    function Swap_Partition(){
        input_swap_device="$input_swap"
        mkswap "/dev/$input_swap_device"
        # swapon "/dev/$input_swap_device"
        SWAP_UUID=$(blkid -s PARTUUID -o value "/dev/$input_swap_device")
        echo "UUID=$SWAP_UUID none swap defaults 0  0" >> /etc/fstab
        mount -a
        # input_swap_size=$(df -ha | grep "$input_swap_device" | awk -F " " '{print $2}')
        input_swap_size=$(lsblk | grep "$input_swap_device" | awk -F " " '{print $4}')
        echo -e "${PSG} ${g}Assigned Swap file Size: $input_swap_size .${h}"
        Config_File_Manage INFO Write Swap "/dev/$input_swap_device"
        Config_File_Manage INFO Write Swap_size "${input_swap_size}"
    }
    local read_text_output
    showDisk
    CONF_Root_SystemFile=$(Config_File_Manage INFO Read Root_SystemFile)
    read_text_output=$(echo -e "\n${PSY} ${y}lease select the Swapfile: ${g}[size:256M-100G ~] and Swap partition: ${g}sdX[0-9]${y}Skip: ${g}[No]${h} ${JHB}")
    read -rp "${read_text_output}"  input_swap
    if echo "$input_swap" | grep -E "^[0-9]*[kK|mM|gG]$" &>/dev/null ; then
        case $CONF_Root_SystemFile in
            ext[2-4]) Swap_File;;
                   *) echo -e "\n${PSR} ${r}Error: Swapfile cannot be created.${h}"
                      sleep 3s; exit 4 ;;
        esac 
    elif testPartition "$input_swap" &>/dev/null ; then
        Swap_Partition
    else
        echo -e "\n${PSY} ${y}Skip create a swap file.${h}"; sleep 1
    fi
    echo -e "${wg} ::==>> Partition complete. ${h}" 
}

# 具体的实现
# >> >> >> >> >> >> >> >> >> >> >> >>
clear; facts;
partition; # 选择磁盘 #parted /dev/sdb mklabel gpt   转换格式 GPT
partition_root;
Conf_New_Other_Partition=$(Config_File_Manage CONF Read "New_Other_Partition")
if [ "$Boot_Type" = "UEFI" ]; then partition_booting_UEFI; else partition_booting_BIOS; fi  
partition_swap;  #swap file 虚拟文件(类似与win里的虚拟文件) 对于swap分区我更推荐这个，后期灵活更变
if [ "$Conf_New_Other_Partition" = yes ]; then partition_other; fi
echo -e "${wg} ::==>> Partition complete. ${h}"