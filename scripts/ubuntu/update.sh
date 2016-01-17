#!/bin/bash -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPTDIR=$( cd -P "$( dirname "$SOURCE" )" && pwd)
BASEDIR=$( dirname $( dirname "$SCRIPTDIR" ) )

TFTPBOOT="$BASEDIR/tftpboot"

mkdir -p "$TFTPBOOT/pxelinux.cfg/"
cp /usr/lib/syslinux/pxelinux.0 "$TFTPBOOT"
cp /usr/lib/syslinux/vesamenu.c32 "$TFTPBOOT"