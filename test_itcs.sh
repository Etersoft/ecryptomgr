#!/bin/sh

# see https://www.altlinux.org/ViPNet_CSP

# TODO: since vipnetcsp_pkg_manager.sh

. $(dirname $0)/functions.sh

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

check_pkg()
{
    local PKG="$1" || return
    local VER="$2"
    local ARCH="$3"
    # TODO: check me on p8
    QPKG="$(epm -q $PKG 2>/dev/null)"
    if [ -z "$QPKG" ] ; then
        printf "  %-50s %s\n" "$PKG" "MISSED"
        return 1
    fi

    if ! echo "$QPKG" | grep -q "^$PKG[-_]$VER.*.$ARCH" ; then
        echo "  $QPKG  mismatch with $PKG[-_]$VER.*.$ARCH"
        return 1
    fi

    printf "  %-50s %s" "$PKG" "exists"

    if ! epm checkpkg $PKG 2>/dev/null >/dev/null ; then
        echo -en "\b\b\b\b\b\b"
        echo "BRokEN"
        epm checkpkg $QPKG
        return 1
    fi

    echo -en "\b\b\b\b\b\b"
    echo "    OK"
}


# TODO: использовать список того, что ставили?
check_itcs()
{
    local ARCH=$1

    echo

    NAME=$(epm -q itcs-csp-gost) || fatal "Can't find main package"
    VER=$(echo "$NAME" | sed -e "s|itcs-csp-gost-\([4-5].[0-9]\)\..*|\1|") #"

    echo "Checking $ARCH itcs-* version $VER packages ..."

    check_pkg itcs-licensing 1 $ARCH

    for i in itcs-winapi itcs-csp-gost \
             itcs-integrity-check itcs-cryptofile ; do
        check_pkg $i $VER $ARCH
    done

    if [ "$VER" = "4.4" ] ; then
        ENTROPYVER="4.5"
        for i in itcs-pkicmd itcs-known-path; do
            check_pkg $i $VER $ARCH
        done
    else
        ENTROPYVER="4.4"
    fi

    check_pkg itcs-entropy-gost $ENTROPYVER $ARCH


    if [ -n "$GUI" ] ; then
        check_pkg itcs-entropy-gost-gui $ENTROPYVER $ARCH
        for i in itcs-csp-gost-gui itcs-winapi-gui ; do
            check_pkg $i $VER $ARCH
        done
    fi

    if [ -n "$DEVEL" ] ; then
        for i in itcs-csp-dev ; do
             check_pkg $i $VER $ARCH
        done
    fi
}


if [ -n "$INSTALL64" ] ; then
    check_itcs x86_64
fi

if [ -n "$INSTALL32" ] ; then
    check_itcs i386
fi

logger()
{
    cat
}

IC=/opt/itcs/bin/csp_integrity_check.sh
echo
info "Checking integrity via $IC ..."
. $IC
