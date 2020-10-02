#!/bin/sh -x

BIARCH=''
[ "$(distro_info -a)" = "x86_64" ] && BIARCH="i586-"

test_token()
{
    [ -s $1 ] || return

    pkcs11-tool -L --module "$1" | head -n 12

    pkcs11-tool -Ol --module "$1"
}

if [ -n "$BIARCH" ] ; then
    echo "pkcs11-tool is 64 bit, so skip 32 bit library testing"
else
    test_token /usr/lib/pkcs11/libjcPKCS11-2.so.2.4.0
fi

test_token /usr/lib64/pkcs11/libjcPKCS11-2.so.2.4.0
