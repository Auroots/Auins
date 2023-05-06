#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure Partition -> auin V4.6 r7
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
export Root_SystemFiles

function Config_File_Manage(){ 
    local format=" = "; parameter="$3"; content="$4";
    case "$1" in
        INFO) local Files="$Auins_Infofile" ;;
        CONF) local Files="$Auins_Profile" ;;
    esac
    case "$2" in
        Read )   grep -w "$parameter" < "$Files" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';)
                sed -i "${List_row:-Not}c ${parameter}${format}${content}" "$Files" 2>/dev/null
    esac
}
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white() { printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# feedback successfully info
function feed_well(){ echo -e "\033[1;37m:: $(tput bold; tput setaf 2)=> \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run() { echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip() { echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }
# @输出磁盘表及UUID
function showDisk(){ echo; lsblk -o+UUID | grep -E "sd..|vd..|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$"; }

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
function init(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    # yellow='\033[1;33m'; 
    blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'  
    wg='\033[1;42m';  
    # 定义全局变量
    export System_Root Boot_Dir Boot_Type System_Disk_Type
    # Detect boot 检查引导, 并赋予引导类型
    if [ -d /sys/firmware/efi ]; then
        Boot_Type="UEFI" System_Disk_Type="GPT"
    else
        Boot_Type="BIOS" System_Disk_Type="MBR"
    fi
    # 记录
    Config_File_Manage INFO Write "Boot_Type" "$Boot_Type" 
    Config_File_Manage INFO Write "Disk_Type" "$System_Disk_Type"
    # 定义目录
    System_Root="/mnt"
    Boot_Dir="${System_Root}/boot/efi"
}

# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    PM_Enter_3=${3}
    case ${PM_Enter_1} in
        start)   bash "$Process_Manage" start "${PM_Enter_2}" "${PM_Enter_3}" ;;
        restart) bash "$Process_Manage" restart "${PM_Enter_2}" "${PM_Enter_3}" ;;
        stop)    bash "$Process_Manage" stop "${PM_Enter_2}" "${PM_Enter_3}"
    esac
}

# 磁盘分区
function partition(){
    showDisk
    tips_white "Please Select disk: /dev/sdX | sdX"
    input_disk=$(Read_user_input)  # 输入磁盘名
    partition_facts _disk_ "$input_disk"
    partition_type "$input_disk"
    cfdisk "/dev/$input_disk"
    Config_File_Manage INFO Write "Disk" "/dev/$input_disk"
}

# 检查输入的值，是否正确; 获取磁盘[\_partition\_], 获取分区[\_partition_root\_], 获取磁盘类型[\_Disk_Type\_], 挂载分区[\_Open_mount\_] [磁盘] [目录].
function partition_facts(){
    local Disk_options=$1 Input_disk=$2 Input_partition=$2 Mount_path=$3

    function inspect_disk_type(){ if [ -e "/dev/$1" ]; then fdisk -l "/dev/$1" | grep -Eo "gpt|dos|sgi|sun"; fi; }
    case ${Disk_options} in
        _disk_          )   # 检查磁盘名称，错误返回: "ERROR"
                            if [[ $(testDisk "$Input_disk") = "ERROR" ]]; then 
                                Process_Management stop "$0" "${red} Unable to find the ${white}[ ${Input_disk} ] ${red} disk address, please check if the disk exists! \n${white}:: => Please input: /dev/sdX | sdX !!!${suffix}"
                            fi ;; 
        _partition_root_)   # 检查分区名称，错误返回: "ERROR"
                            if [[ $(testPartition "$Input_partition") = "ERROR" ]]; then 
                                Process_Management stop "$0" "${white} [ ${Input_partition} ] ${red}Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${suffix}"
                            fi ;; 
        _Disk_Type_     )   # Detect disk type
                            case $(inspect_disk_type "$Input_disk") in 
                                gpt  ) printf "GPT" ;;
                                dos  ) printf "MBR" ;;
                                sgi  ) printf "sgi" ;;
                                sun  ) printf "sun" ;;
                                *  ) printf "Unformatted Disk"
                            esac ;; 
        _Open_mount_)       # Mount partition
                            if ! mountpoint -q "$Mount_path" ; then  # 测试该目录是否已被挂载，系统全部挂载列表：/proc/self/mountinfo
                                mount "$Input_disk" "$Mount_path"
                            else
                                umount -R "$Mount_path" &>/dev/null
                                mount "$Input_disk" "$Mount_path"
                            fi
    esac
}

