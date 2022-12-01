#!/bin/bash
ranger --copy-config=all
rangerRC="${1}/.config/ranger/rc.conf"
rangerConf=$(sed -n '/preview_images /=' "${rangerRC}")
rangerConf2=$(("$rangerConf" + 1))
sed -i "${rangerConf2}c set preview_images true" "${rangerRC}"
rm -rf "$0"