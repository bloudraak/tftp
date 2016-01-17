#!/bin/sh -e

TFTPBOOTDIR="/volume1/tftp"
MEDIADIR="/volume1/media"
INSTALLDIR="/volume1/mirrors"

#
# Copy PXE files to TFTP store
#
CURRENTDIR=$(pwd)
cd "../tftpboot/" 
cp -R * "$TFTPBOOTDIR"
cd $CURRENTDIR