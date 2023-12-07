#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

##############################################################################

function_exists     varname    "Function 'varname' exists"

##############################################################################

cd "$(mktemp -d)"
title "varname: Zero character long variable name"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    varname ""
EOF
is        "$RC"     1          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "varname: Variable name with one letter"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    varname A
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "varname: Variable name with leading digit"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    varname 123abc
EOF
is        "$RC"     1          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "varname: Variable name consisting of single underscore"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    varname _
EOF
is        "$RC"     1          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "varname: Variable name with leading underscore"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    varname _SOME_NAME
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "varname: Variable name with all allowed characters"
execute 3<<"EOF" trap >out 2>err; RC="$?"
    varname abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789
EOF
is        "$RC"     0          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

done_testing

#[eof]
