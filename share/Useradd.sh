#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure useradd -> auin V4.3.5
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# bash "${Share_Dir}/Useradd.sh" "config" "info";
# set -xe
Auins_Config=${1}
Auins_record=${2}

function S_LINE(){
    sed -n -e '/# %wheel ALL=(ALL) NOPASSWD: ALL/=' /etc/sudoers
}
# @读取文件 install.conf（默认）  auins.info（INFO）
function Read_Config(){ 
    # 头部参数 $1 , 地址 $2（如果是查install.conf，可以不用写）（如果是auins.info，必须写INFO） Read_Config "Disk" "INFO"
    if [[ $2 == "INFO" ]]; then
        local Files="$Auins_record"
    else
        local Files="${Auins_Config}"
    fi 
    grep -w "${1}" < "${Files}" | awk -F "=" '{print $2}'; 
}
# @写入信息文件 local/auins.info
function Write_Data(){
    # 头部参数 $1 , 修改内容 $2    
    format=" = "
    List_row=$(grep -nw "${1}" < "${Auins_record}" | awk -F ":" '{print $1}';)
    sed -i "${List_row:-Not}c ${1}${format}${2}" "${Auins_record}" 2>/dev/null
}
function Useradd_Config(){
    PASSWORD_TYPED="false"
    while [ "$PASSWORD_TYPED" != "true" ]; do
        UserPassword=$(whiptail --title "ArchLinux - Password" --passwordbox "Enter User Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3) # 设置密码
        UserPassword_retype=$(whiptail --title "ArchLinux - Password" --passwordbox "Again Enter User Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3) # 设置密码
        if [ "$UserPassword" == "$UserPassword_retype" ]; then
            useradd -m -g users -G wheel -s /bin/bash "${UserName}"  # 新建用户
            echo "${UserName}:${UserPassword}" | chpasswd &> /dev/null # 设置密码 
            whiptail --title "Configure User Password." --msgbox "The ${UserName} password configuration is complete. [OK]" 10 60   # 提示配置root密码成功
            PASSWORD_TYPED="true"
        else
            whiptail --title "Configure User Password." --msgbox "${UserName} password don't match. Please, type again. [X]" 10 60    # 输入两次错误，返回信息
        fi
    done
    UserID=$(id "${UserName}" | cut -d"=" -f2 | cut -d"(" -f1)
    Write_Data "Users" "${UserName}"
    Write_Data "UsersID" "${UserID}"
    Write_Data "User_Password" "${UserPassword}"
}
function Root_password_Config(){
    ROOT_PASSWORD_TYPED="false"
    while [ "$ROOT_PASSWORD_TYPED" != "true" ]; do
        RootPassword=$(whiptail --title "ArchLinux - Root Password" --passwordbox "Enter Root Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)  # 输入第一次root密码
        RootPassword_retype=$(whiptail --title "ArchLinux - Root Password" --passwordbox "Again Enter Root Password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)  # 输入第二次root密码
        if [ "$RootPassword" == "$RootPassword_retype" ]; then
            echo "root:${RootPassword_retype}" | chpasswd &> /dev/null   # 输入两次正确，将在这里设置Root密码
            whiptail --title "Configure Root Password." --msgbox "Root Password setting complete. [OK]" 10 60   # 提示配置root密码成功
            ROOT_PASSWORD_TYPED="true"
        else
            whiptail --title "Configure Root Password." --msgbox "Root password don't match. Please, type again. [X]" 10 60    # 输入两次错误，返回信息
        fi
    done
    Write_Data "Root_Password" "${RootPassword_retype}"
}
function Sudo_Config(){
    if (whiptail --title "Configure Sudoers. Yes/No" --yesno "Auto Configure Sudoers." 10 60); then
        SUDOERS_LIST=$(S_LINE)
        chmod 770 /etc/sudoers  # 设置权限
        sed -i "${SUDOERS_LIST}i %wheel ALL=\(ALL\) NOPASSWD: ALL" /etc/sudoers
        chmod 440 /etc/sudoers  # 设置权限
        whiptail --title "Configure Sudoers." --msgbox "Configure Sudoers succeeded. [Ok]" 10 60   # 设置sudo成功
    else
        whiptail --title "Configure Sudoers." --msgbox "Has been skipped. [X]" 10 60   # 跳过设置sudo
    fi
}
# -------- START -------- #
# Auins_Config={2}  # Configure file
# 该死的颜色
    y='\033[1;33m'  #---黄
    g='\033[1;32m'  #---绿
    h='\033[0m'
    PSY=$(echo -e "${y} ::==>${h}") 

Root_Password=$(Read_Config "Root_Password" "INFO")
UserName=$(Read_Config "Users" "INFO") 
if [ "$Root_Password" = "" ]; then
    UserName=$(whiptail --title "ArchLinux - UserName" --inputbox "Enter UserName:" 10 60  3>&1 1>&2 2>&3)  # 输入用户名
    Useradd_Config
    Sudo_Config
    Root_password_Config
else
    whiptail --title "ArchLinux - User settings." --msgbox "Users: ${UserName}, Setup has been completed. [Ok]" 10 60
    echo -e "${PSY} ${y}The User: ${g}${UserName} ${y}has been set. [Ok]${h}"
fi
