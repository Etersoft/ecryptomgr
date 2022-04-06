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
    epme --scripts cprocsp-pki-cades-64 cprocsp-pki-plugin-64
fi

if [ -n "$INSTALL32" ] ; then
    epme --scripts cprocsp-pki-cades cprocsp-pki-plugin
fi
