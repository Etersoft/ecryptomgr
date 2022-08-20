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

    pkgtype=$(epm print info -p)
    basename="fns-amd64"
    tarname="csp-fns-amd64.tgz"
    if [ "$pkgtype" = "deb" ] ; then
        basename="fns-amd64_deb"
        tarname="csp-fns-amd64_deb.tgz"
    fi

    epme --scripts cprocsp-rdr-rutoken-64
    epme --scripts cprocsp-rdr-jacarta-64
    epme --scripts cprocsp-rdr-pcsc-64

    if cd $basename ; then
        $SUDO bash ./uninstall.sh
        cd -
    else
        echo "Can't find distro packages, just remove rpms"
        epme --scripts $(epmqp cprocsp-)
    fi

    # epme --scripts cprocsp-cptools-gtk-64
fi

