#!/bin/bash
##
##  Script: unpack-clang.sh
##
##  This second-level script unpacks the source tarballs, places everything
##  in the correct locations, and the performs any required patching.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables and command-line options for this build.
##
source ./clang-build-vars.sh

echo -n "Checking for required tarballs... "
for I in $ALL_TARBALLS
do
    if [ ! -e ./tarballs/$I ]
    then
        echo "Missing required tarball $I...   exiting build..."
        exit
    fi
done
echo "done"
echo ""

##- Unpack and fix up all compiler and tools tarballs.
##
if [ -n "$DO_CLANG" ]
then
    cd $TOP_DIR/tarballs
    mkdir -p tmp
    cd tmp

    echo -n "Checking for existing clang source directory $CLANG_SRC_DIR..."
    if [ ! -e $CLANG_SRC_DIR ]
    then
        echo ""
        echo "Upacking LLVM tarball: $LLVM_TARBALL..."
        tar -Jxf ../$LLVM_TARBALL
        SDIR=`ls`
        mv -vf $SDIR $CLANG_SRC_DIR
        rm -rf *

        echo ""
        echo "Upacking Clang compiler tarball: $CFE_TARBALL..."
        tar -Jxf ../$CFE_TARBALL
        SDIR=`ls`
        mv -vf $SDIR $CLANG_SRC_DIR/tools/clang
        rm -rf *

        echo ""
        echo "Upacking Clang extra-tools tarball: $CTX_TARBALL..."
        tar -Jxf ../$CTX_TARBALL
        SDIR=`ls`
        mv -vf $SDIR $CLANG_SRC_DIR/tools/clang/tools/extra
        rm -rf *

        echo ""
        echo "Upacking Compiler-RT tarball: $CRT_TARBALL..."
        tar -Jxf ../$CRT_TARBALL
        SDIR=`ls`
        mv -vf $SDIR $CLANG_SRC_DIR/projects/compiler-rt
        rm -rf *
    else
        echo " already exists"
    fi

    cd $TOP_DIR
    echo -n "Checking for existing clang build directory $CLANG_BLD_DIR... "
    if [ ! -e $CLANG_BLD_DIR ]
    then
        echo ""
        echo "Making new clang build directory..."
        mkdir -v $CLANG_BLD_DIR
    else
        echo " already exists"
    fi

    cd $CLANG_SRC_DIR
    echo -n "Checking for existence of custom clang patches... "
    if [ ! -e custom_fixes_done ]
    then
        echo ""
        echo "Applying custom clang patches..."

        cd cmake
        if [ ! -e config.guess-orig ]
        then
            echo "Applying top-level llvm config.guess customization..."
            cp -p config.guess config.guess-orig
            cp $TOP_DIR/custom-config-guess.sh ./config.guess
            chmod 755 ./config.guess*
        fi

        cd $CLANG_SRC_DIR/tools/clang/lib/Driver/ToolChains
        if [ ! -e ToolChains.cpp-orig ]
        then
            echo "Applying compiler driver patches..."
            cp -pv Linux.h Linux.h-orig
            patch Linux.h $TOP_DIR/patches/Linux.h.patch

            cp -pv Linux.cpp Linux.cpp-orig
            patch Linux.cpp $TOP_DIR/patches/Linux.cpp.patch

            cp -pv FreeBSD.cpp FreeBSD.cpp-orig
            patch FreeBSD.cpp $TOP_DIR/patches/FreeBSD.cpp.patch
        fi

        echo "Saving status..."
        cd $CLANG_SRC_DIR
        touch custom_fixes_done
    else
        echo " already applied"
    fi

    echo ""
    echo "CLANG unpacking completed!"
    echo ""
fi

##- Unpack and fix up LIBC++ tarball.
##
if [ -n "$DO_CXXLIB" ]
then
    cd $TOP_DIR/tarballs
    mkdir -p tmp
    cd tmp

    echo -n "Checking for libc++ source directory $LIBCXX_SRC_DIR..."
    if [ ! -e $LIBCXX_SRC_DIR ]
    then
        echo ""
        echo "Upacking libc++ tarball: $LIBCXX_TARBALL..."
        tar -Jxf ../$LIB_TARBALL
        SDIR=`ls`
        mv -vf $SDIR $LIBCXX_SRC_DIR
        rm -rf *
    else
        echo " already exists"
    fi

    cd $TOP_DIR
    echo -n "Checking for existing libc++ build directory $LIBCXX_BLD_DIR... "
    if [ ! -e $LIBCXX_BLD_DIR ]
    then
        echo ""
        echo "Making new libc++ build directory..."
        mkdir -v $LIBCXX_BLD_DIR
    else
        echo " already exists"
    fi

    echo ""
    echo "LIBC++ unpacking completed!"
    echo ""
fi
