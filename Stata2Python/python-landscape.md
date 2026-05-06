# Python Package Landscape for artbin

## Overview

artbin provides sample size and power calculations for binary outcome clinical trials.
This document surveys the Python ecosystem for equivalent functionality.

## Existing Python Packages

### General Statistical / Power Analysis

| Package | PyPI | Description | Overlap with artbin |
|---------|------|-------------|---------------------|
| `statsmodels` | Yes | `statsmodels.stats.proportion`: `proportion_effectsize`, `zt_ind_solve_power`, `binom_test` | Low — basic 2-proportion z-test only, no NI, no k-group |
| `scipy.stats` | Yes | Binomial/normal distributions; no sample size functions | Very low — foundation library only |
| `pingouin` | Yes | Statistics library; `pwr2` for two-sample power | Very low — hypothesis testing focus, not SS planning |

### Specialized Clinical Trial Packages

| Package | Status | Description | Overlap |
|---------|--------|-------------|---------|
| `clintrials` (GitHub: brockk/clintrials) | Development | Clinical trial designs in Python; NumPy/SciPy/Pandas | Unclear — active development, limited documentation |
| `PyTrial` | PyPI | AI for drug development; patient outcome prediction | None — ML focus, not statistical SS calculation |
| `pytrials` | PyPI | ClinicalTrials.gov API wrapper | None — data retrieval only |

### Other Relevant

| Package | Notes |
|---------|-------|
| `rpy2` | Bridge to run R packages (including artbin R) from Python |
| `lifelines` | Survival analysis; not sample size for binary outcomes |
| `bambi` | Bayesian models; not frequentist SS calculation |

## Key Gaps

Python currently lacks publication-ready packages for clinical trial sample size calculation
with binary outcomes at the breadth of artbin. Specific missing capabilities:

| artbin feature | Available in Python |
|---------------|---------------------|
| Two-arm superiority binary | Partial (statsmodels z-test approximation) |
| Two-arm NI binary (Farrington-Manning) | Not found |
| K-group (≥3 arms) binary | Not found |
| Loss to follow-up adjustment | Not found |
| Local vs distant alternatives | Not found |
| Three null variance estimation methods | Not found |
| Substantial-superiority | Not found |
| Continuity correction | Not found |
| Allocation ratios | Not found |

## Summary

The Python landscape for clinical trial sample size calculation with binary endpoints is sparse.
`statsmodels` provides a basic 2-proportion z-test power function but nothing approaching the
scope of artbin. There is a clear gap in the Python ecosystem for a rigorous, validated,
publication-quality binary outcome SS package.
