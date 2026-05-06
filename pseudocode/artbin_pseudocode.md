# artbin Pseudocode

Translated from artbin.ado v2.1.2 and art2bin.ado v1.01.

Notation:
- `NULL` means the argument was not supplied by the user
- `qnorm(p)` = inverse standard normal CDF (Stata: `invnormal`)
- `pnorm(x)` = standard normal CDF (Stata: `normprob` / `normal`)
- `qchisq(p, df)` = inverse chi-squared CDF (Stata: `invchi2(df, 1-p)` — note arg order difference)
- `pchisq(x, df, ncp)` = non-central chi-squared CDF (Stata: `nchi2(df, ncp, x)` — note arg order)
- `npnchi2(df, x, p)` = find ncp s.t. pchisq(x, df, ncp) = p (Stata built-in; custom in R via uniroot)
- `ceil(x)` = ceiling (round up to nearest integer)
- `sum(v)` = sum of vector v
- `sum(v * w)` = weighted sum (element-wise product then sum)

---

## Utility Functions

### `_inrange01(x1, x2, ...)`

Returns 1 if all arguments are strictly in (0, 1), else 0.

```
result = 1
FOR each argument x:
    result = result * (x > 0) * (x < 1)
RETURN result
```

---

### `_cc(n, adiff, ratio=1, deflate=FALSE)`

Continuity correction: inflate (for SS calculation) or deflate (for power calculation) a sample size.

```
a = (ratio + 1) / (adiff * ratio)

IF deflate:
    n_adjusted = ((2*n - a)^2) / (4*n)
ELSE:
    cf = ((1 + sqrt(1 + 2*a/n))^2) / 4
    n_adjusted = n * cf

RETURN n_adjusted
```

---

### `_sp(var1, var2, ..., varK)` (Stata dataset operation)

Returns the sum of element-wise products of all supplied variables across all rows.

```
SP = var1 * var2 * ... * varK   (element-wise)
RETURN sum(SP)
```

In R terms: `sum(var1 * var2 * ... * varK)` where each var is a vector of length ngroups.

---

### `_pe2(a0, q0, a1, q1, K, n, crit_val)` → returns beta

Calculate beta (type II error probability) for the distant-alternative unconditional k-group test.

```
b0 = a0 + n * q0
b1 = a1 + 2 * n * q1
l  = b0^2 - K * b1
f  = sqrt(l * (l + K * b1))
l  = (l + f) / b1
f  = crit_val * (K + l) / b0
beta = pchisq(f, df=K, ncp=l)
RETURN beta
```

---

### `npnchi2(df, x, p)` → returns ncp

Find the non-centrality parameter `ncp` such that `pchisq(x, df, ncp) = p`.

Stata: built-in scalar function.
R implementation: solve via `uniroot`:

```
f(ncp) = pchisq(x, df, ncp) - p = 0
upper = 1
WHILE pchisq(x, df, upper) > p:
    upper = upper * 2
ncp = uniroot(f, interval=[0, upper])$root
RETURN ncp
```

---

## Internal Function: art2bin(p0, p1, margin, ar, alpha, power, n, n0, n1, nvmethod, onesided, ccorrect, local, wald, noround)

### Note on p0/p1 notation

In art2bin, `p0` is the **control** arm probability and `p1` is the **intervention** arm probability.
In artbin's output and help file, these are called `pi1` and `pi2` respectively.

### Hypothesis tested

H0: pi2 - pi1 >= margin  (unfavourable outcome)
H1: pi2 - pi1 < margin

or equivalently for favourable outcome:

H0: pi2 - pi1 <= margin
H1: pi2 - pi1 > margin

### 1. Input validation

```
IF alpha <= 0 OR alpha >= 1 → ERROR "alpha() out of range"
IF p0 <= 0 OR p0 >= 1 → ERROR "Control event probability out of range"
IF p1 <= 0 OR p1 >= 1 → ERROR "Intervention event probability out of range"
IF power <= 0 OR power >= 1 → ERROR "power() out of range"
```

### 2. Parse allocation ratio

