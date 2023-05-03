#!/usr/bin/env bash
# Author: Auroot
# QQ： 2763833502
# Description： Auto Install Desktop -> auin V4.5
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

# bash "${Share_Dir}/Desktop_Manage.sh" "share" "local";

echo &>/dev/null
Share_Dir=${1}
Local_Dir=${2}
Auins_Config="${Local_Dir}/profile.conf"  
Auins_Infofile="${Local_Dir}/auins.info"


Desktop_Display_Manager=$(Config_File_Manage CONF Read "Desktop_Display_Manager")
Desktop_Environment=$(Config_File_Manage CONF Read "Desktop_Environment")

# @该死的颜色
red='\033[1;31m'; green='\033[1;32m'  
yellow='\033[1;33m'; blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m'   
# 交互: 蓝  红 \ 绿 黄
inB=$(echo -e "${blue}-=>${suffix} ");
# 提示 蓝 红 绿 黄
outG="${white}::${green} =>${suffix}";
outB="${white}::${blue} =>${suffix}";
out_SKIP="${white}::${yellow} [Skip] =>${suffix}"
out_WARNING="${white}::${yellow} [Warn] =>${suffix}"
out_EXEC="${white}::${blue} [Exec] =>${suffix}"
out_WELL="${white}::${green} [Well] =>${suffix}"
out_ERROR="${white}::${red} [Error] =>${suffix}"

# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
function Config_File_Manage(){ 
    local format=" = "; parameter="$3"; content="$4";
    case "$1" in
        INFO) local Files="$Auins_Infofile" ;;
        CONF) local Files="$Auins_Config" ;;
    esac
    case "$2" in
        Read )   grep -w "$parameter" < "$Files" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';)
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null \
                        ||  echo -e "\n${out_ERROR} ${white}You don't have permission.${suffix}"
                fi
    esac 
}

# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    case ${PM_Enter_1} in
        start)   bash "${Share_Dir}/Process_manage.sh" start "${PM_Enter_2}" ;;
        restart) bash "${Share_Dir}/Process_manage.sh" restart "${PM_Enter_2}" ;;
        stop)    bash "${Share_Dir}/Process_manage.sh" stop "${PM_Enter_2}"
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

function Printf_Info(){
    function DesktopEnvList(){
            echo -e "
    \n\t   ${white}***${suffix} ${blue}Install Desktop${suffix} ${white}***${suffix}    
    ------------------------------------------------
    ${outB} ${green}   KDE plasma.      ${blue}[1]   ${blue}  default: sddm     ${suffix}
    ${outB} ${green}   Gnome.           ${white}[2]  ${white}   default: gdm      ${suffix}
    ${outB} ${green}   Deepin.          ${blue}[3]   ${blue}  default: lightdm  ${suffix}  
    ${outB} ${green}   Xfce4.           ${white}[4]  ${white}   default: lightdm  ${suffix}
    ${outB} ${green}   i3wm.            ${blue}[5]   ${blue}  default: sddm     ${suffix}
    ${outB} ${green}   lxde.            ${blue}[6]   ${blue}  default: lxdm     ${suffix}
    ${outB} ${green}   Cinnamon.        ${white}[7]  ${white}   default: lightdm  ${suffix}
    ${outB} ${green}   Mate.            ${blue}[8]   ${blue}  default: lightdm  ${suffix}
    ${outB} ${green}   Plasma_Wayland.  ${blue}[9]   ${blue}  default: sddm     ${suffix}
    ${outB} ${green}   Openbox.         ${blue}[10]  ${blue}  default: sddm     ${suffix}
    ------------------------------------------------\n"  
        }
        function DesktopManagerList(){
            echo -e "
    ----------------------------
    ${outB} ${green}sddm.            ${white}[1]${suffix}
    ${outB} ${green}gdm.             ${white}[2]${suffix}
    ${outB} ${green}lightdm.         ${white}[3]${suffix}  
    ${outB} ${green}lxdm.            ${white}[4]${suffix} 
    ${outB} ${green}default.         ${white}[*]${suffix}
    ============================"
        }
    case ${1} in
        "DesktopEnvList" ) DesktopEnvList ;; # 桌面环境的选择列表
        "DesktopManagerList") DesktopManagerList ;; # 桌面管理器的选择列表
    esac
}