# 判断使用的磁盘是否符合当前系统要求，并自定义改变[MBR/GPT]
function partition_type(){
    local input_disk_name=$1
    disk_type=$(partition_facts _Disk_Type_ "$input_disk_name")
    lsblk | grep -E "^[a-z]d[a-z]|^nvme|^mmc"|grep -v "grep" 
    if [[ "$disk_type" != "$System_Disk_Type" ]] ; then
        feed_well "${red}Boot and disk do not match ${blue}[ $Boot_Type ${red}-${blue} $disk_type ]${suffix}"
        tips_white "Whether to convert Disklabel type -> [ $System_Disk_Type ] [Y/n]?"
        case "$(Read_user_input)" in
            [Yy]*)
                    if [[ "$System_Disk_Type" = "GPT" ]] ; then
                        System_Disk_Type="gpt"
                    elif [[ "$System_Disk_Type" = "MBR" ]] ; then
                        System_Disk_Type="msdos"   
                    fi
                    parted "/dev/$input_disk_name" mklabel "$System_Disk_Type" -s ;;
            [Nn]*)  Process_Management stop "$0" "${red}Disklabel type${blue}[ ${disk_type} ] ${red}not match and cannot be install System.${suffix}" ;;
                *)
                    if [[ "$System_Disk_Type" = "GPT" ]] ; then
                        System_Disk_Type="gpt"
                    elif [[ "$System_Disk_Type" = "MBR" ]] ; then
                        System_Disk_Type="msdos"   
                    fi
                    parted /dev/"$input_disk_name" mklabel "$System_Disk_Type" -s
        esac 
    else 
        feed_well "Currently booted with ${blue}[ $Boot_Type ] ${green}Select disk type: ${blue}[ $System_Disk_Type ]${suffix}"
    fi 
}

# @ 自选文件系统, 并格式化
function Disk_Filesystem_List(){
echo -e "${green}\n\t File System List${suffix}
------------------------------------
| 1. ext2 | 4. btrfs | 7. jfs      |
------------------------------------
| 2. ext3 | 5. vfat  | 8. ntfs-3g  |
------------------------------------
| 3. ext4 | 6. f2fs  | 9. reiserfs |
------------------------------------
"
    local Disk=$1
    tips_white "Please Select File System. [Default: 3]?"
    input_Fs_type=$(Read_user_input)
    if [[ "$input_Fs_type" = "" ]]; then
        Disk_Filesystem 3 "$Disk"
    else
        Disk_Filesystem "$input_Fs_type" "$Disk"
    fi   
}

#其他分区
function partition_other(){
    # @先选择目录, 之后交给: other_Format ;   
    function partition_other_start() {
    echo -e "${green}\n\tMount directory${suffix} 
---------------------------------------------
| home | opt | usr | var | etc | tmp | proc | 
=============================================
# User defined directory, please enter absolute address.
# Wrong choice? Enter (quit) to exit"

        tips_white "Please Select directory. [home|usr|...]?"
        case $(Read_user_input) in
            home) other_Format "/home" ;;
            opt)  other_Format "/opt" ;;
            usr)  other_Format "/usr" ;;
            var)  other_Format "/var" ;;
            etc)  other_Format "/etc" ;;
            tmp)  other_Format "/tmp" ;;
            proc) other_Format "/proc" ;;
            quit) run "Partition complete."; exit 0 ;;
        esac
    }

    tips_white "Continue to mount directory. [Y/n]?"
    case $(Read_user_input) in
        [Yy]* ) partition_other_start ;;
            * ) feed_well "${wg} Partition complete. ${suffix}"; exit 0
    esac
    
    # other_Format [path]， 掩盖/mnt前缀，挂载到新系统的根下某目录，例：other_Format /auroot
    function other_Format(){
        local 
        local path=${System_Root}${1}
        if ls "${path}" &>/dev/null ; then
            Format "${path}" # 获取磁盘名
        else
            run "Creating directory: ${blue}[ $path ]${suffix}" 
            mkdir -p "${path}"
            Format "${path}" # 获取磁盘名
        fi
        partition_facts _Open_mount_ "/dev/$Format_return_partition_name" "${path}" # 万事俱备，挂载
        showDisk  # 最后输出一下分区表
    }
    partition_other # 再运行, 输入quit，即退出
}

