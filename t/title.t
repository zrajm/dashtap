#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists  title      "Function 'title' exists"

##############################################################################

cd "$(mktemp -d)"
title "title: Fail when called with two args"
STDOUT=""
STDERR="title: Bad number of args
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    title MANY ARGS; RC="$?"; EXEC=FULL
    fail "Test description"
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "title: Fail when called with no args"
STDOUT=""
STDERR="title: Bad number of args
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    title; RC="$?"; EXEC=FULL
    fail "Test description"
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "title: Pass when setting a title"
STDOUT="# Test title
not ok 1
not ok 2 - Test description
"
STDERR="
# Test title
#   Failed test in '$0'
#   Failed test 'Test description'
#   in '$0'
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    title "Test title"; RC="$?"; EXEC=FULL
    fail
    fail "Test description"
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"

##############################################################################

done_testing

#[eof]
