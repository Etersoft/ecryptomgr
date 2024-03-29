#!/bin/sh

SDIR=$(dirname "$0")
[ "$SDIR" = "." ] && SDIR=$(pwd)

. $SDIR/functions.sh


if [ "$1" = "-h" ] || [ "$1" == "--help" ] ; then
    cat <<EOF
ecryptomgr - crypto provider manager    Telegram: https://t.me/crypto_etersoft  https://wiki.etersoft.ru/CRYPTO@Etersoft

Usage: $ ecryptomgr <command>install|remove|clean|license|status|test [options] [cprocsp|itcs|rutoken|jacarta|cades] [arch]

Commands:
    install - install crypto provider
    remove  - uninstall crypto provider
    clean   - remove old files after uninstall (wipe all related data)
    license - check license status
    status  - check if crypto provider is installed
    test    - check integrity and run some tests

Options:
    --devel - install development packages too
    --nogui - don't install gui packages
    --gui-install - use GUI installer

Crypto providers:
    cprocsp - CryptoPro
    csp-fns - CryptoPro FNS (free to use) (with GUI by default)
    itcs    - ViPNet CSP
    rutoken - ruToken
    jacarta - JaCarta
    cades   - CryptoPro CAdES Plugin
    pcsc    - PC/SC support
    ifcplugin - IFCPlugin


Arch:
      32 - i586 packages (does not matter you have 32 or 64 bit OS)
      64 - x86_64 packages (default on x86_64 or aarch64 systems)
    both - install both 32 and 64 bit (not supported yet for ViPNet CSP)

Download crypto provider distro files and run ecryptomgr install command with appropriate args.

Examples:
 $ ecryptomgr install cryptopro
 $ ecryptomgr install cprocsp
 $ ecryptomgr install cprocsp both
 $ ecryptomgr install --devel itcs 32
 $ ecryptomgr clean cprocsp
EOF
    exit
fi

COMMAND="$1" && shift

DEVEL=''
GUI=''
GUIINSTALL=''

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
CPROV=''
while [ -n "$1" ] ; do
case "$1" in
    cprocsp|cryptopro)
        CPROV="cryptopro"
        ;;
    csp-fns|cryptopro-fns)
        CPROV="csp-fns"
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
    ifcplugin)
        CPROV="ifcplugin"
        ;;
    "--devel")
        DEVEL="$1"
        ;;
    "--nogui")
        GUI="$1"
        ;;
    "--gui-install")
        GUIINSTALL="$1"
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

if [ -z "$CPROV" ] ; then
cat <<EOF >&2
ecryptomgr - crypto provider manager    Telegram: https://t.me/crypto_etersoft  https://wiki.etersoft.ru/CRYPTO@Etersoft

Run $ ecryptomgr --help to get help.
EOF
    exit 1
fi

echo "Doing $COMMAND $CPROV for $ARCH arch(es) ..."
# first arg
case $COMMAND in
    install)
            $SDIR/install_$CPROV.sh $DEVEL $GUI $GUIINSTALL $ARCH
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