# 负责简化和检查输入到磁盘地址: /dev/sdX[0-9] -> sdX[0-9],如果没有问题，将值给Disk_Filesystem_List格式化操作
function Format(){
    local input_Path=$1 Rename_root=$2; input_Path=${Rename_root:-$input_Path}
    showDisk 
    tips_white "Please Choose your [ $input_Path ] partition: /dev/sdX[0-9] | sdX[0-9]"
    partition_name="$(Read_user_input)"
    partition_facts _partition_root_ "$partition_name"

    Disk_Filesystem_List "/dev/$partition_name"
    Format_return_partition_name="$partition_name"; # 返回用户输入到分区名
}

# 自定义文件系统格式化
function Disk_Filesystem(){
    local Options=$1
    local Disk=$2
    case ${Options} in
        1)  mkfs.ext2 "${Disk}" && Root_SystemFiles="ext2" ;;
        2)  mkfs.ext3 "${Disk}" && Root_SystemFiles="ext3" ;;
        3)  mkfs.ext4 "${Disk}" && Root_SystemFiles="ext4" ;;
        4)
            tips_white "Please enter the disk label. [Default: Data]?"
            Disk_label=$(Read_user_input)
            if [ "$Disk_label" = "" ]; then
                mkfs.btrfs -L Data -f "${Disk}"
            else
                mkfs.btrfs -L "$Disk_label" -f "${Disk}"
            fi && Root_SystemFiles="btrfs"
        ;;
        5) mkfs.vfat "${Disk}" && Root_SystemFiles="vfat" ;;
        6) mkfs.f2fs "${Disk}" && Root_SystemFiles="f2fs" ;;
        7) mkfs.jfs  "${Disk}" && Root_SystemFiles="jfs" ;;
        8) ntfs-3g   "${Disk}" && Root_SystemFiles="ntfs-3g" ;;
        9) mkfs.reiserfs "${Disk}" && Root_SystemFiles="reiserfs" ;;
    esac
    if [ -n "${Root_SystemFiles}" ] ; then
        feed_well "Successfully formatted ${white}[ $Disk ]${green} as ${white}[ $Root_SystemFiles ]${green} file system.${suffix}"
    fi
}

# 格式化并挂载Root分区, 输入: /dev/sdX[0-9] | sdX[0-9]
function partition_root(){
    umount -R $System_Root* 2>/dev/null
    Format "$System_Root" 'root(/)' # 请求输入磁盘地址和文件系统类型，格式化, 会生成变量：Format_return_partition_name
    partition_facts _Open_mount_ "/dev/$Format_return_partition_name" "$System_Root" # 挂载
    
    Config_File_Manage INFO Write Root_partition "/dev/$Format_return_partition_name"
    Config_File_Manage INFO Write Root_SystemFile "$Root_SystemFiles"
    Boot_partition=$(echo "/dev/$Format_return_partition_name" | awk '{sub(/[1-9]*$/,"");print}')
    if [ $Boot_Type = "BIOS" ]; then Config_File_Manage INFO Write Boot_partition "$Boot_partition"; fi
}

