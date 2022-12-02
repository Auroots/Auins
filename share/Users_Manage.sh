#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure users -> Auins v4.5.3
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
Auins_Config=${1}
Auins_record=${2}

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
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

# 该死的颜色
function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    # red='\033[1;31m'; User_Password_INFO
    green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     

    out_SKIP="${white}::${yellow} [Skip] =>${suffix}"
    out_WARNING="${white}::${yellow} [Warning] =>${suffix}"
    out_EXEC="${white}::${blue} [Exec] =>${suffix}"
    # out_WELL="${white}::${green} [Well] =>${suffix}"
    # out_ERROR="${white}::${red} [ Error ] =>${suffix}"
}

# Start Script | 从这里开始
# >> >> >> >> >> >> >> >> >> >> >> >> 
Script_init_Variable
Set_Color_Variable

case "$Auto_Config_Users" in 
    [Yy]*)
        # 配置用户 >> >> >> >> >> >> >> >> >> 
        echo -e "${out_EXEC} ${green}Configuring user [${white}$User_Name_Conf${suffix}${green}].${suffix}" && sleep 1;
        useradd -m -g users -G wheel -s /bin/bash "${User_Name_Conf}"  # 新建用户
        echo -e "${out_EXEC} ${green}Configuring user [${white}$User_Name_Conf${suffix}${green}] password.${suffix}" && sleep 1;
        echo "${User_Name_Conf}:${User_Password_Conf}" | chpasswd &> /dev/null # 设置密码 
        echo -e "${out_EXEC} ${green}Configuring sudo permission.${suffix}" && sleep 1;
        cp /etc/sudoers /etc/sudoers.back
        # chmod 770 /etc/sudoers
        sed -i "${WHELL_LINE}i %wheel ALL=\(ALL:ALL\) ALL" /etc/sudoers
        # chmod 440 /etc/sudoers
        UsersID=$(id -u "$UserName_INFO" 2> /dev/null)
        Config_File_Manage INFO Write Users "${User_Name_Conf}"
        Config_File_Manage INFO Write UsersID "$UsersID"
        # Config_File_Manage INFO Write User_Password "${User_Password_Conf}"
        # 配置Root用户 >> >> >> >> >> >> >> >> >> 
        echo -e "${out_EXEC} ${green}Configuring user [${white}root${suffix}${green}] password.${suffix}" && sleep 1;
        echo "root:${Root_Password_Conf}" | chpasswd &> /dev/null   # 输入两次正确，将在这里设置Root密码
        # Config_File_Manage INFO Write "Root_Password" "${Root_Password_Conf}"
        # 配置Nopasswd用户 >> >> >> >> >> >> >> >> >> 
        case $Sudo_Nopasswd in
            [Yy]*)
                    echo -e "${out_WARNING} ${green}Enable Sudo Nopasswd.${suffix}" && sleep 1;
                    chmod 770 /etc/sudoers 
                    sed -i "${WHELL_LINE}"d /etc/sudoers  
                    sed -i "${NOPASSWD_LINE}i %wheel ALL=\(ALL:ALL\) NOPASSWD: ALL" /etc/sudoers
                    chmod 440 /etc/sudoers
            ;;
            [Nn]*)
                    echo -e "${out_SKIP} ${green}Not Sudo Nopasswd.${suffix}" && sleep 1;
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
            echo -e "${PSY} ${yellow}The User: ${green}${UserName} ${yellow}has been set. [Ok]${suffix}"
        fi
esac