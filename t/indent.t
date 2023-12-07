#!/usr/bin/env dash
# -*- sh -*-
# Copyright (C) 2015 zrajm <dashtap@zrajm.org>
# License: GPLv2 [https://gnu.org/licenses/gpl-2.0.txt]
. "./dashtap.sh"

##############################################################################

seteval GOT    'indent ""'; RC="$?"
seteval WANTED 'printf ""'
is "$GOT" "$WANTED" "No prefix + no input"
is "$RC"  0         "Exit status"

seteval GOT    'indent "" ""'; RC="$?"
seteval WANTED 'printf ""'
is "$GOT" "$WANTED" "No prefix + empty arg"
is "$RC"  0         "Exit status"

seteval GOT    'indent "" "1"'; RC="$?"
seteval WANTED 'printf " 1\n"'
is "$GOT" "$WANTED" "No prefix + simple arg"
is "$RC"  0         "Exit status"

seteval ARG    'printf "1\n2\n"'
seteval GOT    'indent "" "$ARG"'; RC="$?"
seteval WANTED 'printf " 1\n 2\n"'
is "$GOT" "$WANTED" "No prefix + two-line arg"
is "$RC"  0         "Exit status"

seteval GOT    'printf "" | indent ""'; RC="$?"
seteval WANTED 'printf ""'
is "$GOT" "$WANTED" "No prefix + empty stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "1\n" | indent ""'; RC="$?"
seteval WANTED 'printf " 1\n"'
is "$GOT" "$WANTED" "No prefix + one line on stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "1\n2\n" | indent ""'; RC="$?"
seteval WANTED 'printf " 1\n 2\n"'
is "$GOT" "$WANTED" "No prefix + two lines on stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "2\n" | indent "" "1"'; RC="$?"
seteval WANTED 'printf " 1\n 2\n"'
is "$GOT" "$WANTED" "No prefix + one line on stdin + arg"
is "$RC"  0         "Exit status"

##############################################################################

seteval GOT    'indent " "'; RC="$?"
seteval WANTED 'printf ""'
is "$GOT" "$WANTED" "Space as prefix + no input"
is "$RC"  0         "Exit status"

seteval GOT    'indent " " ""'; RC="$?"
seteval WANTED 'printf ""'
is "$GOT" "$WANTED" "Space as prefix + empty arg"
is "$RC"  0         "Exit status"

seteval GOT    'indent " " "1"'; RC="$?"
seteval WANTED 'printf "  1\n"'
is "$GOT" "$WANTED" "Space as prefix + simple arg"
is "$RC"  0         "Exit status"

seteval ARG    'printf "1\n2\n"'
seteval GOT    'indent " " "$ARG"'; RC="$?"
seteval WANTED 'printf "  1\n  2\n"'
is "$GOT" "$WANTED" "Space as prefix + two-line arg"
is "$RC"  0         "Exit status"

seteval GOT    'printf "" | indent " "'; RC="$?"
seteval WANTED 'printf ""'
is "$GOT" "$WANTED" "Space as prefix + empty stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "2\n" | indent " " "1"'; RC="$?"
seteval WANTED 'printf "  1\n  2\n"'
is "$GOT" "$WANTED" "Space as prefix + one line on stdin + one arg"
is "$RC"  0         "Exit status"

seteval GOT    'printf "1\n2\n" | indent " "'; RC="$?"
seteval WANTED 'printf "  1\n  2\n"'
is "$GOT" "$WANTED" "Space as prefix + two lines on stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "1\n" | indent " "'; RC="$?"
seteval WANTED 'printf "  1\n"'
is "$GOT" "$WANTED" "Space as prefix + one line on stdin"
is "$RC"  0         "Exit status"

##############################################################################

seteval GOT    'indent ">"'; RC="$?"
seteval WANTED 'printf ">\n"'
is "$GOT" "$WANTED" "String prefix + no input"
is "$RC"  0         "Exit status"

seteval GOT    'indent ">" ""'; RC="$?"
seteval WANTED 'printf ">\n"'
is "$GOT" "$WANTED" "String prefix + empty arg"
is "$RC"  0         "Exit status"

seteval GOT    'indent ">" "1"'; RC="$?"
seteval WANTED 'printf "> 1\n"'
is "$GOT" "$WANTED" "String prefix + simple arg"
is "$RC"  0         "Exit status"

seteval ARG    'printf "1\n2\n"'
seteval GOT    'indent ">" "$ARG"'; RC="$?"
seteval WANTED 'printf "> 1\n  2\n"'
is "$GOT" "$WANTED" "String prefix + two-line arg"
is "$RC"  0         "Exit status"

seteval GOT    'printf "" | indent ">"'; RC="$?"
seteval WANTED 'printf ">\n"'
is "$GOT" "$WANTED" "String prefix + empty stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "1\n" | indent ">"'; RC="$?"
seteval WANTED 'printf "> 1\n"'
is "$GOT" "$WANTED" "String prefix + one line on stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "1\n2\n" | indent ">"'; RC="$?"
seteval WANTED 'printf "> 1\n  2\n"'
is "$GOT" "$WANTED" "String prefix + two lines on stdin"
is "$RC"  0         "Exit status"

seteval GOT    'printf "2\n" | indent ">" "1"'; RC="$?"
seteval WANTED 'printf "> 1\n  2\n"'
is "$GOT" "$WANTED" "String prefix + one line on stdin + arg"
is "$RC"  0         "Exit status"

##############################################################################

done_testing

#[eof]