```
// ar is a string of 0, 1, or 2 numbers
IF ar is empty OR ar == 1 OR ar == "1 1":
    ar10 = 1        // ar10 = n1/n0 = ratio of intervention to control
    allocr = "equal group sizes"
ELSE IF ar has 1 number:
    ar10 = ar[1]
    allocr = "1:ar[1]"
ELSE IF ar has 2 numbers:
    ar10 = ar[2] / ar[1]
    allocr = "ar[1]:ar[2]"
ELSE:
    ERROR "Invalid allocation ratio"
```

### 3. Option compatibility

```
IF wald AND nvmethod is given AND nvmethod != 1 → ERROR "Need nvm(1) if Wald specified"
IF wald AND nvmethod is NULL → nvmethod = 1
IF local AND wald → ERROR "Local and Wald not allowed together"
IF nvmethod is NULL OR nvmethod < 1 OR nvmethod > 3 → nvmethod = 3
IF local AND nvmethod != 3 → ERROR "Need nvm(3) if local specified"
IF user specified n → noround = TRUE   // preserve the n as specified
```

### 4. Parse sample size / power

```
// Three usage modes:
// (a) n = 0 and n0 = 0 and n1 = 0 → calculate sample size (ss = TRUE)
// (b) n > 0 → calculate power for given total n
//     n0 = floor(n / (1 + ar10)); n1 = n - n0
// (c) n0 or n1 given → calculate power for given group sizes
//     derive ar10 from the given n0 / n1

IF n == 0 AND n0 == 0 AND n1 == 0:
    ss = TRUE
ELSE IF n > 0:
    ss = FALSE
    IF n0 == 0 AND n1 == 0:
        n0 = n / (1 + ar10)    // exact (not rounded — artbin will round)
        n1 = n - n0
    ELSE: (use given n0/n1)
ELSE (n0 or n1 given):
    ss = FALSE
    // derive missing group size from ar10 or from the given pair
```

### 5. Favourable/unfavourable and trial type (reproduced in art2bin for standalone calls)

```
// Also done in artbin wrapper — redundant when called from artbin but needed for standalone use
threshold = p0 + margin

IF favourable/unfavourable not specified:
    IF p1 < threshold → trialoutcome = "Unfavourable"
    IF p1 > threshold → trialoutcome = "Favourable"
    IF p1 == threshold → ERROR "p2 can not equal p1 + margin"
ELSE:
    use user-specified trialoutcome

// Consistency check (unless force specified):
IF trialoutcome == "Unfavourable" AND threshold < p1 → ERROR (or WARNING if force)
IF trialoutcome == "Favourable" AND threshold > p1 → ERROR (or WARNING if force)

IF trialoutcome=="Unfavourable" AND margin > 0 OR trialoutcome=="Favourable" AND margin < 0:
    trialtype = "Non-inferiority"
ELSE IF trialoutcome=="Unfavourable" AND margin < 0 OR trialoutcome=="Favourable" AND margin > 0:
    trialtype = "Substantial-superiority"
ELSE:
    trialtype = "Superiority"
```

### 6. Null hypothesis event probabilities

```
mrg = margin

IF nvmethod == 1:  // Sample estimate (Wald method)
    p0null = p0
    p1null = p1

IF nvmethod == 2:  // Fixed marginal totals (Dunnett & Gent 1977)
    p0null = (p0 + ar10*p1 - ar10*mrg) / (1 + ar10)
    p1null = (p0 + ar10*p1 + mrg) / (1 + ar10)
    IF NOT _inrange01(p0null, p1null) → ERROR "incompatible with fixed marginal totals method"

IF nvmethod == 3:  // Constrained ML (Farrington & Manning 1990)
    a = 1 + ar10
    b = mrg*(ar10 + 2) - 1 - ar10 - p0 - ar10*p1
    c = (mrg - 1 - ar10 - 2*p0)*mrg + p0 + ar10*p1
    d = p0 * mrg * (1 - mrg)
    v = (b/(3a))^3 - (b*c)/(6*a^2) + d/(2*a)
    u = sign(v) * sqrt((b/(3a))^2 - c/(3a))

    // Safe division: avoid 0/0 when (p0+p1)=1 and margin=0
    IF |v| <= 1e-12 AND |u^3| <= 1e-12:
        cos_val = 0
    ELSE:
        cos_val = v / u^3

    w = (π + acos(cos_val)) / 3
    p0null = 2*u*cos(w) - b/(3*a)
    p1null = p0null + mrg
    // Note: p0null, p1null should be in (0,1); if not, that's an unreachable edge case
```

