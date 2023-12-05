#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

##############################################################################

function_exists     TODO       "Function 'TODO' exists"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 - descr # TODO with reason"
title "TODO: Test description + TODO with reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 'descr # TODO with reason'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 - descr # TODO"
title "TODO: Test description + TODO without reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 'descr # TODO'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 # TODO with reason"
title "TODO: No test description + TODO with reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 '# TODO with reason'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 # TODO"
title "TODO: No test description + TODO without reason in description"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    is 1 2 '# TODO'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 - descr # TODO '\"with reason"
title "TODO: Test description + TODO with reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    TODO "'\"with reason"
    is 1 2 'descr'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 - descr # TODO"
title "TODO: Test description + TODO without reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    TODO
    is 1 2 'descr'
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 # TODO with reason"
title "TODO: No test description + TODO with reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    TODO "with reason"
    is 1 2
EOF
is        $?        0          "Exit status"
file_is   out       "$STDOUT"  "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
STDOUT="not ok 1 # TODO"
title "TODO: No test description + TODO without reason as separate function"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    TODO
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
#   in 't/todo.t'
#     GOT   : 1
#     WANTED: 2"
title "TODO: Test description + no TODO"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    TODO
    END_TODO
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
#   Failed test in 't/todo.t'
#     GOT   : 1
#     WANTED: 2"
title "TODO: No test description + no TODO"

execute 3<<"EOF" trap >out 2>err
    dashtap_init
    TODO
    END_TODO
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
