#!/bin/bash
# Author: Auroot
# QQ： 2763833502
# Description：Drive Manager -> Auins v4.7.1
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -x
# https://www.jianshu.com/p/ca79f476b3f3

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
    bash "$Tools_modules" "$config_File" "$info_File" " " "$1" "$2" "$3" "$4" "$5"
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
            sleep 2; break;
        fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}

# @Install I/O Driver 安装驱动
function main(){
    # 读取配置 
    INFO_CPU_Vendor=$(run_tools file_rw INFO Read CPU_Vendor)
    CONF_Driver_Audio=$(run_tools file_rw CONF Read Install_Driver_Audio)
    CONF_Driver_input=$(run_tools file_rw CONF Read Install_Driver_Input)
    CONF_Driver_Bluez=$(run_tools file_rw CONF Read Install_Driver_Bluetooth)
    # 读取包名
    CONF_PKG_INTEL=$(run_tools file_rw CONF Read PGK_Intel)
    CONF_PKG_AMD=$(run_tools file_rw CONF Read PGK_Amd)
    CONF_PGK_Audio_Driver="$(run_tools file_rw CONF Read PGK_Audio_Driver)"
    CONF_PGK_Input_Driver="$(run_tools file_rw CONF Read PGK_Input_Driver)"
    CONF_PGK_Bluez_Driver="$(run_tools file_rw CONF Read PGK_Bluetooth_Driver)"
    # CPU
    function install_intel(){
        run_tools run "Install the Intel driver."
        Install_Program "$CONF_PKG_INTEL"
        run_tools feed "Intel driver installation successfully." "Intel driver installation failed."
    }
    function install_amd(){
        run_tools run "Install the Amd driver."
        Install_Program "$CONF_PKG_AMD"
        run_tools feed "Amd driver installation successfully." "Amd driver installation failed."
    }
    case $INFO_CPU_Vendor in
    intel)  install_intel ;;
      amd)  install_amd ;;
        *)  tips_white "Please select: Intel[1] AMD[2]"
            case $(run_tools read) in
                1)  install_intel;;
                2)  install_amd
            esac
    esac
    # 安装音频驱动 
    case $CONF_Driver_Audio in 
        yes) 
            run_tools run "Installing Audio driver."
            Install_Program "$CONF_PGK_Audio_Driver"
            run_tools feed "Audio driver installation successfully." "Audio driver installation failed."
            systemctl enable alsa-state.service
            run_tools feed "alsa-state.service enable successfully." "alsa-state.service enable failed."
        ;;
        *)  skip "Installing Audio driver..."
    esac
    # 安装 I/O 驱动 
    case $CONF_Driver_input in 
        yes) 
            run_tools run "Installing input driver."
            Install_Program "$CONF_PGK_Input_Driver"
            run_tools feed "Input driver installation successfully." "Input driver installation failed."
        ;;
        *)   skip "Installing input driver..."
    esac 
    # 安装蓝牙驱动
    case $CONF_Driver_Bluez in 
        yes) run_tools run "Installing Bluetooth driver."
             Install_Program "$CONF_PGK_Bluez_Driver"
             run_tools feed "Bluetooth driver installation successfully." "Bluetooth driver installation failed."
             echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa
             echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa;;
        *)   skip "Installing bluetooth driver..."
    esac 
}

include "$@"
main