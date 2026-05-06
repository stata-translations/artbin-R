# Translation Recommendation: artbin Stata → Python

## Recommendation: Lower Priority; Consider After CRAN Submission

### Summary

A Python translation of artbin is feasible and would fill a genuine gap in the Python
ecosystem, but it is lower priority than the completed R translation. It should be considered
after the R package is published on CRAN.

### Rationale

#### Arguments For

1. **Clear gap** — No Python package covers the artbin feature set. A Python artbin would be the
   only rigorous, validated binary outcome SS tool in the Python ecosystem.

2. **Growing Python use in clinical trials** — Python use in academic biostatistics and clinical
   research is increasing, particularly in ML-augmented trial design workflows.

3. **Straightforward implementation** — All required mathematical functions exist in
   `scipy.stats` and `numpy`. The R translation (now complete) provides a well-tested
   intermediate reference. Python translation would be simpler than the Stata → R step.

4. **NumPy/SciPy equivalents are direct:**

   | Stata | R | Python |
   |-------|---|--------|
   | `invnormal(p)` | `qnorm(p)` | `scipy.stats.norm.ppf(p)` |
   | `normprob(x)` | `pnorm(x)` | `scipy.stats.norm.cdf(x)` |
   | `invchi2(df, p)` | `qchisq(p, df)` | `scipy.stats.chi2.ppf(p, df)` |
   | `nchi2(df, ncp, x)` | `pchisq(x, df, ncp)` | `scipy.stats.ncx2.cdf(x, df, ncp)` |
   | `npnchi2(df, x, p)` | custom via uniroot | `scipy.optimize.brentq(...)` |

#### Arguments Against / Risks

1. **Lower demand** — The primary users of artbin are clinical trialists, who predominantly
   use R, Stata, or SAS. Python uptake in this community is lower than in data science generally.

2. **Maintenance burden** — A third implementation adds ongoing maintenance. Bugs fixed in
   Stata/R would need porting to Python.

3. **R is sufficient** — R is the standard for statistical computing in clinical trials.
   Python users in this domain often use `rpy2` to call R packages directly.

4. **Packaging ecosystem** — R's CRAN provides strong discoverability for statistical packages.
   PyPI is more general-purpose and the package would be harder to find.

### Proposed Approach (If Undertaken)

**Package name:** `artbin`  
**Target:** PyPI  
**Dependencies:** `numpy`, `scipy` only  
**Reference implementation:** Port from the completed R package rather than directly from Stata

```python
# Proposed API (mirrors R)
from artbin import artbin

result = artbin(pr=[0.1, 0.05], alpha=0.05, power=0.9, wald=True)
# result.n → 1156
```

**Test strategy:** Port R testthat tests to pytest, using same reference values.

### Decision Criteria

Proceed with Python translation if:
- R package is published on CRAN and receives community interest
- Python users in clinical trials request it
- A contributor with Python packaging experience is available

Do not proceed if:
- Resources are better spent extending the R package or Stata package
- No Python user community demand is identified
