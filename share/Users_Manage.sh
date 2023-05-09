#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure users -> Auins v4.6 r7
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
# 该死的颜色
# 红 绿 黄 蓝 白 后缀
# red='\033[1;31m'; User_Password_INFO
green='\033[1;32m' yellow='\033[1;33m'; 
# blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m' 

# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white() { printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# Error message wrapper
# function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run() { echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip() { echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }

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
                    warn "${white}$itself ${yellow}Read file: ${white}$Files${yellow} missing value: [${white} $parameter  ${yellow}]."
                    sleep 3
                fi
         ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';) # 在文件中查找匹配的值, 并打印行号
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "${white}$itself ${yellow}Write file: ${white}$Files${yellow} missing value: [${white} $parameter  ${yellow}] + [${white} $content ${yellow}]."
                    sleep 3
                fi
    esac 
}

function Script_init_Variable(){
    # 获取sudo关于新用户权限的行
    WHELL_LINE=$(awk '/%wheel ALL=\(ALL:ALL\) ALL/ {print NR}' /etc/sudoers)
    NOPASSWD_LINE=$(awk '/NOPASSWD/ {print NR}' /etc/sudoers)
    # 从信息表文件中获取信息
    UserName_INFO=$(Config_File_Manage INFO Read "Users")
    # 从配置文件中获取信息
    Auto_Config_Users=$(Config_File_Manage CONF Read "Auto_Config_Users")
    Sudo_Nopasswd=$(Config_File_Manage CONF Read "Sudo_Nopasswd")
    User_Name_Conf=$(Config_File_Manage CONF Read "User_Name")
    User_Password_Conf=$(Config_File_Manage CONF Read "User_Password")
    Root_Password_Conf=$(Config_File_Manage CONF Read "Root_Password")
}

