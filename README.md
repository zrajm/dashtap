# Dashtap.sh

Dashtap is a test frame work which uses [TAP] (*Test Anything Protocol*)
format, allowing you run and process the test result with any compatible set of
tools (such as the `prove` command that comes with Perl).

Dashtap is written using the [Dash] shell, which chosen for its small file size
and fast execution time, something that really matters when you're invoking it
multiple times like in a test suite.


# Tests

There's a set of tests for Dashtap, which can be found in the test directory
`t/`. To run these tests, use:

    prove


# Additional Notes

Dashtap uses [semantic versioning][SemVer] (also known as SemVer).


[Dash]: http://gondor.apana.org.au/~herbert/dash/ "Debian Almquist SHell"
[SemVer]: //semver.org/ "Semantic Versioning"
[TAP]: https://testanything.org "Test Anything Protocol"

<!--[eof]-->
