# Maintainer: Auroot <2763833502@qq.com>

pkgname='auins'
# 软件的发布号
pkgver=4.6.rc8
pkgrel=3
# 用于强制升级软件包
epoch=0
SCRIPTS_SOURCE="test"
case $SCRIPTS_SOURCE in
    gitee ) 
        _mirror="https://gitee.com/auroot/Auins/raw/master/local" ;;
    github) 
        _mirror="https://raw.githubusercontent.com/Auroots/Auins/main/local";;
    auroot) 
        _mirror="http://auins.auroot.cn/local" ;;
    test) 
        _mirror="http://test.auroot.cn/local" 
esac
_pkg="$pkgname-${pkgver//_/-}.tar.gz"
_mirror="https://gitee.com/auroot/Arch_install/attach_files"
source=("$_mirror/$_pkg")
# 软件包描述
pkgdesc="Auins(Archlinux system installation script), Highly customized your archLinux."
# 使用的架构
arch=('x86_64')
# 上游 URL
url="https://github.com/Auroots/Auins"
# 许可证协议
license=('GPL3')
# 依赖
depends=('shc>=4.0.3-1')
# 包备份文件
backup=("etc/$pkgname/profile.conf")
md5sums=('7a13530a621e45f9b758fb00147b91ef')
# Error message wrapper
# _err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
# Run message wrapper
_run(){ echo -e "\033[1;37m:: $(tput bold; tput setaf 2)[ + Exec ] => \033[1;32m${*}\033[0m$(tput sgr0)"; }

_src_pkg="${srcdir}/$pkgname-${pkgver//_/-}"
build(){
    (
    _run "Extracting DPKG package ..."
        tar zxf "$_src_pkg.tar.gz"
    )
    (
    _run "Build modules package..."
        cd "$_src_pkg/share"
        for file in *.sh; do 
            shc -f "$file" -o "$file" && rm -rf "./$file.x.c"
        done
    )
    (
    _run "Build software package..."
        cd "$_src_pkg"
        shc -f $pkgname -o $pkgname && rm -rf ./$pkgname.x.c
    )
    (
        mkdir -p /etc/$pkgname/ && cp -rf "$_src_pkg/local/*" /etc/$pkgname/
        mkdir -p /usr/local/auins_modules && cp -rf "$_src_pkg/share/*" /usr/local/auins_modules
    )
}
package() {
    _run "Installing auins..."
    install -Dm755 "$pkgname" "$pkgdir/usr/bin/$pkgname"
    rm "${srcdir}/$_pkg"
    rm "${srcdir}/$_src_pkg"
}

# 需要重置的目录有
# local 重置 /etc/auins
# share 重置 /usr/local/auins_modules