# 格式化并挂载 UEFI引导分区，输入: /dev/sdX[0-9] | sdX[0-9]
function partition_booting_UEFI(){
    umount -R ${Boot_Dir} 2&>/dev/null
    if ! ls ${Boot_Dir} &>/dev/null ; then
        mkdir -p ${Boot_Dir}
    fi
    showDisk 
    tips_white "Please Choose your [ UEFI(${Boot_Dir}) ] partition: /dev/sdX[0-9] | sdX[0-9]"
    # 等待用户输入引导分区
    UEFI_partition_name=$(Read_user_input)
    partition_facts _partition_root_ "$UEFI_partition_name"
    Disk_Filesystem 5 "/dev/$UEFI_partition_name" 
    partition_facts _Open_mount_ "/dev/$UEFI_partition_name" "$Boot_Dir"
    Config_File_Manage INFO Write Boot_partition "/dev/$UEFI_partition_name"
    Config_File_Manage INFO Write Boot_SystemFile "$Root_SystemFiles"
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
        run "Assigned Swap file Size: ${white}[ $1 ]${suffix}"
        fallocate -l "${1}" /mnt/swapfile \
            || err "Create Swap failed." # 创建指定大小的swap虚拟化文件
        chmod 600 /mnt/swapfile # 设置权限
        mkswap /mnt/swapfile    # 格式化swap文件
        swapon /mnt/swapfile    # 挂载swap文件
        Config_File_Manage INFO Write Swap "/mnt/swapfile"
        Config_File_Manage INFO Write Swap_size "${1}"
        feed_well "Successfully created Swap."
    }
    function Swap_Partition(){
        input_swap_device="$1"
        mkswap "/dev/$input_swap_device"
        # swapon "/dev/$input_swap_device"
        SWAP_UUID=$(blkid -s PARTUUID -o value "/dev/$input_swap_device")
        echo "UUID=$SWAP_UUID none swap defaults 0  0" >> /etc/fstab
        mount -a
        # input_swap_size=$(df -ha | grep "$input_swap_device" | awk -F " " '{print $2}')
        input_swap_size=$(lsblk | grep "$input_swap_device" | awk -F " " '{print $4}')
        feed_well "Successfully allocated swap partition, size: ${white}$input_swap_size${suffix}"
        Config_File_Manage INFO Write Swap "/dev/$input_swap_device"
        Config_File_Manage INFO Write Swap_size "${input_swap_size}"
    }
    showDisk
    CONF_Root_SystemFile=$(Config_File_Manage INFO Read Root_SystemFile)

    tips_white "Please set swap size: [ 256M-100G~ ]? Or exchange partition: sdX[0-9]? Skip: [No]?"
    input_swap=$(Read_user_input)
    if echo "$input_swap" | grep -E "^[0-9]*[kK|mM|gG]$" &>/dev/null ; then
        case $CONF_Root_SystemFile in
            ext[2-4]) Swap_File "$input_swap";;
                   *) err "Swapfile cannot be created." ;;
        esac 
    elif testPartition "$input_swap" &>/dev/null ; then
         Swap_Partition "$input_swap"
    else
        skip "create a swap file."; sleep 1
    fi
}

# 具体的实现 >> >> >> >> >> >> >> >> 
echo &>/dev/null
Auins_Profile=${1}
Auins_Infofile=${2}
Share_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
Process_Manage="${Share_Dir}/Process_Manage.sh"
clear; init;
partition; # 选择磁盘 #parted /dev/sdb mklabel gpt   转换格式 GPT
partition_root;
Conf_New_Other_Partition=$(Config_File_Manage CONF Read "New_Other_Partition")
if [ "$Boot_Type" = "UEFI" ]; then partition_booting_UEFI; else partition_booting_BIOS; fi  
partition_swap;  #swap file 虚拟文件(类似与win里的虚拟文件) 对于swap分区我更推荐这个，后期灵活更变
if [ "$Conf_New_Other_Partition" = yes ]; then partition_other; fi
feed_well "${wg} Partition complete. ${suffix}"
# bash "${Share_Dir}/Partition_Manage.sh" [profile] [info];