### 7. Core quantities

```
D_diff = |p1 - p0 - mrg|

IF onesided:
    za = qnorm(1 - alpha)        // one-sided critical value
ELSE:
    za = qnorm(1 - alpha/2)      // two-sided

zb = qnorm(power)

snull = sqrt(p0null*(1-p0null) + p1null*(1-p1null)/ar10)
salt  = sqrt(p0*(1-p0) + p1*(1-p1)/ar10)
```

### 8a. Sample size calculation (ss == TRUE)

```
// Base formula (score test, distant alternative):
m = ((za*snull + zb*salt) / D_diff)^2

IF local:
    m = ((za*snull + zb*snull) / D_diff)^2

IF wald:
    m = ((za*salt + zb*salt) / D_diff)^2

IF ccorrect:
    m = _cc(m, adiff=D_diff, ratio=ar10)   // inflate

IF noround:
    n0 = m
    n1 = ar10 * m
ELSE:
    n0 = ceil(m)
    n1 = ceil(ar10 * m)

n = n0 + n1
D = n0*p0 + n1*p1      // expected events (on rounded n)
Power = power           // designed power
```

### 8b. Power calculation (ss == FALSE)

```
IF ccorrect:
    n0_eff = _cc(n0, adiff=D_diff, ratio=ar10, deflate=TRUE)   // deflate
ELSE:
    n0_eff = n0

// Base formula (score test, distant):
Power = pnorm((D_diff * sqrt(n0_eff) - za * snull) / salt)

IF local:
    Power = pnorm((D_diff * sqrt(n0_eff) - za * snull) / snull)

IF wald:
    Power = pnorm((D_diff * sqrt(n0_eff) - za * salt) / salt)

D = n0*p0 + n1*p1
```

### 9. Return values

```
RETURN:
    n = n0 + n1          (total sample size; only if ss=TRUE)
    n0 = n0              (control arm)
    n1 = n1              (intervention arm)
    power = Power
    alpha = alpha
    allocr = allocr
    Dart = D             (expected events)
```

---

## Main Function: artbin(pr, margin, alpha, power, n, aratios, ltfu, onesided, favourable/unfavourable, condit, local, trend, doses, nvmethod, wald, ccorrect, noround, force, notable, debug, convcrit, format)

### Defaults

```
alpha    = 0.05
power    = 0.8 (if n not given)
convcrit = 1e-7
format   = "%-9.2f"
```

### 1. Input validation and option parsing

```
// n and power mutually exclusive:
IF n > 0 AND power given → ERROR "You can't specify both n() and power()"
IF n == 0 AND power == NULL → power = 0.8

// Parse pr numlist:
npr = length(pr)
IF npr < 2 → ERROR "At least two event probabilities required"
IF margin given AND npr > 2 → ERROR "Can not have margin with >2 groups"
IF npr == 2 AND min(pr) == max(pr) AND margin == NULL → ERROR "Event probabilities can not be equal"

// ngroups is ignored if it mismatches npr:
IF ngroups given AND ngroups != npr → WARNING "ngroups value will be ignored"
ngroups = npr

// Old syntax traps:
IF ni2 == "0" → ERROR (use new syntax)
IF ni or ni2 given → ERROR (use margin() syntax)
IF distant given → ERROR (distant is now the default; use -local- to override)

// niss: flag for NI or substantial-superiority trial:
IF margin == NULL OR margin == 0 → niss = 0
ELSE → niss = 1

// One-sided handling (two mechanisms: onesided flag or onesided2() numlist):
IF onesided2 > 0 OR onesided flag given:
    onesided = 1
ELSE:
    onesided = 0

// Continuity correction (two mechanisms: ccorrect flag or ccorrect2() numlist):
IF ccorrect2 > 0 OR ccorrect flag given:
    ccorrect = 1
ELSE:
    ccorrect = 0

// Warn if NI trial with nchi (nchi will be ignored):
IF niss AND nchi → WARNING "nchi will be ignored"

// Option compatibility:
IF local AND wald → ERROR "Local and Wald not allowed together"
IF condit AND wald → ERROR "Conditional and Wald not allowed together"
IF wald AND nvmethod given AND nvmethod != 1 → ERROR "Need nvm(1) if Wald specified"
IF wald AND nvmethod == NULL → nvmethod = 1
IF nvmethod == NULL OR nvmethod < 1 OR nvmethod > 3 → nvmethod = 3
IF local AND nvmethod != 3 → ERROR "Need nvm(3) if local specified"
IF niss AND condit → ERROR "Can not select conditional option for non-inferiority/substantial-superiority"
IF npr == 2 AND trend → ERROR "Can not select trend option for a 2-arm trial"
IF npr == 2 AND doses given → ERROR "Can not select doses option for a 2-arm trial"
IF condit AND NOT local → WARNING "As conditional has been selected local will be used"; local = TRUE
IF npr == 2 AND margin == 0 AND condit AND ccorrect → ERROR "ccorrect not available in 2-arm superiority conditional case"

// Event probability ap2 range check (undocumented option):
IF ap2 < 0 OR ap2 > 1 → ERROR

// LTFU handling:
IF ltfu given:
    obsfrac = 1 - ltfu
ELSE:
    obsfrac = 1

// If user specifies n (power mode), force noround and save ntotal:
IF n > 0:
    noround = TRUE
    ntotal = n
    IF ltfu given:
        n = round(ntotal * obsfrac, 1)   // art2bin needs integer n
```

