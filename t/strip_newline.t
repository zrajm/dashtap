#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

##############################################################################

function_exists strip_newline  "Function 'strip_newline' exists"

##############################################################################

cd "$(mktemp -d)"
STDERR="strip_newline: Bad number of args"
title "strip_newline: Fail when two or more args are used"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    LINE=""
    strip_newline MANY ARGS
    echo "$LINE"
EOF
is        "$RC"     255        "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$STDERR"  "Standard error"
file_is   trap      "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
STDERR="strip_newline: Bad VARNAME 'BAD-VAR'"
title "strip_newline: Fail when bad variable name is used"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    strip_newline "BAD-VAR"
    echo "$BAD-VAR"
EOF
is        "$RC"     255        "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$STDERR"  "Standard error"
file_is   trap      "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="\\No newline at end"
title "strip_newline: Zero length string"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    LINE=""
    strip_newline LINE
    echo "$LINE"
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="Hello\\No newline at end"
title "strip_newline: String with no newline at end"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    LINE="Hello"
    strip_newline LINE
    echo "$LINE"
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="  1  2  spaces  \\No newline at end"
title "strip_newline: String leading + trailing spaces"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    LINE="  1  2  spaces  "
    strip_newline LINE
    echo "$LINE"
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="Hello"
title "strip_newline: String ending in newline"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    LINE="Hello
"
    strip_newline LINE
    echo "$LINE"
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="Hello
"
title "strip_newline: with string ending in two newlines"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    LINE="Hello

"
    strip_newline LINE
    echo "$LINE"
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

done_testing

#[eof]
