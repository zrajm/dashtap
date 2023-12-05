#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015 zrajm <fix@zrajm.org>
# License: GPLv3+ [https://github.com/zrajm/fix.sh/blob/master/LICENSE.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

##############################################################################

function_exists     SKIP       "Function 'SKIP' exists"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 - descr # SKIP with reason"
title "SKIP: Test description + SKIP with reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 'descr # SKIP with reason'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 - descr # SKIP"
title "SKIP: Test description + SKIP without reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 'descr # SKIP'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 # SKIP with reason"
title "SKIP: No test description + SKIP with reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 '# SKIP with reason'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 # SKIP"
title "SKIP: No test description + SKIP without reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 '# SKIP'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 - descr # SKIP with reason"
title "SKIP: Test description + SKIP with reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    SKIP "with reason"
    is 1 2 'descr'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 - descr # SKIP"
title "SKIP: Test description + SKIP without reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    SKIP
    is 1 2 'descr'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 # SKIP with reason"
title "SKIP: No test description + SKIP with reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    SKIP "with reason"
    is 1 2
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="ok 1 # SKIP"
title "SKIP: No test description + SKIP without reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    SKIP
    is 1 2
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 - descr"
STDERR="
#   Failed test 'descr'
#   in 't/skip.t'
#     GOT   : 1
#     WANTED: 2"
title "SKIP: Test description + no SKIP"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    SKIP
    END_SKIP
    unset BAIL_ON_FAIL DIE_ON_FAIL
    is 1 2 "descr"
EOF
is        $?        1          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$STDERR"  "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1"
STDERR="
#   Failed test in 't/skip.t'
#     GOT   : 1
#     WANTED: 2"
title "SKIP: No test description + no SKIP"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    SKIP
    END_SKIP
    unset BAIL_ON_FAIL DIE_ON_FAIL
    is 1 2
EOF
is        $?        1          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$STDERR"  "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

done_testing

#[eof]
