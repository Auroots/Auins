#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure Partition -> auin V4.3
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
echo &>/dev/null

# bash "${Share_Dir}/Partition.sh" "${Share_Dir}" "${Local_Dir}"

# initialization
Share_Dir=${1}
Local_Dir=${2}

function facts(){
# Colour
    r='\033[1;31m'
    g='\033[1;32m'
    y='\033[1;33m'
    b='\033[1;36m'
    w='\033[1;37m'
    h='\033[0m'
    wg='\033[1;42m'  #--白绿
    JHB=$(echo -e "${b}-=>${h} ")
    JHG=$(echo -e "${g}-=>${h} ")
    PSR=$(echo -e "${r} ::==>${h}")
    PSG=$(echo -e "${g} ::==>${h}")
    PSY=$(echo -e "${y} ::==>${h}")


# Detect boot
    if [ -d /sys/firmware/efi ]; then
        Boot_Type="Uefi"
        Disk_Type="gpt"
    else
        Boot_Type="Boot"
        Disk_Type="dos"
    fi
        bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "Boot_Type" "${Boot_Type}"
        bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "Disk_Type" "${Disk_Type}"
    System_Root="/mnt"
}

showDisk(){ echo; lsblk -o+UUID | grep -E "sd..|vd..|nvme|mmc"; }

# Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    case ${PM_Enter_1} in
        start)
            bash "${Share_Dir}/Process_manage.sh" start "${PM_Enter_2}"
        ;;
        restart)
            bash "${Share_Dir}/Process_manage.sh" restart "${PM_Enter_2}"
        ;;
        stop)
            bash "${Share_Dir}/Process_manage.sh" stop "${PM_Enter_2}"
            echo -e "\n\n${wg}---------Script Exit---------${h}"  
        ;;
    esac
}
# 磁盘分区
function partition(){
    local read_text_output
    showDisk
    read_text_output=$(echo -e "\n${PSY} ${y}Select disk: ${g}/dev/sdX | sdX ${h}${JHB}")
    read -rp "${read_text_output}"  input_disk  #给用户输入接口
    partition_facts _disk_ "$input_disk"
    partition_type
    if [[ "$State" = "true" ]] ; then    
        cfdisk "/dev/$userinput_disk" 
    else
        echo -e "\n${PSR} ${r} [cfdisk] Error: Please input: /dev/sdX | sdX? !!! ${h}"  
        Process_Management stop "$0"
    fi
}

# 类型判断 获取磁盘[\_partition\_], 获取分区[\_partition_root\_], 获取磁盘类型[\_Disk_Type\_], 挂载分区[\_Open_mount\_] [磁盘] [目录].
function partition_facts(){
    disk_options=${1}
    diskName=${2}
    mountDir=${3}
    export userinput_disk
    case ${disk_options} in
        _disk_)  # Detect disk
            State="false"
            if echo "${diskName}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^nvme|^mmc" &>/dev/null  ; then
                userinput_disk=$(echo "${diskName}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^nvme|^mmc")
                State="true"
            else
                State="false"
            fi
        ;;
        _partition_root_)  # Detection partition
            State="false"
            if echo "${diskName}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]|^nvme*|^mmc*" &>/dev/null  ; then
                userinput_disk=$(echo "${diskName}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]|^nvme*|^mmc*")
                State="true"
            else
                State="false"
            fi
        ;;
        _Disk_Type_)  # Detect disk type
            if ! fdisk -l /dev/"$userinput_disk" | grep "Disklabel type:" ; then
                user_Disk_Type="false"
            elif fdisk -l /dev/"$userinput_disk" | grep "gpt" ; then
                user_Disk_Type="gpt"
            elif fdisk -l /dev/"$userinput_disk" | grep "dos" ; then
                user_Disk_Type="dos"
            elif fdisk -l /dev/"$userinput_disk" | grep "sgi" ; then
                user_Disk_Type="sgi"
            elif fdisk -l /dev/"$userinput_disk" | grep "sun" ; then
                user_Disk_Type="sun"
            fi
        ;;
        _Open_mount_)  # Mount partition
            if ! mountpoint -q "$mountDir" ; then  # /proc/self/mountinfo
                mount "$diskName" "$mountDir"
            else
                umount -R "$mountDir" &>/dev/null
                mount "$diskName" "$mountDir"
            fi
        ;;
    esac
}

