#!/bin/sh

# see https://www.altlinux.org/ViPNet_CSP

# TODO: since vipnetcsp_pkg_manager.sh

DOWNLOADDIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
LOCALPATH="/opt/distr/ViPNet"
LOCALPATH2="/var/ftp/pvt/Windows/Crypto/ViPNet/ViPNet CSP Linux 4.2.10.51042/Комплект пользователя/SOFT/rpm"

# TODO: only if not root
SUDO=sudo

BIARCH=''
[ "$(distro_info -a)" = "x86_64" ] && BIARCH="i586-"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
}

get_distr_dir()
{
    local i
    for i in "$DOWNLOADDIR" "$LOCALPATH" "$LOCALPATH2" . ; do
        #ls -1 "$i" | grep -q "^$1$" && echo "$i" && return
        ls "$i"/$1 2>/dev/null >/dev/null && echo "$i" && return
    done
    return 1
}


DEVEL=''
[ "$1" = "--devel" ] && DEVEL=$1 && shift
GUI='--gui'
[ "$1" = "--nogui" ] && GUI='' && shift

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
        fatal "Sorry, biarch don't support yet"
        INSTALL32="$1"
        INSTALL64="$1"
        ;;
    *)
        fatal "Run with 32|64|both param"
esac
shift

[ "$1" = "--devel" ] && DEVEL=$1 && shift
[ "$1" = "--nogui" ] && GUI='' && shift


# epmi does rpm -Uvh, it replaces arch packages (don't allow two package with the same name and other arches)
direct_epmi()
{
   local EPMI="$SUDO rpm -ivh"
   echo "$EPMI $*"
   $EPMI "$@"
}

# --force removing x86_64 package if installed
# itcs-entropy-gost:
#  sudo rpm -ivh --badreloc --relocate /opt/itcs=/opt/itcs32 itcs-entropy-gost-4.4.1.649-1.i386.rpm
# Подготовка...
#    пакет itcs-entropy-gost-4.4.1.649-1.i386 уже установлен
reloc_epmi()
{
    local EPMI="$SUDO rpm -ivh --badreloc --relocate /opt/itcs=/opt/itcs32"
    echo "$EPMI $*"
    $EPMI "$@"
}

install_itcs()
{
    local ARCH=$1

    echo
    echo "Installing $ARCH packages ..."

    if [ "$ARCH" = "i386" ] ; then
        epmi --skip-installed ${BIARCH}libstdc++6
    else
        epmi --skip-installed libstdc++6
    fi

    if ! ls -1 | grep -q "^itcs-licensing-.*.$ARCH.rpm" ; then
        fatal "Can't find itcs $ARCH.rpm packages in the current dir $pwd. Run me in the distro dir"
    fi

    EPMI="direct_epmi"
    if [ "$ARCH" = "i386" ] && [ -n "$BIARCH" ] && [ -n "$INSTALL64" ] ; then
        EPMI="reloc_epmi"
    fi

    $EPMI itcs-licensing-*.$ARCH.rpm || fatal

    # ver 4.4
    if ls -1 | grep -q "^itcs-known-path-.*.$ARCH.rpm" ; then
        $EPMI itcs-known-path-*.$ARCH.rpm
    fi

    $EPMI itcs-entropy-gost-4.*.$ARCH.rpm || fatal

    $EPMI itcs-winapi-4.*.$ARCH.rpm \
          itcs-csp-gost-4.*.$ARCH.rpm || fatal

    $EPMI itcs-integrity-check-4.*.$ARCH.rpm \
          itcs-cryptofile-4.*.$ARCH.rpm || fatal

    # ver 4.4
    if ls -1 | grep -q "^itcs-pkicmd-.*.$ARCH.rpm" ; then
        $EPMI itcs-pkicmd-*.$ARCH.rpm
    fi

    if [ -n "$GUI" ] ; then
        # libqt4 will provide needed qt = version
        epmi libqt4 libqt4-gui
        if [ "$ARCH" = "i386" ] && [ -n "$BIARCH" ] ; then
            epmi --skip-installed ${BIARCH}libqt4-gui

            # QGtkStyle could not resolve GTK. Make sure you have installed the proper libraries.
            echo "libgtk+2 add segfault to certmgr-gui, so remove it"
            epme ${BIARCH}libgtk+2
        fi

        $EPMI itcs-csp-gost-gui-4.*.$ARCH.rpm \
              itcs-entropy-gost-gui-4.*.$ARCH.rpm \
              itcs-winapi-gui-4.*.$ARCH.rpm || fatal
    fi

    if [ -n "$DEVEL" ] ; then
         epmi itcs-csp-dev-*.noarch.rpm || fatal
    fi
}

if [ -n "$(epmqp itcs | grep "^itcs-")" ] ; then
    fatal "You are already have itcs packages installed. Run uninstall first."
fi


L=$(get_distr_dir "itcs*.rpm") || fatal "Can't find itcs*.rpm in the current dir $(pwd). Download it and put in here or it $LOCALPATH."
cd "$L"

if [ -n "$INSTALL64" ] ; then
    install_itcs x86_64
fi

echo "Info: on biarch system we install files in another dir, so will use 64 bit utilities from install scripts"
if [ -n "$INSTALL32" ] ; then
    install_itcs i386
fi
