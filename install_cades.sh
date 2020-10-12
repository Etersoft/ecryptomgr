#!/bin/sh

DOWNLOADDIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
LOCALPATH="/opt/distr/CadesPlugin"
LOCALPATH2="/var/ftp/pvt/Linux/CryptoPro CSP/CADES"

CADESBASEURL="https://www.cryptopro.ru/sites/default/files/products/cades/current_release_2_0"

# TODO: only if not root
SUDO=sudo

BIARCH=''
[ "$(distro_info -a)" = "x86_64" ] && BIARCH="i586-"

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
}

download_file()
{
    local file="$(basename "$1")"
    curl --silent "$1" >$file
    [ -s "$file" ] && return
    rm -f "$file"
    return 1
}

get_distr_dir()
{
    local i
    for i in "$DOWNLOADDIR" "$LOCALPATH" "$LOCALPATH2" . ; do
        [ -f "$i/$1" ] && echo "$i" && return
    done

    # TODO: if /opt/dists is writeable
    # FIXME: do not output from this
    #info "Can't find $1 in $LOCALPATH or in the current dir, so start downloading ..."
    info "Downloading $CADESBASEURL/$1 to $(pwd) ..."
    download_file "$CADESBASEURL/$1" && echo "." && return

    return 1
}

unpack_tgz()
{
    epm assure erc || fatal
    local ar="$(get_distr_dir $1)"
    [ -n "$ar" ] || fatal "Can't find $1 in the current dir $(pwd). Download it and put in here or it $LOCALPATH."
    erc "$ar/$1"
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
    TARDIR="$1"
    if [ -d $TARDIR ] ; then
        echo "Note: Will use existed $TARDIR dir ..."
        # rm -rfv linux-amd64/
        # [ -d linux-amd64 ] && fatal "Remove linux-amd64 dir first"
    else
        unpack_tgz $TARDIR.tar.gz || fatal "Can't unpack"
    fi

    cd $TARDIR || fatal
}

if [ -n "$INSTALL64" ] ; then
    cd_to_dir cades_linux_amd64
    epmi cprocsp-pki-cades-64-*.rpm cprocsp-pki-plugin-64-*.rpm
fi

if [ -n "$INSTALL32" ] ; then
    cd_to_dir cades_linux_ia32
    epmi cprocsp-pki-cades-*.rpm cprocsp-pki-plugin-*.rpm
fi

