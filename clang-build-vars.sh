#!/bin/bash
##
##  Script: clang-build-vars.sh
##
##  This script sets configuration and build variables that are used by
##  all the other scripts.  It is intended to be called by other scripts.
##  It assumes that TOP_DIR has been defined appropriately by the caller,
##  and that it is being sourced by the calling script.
##
##- Customize this variable to specify the version of Clang that you want
##  to download and build (replace the 'X.Y' with the minor version and
##  patch level numbers).
##
export CLANG_VERSION=10.X.Y

##- Customize this variables to specify where this version of Clang will
##  be installed.
##
export CLANG_INSTALL_PREFIX=/usr/local/clang/$CLANG_VERSION

##- Customize this variable to specify where to install the scripts that
##  set various important environment variables for using this custom
##  Clang build in day-to-day work.
##
export CLANG_INSTALL_SCRIPTS_PREFIX=/usr/local/bin

##- Customize this variable to specify the installation's time stamp.
##
export CLANG_TIME_STAMP=202208081000

##- Customize this variable if you want to change the arguments passed
##  to "make" that specify the number of threads used to build Clang.
##
export CLANG_BUILD_THREADS_ARG='-j16'

##- If building on Linux, customize these variables to specify the location
##  of the preferred GCC toolchain partner on this platform.  It can be the
##  default system compiler, but also a custom GCC that you have built using
##  gcc-builder.
##
##  The most important thing is that the variable GCC_INSTALL_PREFIX gets
##  defined; further, it should have the same value as the --prefix flag
##  used to configure the GCC installation.
##
if [ `uname` == "Linux" ]
then
    export GCC_VERSION=9.5.0
    export GCC_INSTALL_PREFIX=/opt/tools/gcc/$GCC_VERSION
fi

##- If building on Linux, customize this variable to specify the desired ABI
##  support library that libc++ will be linked against.  The choices currently
##  supported by these scripts are libstdc++ and libsupc++.
##
##  If you think that you'll be building executables that link to shared
##  objects that are themselves linked to libstdc++, then you should specify
##  "GCC_CXX_ABI=libstdc++" below.
##
##  On the other hand, if you'll be building everything using a single version
##  of Clang (this one), and everything you link to is also built using that
##  version of Clang, then it's OK to specify "GCC_CXX_ABI=libsupc++" below.
##
if [ `uname` == "Linux" ]
then
    export GCC_CXX_ABI=libsupc++
fi

##------------------------------------------------------------------------------
##      Maybe change below this line, if you have a good reason.
##------------------------------------------------------------------------------
##
##- Customize variable this to name the installation; the custom name
##  is displayed when a user invokes clang/clang++ with the -v or --version
##  flags ("clang -v").
##
export CLANG_VENDOR="(KEWB Computing Build)"

##- Customize this variable to define the middle substring in the Clang
##  build triple.
##
export CLANG_CUSTOM_BUILD_TAG=kewb

##------------------------------------------------------------------------------
##      Do not change below this line!
##------------------------------------------------------------------------------
##
export CLANG_PLATFORM=`uname`

export LLVM_TARBALL=llvm-$CLANG_VERSION.src.tar.xz
export CFE_TARBALL=clang-$CLANG_VERSION.src.tar.xz
export CRT_TARBALL=compiler-rt-$CLANG_VERSION.src.tar.xz
export CTX_TARBALL=clang-tools-extra-$CLANG_VERSION.src.tar.xz
export LIB_TARBALL=libcxx-$CLANG_VERSION.src.tar.xz
export ALL_TARBALLS="$LLVM_TARBALL $CFE_TARBALL $CRT_TARBALL $CTX_TARBALL $LIB_TARBALL"

export CLANG_TAG="${CLANG_VERSION//.}"
export CLANG_SRC_DIR=$TOP_DIR/llvm-$CLANG_VERSION
export CLANG_BLD_DIR=$TOP_DIR/llvm-$CLANG_VERSION-build
export CLANG_INSTALL_RELDIR=${CLANG_INSTALL_PREFIX#/}
export CLANG_INSTALL_SCRIPTS_RELDIR=${CLANG_INSTALL_SCRIPTS_PREFIX#/}

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
    echo "Error: unknown build platform!"
    exit 1
fi

if [ `uname` == "Linux" ] && [ ! -e $GCC_INSTALL_PREFIX ];
then
    echo "Error: can't find GCC install prefix '$GCC_INSTALL_PREFIX'"
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

##- If building on Linux, we need to locate the ABI headers.
##
if [ `uname` == "Linux" ]
then
    ##- Get the location of the system headers for this GCC distribution; the
    ##  ABI headers are usually in the first two directories.
    ##
    GCC_DIRS=`echo | $GCC_BIN -Wp,-v -x c++ - -fsyntax-only 2>&1 | grep "^ /"`
    GCC_DIR_ARR=( $GCC_DIRS )
    GCC_DIR0=`readlink -f ${GCC_DIR_ARR[0]}`
    GCC_DIR1=`readlink -f ${GCC_DIR_ARR[1]}`
    GCC_CXX_ABI_INC_PATH="$GCC_DIR0;$GCC_DIR1"
fi
