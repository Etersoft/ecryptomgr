#!/bin/sh

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
    epme libjcpkcs11
fi

if [ -n "$INSTALL32" ] ; then
    epme ${BIARCH}libjcpkcs11
fi
