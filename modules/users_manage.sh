#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Configure users -> Auins v4.7。1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
# 列出需要包含的配置文件或模块
function include(){
    set +e
    declare -a argu=("$@")
    # declare -p argu
    export config_File info_File
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    Tools_modules="${argu[2]}"
    set -e
}
# 小型重复性高的模块调用管理器
function run_tools(){
    bash "$Tools_modules" "$config_File" "$info_File" "$1" "$2" "$3" "$4" "$5"
}

function Configure_users_password(){ 
    local user_name=$1; PASSWORD_TYPED="false"
    while [ "$PASSWORD_TYPED" != "true" ]; do
        echo; 
        run_tools tips_y "New user: [ $user_name ] password"
        UserPassword=$(run_tools read) # 设置密码

        run_tools tips_y "Retype new password"
        UserPassword_retype=$(run_tools read) # 设置密码

        if [ "$UserPassword" == "$UserPassword_retype" ]; then
            echo "${user_name}:${UserPassword_retype}" | chpasswd &> /dev/null # 设置密码 
            # 提示密码是否设置成功
            run_tools feed "The [ ${white}${user_name} ${green}] password set successfully." "The [ ${white}${user_name} ${red}] password set failed." 
            PASSWORD_TYPED="true"
            break;
        else
            run_tools err "[ ${white}${user_name} ${red}] password don't match. Please, type again.";     # 输入两次错误，返回信息
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
        run_tools feed "Configure sudo succeeded." "Failed to configure sudo."
        chmod 440 /etc/sudoers 
    }
    nopasswd(){
        echo; 
        run_tools tips_y "Whether to enable Nopasswd [Y/n]?"
        _Nopasswd=$(run_tools read)
        case $_Nopasswd in 
            [Yy]* )
                chmod 770 /etc/sudoers
                sed -i "${WHELL_LINE}"d /etc/sudoers  
                sed -i "${NOPASSWD_LINE}i %wheel ALL=\(ALL:ALL\) NOPASSWD: ALL" /etc/sudoers
                run_tools feed "Configure sudo Nopasswd succeeded." "Failed to configure sudo Nopasswd."
                chmod 440 /etc/sudoers
            ;;
            *)
                run_tools skip "[ sudo Nopasswd ] Has been skipped."
        esac
    }
    case "$1" in
        "default"  ) default ;;
        "nopasswd" ) nopasswd
    esac
}

# Start Script | 从这里开始
# >> >> >> >> >> >> >> >> >> >> >> >>

include "$@"
run_tools ck_p
# 该死的颜色
red='\033[1;31m'; green='\033[1;32m' 
yellow='\033[1;33m';  
white='\033[1;37m'; suffix='\033[0m' 

# 从配置文件中获取信息
CONF_Auto_Config_Users=$(run_tools file_rw CONF Read "Auto_Config_Users")
CONF_Sudo_Nopasswd=$(run_tools file_rw CONF Read "Sudo_Nopasswd")
CONF_User_Name=$(run_tools file_rw CONF Read "User_Name")
CONF_User_Password=$(run_tools file_rw CONF Read "User_Password")
CONF_Root_Password=$(run_tools file_rw CONF Read "Root_Password")
# sudo相关
NOPASSWD_LINE=$(awk '/NOPASSWD/ {print NR}' /etc/sudoers)
# 从信息表文件中获取信息
INFO_Users=$(run_tools file_rw INFO Read "Users")
echo &>/dev/null
case "$CONF_Auto_Config_Users" in 
    [Yy]*)
        if [ "$INFO_Users" = "" ]; then
            # 新建用户
            run_tools run "Configuring user [${white} $CONF_User_Name ${suffix}${green}].${suffix}"
            useradd -m -g users -G wheel -s /bin/bash "${CONF_User_Name}"  # 新建用户
            run_tools feed "User [${white} $CONF_User_Name ${green}], created successfully." "User [${white} $CONF_User_Name ${red}], creation failed."
            # 设置用户密码
            run_tools run "Configuring user [${white} $CONF_User_Name ${suffix}${green}] password.${suffix}" && sleep 1;
            echo "${CONF_User_Name}:${CONF_User_Password}" | chpasswd &> /dev/null # 设置密码 
            # 写入用户信息
            UsersID=$(id -u "$CONF_User_Name" 2> /dev/null)
            run_tools file_rw INFO Write Users "$CONF_User_Name"
            run_tools file_rw INFO Write UsersID "$UsersID"
            # 配置sudo
            run_tools run "Configuring sudo permission." && sleep 1;
            Configure_sudo default
            # 配置sudo Nopasswd
            case $CONF_Sudo_Nopasswd in
                [Yy]*)
                    run_tools warn "Enable Sudo [${white} Nopasswd ${suffix}${yellow}]." && sleep 1;
                    Configure_sudo nopasswd
                ;;
                *)  
                    run_tools skip "Not Sudo Nopasswd." && sleep 1;
            esac
            
            # 配置Root用户 
            run_tools run "Configuring user [${white} root ${suffix}${green}] password.${suffix}" && sleep 1;
            echo "root:${CONF_Root_Password}" | chpasswd &> /dev/null

        else
            run_tools feed "The User: [ ${white}${UserName}${green} ] has been set." "Setting failed."
        fi
    ;;
    [Nn]*)
        if [ "$INFO_Users" = "" ]; then
            echo; 
            run_tools tips_w "Enter new user name"
            UserName=$(run_tools read)  # 输入用户名
            useradd -m -g users -G wheel -s /bin/bash "${UserName}"  # 新建用户 #Configure_Root_Password
            run_tools feed "User [${white} $UserName ${green}], created successfully." "User [${white} $UserName ${red}], creation failed."

            Configure_users_password "${UserName}"

            UsersID=$(id -u "$UserName" 2> /dev/null)
            run_tools file_rw INFO Write Users "$UserName"
            run_tools file_rw INFO Write UsersID "$UsersID"

            Configure_sudo default
            Configure_sudo nopasswd
            Configure_users_password "root"
        else
            run_tools feed "The User: [ ${white}${UserName}${green} ] has been set." "Setting failed"
        fi
esac    