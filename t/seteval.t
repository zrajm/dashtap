#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015-2023 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"
NADA=""; strip_newline NADA                    # NADA = '\No newline at end'

dot() { stdin <"$1"; echo .; }
cat() { stdin <"$1"; }

##############################################################################

function_exists     seteval    "Function 'seteval' exists"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Fail when more than two args are used without '+'"
STDERR="seteval: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval TOO MANY ARGS <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Fail when more than three args are used"
STDERR="seteval: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval '+' TOO MANY ARGS <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Fail when called with no args"
STDERR="seteval: Bad number of args"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Fail when called with bad variable name"
STDERR="seteval: Bad VARNAME '_'"
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval _ <&-; RC="$?"; EXEC=FULL
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          255        "Exit status"
is  "$(cat err)"   "$STDERR"  "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(cat trap)"  "EXIT"     "Called exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Ignore STDIN when two args are used"
VALUE="ARG\No newline at end."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX "printf '%s' ARG" <<-"EOF"; RC="$?"; EXEC=FULL
	printf '%s' STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Ignore STDIN when two args are used, false exit code"
VALUE="ARG\No newline at end."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX "! printf '%s' ARG" <<-"EOF"; RC="$?"; EXEC=FULL
	! printf '%s' STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          1          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Ignore STDIN when two args are used + don't strip newline"
VALUE="ARG."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval + XX "printf '%s' ARG" <<-"EOF"; RC="$?"; EXEC=FULL
	printf '%s' STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process STDIN when one arg is used, output newline"
VALUE="STDIN."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX <<-"EOF"; RC="$?"; EXEC=FULL
	echo STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process STDIN when one arg is used, output newline, false exit code"
VALUE="STDIN."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX <<-"EOF"; RC="$?"; EXEC=FULL
	! echo STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          1          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process STDIN when one arg is used (not ending in newline)"
VALUE="STDIN\No newline at end."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX <<-"EOF"; RC="$?"; EXEC=FULL
	printf '%s' STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process STDIN when one arg is used + don't strip newline"
VALUE="STDIN
."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval + XX <<-"EOF"; RC="$?"; EXEC=FULL
	echo STDIN
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process STDIN when one arg is used + no input"
VALUE="."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval + XX; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Overwriting previously set variable"
VALUE="NEW."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    X="OLD"
    seteval XX "echo NEW"; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process STDIN with space and quotes"
VALUE="  '  \"  ."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX <<-"EOF"; RC="$?"; EXEC=FULL
	echo "  '  \"  "
	EOF
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0          "Exit status"
is  "$(cat err)"   ""         "Standard error"
is  "$(dot out)"   "."        "Standard output"
is  "$(dot value)" "$VALUE"   "Variable value"
is  "$(cat trap)"  "FULL"     "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Process arg with space and quotes"
VALUE="  '  \"  ."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX "echo \"  '  \\\"  \""; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0        "Exit status"
is  "$(cat err)"   ""       "Standard error"
is  "$(dot out)"   "."      "Standard output"
is  "$(dot value)" "$VALUE" "Variable value"
is  "$(cat trap)"  "FULL"   "Didn't call exit"

##############################################################################

cd "$(mktemp -d)"
title "seteval: Two newlines at end, one should be stripped"
VALUE="x
."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval XX "echo x; echo"; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0        "Exit status"
is  "$(cat err)"   ""       "Standard error"
is  "$(dot out)"   "."      "Standard output"
is  "$(dot value)" "$VALUE" "Variable value"
is  "$(cat trap)"  "FULL"   "Didn't call exit"

##############################################################################


cd "$(mktemp -d)"
title "seteval: Two newlines at end, none stripped"
VALUE="x

."
(
    EXEC=EXIT; trap 'echo "$EXEC" >&3' 0
    seteval + XX "echo x; echo"; RC="$?"; EXEC=FULL
    printf "%s" "$XX" >value
    exit "$RC"
) >out 2>err 3>trap; RC="$?"
is  "$RC"          0        "Exit status"
is  "$(cat err)"   ""       "Standard error"
is  "$(dot out)"   "."      "Standard output"
is  "$(dot value)" "$VALUE" "Variable value"
is  "$(cat trap)"  "FULL"   "Didn't call exit"

##############################################################################

done_testing

#[eof]