### 2. Allocation ratio parsing

```
// Parse aratios numlist into allr[1..npr]:
IF aratios not given:
    allr[a] = 1 for all a
    nar = npr
ELSE:
    nar = length(aratios)
    IF npr > 2 AND nar < npr → ERROR "Please specify the same number of aratios() as pr() for >2 groups"
    allr[a] = aratios[a] for a = 1..nar

// Compute totalallr = sum(allr[1..npr]):
totalallr = sum(allr[1..npr])

// American spelling accommodation:
IF "favorable" → treat as "favourable"
IF "unfavorable" → treat as "unfavourable"
IF both favourable and unfavourable given → ERROR
```

### 3. Infer favourable/unfavourable and trial type (2-arm only)

```
// Track whether user specified outcome direction:
IF favourable/unfavourable not given:
    infer = TRUE
ELSE:
    infer = FALSE

IF npr == 2:
    IF margin == NULL → margin = 0
    IF margin == 0 → trialtype = "superiority"
    w1 = pr[1]; w2 = pr[2]
    threshold = w1 + margin

    IF NOT (favourable or unfavourable given):
        IF w2 < threshold → trialoutcome = "unfavourable"
        IF w2 > threshold → trialoutcome = "favourable"
    ELSE:
        trialoutcome = user-specified

    IF w2 == threshold → ERROR "p2 can not equal p1 + margin"

    // Consistency check (unless force):
    IF trialoutcome == "unfavourable" AND threshold < w2 AND NOT force → ERROR
    IF trialoutcome == "unfavourable" AND threshold < w2 AND force → WARNING
    IF trialoutcome == "favourable" AND threshold > w2 AND NOT force → ERROR
    IF trialoutcome == "favourable" AND threshold > w2 AND force → WARNING

    // Trial type classification:
    IF trialoutcome=="unfavourable" AND margin > 0 OR trialoutcome=="favourable" AND margin < 0:
        trialtype = "non-inferiority"
    ELSE IF trialoutcome=="unfavourable" AND margin < 0 OR trialoutcome=="favourable" AND margin > 0:
        trialtype = "substantial-superiority"
    // (else stays "superiority" from above)

    // Hypothesis strings for NI/sub-sup output:
    IF trialoutcome == "unfavourable":
        H0 = "H0: pi2 - pi1 >= margin"
        H1 = "H1: pi2 - pi1 < margin"
    ELSE:
        H0 = "H0: pi2 - pi1 <= margin"
        H1 = "H1: pi2 - pi1 > margin"
```

### 4. Routing: 2-arm vs k-group

```
// Route to art2bin if:
//   - exactly 2 arms, AND
//   - not the undocumented nchi=TRUE superiority case, AND
//   - condit is not specified
use_art2bin = (npr == 2) AND NOT (niss==0 AND nchi) AND NOT condit

IF use_art2bin:
    → Section 5 (art2bin path)
ELSE:
    → Section 6 (k-group path)
```

---

### 5. Two-arm path (via art2bin)

