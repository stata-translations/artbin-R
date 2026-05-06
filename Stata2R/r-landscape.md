# R Package Landscape for artbin

## Overview

artbin provides sample size and power calculations for binary outcome clinical trials,
supporting superiority, non-inferiority, and substantial-superiority designs,
k-group (multi-arm) trials, multiple test statistics, loss to follow-up adjustment,
and unequal allocation ratios.

## Existing R Packages

### Most Relevant

| Package | CRAN | Description | Overlap with artbin |
|---------|------|-------------|---------------------|
| `rpact` | Yes | Confirmatory adaptive trial design; `getSampleSizeRates()` for binary NI | High for 2-arm NI/superiority; no k-arm, no LTFU |
| `TrialSize` | Yes | 80+ SS functions from Chow, Shao & Wang textbook; `TwoSampleProportion.NI.Diff()` | Moderate — NI supported, lacks k-arm / local-distant / integrated continuity correction |
| `gsDesign` | Yes | Group sequential design; `nBinomial()` uses Farrington-Manning (1990) method | Moderate — Farrington-Manning implemented, focused on group sequential, not k-arm |
| `epiR` | Yes | Epidemiology tools; `epi.ssninfb()` for NI binary | Low — 2-arm NI only, single method |
| `pwr` | Yes | Basic power analysis (Cohen 1988 effect sizes) | Low — superiority only, no NI, arcsine transformation |
| `Hmisc` | Yes | `bpower()`, `bsamsize()` for two proportions | Low — Fleiss-Tytun-Ury method only, no NI |
| `samplesize` | Yes | NI for proportions | Low — limited test options |
| `PowerTOST` | Yes | Power/SS for bioequivalence and NI | Low — continuous outcomes, PK focus |
| `clinfun` | Yes | Simon 2-stage, Fisher-exact methods | Low — different design scope |
| `exact.n` | Yes | Exact sample sizes for binary endpoints | Low — exact methods only |
| `blindrecalc` | Yes | Blinded sample size re-estimation for binary NI/superiority | Low — re-estimation focus |
| `EQUIVNONINF` | Yes | Two-arm NI trials with binary outcomes | Moderate — NI binary, but limited scope |

### Closest to artbin Scope

`rpact` and `gsDesign` come closest on the 2-arm path, both implementing Farrington-Manning
score test for binary endpoints. Neither supports:
- K-arm (≥3 group) designs
- Loss to follow-up adjustment
- Local vs distant alternatives
- Three null variance estimation methods in one interface
- Substantial-superiority design

## Key Gaps Across All R Packages

| artbin feature | Available in R |
|---------------|----------------|
| Two-arm superiority binary | Yes (pwr, Hmisc, rpact, gsDesign) |
| Two-arm NI binary (Farrington-Manning) | Yes (rpact, gsDesign, epiR) |
| K-group (≥3 arms) binary | Partial (rpact multi-arm, but different framework) |
| Loss to follow-up adjustment | No dedicated function found |
| Local vs distant alternatives | Not found |
| Three nvmethod options (Wald/FMT/CML) | No (individual packages implement one each) |
| Substantial-superiority | Not found |
| Continuity correction (integrated) | Partial (some packages) |
| Unequal allocation ratios | Partial |

## Conclusion

No existing R package provides the full feature set of artbin. A **standalone artbin R package**
is appropriate, and has been completed (see `R-package/`). Contributing to an existing package
such as `TrialSize` or `rpact` would require significant changes to their internal APIs and would
lose the MRC CTU provenance and the ability to cite the package as a direct translation of the
published Stata software.
