#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists  end_title  "Function 'end_title' exists"

##############################################################################

cd "$(mktemp -d)"
title "end_title: Fail when called with one (or more) args"
STDOUT="# Test title
"
STDERR="end_title: No args allowed
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    title "Test title"
    end_title ARG; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "end_title: Fail when called without first setting a title"
STDOUT=""
STDERR="end_title: Title not set
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    end_title; RC="$?"; EXEC=FULL
    fail "Test description"
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"
is  "$(cat opts)"  "><"        "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "end_title: Unsetting the title"
STDOUT="# Test title
not ok 1 - Test description
"
STDERR="
#   Failed test 'Test description'
#   in '$0'
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    title "Test title"
    end_title; RC="$?"; EXEC=FULL
    fail "Test description"
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
