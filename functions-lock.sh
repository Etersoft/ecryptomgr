
# Uses INSTALL32 INSTALL64
# Examples:
#  install_req cades req cryptopro
#  install-req rutoken
# и пусть дополняет файл при каждом вызове:
#  install_addreq cryptopro req rutoken
#  install_addreq cryptopro req etoken
#  list_installed
#  check_installed <component>
# TODO: Диалоги
#  install если требуется что-то не установленное, предлагает установить
#  remove_req cryptopro
#  читает зависимости, смотрит, что требуется и предлагает удалять

# Запрещает раздельную установку разрядностей.

# ECMLOCKDIR=.

ARCHLIST="32 64 both"

dinfo()
{
    echo "$*"
    exit 1
}

fatal()
{
    echo "$*" >&2
    exit 1
}

get_arch()
{
    if [ "$INSTALL32" = "both" ] ; then
        echo "both"
        return
    fi

    [ "$INSTALL32" = "$INSTALL64" ] && fatal "logical error"

    if [ "$INSTALL32" = "32" ] ; then
        echo "32"
        return
    fi

    if [ "$INSTALL64" = "64" ] ; then
        echo "64"
        return
    fi
}

__check_installed()
{
    local prov="$1"
    local arch="$2"
    [ -n "$arch" ] || return 1

    [ -f "$ECMLOCKDIR/$arch/$prov" ]
}

# external
check_installed()
{
    __check_installed "$1" "$(get_arch)"
}

get_installed_arch()
{
    local prov="$1"
    local i
    for i in $ARCHLIST ; do
        __check_installed $prov $i || continue
        echo "$i"
        return 0
    done
}

check_conflicted()
{
    local prov="$1"
    local arch="$2"
    [ -n "$arch" ] || return 1

    local carch="$(get_installed_arch $prov)"
    if [ -n "$carch" ] && [ "$arch" != "$carch" ] ; then
        dinfo "Component $prov $arch arch conflicts with installed $prov $carch arch. Remove $prov firstly."
    fi
}

low_remove_req()
{
    local prov="$1"
    shift

    # remove all
    local i
    for i in $ARCHLIST ; do
        mkdir -p $ECMLOCKDIR/$i/
        rm -f "$ECMLOCKDIR/$i/$prov" 2>/dev/null
    done
}


__check_req()
{
    local nn="$(get_needed $*)"
    [ -n "$nn" ] && dinfo "Please install $nn firstly."
}

__install_addreq()
{
    local prov="$1"
    shift
    local req="$*"

    local i
    # add our reqs
    for i in $req ; do
        echo "$i" >>"$ECMLOCKDIR/$(get_arch)/$prov"
    done
}

# external
install_addreq()
{
    local prov="$1"
    shift
    shift
    local req="$*"

    [ -f "$ECMLOCKDIR/$(get_arch)/$prov" ] || fatal "Use install_req firstly"

    __check_req $req
    __install_addreq $prov $req
}

# вернёт неустановленные из переданного списка
get_needed()
{
    local i
    for i in $* ; do
        check_installed $i || echo "$i"
    done
}

# external
install_req()
{
    local prov="$1"
    shift
    shift
    local req="$*"

    # уже установлен тот же самый
    __check_installed $prov $INSTALL32 && dinfo "Component $prov for $INSTALL32 arch is already installed."
    __check_installed $prov $INSTALL64 && dinfo "Component $prov for $INSTALL64 arch is already installed."

    # конфликтует
    check_conflicted $prov $INSTALL32
    check_conflicted $prov $INSTALL64

    __check_req $req

    low_remove_req $prov
    touch "$ECMLOCKDIR/$(get_arch)/$prov"

    __install_addreq $prov $req
}

what_depend()
{
    local prov="$1"
    #local carch="$(get_installed_arch $prov)"
    local carch="$(get_arch)"
    local i
    for i in $(echo $ECMLOCKDIR/$carch/*) ; do
        cat "$i" | grep -q "^$prov$" && echo "$(basename $i)"
    done
}

# external
remove_req()
{
    local prov="$1"

    # установлен ли нужный компонент?
    check_installed $prov || dinfo "Component $prov for $(get_arch) arch is not installed."

    # если запрошенный на удаление компонент не установлен
    local carch="$(get_installed_arch $prov)"
    if [ "$(get_arch)" != "$carch" ] ; then
        dinfo "Request to remove $prov $(get_arch), but installed $prov $carch arch."
    fi

    local lr="$(what_depend $prov)"
    [ -n "$lr" ] && dinfo "Please remove $lr firstly."

    rm -f "$ECMLOCKDIR/$(get_arch)/$prov"
}

# external
list_installed()
{
    local i j
    for i in $(echo $ECMLOCKDIR/*) ; do
        for j in $(echo $i/*) ; do
            [ -f "$j" ] || continue
            echo "$(basename $j):$(basename $i)"
        done
    done
}
