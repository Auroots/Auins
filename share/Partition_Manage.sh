#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure Partition -> auin V4.6 r5
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
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
# @输出磁盘表及UUID
function showDisk(){ echo; lsblk -o+UUID | grep -E "sd..|vd..|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$"; }
# @检查磁盘名是否合法
function testDisk(){ echo "${1}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z]$|^vd[a-z]$|^nvme[0-9]n[0-9]$|^mmcblk[0-9]$" || echo "ERROR"; }
# @检查分区名是否合法
function testPartition(){ echo "${1}" | cut -d"/" -f3 | grep -E "^[a-z]d[a-z][1-9]$|^vd[a-z][1-9]$|^nvme[0-9]n[0-9]p[1-9]$|^mmcblk[0-9]p[1-9]$" || echo "ERROR"; }
# 检查输入的值，是否正确; 获取磁盘[\_partition\_], 获取分区[\_partition_root\_], 获取磁盘类型[\_Disk_Type\_], 挂载分区[\_Open_mount\_] [磁盘] [目录].

function init(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'  
    wg='\033[1;42m';  

    #-----------------------------#
    # 交互: 绿 黄
    inG=$(echo -e "${green}-=>${suffix} "); 
    inY=$(echo -e "${yellow}-=>${suffix} ")
    #-----------------------------
    # 提示 红 绿 黄
    outR="${white}::${red} =>${suffix}"
    outG="${white}::${green} =>${suffix}"; 
    outY="${white}::${yellow} =>${suffix}"

    out_SKIP="${white}::${yellow} [ Skip ] =>${suffix}"
    out_EXEC="${white}::${blue} [ Exec ] =>${suffix}"
    out_WELL="${white}:: ${wg}[ Well ]${suffix}${green} =>${suffix}"
    out_ERROR="${white}::${red} [ Error ] =>${suffix}"
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
    case ${PM_Enter_1} in
        start)   bash "$Process_Manage" start "${PM_Enter_2}" ;;
        restart) bash "$Process_Manage" restart "${PM_Enter_2}" ;;
        stop)    bash "$Process_Manage" stop "${PM_Enter_2}"
    esac
}
# 磁盘分区
function partition(){
    showDisk
    printf "\n${outY} ${yellow}Please Select disk: ${green}/dev/sdX | sdX ${suffix} %s" "${inY}"
    input_disk=$(Read_user_input)  # 输入磁盘名
    inspect_Disk=$(partition_facts _disk_ "$input_disk") # 检查磁盘是否输入正确, 如果输入错误则返回"ERROR"
    case "$inspect_Disk" in
        ERROR)  echo -e "\n${out_ERROR} ${red} [cfdisk] Please input: /dev/sdX | sdX !!! ${suffix}"  
                Process_Management stop "$0";;
        *   )   Config_File_Manage INFO Write "Disk" "$input_disk" && partition_type "$input_disk"
                cfdisk "/dev/$inspect_Disk"
    esac
}

