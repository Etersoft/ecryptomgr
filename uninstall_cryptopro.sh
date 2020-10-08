#!/bin/sh

# TODO: fix epme uninstalled packed

# TODO: only if not root
SUDO=sudo

BIARCH=''
[ "$(distro_info -a)" = "x86_64" ] && BIARCH="i586-"


fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}


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



if [ -n "$INSTALL64" ] ; then

    epme cprocsp-rdr-rutoken-64
    epme cprocsp-rdr-jacarta-64
    epme cprocsp-rdr-pcsc-64

    if cd linux-amd64 ; then
        $SUDO bash ./uninstall.sh
        cd -
    else
        echo "Can't find distro packages, just remove rpms"
        epme $(epmqp cprocsp-)
    fi

    # epme cprocsp-cptools-gtk-64
fi

if [ -n "$INSTALL32" ] ; then

    epme cprocsp-rdr-rutoken
    epme cprocsp-rdr-jacarta
    epme cprocsp-rdr-pcsc

    if cd linux-ia32 ; then
        $SUDO i586 bash ./uninstall.sh
        cd -
    else
        echo "Can't find distro packages, just remove rpms"
        epme $(epmqp cprocsp-)
    fi

    # epme cprocsp-cptools-gtk
fi
