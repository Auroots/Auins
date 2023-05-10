#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description： Configure users -> Auins v4.6 r8
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
# 该死的颜色
# 红 绿 黄 蓝 白 后缀
red='\033[1;31m'; green='\033[1;32m' 
yellow='\033[1;33m'; 
# blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m' 

# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white(){ printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# Tips output colour: yellow
function tips_yellow(){ printf "\033[1;37m:: $(tput bold; tput setaf 7)\033[1;33m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; sleep 1; } 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run() { echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip() { echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }
  # feedback successfully info
function feed_status(){ 
    if [ $? = 0 ]; then 
        echo -e "\033[1;37m:: $(tput bold; tput setaf 2)=> \033[1;32m${1}\033[0m$(tput sgr0)"; 
    else 
        err "$2"
    fi
}
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

function Configure_users_password(){ 
    local user_name=$1; PASSWORD_TYPED="false"
    while [ "$PASSWORD_TYPED" != "true" ]; do
        echo; 
        tips_yellow "New user: [ $user_name ] password"
        UserPassword=$(Read_user_input) # 设置密码

        tips_yellow "Retype new password"
        UserPassword_retype=$(Read_user_input) # 设置密码

        if [ "$UserPassword" == "$UserPassword_retype" ]; then
            echo "${user_name}:${UserPassword_retype}" | chpasswd &> /dev/null # 设置密码 
            # 提示密码是否设置成功
            feed_status "The [ ${white}${user_name} ${green}] password set successfully." "The [ ${white}${user_name} ${red}] password set failed." 
            PASSWORD_TYPED="true"
            break;
        else
            err "[ ${white}${user_name} ${red}] password don't match. Please, type again.";     # 输入两次错误，返回信息
        fi
    done
}

function Configure_sudo(){
    default(){
        cp /etc/sudoers /etc/sudoers.back
        chmod 770 /etc/sudoers 
        # 获取sudo关于新用户权限的行
        WHELL_LINE=$(awk '/%wheel ALL=\(ALL:ALL\) ALL/ {print NR}' /etc/sudoers)
        sed -i "${WHELL_LINE}i %wheel ALL=\(ALL:ALL\) ALL" /etc/sudoers
        feed_status "Configure sudo succeeded." "Failed to configure sudo."
        chmod 440 /etc/sudoers 
    }
    nopasswd(){
        echo; 
        tips_yellow "Whether to enable Nopasswd [Y/n]?"
        _Nopasswd=$(Read_user_input)
        case $_Nopasswd in 
            [Yy]* )
                chmod 770 /etc/sudoers
                sed -i "${WHELL_LINE}"d /etc/sudoers  
                sed -i "${NOPASSWD_LINE}i %wheel ALL=\(ALL:ALL\) NOPASSWD: ALL" /etc/sudoers
                feed_status "Configure sudo Nopasswd succeeded." "Failed to configure sudo Nopasswd."
                chmod 440 /etc/sudoers
            ;;
            *)
                skip "[ sudo Nopasswd ] Has been skipped."
        esac
    }
    case "$1" in
        "default"  ) default ;;
        "nopasswd" ) nopasswd
    esac
}

# Start Script | 从这里开始
# >> >> >> >> >> >> >> >> >> >> >> >> 
Auins_Profile="$1"
Auins_Infofile="$2"

NOPASSWD_LINE=$(awk '/NOPASSWD/ {print NR}' /etc/sudoers)
# 从配置文件中获取信息
CONF_Auto_Config_Users=$(Config_File_Manage CONF Read "Auto_Config_Users")
CONF_Sudo_Nopasswd=$(Config_File_Manage CONF Read "Sudo_Nopasswd")
CONF_User_Name=$(Config_File_Manage CONF Read "User_Name")
CONF_User_Password=$(Config_File_Manage CONF Read "User_Password")
CONF_Root_Password=$(Config_File_Manage CONF Read "Root_Password")
# 从信息表文件中获取信息
INFO_Users=$(Config_File_Manage INFO Read "Users")
echo &>/dev/null
case "$CONF_Auto_Config_Users" in 
    [Yy]*)
        if [ "$INFO_Users" = "" ]; then
            # 新建用户
            run "Configuring user [${white} $CONF_User_Name ${suffix}${green}].${suffix}"
            useradd -m -g users -G wheel -s /bin/bash "${CONF_User_Name}"  # 新建用户
            feed_status "User [${white} $CONF_User_Name ${green}], created successfully." "User [${white} $CONF_User_Name ${red}], creation failed."
            # 设置用户密码
            run "Configuring user [${white} $CONF_User_Name ${suffix}${green}] password.${suffix}" && sleep 1;
            echo "${CONF_User_Name}:${CONF_User_Password}" | chpasswd &> /dev/null # 设置密码 
            # 写入用户信息
            UsersID=$(id -u "$CONF_User_Name" 2> /dev/null)
            Config_File_Manage INFO Write Users "$CONF_User_Name"
            Config_File_Manage INFO Write UsersID "$UsersID"
            # 配置sudo
            run "Configuring sudo permission." && sleep 1;
            Configure_sudo default
            # 配置sudo Nopasswd
            case $CONF_Sudo_Nopasswd in
                [Yy]*)
                    warn "Enable Sudo [${white} Nopasswd ${suffix}${yellow}]." && sleep 1;
                    Configure_sudo nopasswd
                ;;
                *)   skip "Not Sudo Nopasswd." && sleep 1;
            esac
            
            # 配置Root用户 
            run "Configuring user [${white} root ${suffix}${green}] password.${suffix}" && sleep 1;
            echo "root:${CONF_Root_Password}" | chpasswd &> /dev/null

        else
            feed_status "The User: [ ${white}${UserName}${green} ] has been set." "Setting failed."
        fi
    ;;
    [Nn]*)
        if [ "$INFO_Users" = "" ]; then
            echo; 
            tips_white "Enter new user name"
            UserName=$(Read_user_input)  # 输入用户名
            useradd -m -g users -G wheel -s /bin/bash "${UserName}"  # 新建用户 #Configure_Root_Password
            feed_status "User [${white} $UserName ${green}], created successfully." "User [${white} $UserName ${red}], creation failed."

            Configure_users_password "${UserName}"

            UsersID=$(id -u "$UserName" 2> /dev/null)
            Config_File_Manage INFO Write Users "$UserName"
            Config_File_Manage INFO Write UsersID "$UsersID"

            Configure_sudo default
            Configure_sudo nopasswd
            Configure_users_password "root"
        else
            feed_status "The User: [ ${white}${UserName}${green} ] has been set." "Setting failed"
        fi
esac    