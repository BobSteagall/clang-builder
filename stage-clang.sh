#!/bin/bash
##
##  Script: stage-clang.sh
##
##  This top-level script installs the new Clang build into a staging location
##  suitable for building a distribution tarball and/or RPM.
##
##- Make sure we're in the same directory as this script.
##
export TOP_DIR="$(cd "$(dirname "$0")" && pwd)"
cd $TOP_DIR

##- Get the CLANG-related variables for this build.
##
source ./clang-build-vars.sh

##- Make the dummy installation directory.
##
mkdir -p $CLANG_STAGEDIR/$CLANG_INSTALL_SCRIPTS_RELDIR

##- Install LLVM and CLANG.
##
if [ -n "$DO_CLANG" ]
then
    cd $CLANG_BLD_DIR
    $CLANG_MAKE install DESTDIR=$CLANG_STAGEDIR

    cd $CLANG_STAGEDIR/$CLANG_INSTALL_PREFIX/lib
    chmod 644 lib*.a *.so

    cd $CLANG_STAGEDIR/$CLANG_INSTALL_PREFIX/bin
    ln -vf -s clang cc
    ln -vf -s clang++ c++

    cd $TOP_DIR

    if [ "$CLANG_PLATFORM" == "FreeBSD" ]
    then
        sed "s|ABCXYZ|$CLANG_INSTALL_PREFIX|"   \
            ./setenv-for-clang-freebsd.sh >     \
            ./setenv-for-clang$CLANG_TAG.sh

    elif [ "$CLANG_PLATFORM" == "Linux" ]
    then
        sed "s|ABCXYZ|$CLANG_INSTALL_PREFIX|"   \
            ./setenv-for-clang-linux.sh >       \
            ./setenv-for-clang-linux-tmp.sh

        sed "s|DEFUVW|$GCC_INSTALL_PREFIX|"     \
            ./setenv-for-clang-linux-tmp.sh >   \
            ./setenv-for-clang$CLANG_TAG.sh

        rm -f ./setenv-for-clang-linux-tmp.sh
    fi

    chmod 755 ./setenv-for-clang$CLANG_TAG.sh
    mv -vf ./setenv-for-clang$CLANG_TAG.sh  $CLANG_STAGEDIR/$CLANG_INSTALL_SCRIPTS_RELDIR
    cp -v ./restore-default-paths.sh ./restore-default-paths-clang$CLANG_TAG.sh
    chmod 755 ./restore-default-paths-clang$CLANG_TAG.sh
    mv -vf ./restore-default-paths-clang$CLANG_TAG.sh  $CLANG_STAGEDIR/$CLANG_INSTALL_SCRIPTS_RELDIR

    cd $CLANG_STAGEDIR/$CLANG_INSTALL_SCRIPTS_RELDIR

    ln -vf -s $CLANG_INSTALL_PREFIX/bin/clang   clang$CLANG_TAG
    ln -vf -s $CLANG_INSTALL_PREFIX/bin/clang++ clang++$CLANG_TAG

    echo ""
    echo "CLANG installation completed!"
fi

##- Install LIBCXX
##
if [ -n "$DO_CXXLIB" ]
then
    cd $LIBCXX_BLD_DIR
    $CLANG_MAKE install DESTDIR=$CLANG_STAGEDIR

    cd $CLANG_STAGEDIR/$CLANG_INSTALL_PREFIX/lib

    rm -rf libc++.so.1 libc++.so

    mv -v libc++.so.1.0 libc++.so.1.0.$CLANG_TAG
    ln -v -s libc++.so.1.0.$CLANG_TAG libc++.so.1.0
    ln -v -s libc++.so.1.0 libc++.so.1
    ln -v -s libc++.so.1 libc++.so
    chmod 644 libc++.so.1.0.$CLANG_TAG

    echo ""
    echo "LIBC++ installation completed!"
fi

##- Touch all the files to have the desired timestamp.
##
cd $CLANG_STAGEDIR
find $CLANG_STAGEDIR/$CLANG_INSTALL_RELDIR -exec touch -h -t $CLANG_TIME_STAMP {} \+
find $CLANG_STAGEDIR/$CLANG_INSTALL_SCRIPTS_RELDIR -exec touch -h -t $CLANG_TIME_STAMP {} \+
echo ""
