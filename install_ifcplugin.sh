#!/bin/sh

DOWNLOADDIR="$(xdg-user-dir DOWNLOAD 2>/dev/null)"
LOCALPATH="/opt/distr/IFCPlugin"

BASEURL="https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib"

. $(dirname $0)/functions.sh

# Args: URL output_file
download_file()
{
    local file="$2"
# TODO: Невозможно локально проверить подлинность запрашивающего.
    eget -k "$1"
    [ -s "$file" ] && return
    rm -f "$file"
    return 1
}

get_distr_dir()
{
    local i
    DISTRPACKAGE=''
    for i in . "$DOWNLOADDIR" "$LOCALPATH" ; do
        [ -f "$i/$1" ] && DISTRPACKAGE="$i/$1" && return
    done

    # TODO: if /opt/dists is writeable
    # FIXME: do not output from this
    #info "Can't find $1 in $LOCALPATH or in the current dir, so start downloading ..."
    info "Downloading $1 from $BASEURL to $(pwd) ..."
    download_file "$BASEURL/$1" "$1" && DISTRPACKAGE="$(pwd)/$1" && return

    return 1
}

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

repack=''
pkgtype="$(epm print info -p)"
[ "$pkgtype" = "deb" ] || repack='--repack'

if [ -n "$INSTALL64" ] ; then
    pkgname="IFCPlugin-x86_64.$pkgtype"
    get_distr_dir $pkgname
    epm install $repack --scripts "$DISTRPACKAGE"
fi

if [ -n "$INSTALL32" ] ; then
    pkgname="IFCPlugin-i386.$pkgtype"
    get_distr_dir $pkgname
    epm install $repack --scripts "$DISTRPACKAGE"
fi

