#!/bin/sh

# TODO: only if not root
SUDO=sudo

BIARCH=''
[ "$(epm print info -a)" = "x86_64" ] && BIARCH="i586-"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
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
#        if [ "$(epm --quiet checkpkg $PKG)" = \
#            "S.5....T.  c /etc/opt/cprocsp/config64.ini
#/var/opt/cprocsp/users/global.ini
        echo -en "\b\b\b\b\b\b"
        echo "BRokEN"
        epm checkpkg $PKG
        return 1
    fi

    echo -en "\b\b\b\b\b\b"
    echo "    OK"
}


# TODO: использовать список того, что ставили?
check_cryptopro()
{
    local ARCH=$1
    local ARCHSUFFIX=$2
    echo

    # TODO: epm print version for
    VER=$(rpmquery --queryformat="%{version}\n" lsb-cprocsp-base) || fatal "Can't find $lsb-cprocsp-base"

    echo "Checking $ARCH cprocsp-* $VER packages ..."

    check_pkg lsb-cprocsp-base $VER noarch

    for i in lsb-cprocsp-pkcs11 cprocsp-rdr-pcsc \
             cprocsp-curl lsb-cprocsp-rdr \
             lsb-cprocsp-kc1 lsb-cprocsp-capilite cprocsp-rdr-pcsc ; do
        check_pkg $i$ARCHSUFFIX $VER $ARCH
    done

    if epmqp --quiet jcPKCS11-2 >/dev/null ; then
        check_pkg cprocsp-rdr-jacarta$ARCHSUFFIX $VER $ARCH
    fi

    if epmqp --quiet librtpkcs11ecp >/dev/null ; then
        check_pkg cprocsp-rdr-rutoken$ARCHSUFFIX $VER $ARCH
    fi

    if [ -n "$DEVEL" ] ; then
        check_pkg lsb-cprocsp-devel $VER noarch
    fi

    if [ -n "$GUI" ] ; then
        for i in cprocsp-cptools-gtk cprocsp-rdr-gui-gtk ; do
            check_pkg $i$ARCHSUFFIX $VER $ARCH
        done
    fi

}


if [ -n "$INSTALL64" ] ; then
    check_cryptopro x86_64 "-64"
fi

if [ -n "$INSTALL32" ] ; then
    check_cryptopro i686 ""
fi

echo
info "Checking integrity via /etc/init.d/cprocsp check ..."
info "TODO: appropriate arch"
$SUDO /etc/init.d/cprocsp check

test_certmgr()
{
    [ -x $1 ] || return
    $1 -list
}

test_certmgr /opt/cprocsp/bin/ia32/certmgr

test_certmgr /opt/cprocsp/bin/amd64/certmgr
