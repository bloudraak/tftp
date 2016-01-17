#!/bin/sh -e

if ! [ $(id -u) = 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

rm -Rf /volume1/tftp/*
rm -Rf /volume1/media/*
rm -Rf /volume1/install/*
rm -Rf /volume1/packages/*
