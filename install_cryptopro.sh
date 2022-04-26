#!/bin/sh

# see https://www.altlinux.org/КриптоПро

DOWNLOADDIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
LOCALPATH="/opt/distr/CryptoPro"
LOCALPATH2="/var/ftp/pvt/Linux/CryptoPro CSP/5.0/5.0.11453"

. $(dirname $0)/functions.sh

get_distr_dir()
{
    local i
    for i in "$DOWNLOADDIR" "$LOCALPATH" "$LOCALPATH2" . ; do
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

install_lsb32()
{
    epmi lsb-release lsb-init
    case $(epm print info -d) in
        ALTLinux)
            ;;
        *)
            fatal "$(epm print info -e) is not yet supported"
            ;;
    esac

    if [ -z "$BIARCH" ] ; then
        epmi lsb-core
        return
    fi

    echo "Workaround for https://bugzilla.altlinux.org/show_bug.cgi?id=38855"
    # Следующие пакеты имеют неудовлетворенные зависимости:
    #    lsb-cprocsp-rdr.32bit: Для установки требует: lsb-core-ia32 (>= 3.0) но пакет не может быть установлен

    # HACK:
    epm assure eget

    # for install deps
    epmi lsb-core i586-lsb-core || fatal
    epme i586-lsb-core --nodeps

    case $(epm print info -v) in
        Sisyphus)
            LSBCOREURL=http://ftp.basealt.ru/pub/distributions/ALTLinux/Sisyphus/i586/RPMS.classic/lsb-core-5.0-alt2.i586.rpm
            ;;
        p10)
            LSBCOREURL=http://ftp.basealt.ru/pub/distributions/ALTLinux/p10/branch/i586/RPMS.classic/lsb-core-5.0-alt1.i586.rpm
            ;;
        p9)
            LSBCOREURL=http://ftp.basealt.ru/pub/distributions/ALTLinux/p9/branch/i586/RPMS.classic/lsb-core-4.0-alt12.i586.rpm
            ;;
        p8)
            LSBCOREURL=http://ftp.basealt.ru/pub/distributions/ALTLinux/p8/branch/i586/RPMS.classic/lsb-core-4.0-alt5.i586.rpm
            ;;
        *)
            fatal "$(epm print info -e) is not yet supported"
            ;;
    esac

    eget $LSBCOREURL
    epme lsb-core --nodeps
    epmi $(basename $LSBCOREURL)
}

DEVEL=''
[ "$1" = "--devel" ] && DEVEL=$1 && shift
GUI='--gui'
[ "$1" = "--nogui" ] && GUI='' && shift
INSTALLER="install.sh"
[ "$1" = "--gui-install" ] && INSTALLER='install_gui.sh' && shift

INSTALL32=''
INSTALL64=''
case "$1" in
    32)
        INSTALL32="$1"
        ;;
    64)
        INSTALL64="$1"
        ;;
    both)
        INSTALL32="$1"
        INSTALL64="$1"
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
    if [ -d linux-amd64 ] ; then
        echo "Note: Will use existed linux-amd64 dir ..."
        # rm -rfv linux-amd64/
        # [ -d linux-amd64 ] && fatal "Remove linux-amd64 dir first"
    else
        unpack_tgz linux-amd64.tgz || fatal "Can't unpack"
    fi
    cd linux-amd64 || fatal
    install_lsb64 || fatal

    a='' ./integrity.sh || fatal

    echo
    echo "Installing x86_64 packages ..."

    epmi "libidn.so.11()(64bit)"

    if [ "$INSTALLER" = "install_gui.sh" ] ; then
        # whiptail for install-gui.sh
        epm assure whiptail newt52
    fi

    if [ -n "$GUI" ] ; then
        epmi --skip-installed libpango libgtk+2 libSM libpng12
    fi

    # TODO: don't use their install.sh

    $SUDO bash ./$INSTALLER || fatal


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
    # needed for unstalled
    # rm -rfv linux-amd64
fi

if [ -n "$INSTALL32" ] ; then
    if [ -d linux-ia32 ] ; then
        echo "Note: Will use existed linux-ia32 ..."
        # rm -rfv linux-ia32/
        # [ -d linux-ia32 ] && fatal "Remove linux-ia32 dir first"
    else
        unpack_tgz linux-ia32.tgz || fatal "Can't unpack"
    fi

    cd linux-ia32 || fatal
    install_lsb32 || fatal

    a='' ./integrity.sh || fatal

    echo
    echo "Installing i686 packages ..."

    epmi "libidn.so.11"

    if [ "$INSTALLER" = "install_gui.sh" ] ; then
        # whiptail for install-gui.sh
        epm assure whiptail newt52
    fi

    if [ -n "$GUI" ] ; then
        epmi --skip-installed ${BIARCH}libpango ${BIARCH}libgtk+2 ${BIARCH}libSM ${BIARCH}libpng12
    fi

    if [ "$INSTALL32" = "both" ] ; then
        # install the same packages as for 64 bit
        # hack, otherwise 32bit install.sh will remove 64bit packages
        toinstall="$(epmqp --short cprocsp- | grep "cprocsp-.*-64$" | sed -e 's|-64$|-*.rpm|')"
        epmi --scripts $toinstall
    else
        $SUDO i586 bash ./$INSTALLER || fatal
    fi

    if [ -n "$DEVEL" ] ; then
         epmi --scripts --skip-installed lsb-cprocsp-devel-*.noarch.rpm
    fi

    if [ -n "$BIARCH" ] ; then
        epm play i586-fix
    fi

    epmi --scripts --skip-installed lsb-cprocsp-rdr-5.*.i686.rpm
    # PKCS#11
    epmi --scripts --skip-installed lsb-cprocsp-pkcs11-*.i686.rpm

    #if epmqp libpcsclite
    # needed for other cprocsp-rdr
    epmi --scripts --skip-installed cprocsp-rdr-pcsc-*.i686.rpm || fatal

    # TODO: check if the system has rutoken/jacarta supports
    info "Check if Jacarta support is needed ..."
    if epm installed libjcpkcs11 >/dev/null ; then
        # Note: have brain broken postinstall script
        epmi --scripts --skip-installed cprocsp-rdr-jacarta-*.i686.rpm
    fi

    info "Check if ruToken support is needed ..."
    if epm installed librtpkcs11ecp >/dev/null ; then
        epmi --scripts --skip-installed cprocsp-rdr-rutoken-*.i686.rpm  || fatal
    fi

    if [ -n "$GUI" ] ; then
        epmi --scripts --skip-installed cprocsp-cptools-gtk-*.i686.rpm
        epmi --scripts --skip-installed cprocsp-rdr-gui-gtk-*.i686.rpm
    fi

    cd -
    # needed for uninstall
    # rm -rfv linux-ia32
fi
