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

    # ruToken support
    epme pcsc-lite-rutokens pcsc-lite-ccid librtpkcs11ecp
fi

if [ -n "$INSTALL32" ] ; then

    # ruToken support
    epme ${BIARCH}pcsc-lite-rutokens ${BIARCH}pcsc-lite-ccid ${BIARCH}librtpkcs11ecp
fi
