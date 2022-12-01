#!/usr/bin/env bash
# Author: Auroot
# QQ： 2763833502
# Description： Auto Install Desktop -> auin V4.5.3
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

echo &>/dev/null

# @ 脚本的依赖下载源
# auroot  |  gitee  |  github  |  test
# SCRIPTS_SOURCE="$1"
# Share_Dir="$2" 
Local_Dir="$3"
Auins_Config="$Local_Dir/profile.conf"  
Auins_record="$Local_Dir/auins.info" 

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
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null \
                        ||  echo -e "\n${out_ERROR} ${white}You don't have permission.${suffix}"
                fi
    esac 
}

# @下载所需的脚本模块
# function Update_Share(){     
#     # 根据配置文件选择源, 将其作为脚本的下载源 Module URL: Default settings
#     case ${SCRIPTS_SOURCE} in
#     test)
#         source="http://test.auroot.cn" 
#     esac
#     # Source_Share="${source}/share"
#     Source_Local="${source}/local"
    
#     if [ ! -e "$Mirrorlist_Script" ]; then curl -fsSL "$Source_Share/Mirrorlist_Manage.sh" > "$Mirrorlist_Script"  && chmod +x "$Mirrorlist_Script"; fi
# }

# @该死的颜色
function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     
    #-----------------------------#
    # 交互: 蓝  红 \ 绿 黄
    # inB=$(echo -e "${blue}-=>${suffix} "); # inR=$(echo -e "${red}-=>${suffix} ")
    #-----------------------------
    # 提示 蓝 红 绿 黄
    outG="${white}::${green} =>${suffix}"; #outY="${white}::${yellow} =>${suffix}"

    out_SKIP="${white}::${yellow} [Skip] =>${suffix}"
    out_WARNING="${white}::${yellow} [Warn] =>${suffix}"
    out_EXEC="${white}::${blue} [Exec] =>${suffix}"
    out_WELL="${white}::${green} [Well] =>${suffix}"
    out_ERROR="${white}::${red} [Error] =>${suffix}"
}

