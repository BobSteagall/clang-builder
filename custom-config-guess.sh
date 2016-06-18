#!/bin/bash
##
##  Script: custom-config-guess.sh
##
##  This second-level script returns the (possibly customized) Clang triple.
##
##- Get the directory this script resides in so we can be sure to run the
##  correct version of the original guessing script.
##
export THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
export ORIG_GUESS=$THIS_DIR/config.guess-orig

##- Update the name, if a custom build is specified.
##
if [ -z "$CLANG_CUSTOM_BUILD_TAG" ]
then
    echo `$ORIG_GUESS`
else
    echo `$ORIG_GUESS | sed -r s/-unknown-\|-pc-/-$CLANG_CUSTOM_BUILD_TAG-/`
fi
exit
