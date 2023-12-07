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
    trap 'echo EXIT >&3' 0
    title "Test title"
    end_title ARG
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "end_title: Fail when called without first setting a title"
STDOUT=""
STDERR="end_title: Title not set
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    trap 'echo EXIT >&3' 0
    end_title
    fail "Test description"
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"

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
    trap 'echo EXIT >&3' 0
    title "Test title"
    end_title
    fail "Test description"
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"

##############################################################################

done_testing

#[eof]
