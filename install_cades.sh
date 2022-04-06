#!/bin/sh

DOWNLOADDIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
LOCALPATH="/opt/distr/CadesPlugin"
LOCALPATH2="/var/ftp/pvt/Linux/CryptoPro CSP/CADES"

CADESBASEURL="http://www.cryptopro.ru/products/cades/plugin/get_2_0"

# TODO: only if not root
SUDO=sudo

BIARCH=''
arch="$(epm print info -a)"
[ "$arch" = "x86_64" ] && BIARCH="i586-"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
}

# Args: URL output_file
download_file()
{
    local file="$2"
    # arch hack
    [ -n "$INSTALL32" ] && [ "$arch" = "x86_64" ] && ARCHCMD=i586 || ARCHCMD=''
    $ARCHCMD eget -k -U "$1"
    [ -s "$file" ] && return
    rm -f "$file"
    return 1
}

get_distr_dir()
{
    local i
    DISTRTAR=''
    for i in "$DOWNLOADDIR" "$LOCALPATH" "$LOCALPATH2" . ; do
        [ -f "$i/$1" ] && DISTRTAR="$i/$1" && return
    done

    # TODO: if /opt/dists is writeable
    # FIXME: do not output from this
    #info "Can't find $1 in $LOCALPATH or in the current dir, so start downloading ..."
    info "Downloading $1 from $CADESBASEURL to $(pwd) ..."
    download_file "$CADESBASEURL" "$1" && DISTRTAR="$(pwd)/$1" && return

    return 1
}

unpack_tgz()
{
    epm assure erc || fatal
    get_distr_dir "$1"
    [ -n "$DISTRTAR" ] || fatal "Can't find $1 in the current dir $(pwd). Download it and put in here or in $LOCALPATH."
    erc "$DISTRTAR"
}


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
        fatal "Both arches is not supported due file conflicts"
        INSTALL32="$1"
        INSTALL64="$1"
        ;;
    *)
        fatal "Run with 32|64|both param"
esac


cd_to_dir()
{
    TARDIR="$1.tar"
    if [ -d $TARDIR ] ; then
        echo "Note: Will use existed $TARDIR dir ..."
        # rm -rfv linux-amd64/
        # [ -d linux-amd64 ] && fatal "Remove linux-amd64 dir first"
    else
        unpack_tgz $TARDIR.gz || fatal "Can't unpack"
    fi

    cd $TARDIR || fatal
}

if [ -n "$INSTALL64" ] ; then
    cd_to_dir cades-linux-amd64
    epmi --scripts cprocsp-pki-cades-64-*.rpm cprocsp-pki-plugin-64-*.rpm
fi

if [ -n "$INSTALL32" ] ; then
    cd_to_dir cades-linux-ia32
    epmi --scripts cprocsp-pki-cades-*.rpm cprocsp-pki-plugin-*.rpm
fi

