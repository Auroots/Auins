#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Install Fonts -> Auins v4.7.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins   
# set -xe

function include(){
    declare -a argu=("$@")
    # declare -p argu
    export local_Dir config_File info_File 
    export Tools_modules Info_modules  
    export option other_option_1
    config_File="${argu[0]}"
    info_File="${argu[1]}"
    local_Dir="${argu[2]}"
    Tools_modules="${argu[3]}"
    Info_modules="${argu[4]}"
    option="${argu[5]}"
    other_option_1="${argu[6]}"
}
# 小型重复性高的模块调用管理器
function run_tools(){
    bash "$Tools_modules" "$config_File" "$info_File" "$local_Dir" "$1" "$2" "$3" "$4" "$5"
}
# 信息打印,详细参数看auins
function run_print_info(){
    bash "$Info_modules" "$config_File" "$info_File" "$Tools_modules" "$1" "$2" "$3"
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

# 安装JetBrainsFira字体(code)
function InstallJetBrainsFira(){
    if wget -P "$local_Dir" "${CONF_local_source}/JetBrains_Fira_Fonts.zip"; then
        mkdir -p /usr/share/fonts
        unzip -d /usr/share/fonts "${local_Dir}/JetBrains_Fira_Fonts.zip"
        fc-cache
    fi
    # 输出使用方法
    run_print_info JetBrainsFira_font_usage
}
# 根据配置文件安装相应的字体
function Config_file_install_fonts(){
    export Common_status Adobe_status JetBrainsFira_status
    Common_status="false" 
    Adobe_status="false" 
    JetBrainsFira_status="false"
    
    case $CONF_Install_Font_Common in
        [Yy]* )  
                run_tools "run" "Installing [ ${white}Common fonts${green} ]."
                sleep 0.5
                Install_Program "$CONF_PGK_FONTS"
                Common_status="true" ;; 
        [Nn]* )  
                run_tools "skip" "[ Common fonts ]."
    esac   
    case $CONF_Install_Font_Adobe in
        [Yy]* )  
                run_tools "run" "Installing [ ${white}Adobe fonts${green} ]."
                sleep 0.5
                Install_Program "$CONF_PGK_FONTS_ADOBE"
                Adobe_status="true" ;;
        [Nn]* )  
                run_tools "skip" "[ Adobe fonts ]."
    esac
    case $CONF_Install_Font_JetBrains_Fira in
        [Yy]* )  
                run_tools "run" "Installing [ ${white}JetBrains / Fira fonts${green} ]."
                sleep 0.5
                InstallJetBrainsFira
                JetBrainsFira_status="true" ;;
        [Nn]* )  
                run_tools "skip" "[ JetBrains / Fira fonts ]."
    esac 
}
# 根据用户选项安装相应的字体
function User_options_install_fonts(){
    local option=$1
    case ${option} in
        all)
            run_tools "run" "Installing [ All fonts ]."; sleep 1s
            Install_Program "$CONF_PGK_FONTS"
            Install_Program "$CONF_PGK_FONTS_ADOBE"
            InstallJetBrainsFira ;;
        common)
            run_tools "run" "Installing [ Common fonts ]."; sleep 1s
            Install_Program "$CONF_PGK_FONTS" ;;
        adobe)
            run_tools "run" "Installing [ Adobe fonts ]."; sleep 1s
            Install_Program "$CONF_PGK_FONTS_ADOBE" ;;
        code)
            run_tools "run" "Installing [ JetBrains / Fira fonts ]."; sleep 1s 
            InstallJetBrainsFira ;;
        *)
            echo -e "${white}::${yellow} [ Usage ] =>${suffix} ${green}${0##*/} font [all] ${white}or ${green}[commin] ${white}or ${green}[adobe]${white} or ${green}[code]${white}.${suffix}"
            run_tools "err" "Input error or the option does not exist."
    esac 
}
# 脚本运行时，由脚本自动判断，自动安装配置文件中的选项，另外询问是否安装其他
# 'Droid Sans Mono', 'monospace', monospace
function Script_Runing_install_fonts(){
    Config_file_install_fonts

    if [[ $Common_status == "false" ]]; then
        run_tools "tips_w" "Whether to install the [ Common fonts ] [Y/n]?"
        case $(run_tools read) in
            [Yy]* ) 
                Install_Program "$CONF_PGK_FONTS"
        esac
    fi
    if [[ $Adobe_status == "false" ]]; then
        run_tools "tips_w" "Whether to install the [ Adobe fonts ] [Y/n]?"
        case $(run_tools read) in
            [Yy]* ) 
                Install_Program "$CONF_PGK_FONTS_ADOBE"
        esac
    fi
    if [[ $JetBrainsFira_status == "false" ]]; then
        run_tools "tips_w" "Whether to install the [ JetBrainsFira fonts (code) ] [Y/n]?"
        case $(run_tools read) in
            [Yy]* ) 
                InstallJetBrainsFira
        esac
    fi 
}

# 具体的实现 >> >> >> >> >> >> >> >> 
echo &>/dev/null
include "$@"
run_tools "ck_p"
CONF_local_source=$(run_tools file_rw CONF Read local_source)
run_tools "feed" "source: $CONF_local_source" "Please update mirror." 

# 获取配置文件中的软件包名
export CONF_PGK_FONTS CONF_PGK_FONTS_ADOBE CONF_Install_Font_Common CONF_Install_Font_Adobe CONF_Install_Font_JetBrains_Fira
CONF_PGK_FONTS=$(run_tools file_rw  CONF Read "PGK_Fonts")
CONF_PGK_FONTS_ADOBE=$(run_tools file_rw  CONF Read "PGK_Fonts_Adobe")
CONF_Install_Font_Common=$(run_tools file_rw  CONF Read "Install_Font_Common")
CONF_Install_Font_Adobe=$(run_tools file_rw  CONF Read "Install_Font_Adobe")
CONF_Install_Font_JetBrains_Fira=$(run_tools file_rw  CONF Read "Install_Font_JetBrains_Fira")
# @该死的颜色
# red='\033[1;31m'; 
green='\033[1;32m'  
yellow='\033[1;33m'; #blue='\033[1;36m'  
white='\033[1;37m'; suffix='\033[0m'  

case $option in
    # 根据配置文件安装相应的字体
    "Config_file_install_fonts") Config_file_install_fonts ;;
    # 根据用户选项安装相应的字体
    "User_options_install_fonts") User_options_install_fonts "$other_option_1" ;;
    # 脚本运行时，由脚本自动判断，自动安装配置文件中的选项，另外询问是否安装其他
    "Script_Runing_install_fonts") Script_Runing_install_fonts ;;
    *) ;;
esac 

# Font_Manager [Share路径] [Local路径] [使用什么方式运行] [字体下载URL] [User_options_install_fonts所需的用户选择]