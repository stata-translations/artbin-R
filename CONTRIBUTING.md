# Contributing to artbin

Thank you for your interest in contributing to artbin!

## Reporting bugs

Please report bugs on the [issue tracker](https://github.com/UCL/artbin/issues).
Include:

- The R code that triggered the problem
- The output (including any error messages)
- The result from `sessionInfo()`
- The expected result, and why you expect it (e.g. a reference to the
  Stata artbin documentation or publication)

## Verifying against Stata

The R package is a translation of the Stata artbin package (v2.1.2). The
core calculation should produce identical results. When reporting a
discrepancy, please include the equivalent Stata command and its output.

## Submitting changes

1. Fork the repository and create a branch from `main`.
2. Implement your change with tests.
3. Run `devtools::test()` to confirm all tests pass.
4. Run `devtools::check()` (or `R CMD check`) and address any errors or
   warnings.
5. Open a pull request against `main`.

## Code style

- Follow the [tidyverse style guide](https://style.tidyverse.org/).
- Internal helper functions are named with a leading dot (`.fun_name`).
- No comments that describe *what* the code does — only comments that
  explain *why* a non-obvious decision was made (e.g. a reference to the
  Stata source, a numerical edge case).

## Tests

Tests live in `tests/testthat/` and are organised by feature:

| File | Coverage |
|---|---|
| `test-artbin-sup.R` | Superiority trials |
| `test-artbin-ni.R` | Non-inferiority and substantial-superiority |
| `test-artbin-ccorrect.R` | Continuity correction |
| `test-artbin-kgroup.R` | K-group (>2 arms), trend, conditional |
| `test-artbin-ltfu.R` | Loss to follow-up |
| `test-artbin-rounding.R` | Rounding behaviour |
| `test-artbin-errors.R` | Error and warning messages |

## License

By contributing you agree that your contributions will be licensed under the
GPL-3 license that covers this project.
