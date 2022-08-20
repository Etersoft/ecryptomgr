#!/bin/sh

# see https://www.altlinux.org/КриптоПро

DOWNLOADDIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
LOCALPATH="/opt/distr/CryptoPro-FNS"

. $(dirname $0)/functions.sh

get_distr_dir()
{
    local i
    for i in "$DOWNLOADDIR" "$LOCALPATH" . ; do
        [ -f "$i/$1" ] && echo "$i" && return
    done
    return 1
}

unpack_tgz()
{
    epm assure erc || fatal
    local ar=$(get_distr_dir $1)
    [ -n "$ar" ] || fatal "Can't find $1 in the current dir $(pwd). Download it and put in here or in $LOCALPATH."
    #info "Unpacking $ar/$1 ..."
    erc "$ar/$1"
}

install_lsb64()
{
    epmi lsb-release lsb-init
    epme i586-lsb-core --nodeps
    epm --auto reinstall lsb-core || fatal
}

DEVEL=''
[ "$1" = "--devel" ] && DEVEL=$1 && shift
GUI='--gui'
[ "$1" = "--nogui" ] && GUI='' && shift
#INSTALLER="install.sh"
# by default
INSTALLER='install_gui.sh'
[ "$1" = "--gui-install" ] && INSTALLER='install_gui.sh' && shift

INSTALL64=''
case "$1" in
    32)
        fatal "32 bit is not supported"
        ;;
    64)
        INSTALL64="$1"
        ;;
    both)
        fatal "32 bit is not supported"
        ;;
    *)
        fatal "Run with 32|64|both param"
esac
shift

# TODO: improve
[ "$1" = "--devel" ] && DEVEL=$1 && shift
[ "$1" = "--nogui" ] && GUI='' && shift
[ "$1" = "--gui-install" ] && INSTALLER='install-gui.sh' && shift

if [ -n "$(epmqp cprocsp | grep "^cprocsp-")" ] ; then
    fatal "You are already have cprocsp packages installed. Run uninstall first."
fi

$SUDO rm -fv /var/opt/cprocsp/tmp/*lock* 2>/dev/null

if [ -n "$INSTALL64" ] ; then
    pkgtype=$(epm print info -p)
    basename="fns-amd64"
    tarname="csp-fns-amd64.tgz"
    if [ "$pkgtype" = "deb" ] ; then
        basename="fns-amd64_deb"
        tarname="csp-fns-amd64_deb.tgz"
    fi
    if [ -d $basename ] ; then
        echo "Note: Will use existing $basename dir ..."
    else
        unpack_tgz $tarname || fatal "Can't unpack"
    fi
    cd $basename || fatal
    install_lsb64 || fatal

    a='' ./integrity.sh || fatal

    echo
    echo "Installing x86_64 packages ..."

    #epmi "libidn.so.11()(64bit)"

    if [ "$INSTALLER" = "install_gui.sh" ] ; then
        # whiptail for install-gui.sh
        epm assure whiptail newt52
    fi

    epmi --skip-installed libpcsclite

    #if [ -n "$GUI" ] ; then
    #    epmi --skip-installed libpango libgtk+2 libSM libpng12
    #fi

    # from _FNS_INSTALLER.sh
    export CPRO_INSTALL_FEATURE_KEYS="lsb-cprocsp-kc1 rdr-gui-gtk cprocsp-cptools-gtk readers pkcs11 cades-plugin" CPRO_INSTALL_NO_LICENSE=1

    # TODO: don't use their install.sh
    $SUDO bash ./$INSTALLER || fatal

    exit

    if [ -n "$DEVEL" ] ; then
         epmi lsb-cprocsp-devel-*.noarch.rpm
    fi

    epmi --scripts --skip-installed lsb-cprocsp-rdr-64-5.*.x86_64.rpm
    # PKCS#11
    epmi --scripts --skip-installed lsb-cprocsp-pkcs11-64-*.x86_64.rpm

    # if epmqp libpcsclite
    # needed for other cprocsp-rdr
    epmi --scripts --skip-installed cprocsp-rdr-pcsc-64-*.x86_64.rpm

    info "Check if Jacarta support is needed ..."
    if epm installed libjcpkcs11 ; then
        # Note: have brain broken postinstall script
        epmi --scripts --skip-installed cprocsp-rdr-jacarta-64-*.x86_64.rpm
    fi

    info "Check if ruToken support is needed ..."
    if epmqp librtpkcs11ecp ; then
        epmi --scripts --skip-installed cprocsp-rdr-rutoken-64-*.x86_64.rpm
    fi

    if [ -n "$GUI" ] ; then
        epmi --scripts --skip-installed cprocsp-cptools-gtk-64-*.x86_64.rpm
        epmi --scripts --skip-installed cprocsp-rdr-gui-gtk-64-*.x86_64.rpm
    fi

    cd -
fi

