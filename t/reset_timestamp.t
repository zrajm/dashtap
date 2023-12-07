#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists  reset_timestamp  "Function 'reset_timestamp' exists"

##############################################################################

cd "$(mktemp -d)"
title "reset_timestamp: Fail when called with no argument"
STDOUT=""
STDERR="reset_timestamp: Bad number of args
"
(
    trap 'echo EXIT >&3' 0
    reset_timestamp; RC="$?"
    trap - 0
    echo FULL >&3
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "reset_timestamp: Fail when called with bad timestamp"
STDOUT=""
STDERR="timestamp_file: Bad TIMESTAMP 'NOT-A-TIMESTAMP'
"
(
    trap 'echo EXIT >&3' 0
    reset_timestamp "NOT-A-TIMESTAMP"; RC="$?"
    trap - 0
    echo FULL >&3
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "reset_timestamp: Check that mtime is reset"

# create file
FILE=testfile
echo "CONTENT" >"$FILE"
timestamp TIMESTAMP1 "$FILE"

# modify timestamp
chtime 2000-01-01 "$FILE"
timestamp TIMESTAMP2 "$FILE"
isnt "$TIMESTAMP1" "$TIMESTAMP2"   "Modified file timestamp"

# reset timestamp
reset_timestamp "$TIMESTAMP1"; RC="$?"
timestamp TIMESTAMP3 "$FILE"
is   "$TIMESTAMP1" "$TIMESTAMP3"   "Reset file timestamp"
is   "$RC"         0               "Exit status"

##############################################################################

done_testing

#[eof]
