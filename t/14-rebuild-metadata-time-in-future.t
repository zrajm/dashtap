#!/usr/bin/env dash
# -*- sh -*-
. "t/dashtap.sh"
title - <<"EOF"
Rebuild target that has already been built after target's metadata file's
timestamp have been moved into the future. (Based on 07.)
EOF

init_test
mkdir  fix src
cpdir .fix

write_file a+x -1sec fix/TARGET.fix <<-"END_SCRIPT"
	#!/bin/sh
	echo "OUTPUT"
END_SCRIPT
write_file -1sec build/TARGET <<-"END_TARGET"
	OUTPUT
END_TARGET
chtime 2030-01-01 .fix/state/TARGET

timestamp TARGET        build/TARGET
timestamp METADATA .fix/state/TARGET

file_exists     build/TARGET         "Before build: Target should exist"
file_exists     .fix/state/TARGET    "Before build: Metadata file should exist"

"$TESTCMD" TARGET >stdout 2>stderr
is              $?                   0             "Exit status"
file_is         stdout               "$NADA"       "Standard output"
file_is         stderr               "$NADA"       "Standard error"
file_is         build/TARGET         "OUTPUT"      "Target"
is_unchanged    "$TARGET"                          "Target timestamp"
file_exists     .fix/state/TARGET                  "Metadata file should exist"
is_unchanged    "$METADATA"                        "Metadata timestamp"
file_not_exists build/TARGET--fixing               "Target tempfile shouldn't exist"

done_testing

#[eof]