function Desktop_Env_ID {
    case ${1} in
        1)  export Desktop_Tuple=("plasma" "sddm" "startkde" "PGK_Plasma");;
        2)  export Desktop_Tuple=("gnome" "gdm" "gnome-session" "PGK_Gnome");;
        3)  export Desktop_Tuple=("deepin" "lightdm" "startdde" "PGK_Deepin");;
        4)  export Desktop_Tuple=("xfce4" "lightdm" "startxfce4" "PGK_Xfce4");;
        5)  export Desktop_Tuple=("i3wm" "sddm" "i3" "PGK_I3wm") ;;
        6)  export Desktop_Tuple=("lxde" "lxdm" "startlxde" "PGK_Lxde") ;;
        7)  export Desktop_Tuple=("cinnamon" "lightdm" "cinnamon-session" "PGK_Cinnamon");;
        8)  export Desktop_Tuple=("mate" "lightdm" "mate" "PGK_Mate") ;;
        # 9)  Desktop_Tuple=("Plasma & Wayland" "sddm" "" "P_plasma_Wayland") ;;
        # 10)  bash "${Share_Dir}/Install_openbox.sh" ;;
        *)
            echo -e "${out_ERROR} ${red} Selection error.${suffix}"    
            Process_Management stop "$0" ;;
    esac
}

# @选择桌面环境
function Set_Desktop_Env(){
    # 使用Profile中的设置
    if "$Desktop_Environment" &> /dev/null ; then
        # 查询Profile中的Desktop设置
        declare -A PROFILE_DESKTOP_ID
        PROFILE_DESKTOP_ID=([plasma]=1 [gnome]=2 [deepin]=3 [xfce4]=4 [i3wm]=5 [lxde]=6 [cinnamon]=7 [mate]=8)
        DESKTOP_ID="${PROFILE_DESKTOP_ID[$Desktop_Environment]}"
        # 查询Profile中的DM设置, 并覆盖默认DM设置
        Desktop_Env_ID "$DESKTOP_ID"
        Desktop_Tuple[1]="$Desktop_Display_Manager"
    else # 使用用户输入的设置
        Printf_Info DesktopEnvList; local ID
        printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n" "${CheckingUsers:-$INFO_UserName}" "${CheckingID:-$INFO_UsersID}"
        printf "${outG} ${yellow} Please select desktop:${suffix} %s" "$inB"
        DESKTOP_ID="0"; read -r ID
        if [ "$ID" ]; then 
            Desktop_Env_ID "$ID"
        else
            echo -e "${out_ERROR} ${red} Selection error.${suffix}"    
            Process_Management stop "$0"
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
    
    echo -e "\n${out_EXEC} ${green}Configuring desktop environment ${white}[$Desktop_Name].${suffix}"; sleep 1;
    Install_Program "$CONF_PGK_Xorg"
    Install_Program "$Desktop_Program"
    Install_Program "$CONF_PGK_Gui_Package"
    Desktop_Manager "$Default_DM"
    Desktop_Xorg_Config "$Desktop_Name" "$Desktop_Xinit"
}

# @桌面管理器选择列表，选择后，自动安装及配置服务；
function Desktop_Manager(){
    Printf_Info DesktopManagerList
    printf "${outG} ${yellow} Please select Desktop Manager: ${suffix} %s" "$inB"
    read -r DM_ID
    case ${DM_ID} in
        1) DmS="sddm" ;;
        2) DmS="gdm"  ;;
        3) DmS="lightdm" ;;
        4) DmS="lxdm" ;;
        *) DmS="$1" ;;
    esac
    Config_File_Manage INFO Write Desktop_Display_Manager "$DmS"
    echo -e "\n${out_EXEC} ${green}Configuring desktop display manager ${white}[$DmS].${suffix}"; sleep 1;
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
    echo -e "\n${out_WELL} ${green} Desktop manager installed successfully -=> ${white}[ $DmS ] ${suffix}\n"
    sleep 3;
}

# @configure desktop environment
function Desktop_Xorg_Config(){
    if [ -e /home/"$CheckingUsers"/.xinitrc ];then
        echo -e "${out_WARNING} ${yellow}Repeated execution !${suffix}";sleep 2; 
    else
        # xinitrc_file="/etc/X11/xinit/xinitrc"
        # startLine=$(sed -n '/twm &/=' $xinitrc_file) 
        # lineAfter=4
        # endLine=$(("$startLine" + "$lineAfter"))
        # sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec ${2}" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$CheckingUsers"/.xinitrc 
        echo -e "${out_WELL} ${white}${1} ${green}Desktop environment configuration completed.${suffix}"  
    fi
}

