#!/bin/bash


# Error message wrapper
function err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Warning message wrapper
function warn(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 3)[ ! Warning ] => \033[1;33m${*}\033[0m$(tput sgr0)"; }
# Run message wrapper
function run(){ echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }
# Skip message wrapper
function skip(){ echo -e "\033[1;37m:: $(tput bold; tput setaf 0)[ - Skip ] => ${*}\033[0m$(tput sgr0)"; }
# @获取用户输入，并返回
function Read_user_input(){ local user_input; read -r user_input; echo "$user_input"; }
# Tips output colour: white
function tips_white(){ printf "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;37m%s \033[1;32m-+> \033[0m$(tput sgr0)" "${*}"; }
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
    # err "you must be root"
    err "Please use command: \033[1;33m\"sudo\"\033[1;31m or user: \033[1;33m\"root\"\033[1;31m to execute.\033[0m"
  fi
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

# 地址: auins.info(INFO)| script.conf(CONF)
# 读取: Config_File_Manage [INFO/CONF] [Read] [头部参数]
# 写入: Config_File_Manage [INFO/CONF] [Write] [头部参数] [修改内容]
function Config_File_Manage(){ 
    local format=" = "; parameter="$3"; content="$4"; itself=$(echo "$0" | awk -F"/" '{print $NF}')
    case "$1" in
        INFO) local Files="$info_File" ;;
        CONF) local Files="$config_File" ;;
    esac
    case "$2" in
        Read ) 
                read_info=$(grep -w "$parameter" < "$Files") # 在文件中查找匹配的值
                if [ -n "$read_info" ]; then 
                    echo "$read_info" | awk -F "=" '{print $2}' | awk '{sub(/^[\t ]*/,"");print}' | awk '{sub(/[\t ]*$/,"");print}' 
                else
                    warn "${white}$itself ${yellow}Read file: ${white}$Files${yellow} missing value: [${white} $parameter  ${yellow}]."
                    sleep 1.5
                fi
         ;;
        Write) 
                List_row=$(grep -nw "$parameter" < "$Files" | awk -F ":" '{print $1}';) # 在文件中查找匹配的值, 并打印行号
                if [ -n "$List_row" ]; then
                    sed -i "${List_row}c ${parameter}${format}${content}" "$Files" 2>/dev/null
                else
                    warn "${white}$itself ${yellow}Write file: ${white}$Files${yellow} missing value: [${white} $parameter  ${yellow}] + [${white} $content ${yellow}]."
                    sleep 1.5
                fi
    esac 
}
# 创建临时目录,脚本退出后自动删除,正常运行时,cd到目录
make a temporary directory and cd into
function make_tmp_dir(){
    tmp="$(mktemp -d /tmp/Auins_strap.XXXXXXXX)"
    trap 'rm -rf $tmp' EXIT
    cd "$tmp" || err "Could not enter directory $tmp"
}
    # 红 绿 黄 蓝 白 后缀
    # red='\033[1;31m'; green='\033[1;32m'  
    # yellow='\033[1;33m'; blue='\033[1;36m'  
    # white='\033[1;37m'; suffix='\033[0m' 
    # ]





