#!/bin/sh

# see https://www.altlinux.org/КриптоПро
# https://support.cryptopro.ru/index.php?/Knowledgebase/Article/View/87/2/ustnovk-kriptopro-csp-n-os-linux--rutoken

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

    # ruToken support
    # instead of cryptopro-preinstall, see https://www.altlinux.org/КриптоПро#Установка_пакетов
    epmi pcsc-lite-rutokens pcsc-lite-ccid librtpkcs11ecp libpcsclite

    # TODO:
    # Почему у нас токены через pcscd?
    # Зачем тогда cprocsp-rdr-rutoken ?
    # Какие пакеты нужны для токена? Отделить отсюда?
    # Ответ: Современные аппаратные и программно-аппаратные хранилища ключей, такие как Рутокен ЭЦП или eSmart ГОСТ, поддерживаются через интерфейс PCSC
fi

if [ -n "$INSTALL32" ] ; then

    # ruToken support
    # instead of cryptopro-preinstall, see https://www.altlinux.org/КриптоПро#Установка_пакетов
    epmi ${BIARCH}pcsc-lite-rutokens ${BIARCH}pcsc-lite-ccid ${BIARCH}librtpkcs11ecp ${BIARCH}libpcsclite
fi

epmi opensc
epmi pcsc-lite

echo "Enabling pcscd service ..."
serv pcscd on
