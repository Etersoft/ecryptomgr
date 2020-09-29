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
Usage: $ ecryptomgr install|remove|clean|status|test [cprocsp|itcs] [32|64|both]

Just run this script in a dir with crypto provider distro.
Supported:
* CryptoPro
* ViPNet CSP

Example:
 $ ecryptomgr install cprocsp both
EOF
    exit
fi

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
        fatal "Unknown provider $2"
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
            $SDIR/install_$CPROV.sh $ARCH
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
    test|check)
            $SDIR/test_$CPROV.sh $ARCH
        ;;
    "")
        fatal "TODO: AI. run with --help"
        ;;
    *)
        fatal "Unknown command $1"
esac

