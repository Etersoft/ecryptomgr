#!/bin/sh

# https://www.altlinux.org/JaCarta/PKI#Установка_КриптоПро

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
if [ "$1" = "--devel" ] ; then
    DEVEL=1
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


if [ -n "$INSTALL64" ] ; then
    epmi jcPKCS11-2
fi

if [ -n "$INSTALL32" ] ; then
    epmi ${BIARCH}jcPKCS11-2
fi

epmi opensc
epmi pcsc-lite

echo "Enabling pcscd service ..."
serv pcscd on