```
// Call art2bin with noround=TRUE; artbin will apply rounding itself
IF n == 0:
    CALL art2bin(w1, w2, margin=margin, power=power, ar=aratios,
                 alpha=alpha, nvmethod=nvmethod,
                 onesided=onesided, ccorrect=ccorrect, local=local, wald=wald,
                 noround=TRUE)
    n_unrounded = r(n)
    ssize = TRUE
ELSE:
    CALL art2bin(w1, w2, margin=margin, n0=floor(n/(1+ar)), n1=floor(n*ar/(1+ar)),
                 ar=aratios, alpha=alpha, nvmethod=nvmethod,
                 onesided=onesided, ccorrect=ccorrect, local=local, wald=wald,
                 noround=TRUE)
    power = r(power)
    ssize = FALSE

n = r(n)                // unrounded total (used as base for artbin's rounding step)
Power = r(power)
D = r(Dart)             // expected events
allocr = r(allocr)
artcalcused = "2-arm"

// → continue to Section 7 (rounding)
```

---

### 6. K-group path

```
// Additional validation for k-group:
IF alpha <= 0 OR alpha >= 1 → ERROR
IF n < 0 → ERROR
IF niss AND (npr > 2 OR ngroups > 2) → ERROR "Only two groups allowed for NI/sub-sup designs"
IF ccorrect AND ngroups > 2 → ERROR "Continuity correction not allowed for >2 groups"
IF onesided AND ngroups > 2 AND NOT (trend or doses given) → ERROR "One-sided not allowed for >2 groups unless trend specified"

ssize = (n == 0)

// CRITICAL: for k-group, onesided means double alpha for the chi-squared test
IF onesided:
    alpha = 2 * alpha   // chi-sq critical value uses 2*alpha for one-sided
    sided = "one"
ELSE:
    sided = "two"

IF local:
    localdescr = "local"
ELSE:
    localdescr = "distant"
```

#### 6a. K-group NI/sub-sup 2-arm via art2bin (niss = 1, npr == 2 via the k-group branch)

```
// This path is reached when condit is specified with 2 arms or when nchi is used
// (rare/undocumented; the normal 2-arm NI path goes to Section 5)
// Calls art2bin directly; see Section 5 for details
IF niss:
    [analogous to Section 5 art2bin call]
```

#### 6b. K-group superiority (niss = 0, npr >= 2)

This section operates on Stata dataset columns (in R: use vectors of length ngroups).

```
// Setup vectors (length = ngroups):
PI[i]  = pr[i]                          // anticipated event probabilities
AR[i]  = allr[i] / sum(allr)           // normalised allocation ratios (sum to 1)
pibar  = sum(PI * AR)                   // weighted mean probability
s      = pibar * (1 - pibar)            // variance at weighted mean
S[i]   = PI[i] * (1 - PI[i])          // per-arm variance
sbar   = sum(S * AR)                    // weighted mean per-arm variance
K      = ngroups - 1                    // degrees of freedom
MU[i]  = PI[i] - pibar                 // deviations from weighted mean

IF ssize: beta = 1 - power
```

**Trend test (if trend or doses specified):**

```
// Default doses: 0, 1, ..., ngroups-1
IF doses == NULL: DOSE[i] = i - 1  (for i = 1..ngroups)
ELSE: DOSE = user-supplied values (must be non-negative)

// Centre doses by weighted mean:
DOSE = DOSE - sum(DOSE * AR)

tr  = sum(MU * DOSE * AR)             // _sp MU DOSE AR
q0  = sum(DOSE^2 * AR) * s            // _sp DOSE DOSE AR, then * s

IF local:
    q1 = q0
ELSE:
    q1 = sum(DOSE^2 * S * AR)         // _sp DOSE DOSE S AR

IF wald:
    a_crit = sqrt(q1) * qnorm(1 - alpha/2)
ELSE:
    a_crit = sqrt(q0) * qnorm(1 - alpha/2)

IF ssize:
    a_crit = a_crit + sqrt(q1) * qnorm(power)
    n = (a_crit / tr)^2

IF NOT ssize (power mode):
    a_val = |tr| * sqrt(n) - a_crit
    beta  = 1 - pnorm(a_val / sqrt(q1))
    power = 1 - beta

D = n * pibar
→ Section 7 (rounding)
```

**Unconditional test, local alternative OR Wald (no trend):**

