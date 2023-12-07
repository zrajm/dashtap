#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists     setread    "Function 'setread' exists"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when more than two args are used without '+'"
STDERR="setread: Bad number of args"
(
    trap 'echo EXIT >&3' 0
    setread TOO MANY ARGS <&-
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when more than three args are used"
STDERR="setread: Bad number of args"
(
    trap 'echo EXIT >&3' 0
    setread '+' TOO MANY ARGS <&-
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when called with no args"
STDERR="setread: Bad number of args"
(
    trap 'echo EXIT >&3' 0
    setread <&-
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when called with bad variable name"
STDERR="setread: Bad VARNAME '_'"
(
    trap 'echo EXIT >&3' 0
    setread _ <&-
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Ignore STDIN when two args are used"
VALUE="ARG\No newline at end."
(
    trap 'echo EXIT >&3' 0
    setread XX "ARG" <<-"EOF"
	STDIN
	EOF
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Ignore STDIN when two args are used + don't strip newline"
VALUE="ARG."
(
    trap 'echo EXIT >&3' 0
    setread + XX "ARG" <<-"EOF"
	STDIN
	EOF
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN when one arg is used"
VALUE="STDIN."
(
    trap 'echo EXIT >&3' 0
    setread XX <<-"EOF"
	STDIN
	EOF
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN when one arg is used + don't strip newline"
VALUE="STDIN
."
(
    trap 'echo EXIT >&3' 0
    setread + XX <<-"EOF"
	STDIN
	EOF
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN when one arg is used + no input"
VALUE="."
(
    trap 'echo EXIT >&3' 0
    setread + XX
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Overwriting previously set variable"
VALUE="NEW."
(
    trap 'echo EXIT >&3' 0
    X="STRING"
    setread + XX "NEW"
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN with space and quotes"
VALUE="  '  \"  ."
(
    trap 'echo EXIT >&3' 0
    setread XX <<-"EOF"
	  '  "  
	EOF
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process arg with space and quotes"
VALUE="  '  \"  \No newline at end."
(
    trap 'echo EXIT >&3' 0
    setread XX "  '  \"  "
    printf "%s" "$XX" >value
    trap - 0
    echo FULL >&3
) >out 2>err 3>trap
is  $?             0        "Exit status"
is  "$(cat err)"   ""       "Standard error"
is  "$(dot out)"   "."      "Standard output"
is  "$(dot value)" "$VALUE" "Variable value"
is  "$(cat trap)"  "FULL"   "Didn't call exit"

##############################################################################

done_testing

#[eof]
