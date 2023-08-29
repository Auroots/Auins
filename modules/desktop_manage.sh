#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Auto Install Desktop -> Auins v4.7.6
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x
function include(){
    set +e
    declare -a argu=("$@")
    # declare -p argu
    export local_Dir config_File info_File Info_modules Fonts_modules 
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    local_Dir="${argu[2]}"
    Tools_modules="${argu[3]}"
    Info_modules="${argu[4]}"
    Fonts_modules="${argu[5]}"
    set -e
}
# 小型重复性高的模块调用管理器
function run_tools(){
    bash "$Tools_modules" "$config_File" "$info_File" "$local_Dir" "$1" "$2" "$3" "$4" "$5"
}
# 信息打印,详细参数看auins
function run_print_info(){
    bash "$Info_modules" "$config_File" "$info_File" "$Tools_modules" "$1" "$2" "$3"
}
# 字体安装,详细参数看auins
function run_configure_fonts(){
    bash "$Fonts_modules" "$config_File" "$info_File" "$local_Dir" \
         "$Tools_modules" "$Info_modules" "$1" "$2"
}
# @install Programs 安装包
function Install_Program() {
    set +e
    IFS=' '; PACKAGES=("$@");
    for VARIABLE in {1..3}
    do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        if ! bash -c "$COMMAND" ; then break; else sleep 1.5; break; fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}

# Desktop_Tuple [0]:桌面名称 [1]:桌面管理器 [2]:xinit启动命令 [3]:桌面安装包
export Desktop_Tuple
function Desktop_Env_ID {
    case ${1} in
        1)  
            Desktop_Tuple=("plasma" "sddm" "startkde" "PGK_Plasma");;
        2)  
            Desktop_Tuple=("gnome" "gdm" "gnome-session" "PGK_Gnome");;
        3)  
            Desktop_Tuple=("deepin" "lightdm" "startdde" "PGK_Deepin");;
        4)  
            Desktop_Tuple=("xfce4" "lightdm" "startxfce4" "PGK_Xfce4");;
        5)  
            Desktop_Tuple=("i3wm" "sddm" "i3" "PGK_I3wm") ;;
        6)  
            Desktop_Tuple=("lxde" "lxdm" "startlxde" "PGK_Lxde") ;;
        7)  
            Desktop_Tuple=("cinnamon" "lightdm" "cinnamon-session" "PGK_Cinnamon");;
        8)  
            Desktop_Tuple=("mate" "lightdm" "mate" "PGK_Mate") ;;
        9)  
            Desktop_Tuple=( "openbox" "lxdm" "openbox-session" "PGK_Openbox") ;;
        10)  
            Desktop_Tuple=("Plasma & Wayland" "sddm" "" "PGK_Wayland_Plasma") ;;
        11)  
            Desktop_Tuple=("Sway & Wayland" "sddm" "" "PGK_Wayland_Sway") ;;
        *) 
            run_tools process stop "$0" "Selection error.";;
    esac
}

# @选择桌面环境
function Set_Desktop_Env(){
    local ID
    # 使用Profile中的设置
    if "$CONF_Desktop_Environment" &> /dev/null ; then
        # 查询Profile中的Desktop设置
        declare -A PROFILE_DESKTOP_ID
        PROFILE_DESKTOP_ID=([plasma]=1 [gnome]=2 [deepin]=3 [xfce4]=4 [i3wm]=5 [lxde]=6 [cinnamon]=7 [mate]=8)
        DESKTOP_ID="${PROFILE_DESKTOP_ID[$CONF_Desktop_Environment]}"
        # 查询Profile中的DM设置, 并覆盖默认DM设置
        Desktop_Env_ID "$DESKTOP_ID"
        Desktop_Tuple[1]="$CONF_Desktop_Display_Manager"
    else # 使用用户输入的设置
        run_print_info desktop_env_list; 
        printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n" \
        "$INFO_UserName" "$INFO_UsersID"

        run_tools "tips_w" "Please select desktop"
        DESKTOP_ID="0"; ID=$(run_tools read)
        if [ "$ID" ]; then 
            Desktop_Env_ID "$ID"
        else
            run_tools process stop "$0" "Selection error."
        fi 
   fi
}

