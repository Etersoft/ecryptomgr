#!/bin/sh

. $(dirname $0)/functions.sh

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

    epmi pcsc-lite-ccid libpcsclite pcsc-lite-rutokens
fi

if [ -n "$INSTALL32" ] ; then

    epmi ${BIARCH}pcsc-lite-ccid ${BIARCH}libpcsclite ${BIARCH}pcsc-lite-rutokens
fi

epmi opensc
epmi pcsc-lite

echo "Enabling pcscd service ..."
serv pcscd on

echo "Now you can check your token via $ pcsc_scan command"
