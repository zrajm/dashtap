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
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    reset_timestamp; RC="$?"; EXEC=FULL
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
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    reset_timestamp "NOT-A-TIMESTAMP"; RC="$?"; EXEC=FULL
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
timestamp TIMESTAMP1 "$FILE"; RC="$?"
is   "$RC"         0               "Exit status"
isnt "$TIMESTAMP1" ""              "Timestamp1 mustn't be empty"

# modify timestamp
chtime 2000-01-01 "$FILE"
timestamp TIMESTAMP2 "$FILE"; RC="$?"
is   "$RC"         0               "Exit status"
isnt "$TIMESTAMP2" ""              "Timestamp2 mustn't be empty"
isnt "$TIMESTAMP1" "$TIMESTAMP2"   "Modified file timestamp"

# reset timestamp
reset_timestamp "$TIMESTAMP1"; RC="$?"
is   "$RC"         0               "Exit status"

timestamp TIMESTAMP3 "$FILE"; RC="$?"
is   "$RC"         0               "Exit status"
isnt "$TIMESTAMP2" ""              "Timestamp3 mustn't be empty"
is   "$TIMESTAMP1" "$TIMESTAMP3"   "Reset file timestamp"

##############################################################################

done_testing

#[eof]
