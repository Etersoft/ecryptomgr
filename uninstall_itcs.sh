#!/bin/sh

# TODO: only if not root
SUDO=sudo

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

BIARCH=''
[ "$(distro_info -a)" = "x86_64" ] && BIARCH="i586-"


INSTALL32=''
INSTALL64=''
case "$1" in
    32)
        [ -n "$BIARCH" ] && fatal "Only both supported on biarch system"
        INSTALL32="$1"
        ;;
    64)
        [ -n "$BIARCH" ] && fatal "Only both supported on biarch system"
        INSTALL64="$1"
        ;;
    both)
        INSTALL32="$1"
        INSTALL64="$1"
        ;;
    *)
        fatal "Run with 32|64|both param"
esac


EPME=epme
NOSCRIPTS=''

if [ "$INSTALL64" = "both" ] ; then
    NOSCRIPTS="--noscripts"
    EPME="$SUDO rpm -ev"
fi

if [ -n "$INSTALL64" ] ; then
    $EPME $NOSCRIPTS $(epmqp itcs .x86_64)
fi

if [ -n "$INSTALL32" ] ; then
    $EPME $NOSCRIPTS $(epmqp itcs .i386)
fi
