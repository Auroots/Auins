#!/usr/bin/env bash
# Author/Wechat: Auroot
# Description： Edit Database -> auin V4.2
# Script name: Auins (ArchLinux User Installation Scripts) 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
echo &>/dev/null

# @该死的颜色
function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     
    #-----------------------------#
    # wg='\033[1;42m'  #--白绿
    # ws='\033[1;43m'  #--白褐
    #----------------------------#
    # 交互 蓝
    inB=$(echo -e "${blue}-=>${suffix} ")
    #-----------------------------
    # 提示 绿
    outG=$(echo -e "${white}::${green} =>${suffix}")
}

# @读取文件 install.conf（默认）  auins.info（INFO）
function Read_Config(){ 
    # 头部参数 $1 , 地址 $2（如果是查script.conf，可以不用写）（如果是auins.info，必须写INFO） Read_Config "Disk" "INFO"
    case "$2" in
        INFO) local Files="$Auins_record" ;;
        *   ) local Files="$Auins_Config" ;;
    esac
    grep -w "$1" < "$Files" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}';
}
# @写入信息文件 local/auins.info
function Write_Data(){
    # 头部参数 $1 , 修改内容 $2    
    format=" = "
    List_row=$(grep -nw "${1}" < "${Auins_record}" | awk -F ":" '{print $1}';)
    sed -i "${List_row:-Not}c ${1}${format}${2}" "${Auins_record}" 2>/dev/null
}

function openboxManger(){
    local openboxDir openboxTheme
    Desktop_Env_Config "openbox" "openbox-session" #  $1 # Desktop name $2 xinitrc "exec desktop"
    openboxDir="${UserHomeDir}/.config/openbox"
    openboxTheme="${UserHomeDir}/.themes"
    tint2Theme="${UserHomeDir}/.config/tint2/theme"
    mkdir -p "${openboxDir}" &>/dev/null
    rm -rf "${openboxTheme}" &>/dev/null
    rm -rf "${tint2Theme}" &>/dev/null
    cp /etc/xdg/openbox/{rc.xml,menu.xml,autostart,environment} "${openboxDir}" &>/dev/null
    curl -fsSL "$Share_Dir"/Arch_auroot.jpg > "${openboxDir}"/Arch_auroot.jpg
    # openbox-theme
    git clone "$source"/openbox-theme-collections "${openboxTheme}"
    sed -i 's/Clearlooks/Triste-Froly/' "${openboxDir}"/rc.xml
    # .config/openbox/autostart 
    echo -e "tint2 -c ${UserHomeDir}/.config/tint2/theme/minima/minima.tint2rc &\nnitrogen --restore\nfeh --bg-fill ""${openboxDir}""/Arch_auroot.jpg\nxfce4-clipman &" >> "${openboxDir}"/autostart
    # Configure ranager
    curl -fsSL "$Share_Dir"/rangerRc.sh > "$UserHomeDir"/rangerRc.sh
    curl -fsSL "$Share_Dir"/obconf.sh > "$UserHomeDir"/obconf.sh
    echo -e "bash $UserHomeDir/rangerRc.sh ${UserHomeDir} \nsleep 3;" >> "${openboxDir}"/autostart
    echo -e "bash $UserHomeDir/obconf.sh&\nsleep 3;" >> "${openboxDir}"/autostart
    # tint2-theme   tint2 -c /home/"$CheckingUsers"/.config/tint2/theme/minima/minima.tint2rc &
    git clone "$source"/tint2-theme-collections "${tint2Theme}"
    # URxvt-themes
    curl -fsSL "$source"/URxvt-themes/raw/master/smooth-white-blue > /home/"$CheckingUsers"/.Xresources
    chown -R "$CheckingUsers":users "${UserHomeDir}"
    echo -e "sed -i '/obconf\|sed\|rangerRc/d' ${openboxDir}/autostart" >> "${openboxDir}"/autostart
}


Auins_Config=${1}
Auins_record=${2}
Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
Share_Dir="${Auins_Dir}"

UserHomeDir="/home/.." #${UserName}  # Openbox

source="https://gitee.com/auroot"

echo -e "${outG} ${green}Configuring desktop environment.${suffix}"
sleep 1;
Install_Program "$(Read_Config P_xorgGroup)"
Install_Program "$(Read_Config P_openbox)"
Install_Program "$(Read_Config P_gui)"
sleep 1;
printf "${outG} ${green} Using the default Desktop manager:'${blue}slim${green}'[Y/*]?${suffix} %s" "${inB}"
read -r slim_ID
case "$slim_ID" in
    [Yy]*)
        openboxManger;
        # /usr/share/slim/themes   /etc/slim.conf }
        git clone "$source"/slim_themes.git /home/"$CheckingUsers"/slim_themes
        cp -rf /home/"$CheckingUsers"/slim_themes/themes/* /usr/share/slim/themes  
        cp -rf /home/"$CheckingUsers"/slim_themes/previews /usr/share/slim/themes  
        themesNum numlockNum
        themesNum=$(sed -n '/current_theme/=' /etc/slim.conf)
        numlockNum=$(sed -n '/# numlock/=' /etc/slim.conf)
        sed -i "${numlockNum}s/# numlock/numlock/g" /etc/slim.conf
        sed -i "${themesNum}s/default/minimal/g" /etc/slim.conf
        systemctl enable slim ;;
    *) Desktop_Manager; openboxManger ;;
esac 