# -*- sh -*-

## DASHTAP
## =======
## This is the Dashtap testing system. Written in dash (Debian Almquist SHell)
## and featuring TAP (the Test Anything Protocol) of Perl fame.
##
## This test system strives to as similar to the Perl Test::More module as
## possible, while still making the writing of reliable tests easy and fun
## using shellscripts only. You may find it useful for end-to-end test of
## command line tools (written in any language), or maybe to write unit tests
## for shell scripts (see also "WRITING SHELL SCRIPT UNIT TESTS" below).
##
## I wrote this since I needed something lightingly fast to test my 'fix' build
## system with, and since TAP is such a nice and easy-to-work with format for
## test output (with plenty of useful tools readily available, most important
## of which is prove(1) that comes with the standard Perl distribution).
##
## ENVIRONMENT VARIABLE OPTIONS
## ============================
## Set these variables to a non-empty string to get the described effect.
## (Variable names are chosen to be compatible with Test::Most.)
##
##   * BAIL_ON_FAIL - abort on first test fail
##   *  DIE_ON_FAIL - skip remaining tests in file when test fail
##
## SHELL TESTING CAVEATS
## =====================
## 1. Don't use $(...)/`...` to produce strings that are to be tested!
##
##    The shell $(...)/`...` construct STRIPS ALL TRAILING NEWLINES, which
##    makes it too inaccurate for testing purposes. (Texts which differ only in
##    the number of trailing newlines will be considered the same in tests, and
##    be indistinguishable from each other in user messages -- leading to
##    errors that are very hard to track down.) The following code is therefore
##    (subtly) broken:
##
##        # BROKEN EXAMPLE -- DON'T USE
##        fail "$NAME" <<-EOF
##                $(indent "GOT   :" "$GOT")
##                $(indent "WANTED:" "$WANTED")
##        EOF
##
##    This innocently looking example is also broken. (It looks as if the test
##    is carefully matching against a newline ['\n'] at the end of $A, but the
##    $(...) construct strip trailing newlines, so actually the comparison
##    checks that $A = "a" [without newline]!)
##
##        # BROKEN EXAMPLE -- DON'T USE
##        is "$A" "$(printf 'a\n')"
##
##    You can mitigate this problem by adding a non-newline (e.g. a period)
##    character to the end of the strings to be compared, but this leaves you
##    with an extra unwanted character in any error messages output to the
##    user. :(
##
##        # Ugly, but working example (leaves extra '.' in error output)
##        is "$A." "$(printf 'a\n.')"
##
##    For a better solution, see below.
##
## 2. Don't put a test function (inside or) after a pipe!
##
##    Each part of a pipe is executed in its own subshell, meaning that
##    variables set inside a command pipeline CANNOT be seen by the surrounding
##    shell. This means that if you put your test function (any function that
##    call 'pass' or 'fail') in a pipe, it cannot update the global $TEST_COUNT
##    variable, meaning that your test count will not agree with the number of
##    'ok' (and 'not ok') in your TAP output. The following code is therefore
##    also (subtly) broken:
##
##        # BROKEN EXAMPLE -- DON'T USE
##        {
##            indent "GOT   :" "$GOT"
##            indent "WANTED:" "$WANTED"
##        } | fail "$NAME"
##
## Workaround
## ----------
##     The helper function 'seteval' can be used to avoid the above constructs,
##     and preserve any trailing newlines (see 'seteval' below), while still
##     give you neat and accurate error messages. E.g.
##
##         seteval GOT    'indent "GOT   :" "$GOT"'
##         seteval WANTED 'indent "WANTED:" "$WANTED"'
##         fail "$NAME" <<-EOF
##                 $GOT
##                 $WANTED
##                 EOF
##
## WRITING SHELL SCRIPT UNIT TESTS
## ===============================
##
## When writing unit tests (as opposed to end-to-end tests) for shell scripts
## the shell script needs to be broken down into smaller, testable parts. This
## is done by breaking the script into functions, and then writing the script
## in such a way that it is possible both to (a) run it normally and (b) get
## access to all its functions without actually running the script itself.
##
## There are two ways of running a shell script, one is by 'sourcing' it --
## this is done by the '.' command (in newer shells 'source' is also a command
## which does the same thing). When you source a shellscript, it runs in the
## environment of a parent shell, and all its functions and (non-local)
## variables will remain in that shell, even after the shell is done running.
## (Normally you don't source shell scripts, except for your shell shartup
## files, which configure aliases and other convenient stuff.)
##
## The other way is by executing the script (this in the most common way). You
## execute a script by either specifying which shell to use ('bash SCRIPTNAME')
## or, if the script has its 'x' bit set, you can rely on the scripts shebang
## line and execute the script directly ('./SCRIPTNAME').
##
## Now we add a small piece of code that will execute the script's main
## function only if it is executed, but not if it is sourced. (This is similar
## to brian d foy's "modulino" trick used by many Perl hackers to simplify unit
## testing.)
##
## Since sourcing exports all its functions is ideal to use when testing, while
## executing is better suited to the everyday running the script in question.
## To make this work however, the actual script functionality should only be
## invoked when executed, but not when sourced.
##
## This can be done by looking at the $0 variable (which contains the name of
## the running process) to see whether it contains the script name or not, like
## this:
##
##     # call main function script was executed (not sourced)
##     [ "${0##*/}" = SCRIPTNAME ] && main "$@"
##
## NOTE: At first sight it might seem that checking to see whether $0 is equal
## to bash/dash/zsh would be a good idea, but doing that will fail if the
## script is sourced from inside another script. (Such as when using Dashtap.)
##
## NOTE II: In zsh the option FUNCTION_ARGZERO must be unset for $0 to be set
## so that the above code will work.
##


