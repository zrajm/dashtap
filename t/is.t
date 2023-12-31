#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists     is      "Function 'is' exists"

##############################################################################

cd "$(mktemp -d)"
title "is: Fail when called with one (or fewer) args"
STDOUT=""
STDERR="is: Bad number of args
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    is 1; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Called exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "is: Fail when called with four (or more) args"
STDOUT=""
STDERR="is: Bad number of args
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    is FAR TOO MANY ARGS; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Called exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

# FIXME: Check with 'TODO' in description
# FIXME: Check with 'SKIP' in description
# FIXME: Check with 'TODO' called separately
# FIXME: Check with 'SKIP' called separately

##############################################################################

cd "$(mktemp -d)"
title "is: Fail when called with two differing args"
STDOUT="not ok 1
"
STDERR="
#   Failed test in '$0'
#     GOT   : 1
#     WANTED: 2
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    is 1 2; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          1           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

cd "$(mktemp -d)"
title - <<"END_TITLE"
is: Fail (but don't die early) when called with two differing args and shell
option `set -e` in effect
END_TITLE
STDOUT="not ok 1
"
STDERR="
#   Failed test in '$0'
#     GOT   : 1
#     WANTED: 2
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    set -e
    # `if` avoids early termination under `set -e`.
    if
        is 1 2; RC="$?"; EXEC=FULL
    then :; fi                                 # intentional no-op
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          1           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"
is  "$(cat opts)"  ">e<"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "is: Fail when called with two differing args + description"
STDOUT="not ok 1 - Description
"
STDERR="
#   Failed test 'Description'
#   in '$0'
#     GOT   : 1
#     WANTED: 2
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    is 1 2 Description; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          1           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "is: Pass when called with two equal args"
STDOUT="ok 1
"
STDERR=""
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    is 1 1; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "is: Pass when called with two equal args + description"
STDOUT="ok 1 - Description
"
STDERR=""
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    is 1 1 Description; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

done_testing

#[eof]
