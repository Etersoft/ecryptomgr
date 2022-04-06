#!/bin/sh

. $(dirname $0)/functions.sh


echo "All cert store will be cleaned!"
[ "$1" != "--sure" ] || fatal "Run with --sure to real cleaning."

ecryptomgr uninstall itcs both

$SUDO rm -rfv /etc/opt/itcs/
$SUDO rm -rfv /var/opt/itcs/