# @选择桌面环境  (OK)
function Set_Desktop_Env(){
    DESKTOP_ID="$1"  
    printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n" "${CheckingUsers:-$UserName_INFO}" "${CheckingID:-$UsersID_INFO}"
    case ${DESKTOP_ID} in
        plasma  ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Plasma")" plasma startkde;;
        gnome   ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Gnome")"  gnome  gnome-session;;
        deepin  ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Deepin")" deepin startdde;;
        xfce4   ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Xfce4")"  xfce4  startxfce4;;
        i3wm    ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_I3wm")"   i3wm   i3;;
        lxde    ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Lxde")"   lxde   startlxde ;;
        cinnamon) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Cinnamon")" cinnamon cinnamon-session;;
        mate    ) Install_DesktopEnv "$(Config_File_Manage CONF Read "PGK_Mate")"   mate   mate;;
               *) echo -e "${out_ERROR} ${red} Selection error.${suffix}"; exit 5
        esac 
}
# @桌面环境安装 $1(桌面名称) $2(xinitrc配置 "exec desktop") $3(包列表)
function Install_DesktopEnv(){
    local Desktop_Name Desktop_Xinit Desktop_Program;
    Desktop_Program=$1
    Desktop_Name=$2
    Desktop_Xinit=$3
    Config_File_Manage INFO Write Desktop_Environment "$Desktop_Name"
    
    echo -e "${out_EXEC} ${green}Configuring desktop environment.${suffix}"; sleep 1;
    Install_Program "$(Config_File_Manage INFO Read "PGK_Xorg")"
    Install_Program "$Desktop_Program"
    Install_Program "$(Config_File_Manage INFO Read "PGK_Gui_Package")"
    Desktop_Manager "$Desktop_Display_Manager"
    Desktop_Xorg_Config "$Desktop_Name" "$Desktop_Xinit"
}
# @桌面管理器选择列表，选择后，自动安装及配置服务;   (OK)
function Desktop_Manager(){
    echo "$1" > "$Local_Dir/Desktop_Manager"
    case $1 in
        sddm) Install_Program "sddm sddm-kcm" && systemctl enable sddm ;;
        gdm ) Install_Program "gdm" && systemctl enable gdm ;;
        lxdm) Install_Program "lxdm" && systemctl enable lxdm ;;
        lightdm) Install_Program "lightdm lightdm-gtk-greeter" && systemctl enable lightdm ;;
    esac
    echo -e "\n${out_WELL} ${green} Desktop manager installed successfully -=> ${white}[ $1 ] ${suffix}\n"
    Config_File_Manage INFO Write Desktop_Display_Manager "$1"
    sleep 5;
}
# @configure desktop environment
function Desktop_Xorg_Config(){
    Desktop_Name=$1; Desktop_Xinit=$2
    if [ -e /home/"$CheckingUsers"/.xinitrc ];then
        echo -e "${out_WARNING} ${yellow}Repeated execution !${suffix}";sleep 2; 
    else
        xinitrc_file="/etc/X11/xinit/xinitrc"
        startLine=$(sed -n '/twm &/=' $xinitrc_file) 
        lineAfter=4
        endLine=$(("$startLine" + "$lineAfter"))
        sed -i "$startLine"','"$endLine"'d' "$xinitrc_file"
        echo "exec $Desktop_Xinit" >> /etc/X11/xinit/xinitrc 
        cp -rf /etc/X11/xinit/xinitrc  /home/"$CheckingUsers"/.xinitrc 
        echo -e "${out_WELL} ${white}$Desktop_Name ${green}Desktop environment configuration completed.${suffix}"  
    fi
}
# @install fonts 安装所有字体
function Install_Font(){
    local PGK_FONTS, PGK_FONTS_ADOBE, CONF_Font, CONF_Adobe_Font, CONF_JF_Font;
    PGK_FONTS=$(Config_File_Manage CONF Read "PGK_Fonts")
    PGK_FONTS_ADOBE=$(Config_File_Manage CONF Read "PGK_Fonts_Adobe")
    CONF_Font=$(Config_File_Manage CONF Read "Install_Font_Common")
    CONF_Adobe_Font=$(Config_File_Manage CONF Read "Install_Font_Adobe")
    CONF_JF_Font=$(Config_File_Manage CONF Read "Install_Font_JetBrains_Fira")
    
    case ${CONF_Font} in
        [Yy]*) Install_Program "$PGK_FONTS" ;;
            *) echo -e "${out_SKIP} ${white}[Common fonts].${suffix}\n"
    esac
    case ${CONF_Adobe_Font} in
        [Yy]*) Install_Program "$PGK_FONTS_ADOBE" ;;
            *) echo -e "${out_SKIP} ${white}[Adobe fonts].${suffix}\n"
    esac
    case ${CONF_JF_Font} in
        [Yy]*) 
            wget -P "$Local_Dir" http://auins.auroot.cn/local/JetBrains_Fira_Fonts.zip
            mkdir -p /usr/share/fonts
            unzip -d /usr/share/fonts "$Local_Dir/JetBrains_Fira_Fonts.zip"
            fc-cache;;
        *) echo -e "${out_SKIP} ${white}[JetBrains / Fira fonts].${suffix}\n"
    esac
}
# @配置本地化 时区 主机名 语音等  
function Configure_Language(){
    echo -e "${out_EXEC} ${white}Localization language settings. ${suffix}"
        sed -i 's/#.*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    echo -e "${out_EXEC} ${white}Write 'en_US.UTF-8 UTF-8' To /etc/locale.gen. ${suffix}"  
        sed -i 's/#.*zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen 
    echo -e "${out_EXEC} ${white}Write 'zh_CN.UTF-8 UTF-8' To /etc/locale.gen. ${suffix}" 
        locale-gen
    echo -e "${out_EXEC} ${white}Configure local language defaults 'en_US.UTF-8'. ${suffix}"  
        echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 系统语言 "英文" 默认为英文   
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

# @安装桌面
function Installation_Desktop(){
    Desktop_Env=$1  
    UserName_INFO=$(Config_File_Manage INFO Read "Users")
    UsersID_INFO=$(id -u "$UserName_INFO" 2> /dev/null)
    if [ -n "$UserName_INFO" ]; then 
        Set_Desktop_Env "$Desktop_Env"
    else
        echo -e "${out_ERROR} ${white}User has no settings.${suffix}"; sleep 3;
        exit 5;
    fi
}

# 具体的实现
# >> >> >> >> >> >> >> >> >> >> >> >> 
if ! groups "$(whoami)" | grep -i "root" &>/dev/null ; then 
    echo -e "\n${out_ERROR} ${red}There is currently no execute permission.${suffix}" 
    echo -e "${out_ERROR} ${red}Please use ${green}\"command: sudo\"${red} or ${green}\"user: root\"${red} to execute.${suffix}\n"
fi

exprot Desktop_Environment Config_File_Manage
Desktop_Environment=$(Config_File_Manage CONF Read Desktop_Environment)
Desktop_Display_Manager=$(Config_File_Manage CONF Read Desktop_Display_Manager)

Set_Color_Variable  
Update_Share
Installation_Desktop "$Desktop_Environment"