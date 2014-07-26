#!/usr/bin/env dash
# -*- sh -*-
. "t/dashtap.sh"
title - <<"EOF"
Attempt to build target when there is no build script for it.
EOF

init_test
mkdir fix src

ERRMSG="ERROR: Buildscript 'fix/TARGET.fix' does not exist"

file_not_exists build/TARGET         "Before build: Target shouldn't exist"
file_not_exists .fix/state/TARGET    "Before build: Metadata file shouldn't exist"

"$TESTCMD" TARGET >stdout 2>stderr
is              $?                   10            "Exit status"
file_is         stdout               "$NADA"       "Standard output"
file_is         stderr               "$ERRMSG"     "Standard error"
file_not_exists build/TARGET                       "Target shouldn't exist"
file_not_exists .fix/state/TARGET                  "Metadata file shouldn't exist"
file_not_exists build/TARGET--fixing               "Target tempfile shouldn't exist"

done_testing

#[eof]
