#!/bin/sh


BIARCH=''
[ "$(epm print info -a)" = "x86_64" ] && BIARCH="i586-"


# copied from /etc/init.d/outformat (ALT Linux)

# FIXME on Android: FIX ME! implement ttyname_r() bionic/libc/bionic/stubs.c:366
inputisatty()
{
	# check stdin
	#tty -s 2>/dev/null
	test -t 0
}

isatty()
{
	# check stdout
	test -t 1
}

isatty2()
{
	# check stderr
	test -t 2
}

check_tty()
{
	isatty2 || return

	# Set a sane TERM required for tput
	[ -n "$TERM" ] || TERM=dumb
	export TERM

	# egrep from busybox may not --color
	# egrep from MacOS print help to stderr
	if grep -E --help 2>&1 | grep -q -- "--color" ; then
		export EGREPCOLOR="--color"
	fi

	which tput >/dev/null 2>/dev/null || return
	# FreeBSD does not support tput -S
	echo | tput -S >/dev/null 2>/dev/null || return
	[ -z "$USETTY" ] || return
	export USETTY=1
}

: ${BLACK:=0} ${RED:=1} ${GREEN:=2} ${YELLOW:=3} ${BLUE:=4} ${MAGENTA:=5} ${CYAN:=6} ${WHITE:=7}

set_boldcolor()
{
	[ "$USETTY" = "1" ] || return
	{
		echo bold
		echo setaf $1
	} |tput -S
}

restore_color()
{
	[ "$USETTY" = "1" ] || return
	{
		echo op; # set Original color Pair.
		echo sgr0; # turn off all special graphics mode (bold in our case).
	} |tput -S
}

echover()
{
    [ -z "$verbose" ] && return
    echo "$*" >&2
}

# echo string without EOL
echon()
{
	# default /bin/sh on MacOS does not recognize -n
	/bin/echo -n "$*"
}




fatal()
{
    echo "FATAL: $*" >&2
    exit 1
}

info()
{
    echo "$*"
}

#epm assure eepm || fatal

# epm remove/install
epmthird()
{
    epm --scripts
}


is_root()
{
	local EFFUID="$(id -u)"
	[ "$EFFUID" = "0" ]
}



# if we have not sudo, returns 1 and set SUDO variable to fatal
SUDO_TESTED=''
SUDO_CMD='sudo'
set_sudo()
{
	local nofail="$1"

	# cache the result
	[ -n "$SUDO_TESTED" ] && return "$SUDO_TESTED"
	SUDO_TESTED="0"

	SUDO=""
	# skip SUDO if disabled
	[ -n "$EPMNOSUDO" ] && return
	if [ "$DISTRNAME" = "Cygwin" ] || [ "$DISTRNAME" = "Windows" ] ; then
		# skip sudo using on Windows
		return
	fi

	# if we are root, do not need sudo
	is_root && return

	# start error section
	SUDO_TESTED="1"

	if ! which $SUDO_CMD >/dev/null 2>/dev/null ; then
		[ "$nofail" = "nofail" ] || SUDO="fatal 'Can't find sudo. Please install and tune sudo ('# epm install sudo') or run epm under root.'"
		return "$SUDO_TESTED"
	fi

	# if input is a console
	if inputisatty && isatty && isatty2 ; then
		if ! $SUDO_CMD -l >/dev/null ; then
			[ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only without password sudo is supported in non interactive using). Please run epm under root.'"
			return "$SUDO_TESTED"
		fi
	else
		# use sudo if one is tuned and tuned without password
		if ! $SUDO_CMD -l -n >/dev/null 2>/dev/null ; then
			[ "$nofail" = "nofail" ] || SUDO="fatal 'Can't use sudo (only without password sudo is supported). Please run epm under root.'"
			return "$SUDO_TESTED"
		fi
	fi

	SUDO_TESTED="0"
	SUDO="$SUDO_CMD --"
	# check for < 1.7 version which do not support -- (and --help possible too)
	$SUDO_CMD -h 2>/dev/null | grep -q "  --" || SUDO="$SUDO_CMD"

}



check_tty
set_sudo
