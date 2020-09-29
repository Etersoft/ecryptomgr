#!/bin/sh -x

test_certmgr()
{
    [ -x $1 ] || return
    $1 -list
}

test_certmgr /opt/cprocsp/bin/ia32/certmgr

test_certmgr /opt/cprocsp/bin/amd64/certmgr