##############################################################################
##                                                                          ##
##  Test Functions                                                          ##
##                                                                          ##
##############################################################################

TEST_COUNT=0                                   # tests performed
TEST_FAILS=0                                   # failed tests
TEST_PLANNED=-1                                # plan (set by done_testing)
TEST_MODE=""                                   # TODO string (if any)
trap 'on_exit; trap - 0' 0                     # exit messages
on_exit() {
    if [ $TEST_COUNT = 0 ]; then
        diag "No tests run!"
        error
    fi
    if [ $TEST_PLANNED = -1 ]; then
        diag "Tests were run but done_testing() was not seen."
        error
    fi
    [ $TEST_PLANNED = $TEST_COUNT -a $TEST_FAILS = 0 ] && exit 0
    if [ $TEST_COUNT != $TEST_PLANNED ]; then
        diag "Looks like you planned $TEST_PLANNED test(s) but ran $TEST_COUNT."
    fi
    if [ $TEST_FAILS -gt 0 ]; then
        diag "Looks like you failed $TEST_FAILS test(s) of $TEST_COUNT."
    fi
    [ $TEST_FAILS -gt 254 ] && TEST_FAILS=254
    exit $TEST_FAILS
}

error() {
    [ $# = 1 ] && echo "$1" >&2
    exit 255
}

# Usage: indent PROMPT [MSG] [<<EOF
#            CONTENT
#        EOF]
#
# Output MSG, then CONTENT on standard output, after indenting them with PROMPT
# follow by a single space. Prefix is output as-is on the first line, each
# subsequent line is indented by as many spaces as there are characters in the
# original PROMPT.
#
# If there is no output and PROMPT contains non-space characters, then a single
# PROMPT is outputted on a line all by itself.
indent() {
    local PROMPT="$1" MSG="$2" SHOWN="" INDENT="" LINE=""
    case "$PROMPT" in
        *[!' ']*) : ;;
        *)  SHOWN=1                            # PROMPT consists of only spaces
            INDENT="$PROMPT"
    esac
    if [ -n "$MSG" ]; then
        echo "$MSG" | indent "$PROMPT"
        SHOWN=1
    fi
    if [ ! -t 0 ]; then                        # input on stdin
        while IFS='' read -r LINE; do
            if [ -z "$SHOWN" ]; then           # 1st line (has prompt)
                echo "$PROMPT${LINE:+ $LINE}"
                SHOWN=1
                continue
            fi
            if [ -z "$INDENT" ]; then
                INDENT="$(echo "$PROMPT"|tr "[:graph:]" " ")"
            fi
            echo "${LINE:+$INDENT $LINE}"
        done
    fi
    [ -z "$SHOWN" ] && echo "$PROMPT"          # make sure PROMPT was shown
}

done_testing() {
    if [ $TEST_PLANNED = -1 ]; then
        echo "1..$TEST_COUNT"
        TEST_PLANNED=$TEST_COUNT
        return 0
    fi
    fail "done_testing() already called"
}

skip_all() {
    local REASON="$1"
    if [ $TEST_PLANNED = -1 ]; then
        echo "1..0 # SKIP $REASON"
    else
        echo "skip_all() called after done_testing()" >&2
    fi
    exit $TEST_FAILS
}

