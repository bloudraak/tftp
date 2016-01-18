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

    sudo ./synology.sh -i "203.0.113.123" -m "/volume1/media" -t "/volume1/tftp" -p "/volume1/packages" 

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
             INSTALLDIR=$OPTARG
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

rm -Rf "$TFTPBOOTDIR/pxelinux.cfg"

MENUPATH="$TFTPBOOTDIR/pxelinux.cfg/default"

#----------------------------------------------------------------------------
# Copy PXE files to TFTP store
#----------------------------------------------------------------------------
CURRENTDIR=$(pwd)
cd "../tftpboot/" 
cp -R * "$TFTPBOOTDIR"
cd $CURRENTDIR

#----------------------------------------------------------------------------
# Prepare CentOS
#----------------------------------------------------------------------------
OS="CentOS"
OS_TEXT="CentOS"
VERSION="7.2";
ARCH="x86_64";
ARCH_TEXT="64-bit";
URI="http://192.168.1.4/depot/centos/7/CentOS-7-x86_64-Everything-1511.iso";
# URI="http://mirror.nexcess.net/CentOS/7.2.1511/isos/x86_64/CentOS-7-x86_64-Everything-1511.iso";
MEDIAPATH="$MEDIADIR/$OS/$VERSION/$ARCH/CentOS-7-x86_64-DVD-1511.iso"
BOOTDIR="$TFTPBOOTDIR/images/$OS/$VERSION/$PLATFORM/$ARCH";
PACKAGESDIR="$INSTALLDIR/$OS/$VERSION/$ARCH";

if [ ! -f "$MEDIAPATH" ]; then
    mkdir -p "$MEDIADIR/$OS/$VERSION/$ARCH"
    wget "$URI" -O "$MEDIAPATH"
fi

mkdir -p /mnt/loop
mount -o loop -t iso9660 "$MEDIAPATH" /mnt/loop

if [ ! -d "$BOOTDIR" ]; then
	mkdir -p "$BOOTDIR"
	cp /mnt/loop/images/pxeboot/* "$BOOTDIR"
fi
if [ ! -d "$PACKAGESDIR" ]; then
	mkdir -p "$PACKAGESDIR"
	cp -R /mnt/loop/* "$PACKAGESDIR"
fi
umount /mnt/loop

cat << EOF >> "$MENUPATH"
MENU BEGIN $OS_TEXT
MENU TITLE $OS_TEXT 
    LABEL Previous
    MENU LABEL Previous Menu
    TEXT HELP
    Return to previous menu
    ENDTEXT
    MENU EXIT
    MENU SEPARATOR
    MENU INCLUDE pxelinux.cfg/$OS/$OS.menu
MENU END 
EOF

mkdir -p "$TFTPBOOTDIR/pxelinux.cfg/$OS"
if [ ! -f "$TFTPBOOTDIR/pxelinux.cfg/$OS/$OS.menu" ]; then
cat << EOF >> "$TFTPBOOTDIR/pxelinux.cfg/$OS/$OS.menu"
LABEL 2
    MENU LABEL $OS_TEXT $VERSION ($ARCH_TEXT)
    KERNEL images/$OS/$VERSION/$ARCH/vmlinuz
    APPEND url --url http://$INSTALLIP/$OS/$VERSION/$ARCH/ lang=us keymap=us ip=dhcp ksdevice=eth0 noipv6 initrd=images/$OS/$VERSION/$ARCH/initrd.img ramdisk_size=10000
    TEXT HELP
    Install $OS $VERSION ($ARCH_TEXT)
    ENDTEXT
EOF
fi

