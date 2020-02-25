#!/bin/bash
##
##  Script: pack-clang.sh
##
##  This top-level script makes a compressed tarball (TGZ) from the files
##  installed into the staging directory.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

##- Retrieve useful information about the platform.
##
PLATFORM_INFO=(`$TOP_DIR/system-type.sh -f`)
PLATFORM_OS=${PLATFORM_INFO[0]}
PLATFORM_NAME=${PLATFORM_INFO[1]}
PLATFORM_ARCH=${PLATFORM_INFO[4]}
PLATFORM_ARCH=${PLATFORM_INFO[5]}

if [ "$PLATFORM_OS" = "FreeBSD" ] && [ "$PLATFORM_ARCH" = "amd64" ]; then
    PLATFORM_ARCH=x86_64
fi

PLATFORM_FULL="${PLATFORM_DESC}-${PLATFORM_ARCH}"

##- Make the main binary tarball.
##
mkdir -p ./packages
DEST_DIR=`readlink -f ./packages`
TARBALL=$DEST_DIR/kewb-clang${CLANG_TAG}-${PLATFORM_FULL}.tgz
rm -rf $TARBALL

cd $CLANG_STAGEDIR

tar -zcvf $TARBALL *

touch -h -t $CLANG_TIME_STAMP $TARBALL
