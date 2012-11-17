#!/bin/sh
# Tagfilediff.sh - Compare tagfiles from different Slackware versions.
#
# This is free software, released under the terms of the Zlib License:
#
# Copyright (C) 2012 Daniele Moriya Martins de Souza - A.K.A. Aiyumi Moriya
# (aiyumi DOT br AT gmail DOT com)
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
# claim that you wrote the original software. If you use this software
# in a product, an acknowledgment in the product documentation would be
# appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
# misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#

# ==============================================================================
# Functions 
# ==============================================================================

compareTagfiles() { # begin compareTagfiles
    tagfile1="$1"
    tagfile2="$2"
    echo "Comparing '$tagfile1' and '$tagfile2'"
    cut -f1 -d: "$tagfile1" > old_tmp
    cut -f1 -d: "$tagfile2" > new_tmp
    diff -wB --suppress-common-lines old_tmp new_tmp | sed \
        -e "s@^<@Removed@g" -e "s@^>@Added@g"

    # Remove the temporary files
    rm -f old_tmp new_tmp
} # end compareTagfiles

# ==============================================================================
# Main program
# ==============================================================================

if [ $# -lt 2 ]; then
    echo 2>&1 "Usage: $0 old_slack_dir new_slack_dir"
    echo 2>&1 "OR"
    echo 2>&1 "$0 old_tagfile new_tagfile"
    echo 2>&1 ""
    echo 2>&1 "Examples:""
    echo 2>&1 "This will compare the tagfiles in the whole Slackware trees:""
    echo 2>&1 "$0 slackware-13.37/slackware slackware-14.0/slackware"
    echo 2>&1 "And this will compare two individual tagfiles:"
    echo 2>&1 "$0 slackware-13.37/slackware/ap/tagfile slackware-14.0/slackware/ap/tagfile"
    exit 1;
fi

if [ -f $1 -a $(basename $1) = "tagfile" \
    -a -f $2 -a $(basename $2) = "tagfile" ]; then
compareTagfiles "$1" "$2"
else
    for d in a ap d e f k kde kdei l n t tcl x xap xfce y; do
        dir1="$1/$d"
        dir2="$2/$d"
        if [ ! -d $dir1 ]; then
            echo 2>&1 "Error: directory '$dir1' does not exist."
            exit 1
        fi
        if [ ! -d $dir2 ]; then
            echo 2>&1 "Error: directory '$dir2' does not exist."
            exit 1
        fi

        tagfile1="$dir1/tagfile"
        tagfile2="$dir2/tagfile"
        if [ ! -f "$tagfile1" ]; then
            echo 2>&1 "Error: file '$f' does not exist."
            exit 1
        fi
        if [ ! -f "$tagfile2" ]; then
            echo 2>&1 "Error: file '$tagfile2' does not exist."
            exit 1
        fi

        compareTagfiles $tagfile1 $tagfile2

    done
fi