function Configure_Users(){
    PASSWORD_TYPED="false"
    while [ "$PASSWORD_TYPED" != "true" ]; do
        UserPassword=$(whiptail --title "ArchLinux - Password" --passwordbox "Enter User Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3) # 设置密码
        UserPassword_retype=$(whiptail --title "ArchLinux - Password" --passwordbox "Again Enter User Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3) # 设置密码
        if [ "$UserPassword" == "$UserPassword_retype" ]; then
            # Config_File_Manage INFO Write User_Password "${UserPassword_retype}"
            useradd -m -g users -G wheel -s /bin/bash "${UserName}"  # 新建用户
            echo "${UserName}:${UserPassword_retype}" | chpasswd &> /dev/null # 设置密码 
            whiptail --title "Configure User Password." --msgbox "The ${UserName} password configuration is complete. [OK]" 10 60   # 提示配置root密码成功
            PASSWORD_TYPED="true"
            cp /etc/sudoers /etc/sudoers.back
            chmod 770 /etc/sudoers 
            sed -i "${WHELL_LINE}i %wheel ALL=\(ALL:ALL\) ALL" /etc/sudoers
            chmod 440 /etc/sudoers 
            break;
        else
            whiptail --title "Configure User Password." --msgbox "${UserName} password don't match. Please, type again. [X]" 10 60    # 输入两次错误，返回信息
        fi
    done
}

function Configure_Root_Password(){
    ROOT_PASSWORD_TYPED="false"
    while [ "$ROOT_PASSWORD_TYPED" != "true" ]; do
        RootPassword=$(whiptail --title "ArchLinux - Root Password" --passwordbox "Enter Root Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)  # 输入第一次root密码
        RootPassword_retype=$(whiptail --title "ArchLinux - Root Password" --passwordbox "Again Enter Root Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)  # 输入第二次root密码
        if [ "$RootPassword" == "$RootPassword_retype" ]; then
            # Config_File_Manage INFO Write "Root_Password" "${RootPassword_retype}"
            echo "root:${RootPassword_retype}" | chpasswd &> /dev/null   # 输入两次正确，将在这里设置Root密码
            whiptail --title "Configure Root Password." --msgbox "Root Password setting complete. [OK]" 10 60   # 提示配置root密码成功
            ROOT_PASSWORD_TYPED="true"
            break;
        else
            whiptail --title "Configure Root Password." --msgbox "Root password don't match. Please, type again. [X]" 10 60    # 输入两次错误，返回信息
        fi
    done 
}

function Configure_Sudo_Nopasswd(){
    if (whiptail --title "Configure Sudoers. Yes/No" --yesno "Whether to enable [Nopasswd]." 10 60); then
        chmod 770 /etc/sudoers 
        sed -i "${WHELL_LINE}"d /etc/sudoers  
        sed -i "${NOPASSWD_LINE}i %wheel ALL=\(ALL:ALL\) NOPASSWD: ALL" /etc/sudoers
        chmod 440 /etc/sudoers
        whiptail --title "Configure Sudoers." --msgbox "Configure Sudoers succeeded. [Ok]" 10 60   # 设置sudo成功
    else
        whiptail --title "Configure Sudoers." --msgbox "Has been skipped. [X]" 10 60   # 跳过设置sudo
    fi
}

# Start Script | 从这里开始
# >> >> >> >> >> >> >> >> >> >> >> >> 
Auins_Profile=${1}
Auins_Infofile=${2}
Script_init_Variable

case "$Auto_Config_Users" in 
    [Yy]*)
        # 配置用户 >> >> >> >> >> >> >> >> >> 
        run "Configuring user [${white} $User_Name_Conf ${suffix}${green}].${suffix}" && sleep 1;
        useradd -m -g users -G wheel -s /bin/bash "${User_Name_Conf}"  # 新建用户

        run "Configuring user [${white} $User_Name_Conf ${suffix}${green}] password.${suffix}" && sleep 1;
        echo "${User_Name_Conf}:${User_Password_Conf}" | chpasswd &> /dev/null # 设置密码 

        run "Configuring sudo permission." && sleep 1;
        cp /etc/sudoers /etc/sudoers.back
        # chmod 770 /etc/sudoers
        sed -i "${WHELL_LINE}i %wheel ALL=\(ALL:ALL\) ALL" /etc/sudoers
        # chmod 440 /etc/sudoers

        UsersID=$(id -u "$UserName_INFO" 2> /dev/null)
        Config_File_Manage INFO Write Users "${User_Name_Conf}"
        Config_File_Manage INFO Write UsersID "$UsersID"
        # Config_File_Manage INFO Write User_Password "${User_Password_Conf}"

        # 配置Root用户 >> >> >> >> >> >> >> >> >> 
        run "Configuring user [${white} root ${suffix}${green}] password.${suffix}" && sleep 1;
        echo "root:${Root_Password_Conf}" | chpasswd &> /dev/null   # 输入两次正确，将在这里设置Root密码
        # Config_File_Manage INFO Write "Root_Password" "${Root_Password_Conf}"

        # 配置Nopasswd用户 >> >> >> >> >> >> >> >> >> 
        case $Sudo_Nopasswd in
            [Yy]*)
                    warn "Enable Sudo [${white} Nopasswd ${suffix}${yellow}]." && sleep 1;
                    chmod 770 /etc/sudoers 
                    sed -i "${WHELL_LINE}"d /etc/sudoers  
                    sed -i "${NOPASSWD_LINE}i %wheel ALL=\(ALL:ALL\) NOPASSWD: ALL" /etc/sudoers
                    chmod 440 /etc/sudoers
            ;;
            [Nn]*)
                    skip "Not Sudo Nopasswd." && sleep 1;
        esac
    ;;
    [Nn]*)
        if [ "$UserName_INFO" = "" ]; then
            UserName=$(whiptail --title "ArchLinux - UserName" --inputbox "Enter UserName:" 10 60  3>&1 1>&2 2>&3)  # 输入用户名
            UsersID=$(id -u "$UserName_INFO" 2> /dev/null)
            Config_File_Manage INFO Write Users "$UserName"
            Config_File_Manage INFO Write UsersID "$UsersID"
            
            Configure_Users
            Configure_Root_Password
            Configure_Sudo_Nopasswd
        else
            whiptail --title "ArchLinux - User settings." --msgbox "Users: ${UserName}, Setup has been completed. [Ok]" 10 60
            feed_well "The User: [ ${white}${UserName}${green} ] has been set. [Ok]${suffix}"
        fi
esac