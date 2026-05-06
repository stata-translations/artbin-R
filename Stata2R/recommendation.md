# Translation Recommendation: artbin Stata → R

## Status: Complete

The R translation of artbin has been completed as a standalone package at `R-package/`.

- Version: 2.1.2 (mirrors Stata version)
- R CMD check: 0 errors, 0 warnings, 3 NOTEs (expected)
- Tests: 138 passing (testthat)
- Shiny GUI: included at `inst/shiny/artbin_app/app.R`

## Recommendation: Standalone New Package (Implemented)

**Package name:** `artbin`

### Rationale

1. **No equivalent package exists** — No CRAN package covers the full design space of artbin
   (superiority + NI + substantial-superiority, k-arm, multiple test types, three null
   variance estimation methods, LTFU adjustment). See `r-landscape.md` for full comparison.

2. **Preservation of validated behavior** — The Stata package is validated against published
   literature (Blackwelder 1982, Julious 2011, Pocock 1983/2003), commercial software (Cytel EAST),
   and Stata built-ins. All 138 R tests use the same reference values from Stata test logs.

3. **Clean API** — The Stata syntax maps naturally to a single R function `artbin(pr, ...)`.

4. **Maintainability and citability** — Standalone package preserves MRC CTU provenance and
   can be cited as a direct translation of the published Stata software.

## Implemented Package Structure

```
artbin (R package)
├── R/artbin.R          — main user-facing function: artbin(pr, ...)
├── R/art2bin.R         — internal: .art2bin() — 2-arm calculation
├── R/kgroup.R          — internal: .artbin_kgroup() — k-group calculation
└── R/utils.R           — shared utilities: .npnchi2(), continuity correction
```

## Testing Strategy (Implemented)

- All Stata test suites (artbin_testing_1 through artbin_testing_7) ported to testthat
- Reference values from Stata test logs as expected values
- Error condition tests from artbin_errortest_8.do
- Test files: test-artbin-ni.R, test-artbin-sup.R, test-artbin-ccorrect.R,
  test-artbin-kgroup.R, test-artbin-ltfu.R, test-artbin-rounding.R, test-artbin-errors.R

## Next Steps

- Submit to CRAN
- Publish alongside or as companion to the Stata Journal article
