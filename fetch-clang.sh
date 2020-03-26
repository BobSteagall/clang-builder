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

if [ ! -e $LLVM_TARBALL ]
then
    echo "Downloading $LLVM_TARBALL... "
    wget $NEW_CLANG_URL/$LLVM_TARBALL

    if [ $? -ne 0 ]
    then
        wget $OLD_CLANG_URL/$LLVM_TARBALL
    fi
fi

if [ ! -e $CFE_TARBALL ]
then
    echo "Downloading $CFE_TARBALL... "
    wget $NEW_CLANG_URL/$CFE_TARBALL

    if [ $? -ne 0 ]
    then
        wget $OLD_CLANG_URL/$CFE_TARBALL
    fi
fi

if [ ! -e $CRT_TARBALL ]
then
    echo "Downloading $CRT_TARBALL... "
    wget $NEW_CLANG_URL/$CRT_TARBALL

    if [ $? -ne 0 ]
    then
        wget $OLD_CLANG_URL/$CRT_TARBALL
    fi
fi

if [ ! -e $CTX_TARBALL ]
then
    echo "Downloading $CTX_TARBALL... "
    wget $NEW_CLANG_URL/$CTX_TARBALL

    if [ $? -ne 0 ]
    then
        wget $OLD_CLANG_URL/$CTX_TARBALL
    fi
fi

if [ ! -e $LIB_TARBALL ]
then
    echo "Downloading $LIB_TARBALL... "
    wget $NEW_CLANG_URL/$LIB_TARBALL

    if [ $? -ne 0 ]
    then
        wget $OLD_CLANG_URL/$LIB_TARBALL
    fi
fi
