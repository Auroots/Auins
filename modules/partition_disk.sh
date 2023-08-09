#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Partition Disk -> Auins v4.7.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x

# 列出需要包含的配置文件或模块
function include(){
    set +e
    declare -a argu=("$@")
    # declare -p argu
    export config_File info_File Tools_modules
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    Tools_modules="${argu[2]}"
    set -e
}
# 小型重复性高的模块调用管理器
function run_tools(){
    bash "$Tools_modules" "$config_File" "$info_File" " " "$1" "$2" "$3" "$4" "$5"
}

function init(){ 
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    # yellow='\033[1;33m'; 
    blue='\033[1;36m' white='\033[1;37m'; suffix='\033[0m'  
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
    run_tools file_rw INFO Write "Boot_Type" "$Boot_Type" 
    run_tools file_rw INFO Write "Disk_Type" "$System_Disk_Type"
    # 定义目录
    System_Root="/mnt"
    Boot_Dir="${System_Root}/boot/efi"
}

# 磁盘分区
function partition(){
    run_tools show_Disk
    run_tools tips_w "Please Select disk: /dev/sdX | sdX"
    input_disk=$(run_tools read)  # 输入磁盘名
    partition_facts _disk_ "$input_disk"
    partition_type "$input_disk"
    cfdisk "/dev/$input_disk"
    run_tools file_rw INFO Write "Disk" "/dev/$input_disk"
}

# 检查输入的值，是否正确; 获取磁盘[\_partition\_], 获取分区[\_partition_root\_], 获取磁盘类型[\_Disk_Type\_], 挂载分区[\_Open_mount\_] [磁盘] [目录].
function partition_facts(){
    local Disk_options=$1 Input_disk=$2 Input_partition=$2 Mount_path=$3

    function inspect_disk_type(){ if [ -e "/dev/$1" ]; then fdisk -l "/dev/$1" | grep -Eo "gpt|dos|sgi|sun"; fi; }
    case ${Disk_options} in
        _disk_          )   # 检查磁盘名称，错误返回: "ERROR"
                            if [[ $(run_tools test_Disk "$Input_disk") = "ERROR" ]]; then 
                                run_tools process stop "$0" "${red} Unable to find the ${white}[ ${Input_disk} ] ${red} disk address, please check if the disk exists! \n${white}:: => Please input: /dev/sdX | sdX !!!${suffix}"
                                exit 70
                            fi ;; 
        _partition_root_)   # 检查分区名称，错误返回: "ERROR"
                            if [[ $(run_tools test_Part "$Input_partition") = "ERROR" ]]; then 
                                run_tools process stop "$0" "${white} [ ${Input_partition} ] ${red}Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${suffix}"
                                exit 70
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
        run_tools feed "${red}Boot and disk do not match ${blue}[ $Boot_Type ${red}-${blue} $disk_type ]${suffix}"
        run_tools tips_w "Whether to convert Disklabel type -> [ $System_Disk_Type ] [Y/n]?"
        case "$(run_tools read)" in
            [Yy]*)
                    if [[ "$System_Disk_Type" = "GPT" ]] ; then
                        System_Disk_Type="gpt"
                    elif [[ "$System_Disk_Type" = "MBR" ]] ; then
                        System_Disk_Type="msdos"   
                    fi
                    parted "/dev/$input_disk_name" mklabel "$System_Disk_Type" -s ;;
            [Nn]*)  
                    run_tools process stop "$0" "${red}Disklabel type${blue}[ ${disk_type} ] ${red}not match and cannot be install System.${suffix}" ;;
                *)
                    if [[ "$System_Disk_Type" = "GPT" ]] ; then
                        System_Disk_Type="gpt"
                    elif [[ "$System_Disk_Type" = "MBR" ]] ; then
                        System_Disk_Type="msdos"   
                    fi
                    parted /dev/"$input_disk_name" mklabel "$System_Disk_Type" -s
        esac 
    else 
        run_tools feed "Currently booted with ${blue}[ $Boot_Type ] ${green}Select disk type: ${blue}[ $System_Disk_Type ]${suffix}"
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
    run_tools tips_w "Please Select File System. [Default: 3]?"
    input_Fs_type=$(run_tools read)
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

        run_tools tips_w "Please Select directory. [home|usr|...]?"
        case $(run_tools read) in
            home) other_Format "/home" ;;
            opt)  other_Format "/opt" ;;
            usr)  other_Format "/usr" ;;
            var)  other_Format "/var" ;;
            etc)  other_Format "/etc" ;;
            tmp)  other_Format "/tmp" ;;
            proc) other_Format "/proc" ;;
            quit) 
                run_tools run "Partition complete."; exit 0 ;;
        esac
    }

    run_tools tips_w "Continue to mount directory. [Y/n]?"
    case $(run_tools read) in
        [Yy]* ) partition_other_start ;;
            * ) run_tools feed "${wg} Partition complete. ${suffix}"; exit 0
    esac
    
    # other_Format [path]， 掩盖/mnt前缀，挂载到新系统的根下某目录，例：other_Format /auroot
    function other_Format(){
        local 
        local path=${System_Root}${1}
        if ls "${path}" &>/dev/null ; then
            Format "${path}" # 获取磁盘名
        else
            run_tools run "Creating directory: ${blue}[ $path ]${suffix}" 
            mkdir -p "${path}"
            Format "${path}" # 获取磁盘名
        fi
        partition_facts _Open_mount_ "/dev/$Format_return_partition_name" "${path}" # 万事俱备，挂载
        run_tools show_Disk  # 最后输出一下分区表
    }
    partition_other # 再运行, 输入quit，即退出
}

