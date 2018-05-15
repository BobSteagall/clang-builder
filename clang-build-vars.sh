#!/bin/bash
##
##  Script: clang-build-vars.sh
##
##  This script sets configuration and build variables that are used by
##  all the other scripts.  It is intended to be called by other scripts.
##  It assumes that TOP_DIR has been defined appropriately by the caller,
##  and that it is being sourced by the calling script.
##
##- Customize this variable to specify the version of Clang.  Normally the
##  version is determined by checking out a branch of the "clang-builder"
##  repo, rather than changing it here.
##
export CLANG_VERSION=6.0.X

##- Customize variable this to name the installation; the custom name
##  is displayed when a user invokes clang or clang++ with the -v flag
##  ("clang -v").
##
export CLANG_VENDOR="(KEWB Computing Build)"

##- Customize this variable to define the middle substring in the Clang
##  build triple.
##
export CLANG_CUSTOM_BUILD_TAG=kewb

##- Customize these variables to specify where this version of Clang will
##  be installed.
##
export CLANG_INSTALL_ROOT=/usr/local
export CLANG_INSTALL_PREFIX=$CLANG_INSTALL_ROOT/clang/$CLANG_VERSION

##- Customize this variable to specify the installation's time stamp.
##
export CLANG_TIME_STAMP=201805141000

##- Customize this variable if you want to change the arguments passed
##  to "make" that specify the number of threads used to build Clang.
##
export CLANG_BUILD_THREADS_ARG='-j4'

##- If building on Linux, customize these variables to specify the location
##  of the preferred GCC toolchain partner on this platform.  The most
##  important thing is that the variable GCC_INSTALL_PREFIX be defined;
##  it should have the same value as the --prefix flag used to configure
##  the GCC installation.
##
if [ `uname` == "Linux" ]
then
    export GCC_VERSION=8.1.0
    export GCC_INSTALL_PREFIX=/usr/local/gcc/$GCC_VERSION
fi

##- If building on Linux, customize this variable to specify the desired ABI
##  that libc++ will be linked against.  The choices currently supported by
##  these scripts are libstdc++ and libsupc++.
##
##  If you think that you'll be building executables that link to shared
##  objects that are themselves linked to libstdc++, then you should specify
##  "GCC_CXX_ABI=libstdc++" below.
##
##  On the other hand, if you'll be building everything using a single version
##  of Clang (this one), then it's OK to specify "GCC_CXX_ABI=libsupc++" below.
##
if [ `uname` == "Linux" ]
then
    export GCC_CXX_ABI=libsupc++
fi

##------------------------------------------------------------------------------
##      Do not change below this line!
##------------------------------------------------------------------------------
##
export CLANG_PLATFORM=`uname`

export LLVM_TARBALL=llvm-$CLANG_VERSION.src.tar.xz
export CFE_TARBALL=cfe-$CLANG_VERSION.src.tar.xz
export CRT_TARBALL=compiler-rt-$CLANG_VERSION.src.tar.xz
export CTX_TARBALL=clang-tools-extra-$CLANG_VERSION.src.tar.xz
export LIB_TARBALL=libcxx-$CLANG_VERSION.src.tar.xz
export ALL_TARBALLS="$LLVM_TARBALL $CFE_TARBALL $CRT_TARBALL $CTX_TARBALL $LIB_TARBALL"

export CLANG_TAG="${CLANG_VERSION//.}"
export CLANG_SRC_DIR=$TOP_DIR/llvm-$CLANG_VERSION
export CLANG_BLD_DIR=$TOP_DIR/llvm-$CLANG_VERSION-build
export CLANG_INSTALL_RELDIR=`echo $CLANG_INSTALL_PREFIX | sed 's:^/::'`

export LIBCXX_SRC_DIR=$TOP_DIR/libcxx-$CLANG_VERSION
export LIBCXX_BLD_DIR=$TOP_DIR/libcxx-$CLANG_VERSION-build

export CLANG_STAGEDIR=$TOP_DIR/dist

if [ "$CLANG_PLATFORM" == "FreeBSD" ]
then
    export CLANG_MAKE=gmake

elif [ "$CLANG_PLATFORM" == "Linux" ]
then
    export GCC_BIN=$GCC_INSTALL_PREFIX/bin/gcc
    export CLANG_MAKE=make
else
    echo "Unknown build platform!"
    exit 1
fi

if [ -z "$NO_PARSE_OPTS" ]
then
    if [ $# == "0" ]
    then
        DO_CLANG=YES
        DO_CXXLIB=YES
        DO_TEST=YES
    else
        while getopts ":clhtT" opt
        do
            case $opt in
                c ) DO_CLANG=YES ;;
                l ) DO_CXXLIB=YES ;;
                h ) echo "usage: $0 [-c] [-l] [-h] [-t|-T]"
                    exit 1 ;;
                t ) DO_TEST=YES ;;
                T ) DO_TEST= ;;
                * ) echo "usage: $0 [-c] [-l] [-h] [-t|-T]"
                    exit 1 ;;
            esac
        done
    fi
fi