```
// For Wald test, q0 is computed via matrix formula (see below)
// For local non-Wald: q0 = sum(MU^2 * AR) / s
IF wald:
    // Build K × K covariance matrix VA (groups 2..K+1 only; group 1 is reference)
    // VA[k,l] for k,l = 1..K:
    FOR k = 1..K:
        FOR l = 1..K:
            kk = k + 1   // group index
            ll = l + 1
            VA[k,l] = S[kk] * ((k==l) / AR[kk] - 1) - S[ll] + sbar

    MU_sub = MU[2..ngroups]   // length K vector, groups 2..K+1

    // q0 = MU_sub' * VA^{-1} * MU_sub
    q0 = (MU_sub %*% solve(VA) %*% MU_sub)[1,1]

ELSE (local, non-wald):
    q0 = sum(MU^2 * AR) / s   // _sp MU MU AR / s

// Critical chi-squared value:
crit_val = qchisq(1 - alpha, df=K)   // Stata: invchi2(K, 1-alpha)

IF ssize:
    lambda = npnchi2(K, crit_val, beta)   // find ncp s.t. pchisq(crit_val, K, ncp) = beta
    n = lambda / q0
    D = n * pibar

IF NOT ssize:
    beta = pchisq(crit_val, df=K, ncp = n * q0)   // Stata: nchi2(K, n*q0, crit_val)
    power = 1 - beta

→ Section 7 (rounding)
```

**Unconditional test, distant alternative (default, non-wald, no trend):**

```
// Additional quantities beyond the local case:
W[i]  = 1 - 2 * AR[i]
a0    = (sum(S) - sbar) / s              // (unweighted sum(S) - weighted mean sbar) / s
q1    = sum(MU^2 * S * AR) / s^2        // _sp MU MU S AR / s^2
a1    = (sum(S^2 * W) + sbar^2) / s^2  // (_sp S S W + sbar^2) / s^2
                                         // Note: _sp S S W = sum(S[i]^2 * W[i])

// Critical chi-squared value:
crit_val = qchisq(1 - alpha, df=K)

IF ssize:
    // Starting estimate from the local approximation:
    n0 = npnchi2(K, crit_val, beta) / q0

    // Evaluate _pe2 at n0:
    beta0 = _pe2(a0, q0, a1, q1, K, n0, crit_val)

    IF |beta0 - beta| <= convcrit:
        n = n0   // already converged
    ELSE:
        // Set initial bisection bounds:
        IF beta0 < beta:   // n0 gives higher power than needed → n0 is upper bound
            nu = n0
            nl = n0 / 2
        ELSE:              // n0 gives lower power than needed → n0 is lower bound
            nl = n0
            nu = 2 * n0

        // Bisection loop:
        WHILE TRUE:
            n_mid = (nl + nu) / 2
            beta_mid = _pe2(a0, q0, a1, q1, K, n_mid, crit_val)

            IF |beta_mid - beta| <= convcrit:
                BREAK
            ELSE IF beta_mid < beta:   // higher power → reduce upper bound
                nu = n_mid
            ELSE:
                nl = n_mid

            IF (nu - nl) <= convcrit:
                BREAK   // interval too small, accept midpoint

        n = n_mid

    D = n * pibar

IF NOT ssize:
    beta = _pe2(a0, q0, a1, q1, K, n, crit_val)
    power = 1 - beta
    D = n * pibar

→ Section 7 (rounding)
```

