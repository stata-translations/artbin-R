<a href="https://www.mrcctu.ucl.ac.uk/"><img src="https://raw.githubusercontent.com/UCL/artbin/main/MRCCTU_at_UCL_Logo.png" width="50%" /></a>

# artbin

**Sample Size and Power for Binary Outcome Clinical Trials**

An R package translated from the Stata `artbin` package (v2.1.2), part of the
ART (Assessment of Resources for Trials) suite developed at the MRC Clinical
Trials Unit at UCL.

## Overview

`artbin` calculates the power or total sample size for trials comparing K
anticipated event probabilities for binary outcomes. It supports:

- **Superiority**, **non-inferiority**, and **substantial-superiority** designs
- **Two-arm and k-arm** (≥ 3 group) trials
- **Continuity correction** (two-arm)
- **Loss to follow-up** adjustment
- **Unequal allocation** ratios
- **One-sided and two-sided** tests
- **Null variance methods**: Wald (sample estimates), fixed marginal totals, or
  constrained maximum likelihood (Farrington-Manning)
- **Conditional test** (Peto log-odds) and **linear trend test**
- An interactive **Shiny GUI** (`run_artbin_app()`)

Results are identical to the Stata package for all supported scenarios.

## Installation

```r
# Install from GitHub (requires remotes)
remotes::install_github("UCL/artbin", subdir = "R-package")
```

## Quick start

```r
library(artbin)

# Superiority trial, Wald test (Pocock 1983: n = 1156)
artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9, wald = TRUE)

# One-sided non-inferiority trial (n = 914, 457 per arm)
artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)

# 4-arm superiority trial (n = 176, 44 per arm)
artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)

# STREAM trial: NI with 1:2 allocation and 20% LTFU (n = 398)
artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
       aratios = c(1, 2), ltfu = 0.2)

# Calculate power for a given total sample size
artbin(pr = c(0.1, 0.05), n = 1000, wald = TRUE)
```

Each call returns a named list with `n`, `n1`, `n2`, ... (per-arm sizes),
`power`, `D` (total expected events), and `D1`, `D2`, ... (per-arm events).

## Shiny GUI

```r
run_artbin_app()
```

Opens a browser-based interface for interactive sample size calculations, with
a code panel that shows the equivalent `artbin()` call.

## Key parameters

| Parameter | Description |
|---|---|
| `pr` | Vector of event probabilities (control first) |
| `margin` | NI/SS margin; `NULL` or `0` = superiority |
| `alpha` | Significance level (default 0.05, two-sided) |
| `power` | Desired power (default 0.8) |
| `n` | Total sample size (triggers power calculation) |
| `aratios` | Allocation ratios, e.g. `c(1, 2)` for 1:2 |
| `ltfu` | Proportion lost to follow-up |
| `onesided` | If `TRUE`, `alpha` is one-sided |
| `wald` | Wald test (sets `nvmethod = 1`) |
| `ccorrect` | Continuity correction |
| `condit` | Conditional (Peto) test |
| `trend` | Linear trend test (k-group) |
| `noround` | Return unrounded sample sizes |

See `?artbin` for the full parameter reference.

## Paper

If you use this package, please cite the original Stata paper:

> Ella Marley-Zagar, Ian R. White, Patrick Royston, Friederike M.-S. Barthel,
> Mahesh K. B. Parmar, Abdel G. Babiker.
> artbin: Extended sample size for randomised trials with binary outcomes.
> *Stata J* 2023; 23(1): 24–52.
> <https://journals.sagepub.com/doi/pdf/10.1177/1536867X231161971>

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bug reports and discrepancies with the
Stata package should be filed on the
[issue tracker](https://github.com/UCL/artbin/issues).
