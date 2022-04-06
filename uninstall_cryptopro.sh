#!/bin/sh

# TODO: fix epme uninstalled packed

. $(dirname $0)/functions.sh


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

    epme --scripts cprocsp-rdr-rutoken-64
    epme --scripts cprocsp-rdr-jacarta-64
    epme --scripts cprocsp-rdr-pcsc-64

    if cd linux-amd64 ; then
        $SUDO bash ./uninstall.sh
        cd -
    else
        echo "Can't find distro packages, just remove rpms"
        epme --scripts $(epmqp cprocsp-)
    fi

    # epme --scripts cprocsp-cptools-gtk-64
fi

if [ -n "$INSTALL32" ] ; then

    epme --scripts cprocsp-rdr-rutoken
    epme --scripts cprocsp-rdr-jacarta
    epme --scripts cprocsp-rdr-pcsc

    if cd linux-ia32 ; then
        $SUDO i586 bash ./uninstall.sh
        cd -
    else
        echo "Can't find distro packages, just remove rpms"
        epme --scripts $(epmqp cprocsp-)
    fi

    # epme --scripts cprocsp-cptools-gtk
fi
