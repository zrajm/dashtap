#!/usr/bin/env dash
# -*- sh -*-
. "t/test-functions.sh"
note <<EOF
02: Attempt to build target when there is no script dir.
EOF

init_test src
ERRMSG="ERROR: Script dir 'fix' does not exist"

"$TESTCMD" TARGET >stdout 2>stderr
is              $?                   10            "Exit status"
file_is         stdout               ""            "Standard output"
file_is         stderr               "$ERRMSG"     "Standard error"
file_not_exist  build/TARGET--fixing               "Target tempfile shouldn't exist"
file_not_exist  build/TARGET                       "Target shouldn't exist"

done_testing

#[eof]
