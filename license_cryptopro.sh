#!/bin/sh

license()
{
    [ -x $1 ] || return
    $1 -license -view
}

version()
{
    [ -x $1 ] || return
    echo -n "Crypto Pro version: "
    $1 -keyset -verifycontext | sed -n 's/.* Ver:*\([0-9.]\+\).*/\1/p'
}

version /opt/cprocsp/bin/amd64/csptest
version /opt/cprocsp/bin/ia32/csptest
echo
license /opt/cprocsp/sbin/amd64/cpconfig
license /opt/cprocsp/sbin/ia32/cpconfig
