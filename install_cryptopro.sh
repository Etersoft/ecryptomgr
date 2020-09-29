#!/bin/sh

# see https://www.altlinux.org/КриптоПро

LOCALPATH="/var/ftp/pvt/Linux/CryptoPro CSP/5.0/5.0.11453"
# TODO: only if not root
SUDO=sudo

fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
}

unpack_tgz()
{
    epm assure erc || fatal
    local i
    for i in "$LOCALPATH" . ; do
        [ -s "$i/$1" ] || continue
        erc "$i/$1"
        return
    done
    fatal "Can't find $1 in the current dir $(pwd). Download it and put in here,"
}

install_lsb64()
{
    epmi lsb-release lsb-init
    epme i586-lsb-core --nodeps
    epm reinstall lsb-core || fatal
}

install_lsb32()
{
    epmi lsb-release lsb-init
    case $(distro_info -d) in
        ALTLinux)
            ;;
        *)
            fatal "$(distro_info -e) is not yet supported"
            ;;
    esac

    # Workaround for https://bugzilla.altlinux.org/show_bug.cgi?id=38855
    # Следующие пакеты имеют неудовлетворенные зависимости:
    #    lsb-cprocsp-rdr.32bit: Для установки требует: lsb-core-ia32 (>= 3.0) но пакет не может быть установлен
    case $(distro_info -v) in
        Sisyphus)
            fatal "TODO: unsupported"
            ;;
        p9)
            # HACK:
            epm assure eget

            # for install deps
            epmi i586-lsb-core
            epme i586-lsb-core --nodeps

            # FIXME: --force and apt-get are incompatible
            # epmi download: use apt-get after download
            #epmi http://ftp.basealt.ru/pub/distributions/ALTLinux/p9/branch/i586/RPMS.classic/lsb-core-4.0-alt12.i586.rpm
            eget http://ftp.basealt.ru/pub/distributions/ALTLinux/p9/branch/i586/RPMS.classic/lsb-core-4.0-alt12.i586.rpm
            epme lsb-core --nodeps
            epmi lsb-core-4.0-alt12.i586.rpm
            ;;
        p8)
            # HACK:
            epm assure eget

            # for install deps
            epmi i586-lsb-core
            epme i586-lsb-core --nodeps
            #epmi http://ftp.basealt.ru/pub/distributions/ALTLinux/p8/branch/i586/RPMS.classic/lsb-core-4.0-alt5.i586.rpm
            eget http://ftp.basealt.ru/pub/distributions/ALTLinux/p8/branch/i586/RPMS.classic/lsb-core-4.0-alt5.i586.rpm
            epme lsb-core --nodeps
            epmi lsb-core-4.0-alt5.i586.rpm
            ;;
        *)
            fatal "$(distro_info -e) is not yet supported"
            ;;
    esac
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
        INSTALL32="$1"
        INSTALL64="$1"
        ;;
    *)
        fatal "Run with 32|64|both param"
esac

if [ -n "$(epmqp cprocsp)" ] ; then
    info "You are already have cprocsp packages installed. Run uninstall_cryptopro.sh first (or errors are possible)."
fi


if [ -n "$INSTALL64" ] ; then
    if [ -d linux-amd64 ] ; then
        echo "Note: Will use existed linux-amd64 ..."
        # rm -rfv linux-amd64/
        # [ -d linux-amd64 ] && fatal "Remove linux-amd64 dir first"
    else
        unpack_tgz linux-amd64.tgz || fatal "Can't unpack"
    fi
    cd linux-amd64 || fatal
    install_lsb64 || fatal

    echo
    echo "Installing x86_64 packages ..."

    $SUDO bash ./install.sh || fatal


    if [ -n "$DEVEL" ] ; then
         epmi lsb-cprocsp-devel-*.noarch.rpm
    fi

    # PKCS#11
    epmi lsb-cprocsp-pkcs11-64-*.x86_64.rpm

    # ruToken support
    # instead of cryptopro-preinstall, see https://www.altlinux.org/КриптоПро#Установка_пакетов
    epmi pcsc-lite-rutokens pcsc-lite-ccid librtpkcs11ecp
    epmi libpangox-compat opensc newt52
    # TODO:
    # Почему у нас токены через pcscd?
    # Зачем тогда cprocsp-rdr-rutoken ?
    # Какие пакеты нужны для токена? Отделить отсюда?
    # Ответ: Современные аппаратные и программно-аппаратные хранилища ключей, такие как Рутокен ЭЦП или eSmart ГОСТ, поддерживаются через интерфейс PCSC
    epmi pcsc-lite
    serv pcscd on
    epmi cprocsp-rdr-rutoken-64-*.x86_64.rpm cprocsp-rdr-pcsc-64-*.x86_64.rpm || fatal

    epmi libgtk+2 libSM
    epmi cprocsp-cptools-gtk-64-*.x86_64.rpm
    epmi cprocsp-rdr-gui-gtk-64-*.x86_64.rpm
    cd -
    # needed for unstalled
    # rm -rfv linux-amd64
fi

if [ -n "$INSTALL32" ] ; then
    if [ -d linux-ia32 ] ; then 
        echo "Note: Will use existed linux-ia32 ..."
        # rm -rfv linux-ia32/
        # [ -d linux-ia32 ] && fatal "Remove linux-ia32 dir first"
    else
        unpack_tgz linux-ia32.tgz || fatal "Can't unpack"
    fi

    cd linux-ia32 || fatal
    install_lsb32 || fatal

    echo
    echo "Installing i686 packages ..."

    if [ "$INSTALL32" = "both" ] ; then
        # hack, otherwise install.sh removed 64bit packages
        epmi cprocsp-curl-*.i686.rpm cprocsp-rdr-rutoken-*.i686.rpm lsb-cprocsp-rdr-*.i686.rpm \
             lsb-cprocsp-kc1-*.i686.rpm lsb-cprocsp-capilite-*.i686.rpm cprocsp-rdr-pcsc-*.i686.rpm
    else
        $SUDO i586 bash ./install.sh || fatal
    fi

    if [ -n "$DEVEL" ] ; then
         epmi lsb-cprocsp-devel-*.noarch.rpm
    fi

    epmi i586-glibc-nss i586-glibc-gconv-modules
    epm installed sssd-client && epmi i586-sssd-client

    # PKCS#11
    epmi lsb-cprocsp-pkcs11-*.i686.rpm

    # ruToken support
    # instead of cryptopro-preinstall, see https://www.altlinux.org/КриптоПро#Установка_пакетов
    epmi i586-pcsc-lite-rutokens i586-pcsc-lite-ccid i586-librtpkcs11ecp i586-libpangox-compat || fatal
    # TODO: install if not both?
    #opensc pcsc-lite newt52 || fatal
    # epmi pcsc-lite-rutokens pcsc-lite-ccid librtpkcs11ecp
    epmi cprocsp-rdr-rutoken-*.i686.rpm cprocsp-rdr-pcsc-*.i686.rpm || fatal

    epmi i586-libgtk+2 i586-libSM
    epmi cprocsp-cptools-gtk-*.i686.rpm
    epmi cprocsp-rdr-gui-gtk-*.i686.rpm
    cd -
    # needed for uninstall
    # rm -rfv linux-ia32
fi