# 判断使用的磁盘是否符合当前系统要求，并自定义改变[dos/gpt]
function partition_type(){
    local read_text_output
    partition_facts _Disk_Type_ "$userinput_disk"
    lsblk | grep -E "^[a-z]d[a-z]|^nvme|^mmc"|grep -v "grep" 
    echo;
    if [[ "$user_Disk_Type" != "$Disk_Type" ]] ; then
        echo -e "$PSR ${r} The boot does not match the disk ${b}[$Boot_Type] ${r}not ${b}[$user_Disk_Type]$h${r}.$h"
        read_text_output=$(echo -e "\n$PSY ${y}Whether to convert Disklabel type ->${b}[$Disk_Type]${y}? [y/N]:$h $JRY")
        read -rp "${read_text_output}" user_input
        case "$user_input" in
            [Yy]*)
                if [[ "$Disk_Type" = "gpt" ]] ; then
                    Disk_Type="gpt"
                elif [[ "$Disk_Type" = "dos" ]] ; then
                    Disk_Type="msdos"   
                fi
                parted "/dev/$userinput_disk" mklabel "$Disk_Type" -s
            ;;
            [Nn]*)
                echo -e "\n$PSR ${r} Error: Disklabel type${b}[$user_Disk_Type] ${r}not match and cannot be install System.$h"
                Process_Management stop "$0"
            ;;
            *)
                if [[ "$Disk_Type" = "gpt" ]] ; then
                    Disk_Type="gpt"
                elif [[ "$Disk_Type" = "dos" ]] ; then
                    Disk_Type="msdos"   
                fi
                parted /dev/"$userinput_disk" mklabel "$Disk_Type" -s
            ;;
        esac 
    else 
        echo -e "\n${PSG} ${g}Currently booted with ${b}[${Boot_Type}]. ${g}Select disk type: ${b}[${Disk_Type}].${h}"
    fi 
}

# 自定义文件系统列表
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

# 自定义文件系统格式化
function Disk_Filesystem(){
    local Options=$1
    local Disk=$2
    # local Directory=$3
    case ${Options} in
    1)
        mkfs.ext2 "${Disk}"
    ;;
    2)
        mkfs.ext3 "${Disk}"
    ;;
    3)
        mkfs.ext4 "${Disk}"
    ;;
    4)
        read_output=$(echo -e "\n$PSY ${g}Please enter the disk label. [Default: Data]${h} $JHG")
        read -rp "${read_output}" Disk_label
        if [ "$Disk_label" = "" ]; then
            mkfs.btrfs -L Data -f "${Disk}"
        else
            mkfs.btrfs -L "$Disk_label" -f "${Disk}"
        fi
    ;;
    5)
        mkfs.vfat "${Disk}"
    ;;
    6)
        mkfs.f2fs "${Disk}"
    ;;
    7)
        mkfs.jfs "${Disk}"
    ;;
    8)
        ntfs-3g "${Disk}"
    ;;
    9)
        mkfs.reiserfs "${Disk}"
    ;;
    esac
    # partition_facts _Open_mount_ "$Disk" "$Directory"
}

#其他分区
function partition_other(){
    # other_Format [path]， 掩盖/mnt前缀，挂载到新系统的根下某目录，例：other_Format /auroot
    function other_Format(){
        local path=${System_Root}${1}
        if ls "${path}" &>/dev/null ; then
            Format_mount "${path}"
        else
            echo -e "${PSY} ${w}Creating directory: ${b}[${path}]${h}${w}.${h}"   
            mkdir -p "${path}"
            Format_mount "${path}"
        fi
        partition_facts _Open_mount_ "/dev/$userinput_disk" "${path}"
        showDisk  
    }
    read_output=$(echo -e "$PSG ${g}Continue to mount directory. [Quit/exit]?${h} $JHG")
    read -rp "${read_output}" Input_mount_dir
    case ${Input_mount_dir} in
        Quit | quit | QUIT | exit | Exit | EXIT)
        exit 0;
        echo -e "${wg} ::==>> Partition complete. ${h}"  
    ;;
    esac
    echo -e "${g}\t    Mount directory${h}"
    cat << EOF