# @桌面环境安装 $1(桌面名称) $2(xinitrc配置 "exec desktop") $3(包列表)
function Install_Desktop_Env(){
    local Desktop_Name Desktop_Xinit Desktop_Program CONF_PGK_Xorg CONF_PGK_Gui_Package;

    Desktop_Name="${Desktop_Tuple[0]}"
    Default_DM="${Desktop_Tuple[1]}"
    Desktop_Xinit="${Desktop_Tuple[2]}"
    Desktop_Program=$(run_tools file_rw CONF Read "${Desktop_Tuple[3]}")
    CONF_PGK_Xorg=$(run_tools file_rw CONF Read "PGK_Xorg")
    CONF_PGK_Gui_Package=$(run_tools file_rw CONF Read "PGK_Gui_Package")
    
    run_tools run "Configuring desktop environment [${white} $Desktop_Name ${green}]."; sleep 1;
    Install_Program "$CONF_PGK_Xorg"
    Install_Program "$Desktop_Program"
    Install_Program "$CONF_PGK_Gui_Package"
    Desktop_Manager "$Default_DM"
    Desktop_Xorg_Config "$Desktop_Name" "$Desktop_Xinit"
}

# @桌面管理器选择列表，选择后，自动安装及配置服务；
function Desktop_Manager(){
    run_print_info desktop_manager_list
    run_tools "tips_w" "Please select Desktop Manager"
    case $(run_tools read) in
        1) 
            DmS="sddm" ;;
        2) 
            DmS="gdm" ;;
        3) 
            DmS="lightdm" ;;
        4) 
            DmS="lxdm" ;;
        5) 
            DmS="Skip" ;;
        *) 
            DmS="$1" ;;
    esac
    run_tools file_rw INFO Write Desktop_Display_Manager "$DmS"
    run_tools run "Configuring desktop display manager [${white} $DmS ${green}]."; sleep 1;
    echo "$DmS" > "${local_Dir}/Desktop_Manager"
    case ${DmS} in
        sddm)
            Install_Program "sddm sddm-kcm" && systemctl enable sddm ;;
        gdm)
            Install_Program "gdm" && systemctl enable gdm ;;
        lightdm)
            Install_Program "lightdm lightdm-gtk-greeter" && systemctl enable lightdm ;;
        lxdm)
            Install_Program "lxdm" && systemctl enable lxdm ;;
    esac
    if [ "$DmS" = "Skip" ] ; then
        run_tools "skip" "Skip desktop manager installation."
    else
        run_tools feed "Desktop manager installed successfully -=> [${white} $DmS ${green}]."
    fi
    sleep 2;
}

# @configure desktop environment
function Desktop_Xorg_Config(){
    if [ -e /home/"$INFO_UserName"/.xinitrc ];then
        run_tools warn "Repeated execution !";sleep 1; 
    else
        # xinitrc_file="/etc/X11/xinit/xinitrc"
        # startLine=$(sed -n '/twm &/=' $xinitrc_file) 
        # lineAfter=4
        # endLine=$(("$startLine" + "$lineAfter"))
        # sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec ${2}" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$INFO_UserName"/.xinitrc 
        run_tools feed "[${white} ${Desktop_Name} ${green}] Desktop environment configuration completed." "xinitrc configuration failed." 
    fi
}

# @安装桌面具体的实现
function Installation_Desktop(){
    CONF_Desktop_Display_Manager=$(run_tools file_rw CONF Read "Desktop_Display_Manager")
    CONF_Desktop_Environment=$(run_tools file_rw CONF Read "Desktop_Environment")

    INFO_UsersID=$(id -u "$INFO_UserName" 2> /dev/null)
    if [ -n "$INFO_UserName" ]; then 
    #  设置桌面环境
        Set_Desktop_Env; 
    #  安装桌面环境
        Install_Desktop_Env;
    #  安装字体
        run_configure_fonts Script_Runing_install_fonts 
    else
        run_tools err "User has no settings."
        sleep 2
        run_tools process restart "$0"
    fi
}
function Set_Color_Variable(){
    # @该死的颜色
    # red='\033[1;31m'; 
    green='\033[1;32m'  
    # yellow='\033[1;33m'; 
    blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'   
    # 提示 蓝 红 绿 黄
    outG="${white}::${green} =>${suffix}";
}

# 具体的实现 >> >> >> >> >> >> >> >> 
echo &>/dev/null
include "$@"
run_tools ck_p
Set_Color_Variable
INFO_UserName=$(run_tools file_rw INFO Read "Users")
# 附赠的壁纸
if [[ -n "${INFO_UserName}" ]]; then
    wget -P "/home/$INFO_UserName" "$SOURCE_LOCAL/gift_auins_0.png"
    wget -P "/home/$INFO_UserName" "$SOURCE_LOCAL/gift_auins_1.jpg"
fi
Installation_Desktop