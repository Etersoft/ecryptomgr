#!/bin/sh

SDIR=$(dirname "$0")
[ "$SDIR" = "." ] && SDIR=$(pwd)

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
}


if [ "$1" = "-h" ] || [ "$1" == "--help" ] ; then
    cat <<EOF
Usage: $ ecryptomgr install|remove|clean|license|status|test [--devel] [--nogui] [cprocsp|itcs|rutoken|jacarta|cades] [32|64|both]

Commands:
    install - install crypto provider
    remove - uninstall crypto provider
    clean - remove old files after uninstall (wipe all related data)
    license - check license status
    status - check if crypto provider is installed
    test - run test (in development)

Crypto providers:
    cprocsp - CryptoPro
    itcs - ViPNet CSP
    rutoken - ruToken
    jacarta - JaCarta
    cades - CryptoPro CAdES Plugin

Options:
    --devel - install development packages too
    --nogui - don't install gui packages

Arch:
      32 - i586 packages (does not matter you have 32 or 64 bit OS)
      64 - x86_64 packages
    both - install both 32 and 64 bit (not supported yet for ViPNet CSP)

Download crypto provider distro files and run ecryptomgr install command with a appropiate args

Examples:
 $ ecryptomgr install cprocsp
 $ ecryptomgr install cprocsp both
 $ ecryptomgr install --devel itcs 32
EOF
    exit
fi

COMMAND="$1" && shift

DEVEL=''
[ "$1" = "--devel" ] && DEVEL="$1" && shift
GUI=''
[ "$1" = "--nogui" ] && GUI="$1" && shift


# TODO: detect by files in the current dir
# second arg
# TODO: change to cprocsp
CPROV=cryptopro
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
    jacarta|JaCarta)
        CPROV="jacarta"
        ;;
    cades|cadesplugin)
        CPROV="cades"
        ;;
    "")
        fatal "Run with --help."
        ;;
    *)
        fatal "Unknown provider $1. Run with --help."
        ;;
esac
shift

# TODO: detect by files in the current dir and current arch
# third arg
ARCH=""
case "$(distro_info -a)" in
    x86_64)
        ARCH=64
        ;;
    x86)
        ARCH=32
        ;;
    default)
        echo "Note: arch $(distro_info -a) is not autodetected."
        ;;
esac

for i in 32 64 both ; do
    [ "$1" = "$i" ] && ARCH=$1
done

[ "$1" = "--devel" ] && DEVEL="$1" && shift
[ "$1" = "--nogui" ] && GUI="$1" && shift

echo "Do $COMMAND $CPROV for $ARCH ..."
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