function partition_facts(){
    local Disk_options=$1 Input_disk=$2 Input_partition=$2 Mount_path=$3
    function inspect_disk_type(){ fdisk -l "/dev/$1" | grep -Eo "gpt|dos|sgi|sun"; }

    case ${Disk_options} in
        _disk_          ) testDisk "$Input_disk" ;; # 检查磁盘名称，错误返回: "ERROR"
        _partition_root_) testPartition "$Input_partition" ;; # 检查分区名称，错误返回: "ERROR"
        _Disk_Type_     )  # Detect disk type
             case $(inspect_disk_type "$2") in 
                gpt) printf "GPT" ;;
                dos) printf "MBR" ;;
                sgi) printf "sgi" ;;
                sun) printf "sun" ;;
                *  ) printf "Unformatted Disk"
             esac;;
        _Open_mount_)  # Mount partition
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
        printf "\n${outR} ${red} Boot and disk do not match ${blue}[ %s${red} - ${blue}%s ]${suffix}${red}.${suffix}" "${Boot_Type}" "${disk_type}"
        printf "\n${outY} ${yellow}Whether to convert Disklabel type -> ${blue}[$System_Disk_Type]${yellow}? [y/N]:${suffix} %s" "${inY}"
        case "$(Read_user_input)" in
            [Yy]*)
                if [[ "$System_Disk_Type" = "GPT" ]] ; then
                    System_Disk_Type="gpt"
                elif [[ "$System_Disk_Type" = "MBR" ]] ; then
                    System_Disk_Type="msdos"   
                fi
                parted "/dev/$input_disk_name" mklabel "$System_Disk_Type" -s
            ;;
            [Nn]*)
                printf "\n${out_ERROR} ${red}Disklabel type${blue}[ %s ] ${red}not match and cannot be install System.${suffix}" "${disk_type}"
                Process_Management stop "$0"
                exit 2;
            ;;
            *)
                if [[ "$System_Disk_Type" = "GPT" ]] ; then
                    System_Disk_Type="gpt"
                elif [[ "$System_Disk_Type" = "MBR" ]] ; then
                    System_Disk_Type="msdos"   
                fi
                parted /dev/"$input_disk_name" mklabel "$System_Disk_Type" -s
            ;;
        esac 
    else 
        printf "\n${out_WELL} ${green}Currently booted with ${blue}[ %s ]. ${green}Select disk type: ${blue}[ %s ].${suffix}" "${Boot_Type}" "${System_Disk_Type}"; sleep 3
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
    printf "${outG} ${green}Please Select File System. [Default: 3]${suffix} %s" "${inG}"
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

        read_output=$(echo -e "${outG} ${green}Input directory. [home|usr|...]?${suffix} $inG")
        read -rp "${read_output}" Options_mount_dir
        case ${Options_mount_dir} in
            home) other_Format "/home" ;;
            opt)  other_Format "/opt" ;;
            usr)  other_Format "/usr" ;;
            var)  other_Format "/var" ;;
            etc)  other_Format "/etc" ;;
            tmp)  other_Format "/tmp" ;;
            proc) other_Format "/proc" ;;
            quit) echo -e "${out_EXEC} ${wg}Partition complete. ${suffix}"; exit 0 ;;
        esac
    }

    printf "${outG} ${green}Continue to mount directory. [Y/n]?${suffix} %s" "${inG}"
    case $(Read_user_input) in
        [Yy]* ) partition_other_start ;;
            * ) echo -e "${wg} ::==>> Partition complete. ${suffix}"; exit 0
    esac
    
    # other_Format [path]， 掩盖/mnt前缀，挂载到新系统的根下某目录，例：other_Format /auroot
    function other_Format(){
        local 
        local path=${System_Root}${1}
        if ls "${path}" &>/dev/null ; then
            Format "${path}" # 获取磁盘名
        else
            printf "\n${out_EXEC} ${white}Creating directory: ${blue}[ %s ]${suffix}${white}.${suffix}\n" "${path}"
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
    printf "\n${outY} ${yellow}Please Choose your ${white}[ %s ] ${yellow}partition: ${green}/dev/sdX[0-9] | sdX[0-9] ${suffix} %s" "${input_Path}" "${inG}"
    inspect_input_Partition=$(partition_facts _partition_root_ "$(Read_user_input)") # 检查磁盘名称，并返回值
    case "$inspect_input_Partition" in # 格式化
        ERROR)  printf "\n${out_ERROR} ${white} [ %s ] ${red}Please input: /dev/sdX[0-9] | sdX[0-9] !!! ${suffix}\n" "${input_Path}"
                Process_Management stop "$0" ;;
        *   )   if ! Disk_Filesystem_List "/dev/$inspect_input_Partition" ; then
                    sleep 1;
                fi 
    esac
    Format_return_partition_name="$inspect_input_Partition"; # 返回用户输入到分区名
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
            printf "\n${outY} ${green}Please enter the disk label. [Default: Data]${suffix} %s" "${inY}"
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
    printf  "${out_WELL} ${green}Successfully formatted ${white}[ %s ]${green} as ${white}[ %s ]${green} file system.${suffix}\n" "$Disk" "$Root_SystemFiles"
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
    printf "\n${outY} ${yellow}Please Choose your ${white}[ UEFI(${Boot_Dir}) ] ${yellow}partition: ${green}/dev/sdX[0-9] | sdX[0-9] ${suffix} %s" "${inY}"
    # 等待用户输入引导分区
    UEFI_partition_name=$(partition_facts _partition_root_ "$(Read_user_input)")

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
        printf "${out_EXEC} ${green}%s${white}[ %s ]${green}.${suffix}\n" "Assigned Swap file Size: " "$1"
        fallocate -l "${1}" /mnt/swapfile && printf "${out_ERROR} ${red}%s${suffix}\n" "Create Swap failed." # 创建指定大小的swap虚拟化文件
        chmod 600 /mnt/swapfile # 设置权限
        mkswap /mnt/swapfile    # 格式化swap文件
        swapon /mnt/swapfile    # 挂载swap文件
        Config_File_Manage INFO Write Swap "/mnt/swapfile"
        Config_File_Manage INFO Write Swap_size "${1}"
        printf "${out_WELL} ${green}%s${suffix}\n" "Successfully created Swap."
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
        printf "${out_WELL} ${green}%s${white}[ %s ]${green}.${suffix}\n" "Successfully allocated swap partition, size: " "$input_swap_size"
        Config_File_Manage INFO Write Swap "/dev/$input_swap_device"
        Config_File_Manage INFO Write Swap_size "${input_swap_size}"
    }
    showDisk
    CONF_Root_SystemFile=$(Config_File_Manage INFO Read Root_SystemFile)

    printf "\n${outY} ${yellow}lease select the Swapfile: ${green}[size:256M-100G ~] ${yellow}or Swap partition: ${green}sdX[0-9]${yellow} Skip: ${green}[No]${suffix} %s" "${inY}"
    input_swap=$(Read_user_input)
    if echo "$input_swap" | grep -E "^[0-9]*[kK|mM|gG]$" &>/dev/null ; then
        case $CONF_Root_SystemFile in
            ext[2-4]) Swap_File "$input_swap";;
                   *) echo -e "\n${out_ERROR} ${red}Swapfile cannot be created.${suffix}"
                      sleep 2s; exit 4 ;;
        esac 
    elif testPartition "$input_swap" &>/dev/null ; then
         Swap_Partition "$input_swap"
    else
        echo -e "${out_SKIP} ${yellow}create a swap file.${suffix}"; sleep 1
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
echo -e "${wg} ::==>> Partition complete. ${suffix}"

# bash "${Share_Dir}/Partition_Manage.sh" [profile] [info];