#!/bin/bash
##
##  Script: fetch-clang.sh
##
##  This second-level script downloads the Clang sources, as well as any other
##  sources needed to build Clang.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the Clang-related variables for this build.
##
source ./clang-build-vars.sh

mkdir -p ./tarballs
cd ./tarballs

OLD_CLANG_URL=https://releases.llvm.org/$CLANG_VERSION
NEW_CLANG_URL=https://github.com/llvm/llvm-project/releases/download/llvmorg-$CLANG_VERSION

echo "Checking for required tarballs... "

fetch_file() {
    local REMOTE_URL=$1
    local TARBALL=$2

    if [ ! -e $TARBALL ]
    then
        echo "Downloading $TARBALL... "
        wget -t 3 $REMOTE_URL/$TARBALL

        if [ $? -ne 0 ]; then
            echo "Error retrieving $TARBALL... verify the URL and file name...  exiting"
            exit -1
        fi
    else
        echo "Already have $TARBALL"
    fi
}

fetch_file  $NEW_CLANG_URL $LLVM_TARBALL
fetch_file  $NEW_CLANG_URL $CFE_TARBALL
fetch_file  $NEW_CLANG_URL $CRT_TARBALL
fetch_file  $NEW_CLANG_URL $CTX_TARBALL
fetch_file  $NEW_CLANG_URL $LIB_TARBALL

