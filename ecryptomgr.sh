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
Usage: $ ecryptomgr install|remove|clean|license|status|test [--devel] [cprocsp|itcs] [32|64|both]

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

Options:
    --devel - install development packages too

Arch:
    32 - i586 packages (does not matter you have 32 or 64 bit OS)
    64 - x86_64 packages
    both - install both 32 and 64 bit (not supported yet for ViPNet CSP)

Download crypto provider distro files and run ecryptomgr install command with a appropiate args

Examples:
 $ ecryptomgr install cprocsp
 $ ecryptomgr install cprocsp both
 $ ecryptomgr install itcs 32
EOF
    exit
fi

DEVEL=''
[ "$2" = "--devel" ] && DEVEL="$2" && shift

# TODO: detect by files in the current dir
# second arg
# TODO: change to cprocsp
CPROV=cryptopro
case "$2" in
    cprocsp|cryptopro)
        CPROV="cryptopro"
        ;;
    itcs|vipnet)
        CPROV="itcs"
        ;;
    *)
        fatal "Unknown provider $2. Run with --help."
        ;;
esac

# TODO: detect by files in the current dir and current arch
# third arg
ARCH=""
for i in 32 64 both ; do
    [ "$3" = "$i" ] && ARCH=$3
done

# first arg
case $1 in
    install)
            $SDIR/install_$CPROV.sh $DEVEL $ARCH
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
        fatal "Unknown command $1. Run with --help"
esac

