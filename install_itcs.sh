#!/bin/sh

# see https://www.altlinux.org/ViPNet_CSP

# TODO: only if not root
SUDO=sudo

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
if [ "$1" = "--devel" ] ; then
    DEVEL=1
    shift
fi

GUI='default'
if [ "$1" = "--gui" ] ; then
    GUI=1
    shift
fi

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

#if [ -n "$(epmqp itcs)" ] ; then
#    info "You are already have itcs packages installed. Run uninstall_itcs.sh first (or errors are possible)."
#fi

install_itcs()
{
    local ARCH=$1
    if ! ls -1 | grep -q "^itcs-licensing-.*.$ARCH.rpm" ; then
        fatal "Can't find itcs $ARCH.rpm packages in the current dir $pwd. Run me in the distro dir"
    fi

    EPMI="epmi"
    if [ "$INSTALL32" = "both" ] ; then
        EPMI="$SUDO rpm -ivh --badreloc --relocate /opt/itcs=/opt/itcs32"
    fi

    $EPMI itcs-licensing-*.$ARCH.rpm \
          itcs-entropy-gost-4.*.$ARCH.rpm || fatal

    # ver 4.4
    if ls -1 | grep -q "^itcs-know-path-.*.$ARCH.rpm" ; then
        $EPMI itcs-known-path-*.$ARCH.rpm
    fi

    $EPMI itcs-winapi-4.*.$ARCH.rpm \
          itcs-csp-gost-4.*.$ARCH.rpm || fatal

    $EPMI itcs-integrity-check-4.*.$ARCH.rpm \
          itcs-cryptofile-4.*.$ARCH.rpm || fatal

    # ver 4.4
    if ls -1 | grep -q "^itcs-pkicmd-.*.$ARCH.rpm" ; then
        $EPMI itcs-pkicmd-*.$ARCH.rpm
    fi

    if [ -n "$GUI" ] ; then
        $EPMI itcs-csp-gost-gui-4.*.$ARCH.rpm \
              itcs-entropy-gost-gui-4.*.$ARCH.rpm \
              itcs-winapi-gui-4.*.$ARCH.rpm || fatal
    fi

    if [ -n "$DEVEL" ] ; then
         epmi itcs-csp-dev-*.noarch.rpm || fatal
    fi


}

if [ -n "$INSTALL64" ] ; then
    install_itcs x86_64
fi

if [ -n "$INSTALL32" ] ; then
    install_itcs i386
fi
