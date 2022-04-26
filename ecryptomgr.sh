#!/bin/sh

SDIR=$(dirname "$0")
[ "$SDIR" = "." ] && SDIR=$(pwd)

. $SDIR/functions.sh


if [ "$1" = "-h" ] || [ "$1" == "--help" ] ; then
    cat <<EOF
Usage: $ ecryptomgr install|remove|clean|license|status|test [--devel] [--nogui] [cprocsp|itcs|rutoken|jacarta|cades] [32|64|both]

Commands:
    install - install crypto provider
    remove  - uninstall crypto provider
    clean   - remove old files after uninstall (wipe all related data)
    license - check license status
    status  - check if crypto provider is installed
    test    - check integrity and run some tests

Crypto providers:
    cprocsp - CryptoPro
    itcs    - ViPNet CSP
    rutoken - ruToken
    jacarta - JaCarta
    cades   - CryptoPro CAdES Plugin
    pcsc    - PC/SC support

Options:
    --devel - install development packages too
    --nogui - don't install gui packages

Arch:
      32 - i586 packages (does not matter you have 32 or 64 bit OS)
      64 - x86_64 packages
    both - install both 32 and 64 bit (not supported yet for ViPNet CSP)

Download crypto provider distro files and run ecryptomgr install command with appropiate args.

Examples:
 $ ecryptomgr install cprocsp
 $ ecryptomgr install cprocsp both
 $ ecryptomgr install --devel itcs 32
EOF
    exit
fi

COMMAND="$1" && shift

DEVEL=''
GUI=''

# TODO: detect by files in the current dir and current arch
# third arg
ARCH=""
case "$(epm print info -a)" in
    x86_64)
        ARCH=64
        ;;
    x86)
        ARCH=32
        ;;
    default)
        echo "Note: arch $(epm print info -a) is not autodetected."
        ;;
esac

# TODO: detect by files in the current dir
# second arg
# TODO: change to cprocsp
CPROV=cryptopro
while [ -n "$1" ] ; do
case "$1" in
    cprocsp|cryptopro)
        CPROV="cryptopro"
        ;;
    itcs|vipnet)
        CPROV="itcs"
        ;;
    rutoken|ruToken)
        CPROV="rutoken"
        ;;
    pcsc)
        CPROV="pcsc"
        ;;
    jacarta|JaCarta)
        CPROV="jacarta"
        ;;
    cades|cadesplugin)
        CPROV="cades"
        ;;
    "--devel")
        DEVEL="$1"
        ;;
    "--nogui")
        GUI="$1"
        ;;
    32|64|both)
        ARCH=$1
        ;;
    "")
        fatal "Run with --help."
        ;;
    *)
        fatal "Unknown provider $1. Run with --help."
        ;;
esac
shift
done


echo "Doing $COMMAND $CPROV for $ARCH arch(es) ..."
# first arg
case $COMMAND in
    install)
            $SDIR/install_$CPROV.sh $DEVEL $GUI $ARCH
        ;;
    remove|uninstall)
            $SDIR/uninstall_$CPROV.sh $ARCH
        ;;
    clean)
            $SDIR/clean_$CPROV.sh $ARCH
        ;;
    status)
            $SDIR/status_$CPROV.sh $ARCH
        ;;
    license)
            $SDIR/license_$CPROV.sh $ARCH
        ;;
    test|check)
            $SDIR/test_$CPROV.sh $ARCH
        ;;
    "")
        fatal "TODO: AI. run with --help"
        ;;
    *)
        fatal "Unknown command $COMMAND. Run with --help"
esac

