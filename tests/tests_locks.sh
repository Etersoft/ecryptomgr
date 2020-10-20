#!/bin/sh

. ../functions-lock.sh

ERR=''

ECMLOCKDIR=removeme

INSTALL32=32
arch=32
INSTALL64=''

ok()
{
    local res
    echo "${BASH_LINENO[0]} TEST(ok): $*"
    ( "$@" )
    res=$?
    [ "$res" = 0 ] && return $res
    echo "   FAILED"
    ERR=$(($ERR+1))
}

notok()
{
    local res
    echo "${BASH_LINENO[0]} TEST(notok): $*"
    ( "$@" )
    res=$?
    [ "$res" = 0 ] || return $res
    echo "   FAILED"
    ERR=$(($ERR+1))
}

rm -rf $ECMLOCKDIR/
ok install_req rutoken
ok install_req cryptopro req rutoken
# повторно
ok install_addreq cryptopro req rutoken
notok install_addreq cryptopro req etoken
list_installed
# сначала надо cryptopro удалить
notok remove_req rutoken
ok remove_req cryptopro
notok remove_req etoken
ok remove_req rutoken
notok remove_req unknown

rm -rf $ECMLOCKDIR/
# нет требуемого rutoken
notok install_req cryptopro req rutoken

rm -rf $ECMLOCKDIR/
# вообще вдруг addreq
notok install_addreq cryptopro req etoken

rm -rf $ECMLOCKDIR/
ok install_req rutoken
ok install_req cryptopro req rutoken
ok install_req itcs req rutoken
notok remove_req rutoken
ok remove_req cryptopro
notok remove_req rutoken
ok check_installed rutoken $arch

echo
[ -n "$ERR" ] && echo "TOTAL: $ERR TEST(S) FAILED" || echo "TOTAL: TEST PASSED"