--------------------------------------
| home | opt | usr | var | etc | /... |
======================================
# User defined directory, please enter absolute address.
EOF
    read_output=$(echo -e "$PSG ${g}Input directory. [home|usr|...]?${h} $JHG")
    read -rp "${read_output}" Options_mount_dir
    case ${Options_mount_dir} in
    home | Home | HOME)
        other_Format "/home";
    ;;
    usr | Usr | USR)
        other_Format "/usr";
    ;;
    var | Var | VAR)
        other_Format "/var";
    ;;
    opt | Opt | OPT)
        other_Format "/opt";
    ;;
    etc | Etc | ETC)
        other_Format "/etc";
    ;;
    Quit | quit | QUIT | exit | Exit | EXIT)
        exit 0;
        echo -e "${wg} ::==>> Partition complete. ${h}"  
    ;;
    *)  # 无退出，需修复
        other_Format "${Options_mount_dir}";
    ;;
    esac
    # 循环使用
    while [ "$Input_mount_dir" = "y" ] || [ "$Input_mount_dir" = "Y" ]
    do
        partition_other;
    done
}
# 格式化挂载函数, 输入: /dev/sdX[0-9] | sdX[0-9]
function Format_mount(){
    local read_text_output
    local Dir=$1
    export Directory="$Dir"
    local Rename=$2
    local Dir=${Rename:-$Dir} 
    showDisk 
    read_text_output=$(echo -e "\n${PSY} ${y}Choose your [${Dir}] partition: ${g}/dev/sdX[0-9] | sdX[0-9] ${h}${JHB}")
    read -rp "${read_text_output}"  input_Disk
    partition_facts _partition_root_ "$input_Disk"
    if [[ "$State" = "true" ]] ; then
        # if ! mkfs.ext4 "/dev/$userinput_disk" ; then
        if ! Disk_Filesystem_List "/dev/$userinput_disk" ; then
            sleep 1;
        fi 
        # partition_facts _Open_mount_ "/dev/$userinput_disk" "${Directory}"
    else
        echo -e "\n${PSR} ${r} [${Dir}] Error: Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${h}"  
        Process_Management stop "$0"
    fi
}

# 格式化并挂载Root分区, 输入: /dev/sdX[0-9] | sdX[0-9]
function partition_root(){
    umount -R ${System_Root}* 2>/dev/null
    Format_mount ${System_Root} "root(/)"
    bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "Root_partition" "/dev/$userinput_disk"
    # "$Directory" 变量来自 (Format_mount /mnt "root(/)")函数
    partition_facts _Open_mount_ "/dev/$userinput_disk" "$Directory"
    unset Directory;
}

# 格式化并挂载 引导分区，输入: /dev/sdX[0-9] | sdX[0-9]
function partition_booting(){
            if [[ "$Boot_Type" = "Uefi" ]] ; then
                Boot_Dir="${System_Root}/boot/efi"
                umount -R ${Boot_Dir} 2&>/dev/null
                if ! ls ${Boot_Dir} &>/dev/null ; then
                    mkdir -p ${Boot_Dir}
                fi
            else
                Boot_Dir="${System_Root}/boot"
                umount -R ${Boot_Dir} 2&>/dev/null
                mkdir -p ${Boot_Dir} &>/dev/null 
            fi
            Format_mount "${Boot_Dir}" 
            partition_facts _Open_mount_ "/dev/$userinput_disk" ${Boot_Dir}

            bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "Boot_partition" "/dev/$userinput_disk"
}

# 格式化并挂载虚拟的Swap分区，可自定义大小
function partition_swap(){
    local read_text_output
    showDisk
    read_text_output=$(echo -e "\n${PSY} ${y}lease select the size of swapfile: ${g}[example:256M-10000G ~] ${y}Skip: ${g}[No]${h} ${JHB}")
    read -rp "${read_text_output}"  input_swap_size
    case ${input_swap_size} in
        [Nn]* )
            echo -e "${wg} ::==>> Partition complete. ${h}"  
            sleep 1;
        ;;
        * )
            if echo "$input_swap_size" | grep -E "^[0-9]*[A-Z]$" &>/dev/null ; then
                echo -e "${PSG} ${g}Assigned Swap file Size: ${input_swap_size} .${h}"
                fallocate -l "${input_swap_size}" /mnt/swapfile 
                chmod 600 /mnt/swapfile 
                mkswap /mnt/swapfile 
                swapon /mnt/swapfile 
                
                bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "Swap_file" "/mnt/swapfile"
                bash "${Share_Dir}/Edit_Database.sh" "${Local_Dir}" "_Write_" "_Info_" "Swap_size" "${input_swap_size}"
            else
                echo -e "\n${PSY} ${y}Skip create a swap file.${h}"  
                sleep 1;
                echo;
            fi
        ;;
    esac 
}
clear;
facts;
partition; # 选择磁盘 #parted /dev/sdb mklabel gpt   转换格式 GPT
partition_root;
partition_booting;
partition_swap;  #swap file 虚拟文件(类似与win里的虚拟文件) 对于swap分区我更推荐这个，后期灵活更变
partition_other;
echo -e "${wg} ::==>> Partition complete. ${h}" 
