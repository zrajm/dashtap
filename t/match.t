#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

##############################################################################

function_exists         match        "Function 'match' exists"

##############################################################################

cd "$(mktemp -d)"
title "match: Fail when more than two args are used"
STDERR="match: Bad number of args"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    match TOO MANY ARGS
EOF
is           "$RC"      255          "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$STDERR"    "Standard error"
file_is      trapout    "EXIT"       "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Fail when called with no args"
STDERR="match: Bad number of args"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    match
EOF
is           "$RC"      255          "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$STDERR"    "Standard error"
file_is      trapout    "EXIT"       "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Ignore STDIN when two args are used"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    echo "STDIN" | match "ARG" "ARG"
EOF
is           "$RC"      0            "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$NADA"      "Standard error"
file_is      trapout    "FULL"       "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Process STDIN when one arg is used"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    echo "STDIN" | match "STDIN"
EOF
is           "$RC"      0            "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$NADA"      "Standard error"
file_is      trapout    "FULL"       "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Fail to find '*' when missing in string"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    match "*" "ABC"
EOF
is           "$RC"      1            "Exit status without match"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$NADA"      "Standard error"
file_is      trapout    "FULL"       "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Find '*' last in string"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    match "*" "AB*"
EOF
is           "$RC"      0            "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$NADA"      "Standard error"
file_is      trapout    "FULL"       "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Find '*' in middle of string"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    match "*" "A*C"
EOF
is           "$RC"      0            "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$NADA"      "Standard error"
file_is      trapout    "FULL"       "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "match: Find '*' at beginning of string"
execute 3<<"EOF" trapout >stdout 2>stderr; RC="$?"
    match "*" "*BC"
EOF
is           "$RC"      0            "Exit status"
file_is      stdout     "$NADA"      "Standard output"
file_is      stderr     "$NADA"      "Standard error"
file_is      trapout    "FULL"       "Didn't call exit"

##############################################################################

done_testing

#[eof]
