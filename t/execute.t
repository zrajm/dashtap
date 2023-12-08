#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

##############################################################################

function_exists     execute    "Function 'execute' exists"

##############################################################################

cd "$(mktemp -d)"
title "execute: Fail when more than two args are used"
STDERR="execute: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    execute TOO MANY ARGS; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is        "$RC"     255          "Exit status"
file_is   out       "$NADA"      "Standard output"
file_is   err       "$STDERR"    "Standard error"
file_is   trap      "EXIT"       "Called exit"
file_is   opts      "><"         "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "execute: Fail when called with no args"
STDERR="execute: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    execute; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is        "$RC"     255        "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$STDERR"  "Standard error"
file_is   trap      "EXIT"     "Called exit"
file_is   opts      "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "execute: Ignore STDIN when two args are used"
(
    # execute() handles the trap here.
    execute 'echo ARG' trap 3<<-"EOF"; RC="$?"
	echo STDIN
	EOF
    echo ">$-<" >opts
    exit "$RC"
) >out 2>err; RC="$?"
is        "$RC"     0          "Exit status"
file_is   out       "ARG"      "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"
file_is   opts      "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "execute: Process STDIN when one arg is used"
(
    # execute() handles the trap here.
    execute trap 3<<-"EOF"; RC="$?"
	echo STDIN
	EOF
    echo ">$-<" >opts
    exit "$RC"
) >out 2>err; RC="$?"
is        "$RC"     0          "Exit status"
file_is   out       "STDIN"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"
file_is   opts      "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "execute: Returning false"
(
    # execute() handles the trap here.
    execute trap 3<<-"EOF"; RC="$?"
	! :
	EOF
    echo ">$-<" >opts
    exit "$RC"
) >out 2>err; RC="$?"
is        "$RC"     1          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "FULL"     "Didn't call exit"
file_is   opts      "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "execute: Exiting with true exit status"
(
    # execute() handles the trap here.
    execute trap 3<<-"EOF"; RC="$?"
	exit 0
	EOF
    echo ">$-<" >opts
    exit "$RC"
) >out 2>err; RC="$?"
is        "$RC"     0          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "EXIT"     "Called exit"
file_is   opts      "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "execute: Exiting with false exit status"
(
    # execute() handles the trap here.
    execute trap 3<<-"EOF"; RC="$?"
	exit 1
	EOF
    echo ">$-<" >opts
    exit "$RC"
) >out 2>err; RC="$?"
is        "$RC"     1          "Exit status"
file_is   out       "$NADA"    "Standard output"
file_is   err       "$NADA"    "Standard error"
file_is   trap      "EXIT"     "Called exit"
file_is   opts      "><"       "Shell options"

##############################################################################

done_testing

#[eof]
