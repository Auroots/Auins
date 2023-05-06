#!/usr/bin/env bash
# Author: Auroot
# QQ： 2763833502
# Description： Auto Install Desktop -> auin V4.5
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

# bash "${Share_Dir}/Desktop_Manage.sh" "share" "local";

# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)";} 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run() { echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip() { echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }
# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white() { printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
  # feedback successfully info
function feed_status(){ 
    if [ $? = 0 ]; then 
        echo -e "\033[1;37m:: $(tput bold; tput setaf 2)=> \033[1;32m${1}\033[0m$(tput sgr0)"; 
    else 
        err "$2"
    fi
}
# check for root privilege
function check_priv()
{
  if [ "$(id -u)" -ne 0 ]; then
    err "Please use command: ${white}\"sudo\"${red} or user: ${white}\"root\"${red} to execute.${suffix}"
    exit 99;
  fi
}


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
        Read ) 
                read_info=$(grep -w "$parameter" < "$Files") # 在文件中查找匹配的值
                if [ -n "$read_info" ]; then 
                    echo "$read_info" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' 
                else
                    warn "Read file: $Files, missing value [${white} $parameter  ${yellow}]."
                    sleep 3
                fi
         ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';) # 在文件中查找匹配的值, 并打印行号
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "Write file: $Files, missing value [${white} $parameter  ${yellow}] + [${white} $content ${yellow}]."
                    sleep 3
                fi
    esac 
}

# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    PM_Enter_3=${3}
    case ${PM_Enter_1} in
        start)   bash "$Process_Script" start "${PM_Enter_2}" "${PM_Enter_3}" ;;
        restart) bash "$Process_Script" restart "${PM_Enter_2}" "${PM_Enter_3}" ;;
        stop)    bash "$Process_Script" stop "${PM_Enter_2}" "${PM_Enter_3}"
    esac
}

# @install Programs 安装包
function Install_Program() {
    # arch-chroot ${MNT_DIR} bash -c "$COMMAND"
    set +e
    IFS=' '; PACKAGES=("$@");
    for VARIABLE in {1..3}
    do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        if ! bash -c "$COMMAND" ; then
            break;
        else
            sleep 3; break;
        fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}


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
        # 9)  Desktop_Tuple=("Plasma & Wayland" "sddm" "" "P_plasma_Wayland") ;;
        # 10)  bash "${Share_Dir}/Install_openbox.sh" ;;
        *) 
            Process_Management stop "$0" "Selection error.";;
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
        bash "$Print_INFO" DesktopEnvList; 
        printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n" "${CheckingUsers:-$INFO_UserName}" "${CheckingID:-$INFO_UsersID}"
        tips_white "Please select desktop"
        DESKTOP_ID="0"; ID=$(Read_user_input)
        if [ "$ID" ]; then 
            Desktop_Env_ID "$ID"
        else
            Process_Management stop "$0" "Selection error."
        fi 
   fi
}

# @桌面环境安装 $1(桌面名称) $2(xinitrc配置 "exec desktop") $3(包列表)
function Install_Desktop_Env(){
    local Desktop_Name Desktop_Xinit Desktop_Program CONF_PGK_Xorg CONF_PGK_Gui_Package;

    Desktop_Name="${Desktop_Tuple[0]}"
    Desktop_Xinit="${Desktop_Tuple[1]}"
    Default_DM="${Desktop_Tuple[2]}"
    Desktop_Program=$(Config_File_Manage CONF Read "${Desktop_Tuple[3]}")
    CONF_PGK_Xorg=$(Config_File_Manage CONF Read "PGK_Xorg")
    CONF_PGK_Gui_Package=$(Config_File_Manage CONF Read "PGK_Gui_Package")
    
    run "Configuring desktop environment [${white} $Desktop_Name ${green}]."; sleep 1;
    Install_Program "$CONF_PGK_Xorg"
    Install_Program "$Desktop_Program"
    Install_Program "$CONF_PGK_Gui_Package"
    Desktop_Manager "$Default_DM"
    Desktop_Xorg_Config "$Desktop_Name" "$Desktop_Xinit"
}

# @桌面管理器选择列表，选择后，自动安装及配置服务；
function Desktop_Manager(){
    bash "$Print_INFO" DesktopManagerList
    tips_white "Please select Desktop Manager"
    case $(Read_user_input) in
        1) 
            DmS="sddm" ;;
        2) 
            DmS="gdm" ;;
        3) 
            DmS="lightdm" ;;
        4) 
            DmS="lxdm" ;;
        *) 
            DmS="$1" ;;
    esac
    Config_File_Manage INFO Write Desktop_Display_Manager "$DmS"
    run "Configuring desktop display manager [${white} $DmS ${green}]."; sleep 1;
    echo "$DmS" > "${Local_Dir}/Desktop_Manager"
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
    feed_status "Desktop manager installed successfully -=> [${white} $DmS ${green}]."
    sleep 3;
}

# @configure desktop environment
function Desktop_Xorg_Config(){
    if [ -e /home/"$CheckingUsers"/.xinitrc ];then
        warn "Repeated execution !";sleep 1; 
    else
        # xinitrc_file="/etc/X11/xinit/xinitrc"
        # startLine=$(sed -n '/twm &/=' $xinitrc_file) 
        # lineAfter=4
        # endLine=$(("$startLine" + "$lineAfter"))
        # sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec ${2}" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$CheckingUsers"/.xinitrc 
        feed_status "[${white} ${Desktop_Name} ${green}]Desktop environment configuration completed." "xinitrc configuration failed." 
    fi
}

# @安装桌面具体的实现
function Installation_Desktop(){
    CONF_Desktop_Display_Manager=$(Config_File_Manage CONF Read "Desktop_Display_Manager")
    CONF_Desktop_Environment=$(Config_File_Manage CONF Read "Desktop_Environment")

    INFO_UserName=$(Config_File_Manage INFO Read "Users")
    INFO_UsersID=$(id -u "$INFO_UserName" 2> /dev/null)
    if [ -n "$INFO_UserName" ]; then 
    #  设置桌面环境
        Set_Desktop_Env; 
    #  安装桌面环境
        Install_Desktop_Env;
    #  安装字体
        Fonts_Script;      
        tips_white "Whether to install Common Drivers? [Y/n]?"
        case $(Read_user_input) in
            [Yy]*) Install_Io_Driver ;;
            [Nn]*) Process_Management stop "$0" ;;
        esac
    else
        err "User has no settings."
        sleep 2
        Process_Management restart "$0"
    fi
}
# 具体的实现 >> >> >> >> >> >> >> >> 
echo &>/dev/null
check_priv # 检查权限
Share_Dir=${1}
Local_Dir=${2}
Auins_Profile="${Local_Dir}/profile.conf"  
Auins_Infofile="${Local_Dir}/auins.info"
# 需要调用的模块
Process_Script="${Share_Dir}/Process_Manage.sh"
Print_INFO="${Share_Dir}/Print_INFO.sh"
Fonts_Script="${Share_Dir}/Fonts_Manage.sh"

# @该死的颜色
red='\033[1;31m'; green='\033[1;32m'  
yellow='\033[1;33m'; blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m'   
# 提示 蓝 红 绿 黄
outG="${white}::${green} =>${suffix}";

Installation_Desktop