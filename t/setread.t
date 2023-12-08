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
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread TOO MANY ARGS <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when more than three args are used"
STDERR="setread: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread '+' TOO MANY ARGS <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when called with no args"
STDERR="setread: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Fail when called with bad variable name"
STDERR="setread: Bad VARNAME '_'"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread _ <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Ignore STDIN when two args are used"
VALUE="ARG\No newline at end."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread XX "ARG" <<-"EOF"; RC="$?"; EXEC=FULL
	STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Ignore STDIN when two args are used + don't strip newline"
VALUE="ARG."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread + XX "ARG" <<-"EOF"; RC="$?"; EXEC=FULL
	STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN when one arg is used"
VALUE="STDIN."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread XX <<-"EOF"; RC="$?"; EXEC=FULL
	STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN when one arg is used + don't strip newline"
VALUE="STDIN
."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread + XX <<-"EOF"; RC="$?"; EXEC=FULL
	STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN when one arg is used + no input"
VALUE="."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread + XX; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Overwriting previously set variable"
VALUE="NEW."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    X="STRING"
    setread + XX "NEW"; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process STDIN with space and quotes"
VALUE="  '  \"  ."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread XX <<-"EOF"; RC="$?"; EXEC=FULL
	  '  "  
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"
is  "$(cat opts)"  "><"       "Shell options"

##############################################################################

cd "$(mktemp -d)"
title "setread: Process arg with space and quotes"
VALUE="  '  \"  \No newline at end."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3; echo ">$-<" >&4' 0
    setread XX "  '  \"  "; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap 4>opts; RC="$?"
is  "$RC"          0        "Exit status"
is  "$(cat err)"   ""       "Standard error"
is  "$(dot out)"   "."      "Standard output"
is  "$(dot value)" "$VALUE" "Variable value"
is  "$(cat trap)"  "FULL"   "Didn't call exit"
is  "$(cat opts)"  "><"     "Shell options"

##############################################################################

done_testing

#[eof]