# Usage: TODO [REASON]
#        ...              # tests
#        [END_TODO]
#
# Marks the following tests as TODO, optionally providing a REASON (to be
# displayed in the test output). -- TODO tests are used for features which you
# have not yet implemented, but which you plan to add later on (features on
# your TODO list).
#
# These TODO test are expected to FAIL and therefore, to avoid cluttering up
# the output, no detailed diagnostics will we shown (just a single 'not ok'
# line per test).
#
# A good TAP test runner (e.g. the prove(1) command that comes with Perl) will
# notify you if any of your TODO tests suddenly start passing (which most
# likely mean that you have implemented the related feature and that you should
# now turn the test in question into a regular, non-TODO test).
#
# NOTE: Another way of marking a test as TODO is to append "# TODO [<REASON>]"
# to its test name. (This is might be more convenient if you need to mark a
# single test as TODO.)
TODO() {
    [ $# -gt 1 ] && error "TODO: Too many arguments"
    TEST_MODE=" # TODO${1:+ $1}"
}

# Usage: END_TODO
#
# Turn off TODO mode. Takes no arguments.
END_TODO() {
    [ $# != 0 ] && error "END_TODO: No arguments allowed"
    TEST_MODE=""
}

BAIL_OUT() {
    echo "Bail out!${1:+ $1}"
    error
}

# Usage: diag [MSG] [<<EOF
#            CONTENT
#        EOF]
#
# Prints a diagnostic message which is guaranteed not to interfere with test
# output. Returns false, so that you may use 'fail || diag', and still have a
# false return value.
#
# Diagnostic messages are printed on stderr, and always displayed when using
# 'prove' (and other test harnesses), so use them sparingly. See also 'note'.
#
# If MSG and CONTENT are both given, MSG will be output first, then CONTENT.
diag() {
    note "$@" >&2
    return 1
}

# Usage: note [MSG] [<<EOF
#            CONTENT
#        EOF]
#
# Prints debug message which will only be seen when running 'prove' (or other
# test harness) in verbose mode ('prove -v') or when running the test script
# manually. Handy for putting in notes which might be useful for debugging, but
# which do not indicate a problem. See also 'diag'.
#
# If MSG and CONTENT are both given, MSG will be output first, then CONTENT.
note() {
    local MSG="$1"
    [ -n "$MSG" ] && echo "$MSG" | note
    [ -t 0 ] && return
    while IFS='' read -r MSG; do
        echo "#${MSG:+ $MSG}"
    done
}

result() {
    local MSG="$1" NAME="$2"
    TEST_COUNT="$(( TEST_COUNT + 1 ))"
    echo "$MSG $TEST_COUNT${NAME:+ - $NAME}"
}

pass() {
    local NAME="$1$TEST_MODE"; shift
    result "ok" "$NAME"
    note "$@"
    return 0
}

fail() {
    local NAME="$1$TEST_MODE" MSG="$2"
    result "not ok" "$NAME"
    [ "${NAME%# TODO*}" != "$NAME" ] && return 0
    TEST_FAILS=$(( TEST_FAILS + 1 ))
    # Insert extra newline when piped (so 'prove' output looks ok).
    # (Skip this if we're bailing out after the failure.)
    [ -n "$BAIL_ON_FAIL" -o -t 1 ] || echo >&2
    if [ -z "$NAME" ]; then
        diag <<-EOF
	  Failed test in '$0'
	EOF
    else
        diag <<-EOF
	  Failed test '$NAME'
	  in '$0'
	EOF
    fi
    indent "   " "$MSG" | diag                 # diagnostic message + stdin
    [ -n "$BAIL_ON_FAIL" ] && BAIL_OUT
    [ -n  "$DIE_ON_FAIL" ] && error
    return 1
}

ok() {
    local EXPR="$*" NAME="" ERRMSG="" RESULT=""
    for NAME; do :; done                       # get last arg
    [ "$NAME" = "]" ] && NAME=""               #   ignore if ']'
    EXPR="${EXPR% $NAME}"                      #   strip last arg
    if [ -n "${EXPR%\[*}" ]; then              # must start & have only one '['
        echo "ok: Error in expression: 'missing or multiple ['" >&2
        return 255
    fi
    ERRMSG="$(eval "$EXPR 2>&1")"; RESULT=$?
    if [ -n "$ERRMSG" ]; then                  # error msg from eval
        echo "ok: Error in expression: '${ERRMSG#* \[: }'" >&2
        return 255
    fi
    if [ $RESULT = 0 ]; then
        pass "$NAME"
        return
    fi
    fail "$NAME" <<-EOF
	Expression should evaluate to true, but it isn't
	$EXPR
	EOF
}

# Usage: seteval VARNAME [+] STATEMENTS
#
# Evaluates shell STATEMENTS and capture the output thereof into the variable
# named VARNAME. Normally the very last newline is stripped, but if '+' is
# given as the second argument no stripping is done at all. (This differs from
# the '$(...)' construct which strips all trailing newlines.) If no newline was
# could be stripped then the string '\No newline at end' is appended instead.
#
#     seteval X   'echo hello'         # set X to "hello"
#     seteval X + 'echo hello'         # set X to "hello" + newline
seteval() {
    # FIXME: test that $VARNAME is valid variable name, error otherwise

    # NOTA BENE: Only positional parameters ($1, $2, etc) are used in this
    # function, no other variables. THIS IS AN INTENTIONAL WORKAROUND to avoid
    # a namespace collision with variable name specified by the user. I.e. if a
    # variable $X was used in the function (and therefore declared with 'local
    # X') it could not be set for the global scope from within the function,
    # and should the user ever try set that same variable (with 'seteval X
    # <something>') $X would always remain unchanged for the user.
    if [ "$2" = "+" ]; then
        set "$1" "$(eval "$3; echo .")"
        eval $1='${2%.}'
        return
    fi
    set "$1" "$(eval "$2; echo .")"
    set "$1" "${2%.}" "
"   # NB: intentional newline
    if [ "$2" = "${2%$3}" ]; then
        set "$1" "$2\No newline at end" "$3"
    fi
    eval $1='${2%$3}'
}

##############################################################################
##                                                                          ##
##  Test Functions                                                          ##
##                                                                          ##
##############################################################################

##
## Below are test functions, intended to be used it test scripts.
##

is() {
    local GOT="$1" WANTED="$2" NAME="$3" NL="
"   # NB: intentional newline
    if [ $# -gt 3 ]; then
        error "is: Too many arguments (Did you forget to quote a variable?)"
    fi
    if [ "$GOT" = "$WANTED" ]; then
        pass "$NAME"
        return
    fi
    seteval GOT    'indent "GOT   :" "$GOT"'
    seteval WANTED 'indent "WANTED:" "$WANTED"'
    fail "$NAME" <<-EOF
	$GOT
	$WANTED
	EOF
}

file_is() {
    local FILE="$1" WANTED="$2" NAME="$3"
    local GOT="$(cat "$FILE")"
    is "$GOT" "$WANTED" "$NAME"
}

file_exist() {
    local FILE="$1" NAME="$2"
    if [ -e "$FILE" ]; then
        pass "$NAME"
        return
    fi
    fail "$NAME" <<-EOF
	File '$FILE' should exist, but it does not
	EOF
}

file_not_exist() {
    local FILE="$1" NAME="$2"
    if [ ! -e "$FILE" ]; then
        pass "$NAME"
        return
    fi
    fail "$NAME" <<-EOF
	File '$FILE' should not exist, but it does
	EOF
}

# Usage: TIMESTAMP="$(timestamp FILE)"
#
# Stats FILE to get a timestamp (for passing on to is_unchanged, later).
timestamp() {
    local FILE="$1"
    if [ -e "$FILE" ]; then
        local SHA="$(sha1sum "$FILE")"
        echo "${SHA%% *} $(ls --full-time "$FILE")"
    else
        echo "<NON-EXISTING FILE> $FILE"
    fi
}

# Usage: is_changed TIMESTAMP
#
# Compares TIMESTAMP with the file from which the TIMESTAMP was originally
# gotten, return false if the files mtime or other metadata have been modified
# TIMESTAMP was obtained, true if it has not changed.
is_changed() {
    local OLD_TIMESTAMP="$1" NAME="$2"
    local FILE="${OLD_TIMESTAMP##* }"
    local NEW_TIMESTAMP="$(timestamp "$FILE")"
    if [ "$NEW_TIMESTAMP" != "$OLD_TIMESTAMP" ]; then
        pass "$NAME"
        return
    fi
    seteval OLD_TIMESTAMP 'indent OLD: "$OLD_TIMESTAMP"'
    seteval NEW_TIMESTAMP 'indent NEW: "$NEW_TIMESTAMP"'
    fail "$NAME" <<-EOF
	File '$FILE' has been modified, but it shouldn't have
	$OLD_TIMESTAMP
	$NEW_TIMESTAMP
	EOF
}

# Usage: is_unchanged TIMESTAMP
#
# Compares TIMESTAMP with the file from which the TIMESTAMP was originally
# gotten, return false if the files mtime or other metadata have been modified
# TIMESTAMP was obtained, true if it has not changed.
is_unchanged() {
    local OLD_TIMESTAMP="$1" NAME="$2"
    local FILE="${OLD_TIMESTAMP##* }"
    local NEW_TIMESTAMP="$(timestamp "$FILE")"
    if [ "$NEW_TIMESTAMP" = "$OLD_TIMESTAMP" ]; then
        pass "$NAME"
        return
    fi
    seteval OLD_TIMESTAMP 'indent OLD: "$OLD_TIMESTAMP"'
    seteval NEW_TIMESTAMP 'indent NEW: "$NEW_TIMESTAMP"'
    fail "$NAME" <<-EOF
	File '$FILE' has been modified, but it shouldn't have
	$OLD_TIMESTAMP
	$NEW_TIMESTAMP
	EOF
}

##############################################################################
##                                                                          ##
##  Test Initialization                                                     ##
##                                                                          ##
##############################################################################

##
## These functions are specific for the fix.sh tests. They are used to set up
## a test case before running it, and do not perform any actual testing.
##

# Usage: init_test [DIR...]
#
# Initializes a tempdir, and changes directory to it. If any DIR(s) are
# specified they will be created inside the tempdir (relative paths will be
# interpreted relative to the tempdir).
#
# If there is a directory (or symlink) called the same thing as the test file
# (but without the '.t' extension) that directory is taken to contain a '.fix'
# state dir, which is then copied to '.fix' in the tempdir.
#
# Also sets the TESTCMD variable to the full path of 'fix.sh' (it should be
# used in tests instead of refering to any literal executable).
init_test() {
    readonly TESTCMD="$PWD/fix.sh"
    local TESTFILE="$PWD/$0" TESTDIR="$PWD/${0%.t}"
    local TMPDIR="$(mktemp -dt "fix-test-${TESTDIR##*/}.XXXXXX")"
    cd "$TMPDIR"
    note "DIR: $TMPDIR"
    [ $# -gt 0 ] && mkdir -p "$@"
    [ -e "$TESTDIR" ] && cp -rH "$TESTDIR" .fix
}

mkpath() {
    local DIR="${1%/*}"                        # strip trailing filename
    [ -d "$DIR" ] || mkdir -p -- "$DIR"
}

# Usage: chtime YYYY-MM-DD FILE
#
# Change mtime of FILE to YYYY-MM-DD.
chtime() {
    local TIME="$1" FILE="$2"
    [ -e "$FILE" ] || error "chtime: file '$FILE' not found"
    if [ "${TIME#+}" != "${TIME#-}" ]; then    # plus/minus time
        touch -r"$FILE" -d"$TIME" "$FILE" \
            || error "chtime: cannot set file '$FILE' time to '$TIME'"
        return
    fi
    TIME="$(echo "$TIME"|tr -d -)0000"
    touch -t"$TIME" "$FILE" || error "chtime: 'touch' cannot update '$FILE'"
}

# Usage: write_file FILE [YYYY-MM-DD] [BITS] [<<EOF
#            CONTENT
#        EOF]
#
# Creates FILE and writes CONTENT (if no CONTENT is give on standard input,
# then a zero byte file is created), thereafter chmod(1)s FILE to set file
# permissions to BITS, and touch(1)es to set its mtime to YYYY-MM-DD (if any of
# those are specified).
write_file() {
    local FILE="$1" DATE="" BITS="" LINE=""; shift
    for LINE; do
        case "$1" in
            [-+][0-9]*[a-z]|????-??-??)      DATE="$1" ;;
            [ugoa][-+][rwx]|[0-7][0-7][0-7]) BITS="$1" ;;
            *) error "write_file: bad arg '$LINE'"
        esac; shift
    done
    mkpath "$FILE" 2>/dev/null \
        || error "Cannot create dir for file '$FILE'"
    {
        [ -t 0 ] || while IFS='' read -r LINE; do
            echo "$LINE"
        done
    } >"$FILE"
    [ -n "$BITS" ] && chmod  "$BITS" "$FILE"
    [ -n "$DATE" ] && chtime "$DATE" "$FILE"
}

#[eof]
