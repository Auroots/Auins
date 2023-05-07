#!/usr/bin/env bash
# Author: Auroot
# QQ： 2763833502
# Description： Install Fonts -> auin V4.6 r7
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins

# @该死的颜色
# 红 绿 黄 蓝 白 后缀
red='\033[1;31m'; green='\033[1;32m'  
yellow='\033[1;33m'; #blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m'     

# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white() { printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Warning message wrapper
# function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run() { echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip() { echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }

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
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "File: $Files, missing value for [ $content ]."+
                fi
    esac 
}

# check for root privilege
function check_priv()
{
  if [ "$(id -u)" -ne 0 ]; then
    # err "you must be root"
    err "Please use command: ${white}\"sudo\"${red} or user: ${white}\"root\"${red} to execute.${suffix}"
  fi
}

# @Stript Management; 脚本进程管理 [start]开启 [restart]重新开启 [stop]杀死脚本进程
function Process_Management(){
    PM_Enter_1=${1}
    PM_Enter_2=${2}
    PM_Enter_3=${3}
    case ${PM_Enter_1} in
        start)   bash "$Process_Manage" start "${PM_Enter_2}" "${PM_Enter_3}" ;;
        restart) bash "$Process_Manage" restart "${PM_Enter_2}" "${PM_Enter_3}" ;;
        stop)    bash "$Process_Manage" stop "${PM_Enter_2}" "${PM_Enter_3}"
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
        if ! bash -c "$COMMAND" ; then break; else sleep 3; break; fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}

# 安装JetBrainsFira字体(code)
function InstallJetBrainsFira(){
    if wget -P "$Local_Dir" "${Source_Local}/JetBrains_Fira_Fonts.zip"; then
        mkdir -p /usr/share/fonts
        unzip -d /usr/share/fonts "${Local_Dir}/JetBrains_Fira_Fonts.zip"
        fc-cache
    fi
    # 输出使用方法
    bash "$Print_Info_Script" JetBrainsFira_font_usage
}
# 根据配置文件安装相应的字体
function Config_file_install_fonts(){
    Common_status="false" 
    Adobe_status="false" 
    JetBrainsFira_status="false"
    
    CONF_Install_Font_Common=$(Config_File_Manage CONF Read "Install_Font_Common")
    CONF_Install_Font_Adobe=$(Config_File_Manage CONF Read "Install_Font_Adobe")
    CONF_Install_Font_JetBrains_Fira=$(Config_File_Manage CONF Read "Install_Font_JetBrains_Fira")

    CONF_PGK_FONTS=$1
    CONF_PGK_FONTS_ADOBE=$2

    case $CONF_Install_Font_Common in
        [Yy]* )  run "Installing [ ${white}Common fonts${green} ]."; sleep 2s 
                Install_Program "$CONF_PGK_FONTS"; Common_status="true" ;; 
            * )  skip "[ Common fonts ]."
    esac   
    case $CONF_Install_Font_Adobe in
        [Yy]* )  run "Installing [ ${white}Adobe fonts${green} ]."; sleep 2s
                Install_Program "$CONF_PGK_FONTS_ADOBE"; Adobe_status="true" ;;
            * )  skip "[ Adobe fonts ]."
    esac
    case $CONF_Install_Font_JetBrains_Fira in
        [Yy]* )  run "Installing [ ${white}JetBrains / Fira fonts${green} ]."; sleep 2s 
                InstallJetBrainsFira; JetBrainsFira_status="true" ;;
            * )  skip "[ JetBrains / Fira fonts ]."
    esac 
}
# 根据用户选项安装相应的字体
function User_options_install_fonts(){
    local option=$1
    CONF_PGK_FONTS=$2
    CONF_PGK_FONTS_ADOBE=$3
    case ${option} in
        all)
            run "Installing [ All fonts ]."; sleep 1s
            Install_Program "$CONF_PGK_FONTS"
            Install_Program "$CONF_PGK_FONTS_ADOBE"
            InstallJetBrainsFira
            ;;
        common)
            run "Installing [ Common fonts ]."; sleep 1s
            Install_Program "$CONF_PGK_FONTS"
            ;;
        adobe)
            run "Installing [ Adobe fonts ]."; sleep 1s
            Install_Program "$CONF_PGK_FONTS_ADOBE"
            ;;
        code)
            run "Installing [ JetBrains / Fira fonts ]."; sleep 1s 
            InstallJetBrainsFira 
            ;;
        *)
            echo -e "${white}::${yellow} [ Usage ] =>${suffix} ${green}${0##*/} font [all] ${white}or ${green}[commin] ${white}or ${green}[adobe]${white} or ${green}[code]${white}.${suffix}"
            err "Input error or the option does not exist."
        ;;
    esac 
}
# 脚本运行时，由脚本自动判断，自动安装配置文件中的选项，另外询问是否安装其他
# 'Droid Sans Mono', 'monospace', monospace
function Script_Runing_install_fonts(){
    CONF_PGK_FONTS=$1
    CONF_PGK_FONTS_ADOBE=$2

    Config_file_install_fonts "$CONF_PGK_FONTS" "$CONF_PGK_FONTS_ADOBE"
    if [[ $Common_status == "false" ]]; then
        tips_white "Whether to install the [ Common fonts ] [Y/n]?"
        case $(Read_user_input) in
            [Yy]* ) Install_Program "$CONF_PGK_FONTS";;
        esac 
    elif [[ $Adobe_status == "false" ]]; then
        ptips_white "Whether to install the [ Adobe fonts ] [Y/n]?"
        case $(Read_user_input) in
            [Yy]* ) Install_Program "$CONF_PGK_FONTS_ADOBE";;
        esac
    elif [[ $JetBrainsFira_status == "false" ]]; then
        ptips_white "Whether to install the [ JetBrainsFira fonts (code) ] [Y/n]?"
        case $(Read_user_input) in
            [Yy]* ) InstallJetBrainsFira;;
        esac
    fi 
}

# 具体的实现 >> >> >> >> >> >> >> >> 
echo &>/dev/null
check_priv
Share_Dir=$1
Local_Dir=$2
Source_Local=$3
Auins_Profile="${Local_Dir}/profile.conf"  
Auins_Infofile="${Local_Dir}/auins.info"
Print_Info_Script="${Share_Dir}/Print_Info.sh"
Process_Manage="${Share_Dir}/Process_Manage.sh"
# 获取配置文件中的软件包名
# CONF_PGK_FONTS=$(Config_File_Manage CONF Read "PGK_Fonts")
# CONF_PGK_FONTS_ADOBE=$(Config_File_Manage CONF Read "PGK_Fonts_Adobe")
# # 获取配置文件中的用户设置

case ${4} in
    # 根据配置文件安装相应的字体
    "Config_file_install_fonts") Config_file_install_fonts "$CONF_PGK_FONTS" "$CONF_PGK_FONTS_ADOBE" ;;
    # 根据用户选项安装相应的字体
    "User_options_install_fonts") User_options_install_fonts "$5" "$CONF_PGK_FONTS" "$CONF_PGK_FONTS_ADOBE" ;;
    # 脚本运行时，由脚本自动判断，自动安装配置文件中的选项，另外询问是否安装其他
    "Script_Runing_install_fonts") Script_Runing_install_fonts "$CONF_PGK_FONTS" "$CONF_PGK_FONTS_ADOBE" ;;
    *) ;;
esac 

# Font_Manager [Share路径] [Local路径] [使用什么方式运行] [字体下载URL] [User_options_install_fonts所需的用户选择]