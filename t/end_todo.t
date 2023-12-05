#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists  END_TODO  "Function 'END_TODO' exists"

##############################################################################

cd "$(mktemp -d)"
title "END_TODO: Fail when called with one (or more) args"
STDOUT=""
STDERR="END_TODO: No args allowed
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    trap 'echo EXIT >trap' 0
    TODO "Reason"
    END_TODO ARG
    trap - 0
    echo FULL >trap
) >out 2>err
is  $?             255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "END_TODO: Fail when called without first using TODO"
STDOUT=""
STDERR="END_TODO: TODO not set
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    trap 'echo EXIT >trap' 0
    END_TODO
    fail "Test description"
    trap - 0
    echo FULL >trap
) >out 2>err
is  $?             255         "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "EXIT"      "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "END_TODO: Unsetting the TODO"
STDOUT="ok 1 - pass # TODO Reason
not ok 2 - fail # TODO Reason
not ok 3 - is # TODO Reason
ok 4 - pass
not ok 5 - fail
not ok 6 - is
"
STDERR="
#   Failed test 'fail'
#   in 't/end_todo.t'
#   Failed test 'is'
#   in 't/end_todo.t'
#     GOT   : 1
#     WANTED: 2
"
(
    unset BAIL_ON_FAIL DIE_ON_FAIL
    dashtap_init
    trap 'echo EXIT >trap' 0
    TODO "Reason"
    pass "pass"
    fail "fail"
    is 1 2 "is"
    END_TODO
    pass "pass"
    fail "fail"
    is 1 2 "is"
    trap - 0
    echo FULL >trap
) >out 2>err
is  $?             0           "Exit status"
is  "$(dot err)"   "$STDERR."  "Standard error"
is  "$(dot out)"   "$STDOUT."  "Standard output"
is  "$(cat trap)"  "FULL"      "Didn't call exit"

##############################################################################

done_testing

#[eof]