# 负责简化和检查输入到磁盘地址: /dev/sdX[0-9] -> sdX[0-9],如果没有问题，将值给Disk_Filesystem_List格式化操作
function Format(){
    local input_Path=$1 Rename_root=$2; input_Path=${Rename_root:-$input_Path}
    run_tools show_Disk 
    run_tools tips_w "Please Choose your [ $input_Path ] partition: /dev/sdX[0-9] | sdX[0-9]"
    partition_name="$(run_tools read)"
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
            run_tools tips_w "Please enter the disk label. [Default: Data]?"
            Disk_label=$(run_tools read)
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
        run_tools feed "Successfully formatted ${white}[ $Disk ]${green} as ${white}[ $Root_SystemFiles ]${green} file system.${suffix}"
    fi
}

# 格式化并挂载Root分区, 输入: /dev/sdX[0-9] | sdX[0-9]
function partition_root(){
    set +e
    umount -R $System_Root 2>/dev/null
    set -e
    Format "$System_Root" 'root(/)' # 请求输入磁盘地址和文件系统类型，格式化, 会生成变量：Format_return_partition_name
    partition_facts _Open_mount_ "/dev/$Format_return_partition_name" "$System_Root" # 挂载
    run_tools file_rw INFO Write Root_partition "/dev/$Format_return_partition_name"
    run_tools file_rw INFO Write Root_SystemFile "$Root_SystemFiles"
    if [ $Boot_Type = "BIOS" ]; then
        partition_booting_BIOS
    fi
}

# 格式化并挂载 UEFI引导分区，输入: /dev/sdX[0-9] | sdX[0-9]
function partition_booting_UEFI(){
    set +e
    umount -R ${Boot_Dir} 2&>/dev/null
    if ! ls ${Boot_Dir} &>/dev/null ; then
        mkdir -p ${Boot_Dir}
    fi
    set -e
    run_tools show_Disk 
    run_tools tips_w "Please Choose your [ UEFI(${Boot_Dir}) ] partition: /dev/sdX[0-9] | sdX[0-9]"
    # 等待用户输入引导分区
    UEFI_partition_name=$(run_tools read)
    partition_facts _partition_root_ "$UEFI_partition_name"
    Disk_Filesystem 5 "/dev/$UEFI_partition_name" 
    partition_facts _Open_mount_ "/dev/$UEFI_partition_name" "$Boot_Dir"
    run_tools file_rw INFO Write Boot_partition "/dev/$UEFI_partition_name"
}