# @install fcitx 
function Install_Fcitx(){
    Fcitx_Config="
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx"
    CONF_Install_Fcitx=$(Config_File_Manage CONF Read "Install_Fcitx")
    CONF_PKG_Fcitx=$(Config_File_Manage CONF Read "PKG_Fcitx")
    case $CONF_Install_Fcitx in
    [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Fcitx].${suffix}"; sleep 2s
            pacman -Rsc --noconfirm fcitx
            Install_Program "$CONF_PKG_Fcitx" 
            echo "$Fcitx_Config" >> /etc/environment;; 
        *)  printf "${outG} ${yellow}Whether to install [Fcitx]. Install[y] No[*]${suffix} %s" "$inB"
            read -r UserInf_Fcitx
            case ${UserInf_Fcitx} in
                [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Fcitx].${suffix}"; sleep 2s
                        pacman -Rsc --noconfirm fcitx
                        Install_Program "$CONF_PKG_Fcitx" 
                        echo "$Fcitx_Config" >> /etc/environment;;
                    *) echo -e "${out_SKIP} ${white}[Fcitx].${suffix}\n"
            esac
    esac 
}

# @install fonts 安装所有字体
function Install_Font(){
    CONF_PGK_FONTS=$(Config_File_Manage CONF Read "PGK_Fonts")
    CONF_PGK_FONTS_ADOBE=$(Config_File_Manage CONF Read "PGK_Fonts_Adobe")
    
    CONF_Install_Font_Common=$(Config_File_Manage CONF Read "Install_Font_Common")
    CONF_Install_Font_Adobe=$(Config_File_Manage CONF Read "Install_Font_Adobe")
    CONF_Install_Font_JetBrains_Fira=$(Config_File_Manage CONF Read "Install_Font_JetBrains_Fira")
    
    function InstallJetBrainsFira(){
        wget -P "$Local_Dir" http://auins.auroot.cn/local/JetBrains_Fira_Fonts.zip
        mkdir -p /usr/share/fonts
        unzip -d /usr/share/fonts "${Local_Dir}/JetBrains_Fira_Fonts.zip"
        fc-cache
    }
    case $CONF_Install_Font_Common in
        [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Common fonts].${suffix}"; sleep 2s 
                Install_Program "$CONF_PGK_FONTS" ;; 
            *)  echo -e "${out_SKIP} ${white}[Common fonts].${suffix}\n"
    esac   
    case $CONF_Install_Font_Adobe in
        [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [Adobe fonts].${suffix}"; sleep 2s
                Install_Program "$CONF_PGK_FONTS_ADOBE" ;;
            *)  echo -e "${out_SKIP} ${white}[Adobe fonts].${suffix}\n"
    esac
    case $CONF_Install_Font_JetBrains_Fira in
        [Yy]*)  echo -e "\n${out_EXEC} ${green}Installing [JetBrains / Fira fonts].${suffix}"; sleep 2s 
                InstallJetBrainsFira ;;
            *)  echo -e "${out_SKIP} ${white}[JetBrains / Fira fonts].${suffix}\n"
    esac 
}

# @安装桌面具体的实现
function Installation_Desktop(){
    INFO_UserName=$(Config_File_Manage INFO Read "Users")
    INFO_UsersID=$(id -u "$INFO_UserName" 2> /dev/null)
    if [ -n "$INFO_UserName" ]; then 
    #  设置桌面环境
        Set_Desktop_Env; 
    #  安装桌面环境
        Install_Desktop_Env;
    #  安装字体
        Install_Font;    
    #  安装Fcitx输入法
        Install_Fcitx;   
        printf "${outG} ${yellow}Whether to install Common Drivers? [y/N]:${suffix}%s" "$inB"
        read -r CommonDrive
        case ${CommonDrive} in
            [Yy]*) Install_Io_Driver ;;
            [Nn]*) Process_Management stop "$0" ;;
        esac
    else
        echo -e "${out_ERROR} ${white}User has no settings.${suffix}"; sleep 3;
        Process_Management restart "$0"
    fi
}

Installation_Desktop