**Conditional test (Peto's log-odds, no trend):**

```
v    = pibar * (1 - pibar)
LOR[i] = log(PI[i] / (1 - PI[i])) - log(PI[1] / (1 - PI[1]))   // log-odds ratio vs group 1
LOR[1] = 0
LOR    = LOR - sum(LOR * AR)   // centre by weighted mean

q0 = sum(LOR^2 * AR)           // _sp LOR LOR AR
crit_val = qchisq(1 - alpha, df=K)

IF ssize:
    lambda = npnchi2(K, crit_val, beta)
    d = lambda
    l = sqrt(d * (d - 4 * q0 * v))
    d = (d + l) / (2 * q0 * (1 - pibar))
    n = d / pibar

IF NOT ssize:
    d = n * pibar
    l = d * (n - d) * q0 / (n - 1)
    beta = pchisq(crit_val, df=K, ncp=l)
    power = 1 - beta

D = d   // = n * pibar (from SS calculation) or computed d (from power calculation)

→ Section 7 (rounding)
```

**Conditional trend test:**

```
// Doses set up as in unconditional trend (centred by weighted mean)
tr  = sum(DOSE * LOR * AR)    // _sp DOSE LOR AR
q0  = sum(DOSE^2 * AR)        // _sp DOSE DOSE AR

// One-df normal test (not chi-squared):
z_alpha = qnorm(1 - alpha/2)

IF ssize:
    a_val = sqrt(q0) * (z_alpha + qnorm(power))
    lambda = (a_val / tr)^2
    d = lambda
    l = sqrt(d * (d - 4 * v))   // here v = pibar*(1-pibar)
    d = (d + l) / (2 * (1 - pibar))
    n = d / pibar

IF NOT ssize:
    d = n * pibar
    l = d * (n - d) / (n - 1)
    a_val = |tr| * sqrt(l / q0) - z_alpha
    beta = 1 - pnorm(a_val)
    power = 1 - beta

D = d
```

---

### 7. Rounding and per-arm sample sizes (always done at artbin level)

```
// At this point n holds the unrounded total sample size from the calculation.
// For ssize=FALSE (power mode), ntotal was set from user input in Section 1.

// Special case: if npr==2 and only 1 allocation ratio given:
IF npr == 2 AND nar == 1:
    allr[2] = allr[1]
    allr[1] = 1
    totalallr = 2

// Rescale so that allr[1] == 1:
IF allr[1] != 1:
    allr = allr / allr[1]           // divide all by first element
    totalallr = totalallr / allr[1]

nbygroup = n / totalallr            // per-unit sample size

ntotal = 0
D = 0
FOR a = 1..npr:
    IF ssize:
        IF noround:
            n[a] = nbygroup * allr[a] / obsfrac
        ELSE:
            n[a] = ceil(nbygroup * allr[a] / obsfrac)
        ntotal = ntotal + n[a]
    ELSE:  // power mode
        n[a] = ntotal_input * allr[a] / totalallr

    d[a] = n[a] * pr[a] * obsfrac      // expected events in arm a
    D = D + d[a]

// ntotal for ssize=FALSE is the user-supplied n value (not recalculated)
IF NOT ssize: ntotal = ntotal_input
```

### 8. Return values

```
RETURN:
    n       = ntotal          // total sample size
    n[a]    = n[a]            // per-arm sample sizes (n1, n2, ..., nK)
    power   = Power           // designed (ssize=TRUE) or calculated (ssize=FALSE)
    D       = D               // total expected events
    D[a]    = d[a]            // per-arm expected events
```

---

## Utility: artformatnos(n_string, maxlen, format, leading, separator)

Wraps a space-separated list of numbers across multiple output lines so no line exceeds `maxlen` characters. Used only for display output — not relevant for the mathematical translation.

---

## Key behavioral notes

1. **art2bin is always called with `noround=TRUE`**: rounding is applied by artbin in Section 7, never inside art2bin, when called from artbin. art2bin's own rounding is only used when art2bin is called standalone.

2. **K-group one-sided**: when `onesided=TRUE` and the k-group path is used, `alpha` is doubled before computing the chi-squared critical value. This means the test uses `qchisq(1 - 2*alpha, K)`. This is NOT done in the 2-arm art2bin path (which uses `qnorm(1 - alpha)` directly).

3. **LTFU**: applied in the rounding step as `n[a] = ceil(nbygroup * allr[a] / obsfrac)`. The `n` from the calculation (Section 5 or 6) is the *observable* sample size; `n[a]/obsfrac` gives the *recruited* sample size.

4. **D (expected events)**: `d[a] = n[a] * pr[a] * obsfrac`. If LTFU = 0 then `obsfrac = 1` and `d[a] = n[a] * pr[a]`.

5. **Wald test routing**: when `wald=TRUE` and 2 arms, goes to art2bin with `nvmethod=1`. When k-group, uses the matrix formula in Section 6b.

6. **condit forces local**: if user specifies `condit` without `local`, local is silently enabled.

7. **frac_ddp**: a display utility from the wider ART suite that formats a number to N decimal places, returning the result in `r(ddp)`. Not part of the core calculation — safely ignored in translations.

8. **npnchi2**: built-in in Stata; in R must be implemented via `uniroot` (see utility section above).