# 格式化并挂载 BIOS引导分区，输入: /dev/sdX[0-9] | sdX[0-9]
function partition_booting_BIOS(){
    Boot_partition=$(echo "/dev/$Format_return_partition_name" | awk '{sub(/[1-9]*$/,"");print}')
    run_tools file_rw INFO Write Boot_partition "$Boot_partition"
}

# 格式化并挂载虚拟的Swap分区，可自定义大小
function partition_swap(){
    function Swap_File(){
        run_tools run "Assigned Swap file Size: ${white}[ $1 ]${suffix}"
        fallocate -l "${1}" /mnt/swapfile \
            || run_tools err "Create Swap failed." # 创建指定大小的swap虚拟化文件
        chmod 600 /mnt/swapfile # 设置权限
        mkswap /mnt/swapfile    # 格式化swap文件
        swapon -f /mnt/swapfile    # 挂载swap文件
        run_tools file_rw INFO Write Swap "/mnt/swapfile"
        run_tools file_rw INFO Write Swap_size "${1}"
        run_tools feed "Successfully created Swap."
    }
    function Swap_Partition(){
        input_swap_device="$1"
        mkswap "/dev/$input_swap_device"
        SWAP_UUID=$(blkid -s PARTUUID -o value "/dev/$input_swap_device")
        echo "UUID=$SWAP_UUID none swap defaults 0  0" >> /etc/fstab
        mount -a
        # input_swap_size=$(df -ha | grep "$input_swap_device" | awk -F " " '{print $2}')
        input_swap_size=$(lsblk | grep "$input_swap_device" | awk -F " " '{print $4}')
        run_tools feed "Successfully allocated swap partition, size: ${white}$input_swap_size${suffix}"
        run_tools file_rw INFO Write Swap "/dev/$input_swap_device"
        run_tools file_rw INFO Write Swap_size "${input_swap_size}"
    }
    run_tools show_Disk
    CONF_Root_SystemFile=$(run_tools file_rw INFO Read Root_SystemFile)

    run_tools tips_w "Please set swap size: [ 256M-100G~ ]? Or exchange partition: sdX[0-9]? Skip: [No]?"
    input_swap=$(run_tools read)
    case $input_swap in 
    [Nn]*)
        run_tools skip "create a swap file."; sleep 1
    ;; 
    *)
        if [[ $input_swap != "" ]]; then
            if echo "$input_swap" | grep -E "^[0-9]*[kK|mM|gG]$" &>/dev/null ; then
                case $CONF_Root_SystemFile in
                    ext[2-4]) Swap_File "$input_swap";;
                        *) run_tools err "Swapfile cannot be created." ;;
                esac 
            elif run_tools test_Part "$input_swap" &>/dev/null ; then
                Swap_Partition "$input_swap"
            else
                run_tools skip "create a swap file."; sleep 1
            fi
        else
            run_tools skip "create a swap file."; sleep 1
        fi
    esac 
}

# 具体的实现 >> >> >> >> >> >> >> >> 
echo &>/dev/null
include "$@"
clear; init
partition # 选择磁盘 #parted /dev/sdb mklabel gpt   转换格式 GPT
partition_root
Conf_New_Other_Partition=$(run_tools file_rw CONF Read "New_Other_Partition")
if [ "$Boot_Type" = "UEFI" ]; then partition_booting_UEFI else partition_booting_BIOS; fi  
partition_swap  #swap file 虚拟文件(类似与win里的虚拟文件) 对于swap分区我更推荐这个，后期灵活更变
if [ "$Conf_New_Other_Partition" = yes ]; then partition_other; fi
run_tools feed "${wg} Partition complete. ${suffix}"
