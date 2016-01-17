#!/bin/sh -e

usage()
{
cat << EOF
usage: $0 options

This script prepares a Synology DSM 5.2 device to PXE boot several operating 
systems. It will download the distros and store them in the media shared 
folder. It will then mount the media and copy PXE boot files to the TFTP 
folder and the contents of the DVD to the mirrors folder.

OPTIONS:
    -h      Show this message.
    -i      The IP Address of the Synology DSM.
    -m      The shared folder where media, e.g. ISOs, should be stored.
    -t      The shared folder where TFTP, e.g. PXE Menus, should be stored.
    -p      The shared folder where packages will be stored. 
    -v      Verbose

EXAMPLE:

    sudo ./synology.sh -i 203.0.113.123 -m /volume1/media -t /volume1/tftp -p /volume1/packages 

EOF
}

if ! [ $(id -u) = 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

INSTALLIP=
TFTPBOOTDIR=
MEDIADIR=
INSTALLDIR=
while getopts “hi:m:t:p:v” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
             INSTALLIP=$OPTARG
             ;;
         m)
             MEDIADIR=$OPTARG
             ;;
         t)
             TFTPBOOTDIR=$OPTARG
             ;;
         p)
             INSTALLDIR=1
             ;;
         v)
             VERBOSE=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [ -z $INSTALLIP ]
then
     usage
     exit 1
fi
if [ -z $TFTPBOOTDIR ]
then
     usage
     exit 1
fi
if [ -z $MEDIADIR ]
then
     usage
     exit 1
fi
if [ -z $INSTALLDIR ]
then
     usage
     exit 1
fi
MENUPATH="$TFTPBOOTDIR/pxelinux.cfg/default"

#----------------------------------------------------------------------------
# Copy PXE files to TFTP store
#----------------------------------------------------------------------------
CURRENTDIR=$(pwd)
cd "../tftpboot/" 
cp -R * "$TFTPBOOTDIR"
cd $CURRENTDIR

#----------------------------------------------------------------------------
# Copy PXE files to TFTP store
#----------------------------------------------------------------------------
