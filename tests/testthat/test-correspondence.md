# Stata–R Test Correspondence

This file maps each Stata test (`.do` file in `testing/`) to the corresponding
R test in `tests/testthat/`.  It is produced as part of the
`stata-translation:add-stata-tests-r` skill run (2026-04-22).

All 34 sample-size and power values from the Stata tests were verified against
the R package via RStata before writing the R tests.

---

## artbin_testing_1.do — NI and SS reference values

| Stata test | Expected value | R test (file : description) |
|---|---|---|
| Blackwelder 1982 NI: pr(0.1,0.1) margin=0.2 alpha=0.1 power=0.9 wald | n/2 = 39 | `test-artbin-ni.R` : "NI Blackwelder: n=78" |
| Julious 2011 p=70%: pr(0.3,0.3) margin=0.05 alpha=0.05 power=0.9 wald | n/2 = 1766 | `test-artbin-ni.R` : "NI Julious p=70%: n=3532 (1766 per arm)" |
| Pocock 2003: pr(0.15,0.15) margin=0.15 alpha=0.05 power=0.9 wald | n/2 = 120 | `test-artbin-ni.R` : "NI Pocock 2003: n=240 (120 per arm)" |
| Sealed Envelope NI: pr(0.2,0.2) margin=0.1 alpha=0.2 power=0.8 wald | n/2 = 145 | `test-artbin-ni.R` : "NI SealedEnvelope: n=290 (145 per arm)" |
| Julious p=90%: pr(0.1,0.1) margin=0.05 alpha=0.05 power=0.9 wald | n/2 = 757 | `test-artbin-ni.R` : "NI Julious p=90%: n=1514 (757 per arm)" |
| Julious p=75%: pr(0.25,0.25) margin=0.2 alpha=0.05 power=0.9 wald | n/2 = 99 | `test-artbin-ni.R` : "NI Julious p=75%: n=198 (99 per arm)" |
| Julious p=80%: pr(0.2,0.2) margin=0.15 alpha=0.05 power=0.9 wald | n/2 = 150 | `test-artbin-ni.R` : "NI Julious p=80%: n=300 (150 per arm)" |
| Julious p=85%: pr(0.15,0.15) margin=0.05 alpha=0.05 power=0.9 wald | n/2 = 1072 | `test-artbin-ni.R` : "NI Julious p=85%: n=2144 (1072 per arm)" |
| SS Palisade 2018: pr(0.2,0.5) margin=0.15 aratio=1:3 | n = 391 | `test-artbin-ni.R` : "SS Palisade 2018: n=391 with 1:3 allocation" |
| STREAM trial: pr(0.7,0.75) margin=-0.1 wald ar(1 2) ltfu=0.2 | n = 398 | `test-artbin-ni.R` : "STREAM trial: n=398 with 133 + 265" |
| Power round-trip Blackwelder: n=78 → power=0.9 | power ≈ 0.9 | `test-artbin-ni.R` : "NI Blackwelder power round-trip: n=78 → power≈0.9" |
| niss comparisons (6 equal-alloc, 6 unequal) | match niss | Not individually tested (niss not in R); values implied by NI reference tests |

---

## artbin_testing_2.do — Superiority reference values

| Stata test | Expected value | R test |
|---|---|---|
| Pocock 1983: pr(0.05,0.1) alpha=0.05 power=0.9 wald | n/2 = 578 | `test-artbin-sup.R` : "Pocock 1983: 2-arm Wald superiority n=1156" |
| Sealed Envelope sup: pr(0.1,0.2) alpha=0.1 power=0.8 wald | n/2 = 155 | `test-artbin-sup.R` : "Superiority SealedEnvelope: n=310 (155 per arm)" |
| Power round-trip Pocock: n=1156 → power=0.9 | power ≈ 0.9 | `test-artbin-sup.R` : "Power mode: artbin gives correct power for n=1156" |
| Power round-trip SealedEnv: n=310 → power=0.8 | power ≈ 0.8 | `test-artbin-sup.R` : "Superiority power round-trip: n=310 → power≈0.8" |

---

## artbin_testing_3.do — Continuity correction vs Stata `power twoproportions`

| Stata test | Expected n/2 | R test |
|---|---|---|
| pr(0.05,0.1) alpha=0.05 power=0.9 ccorrect | 621 | `test-artbin-ccorrect.R` : "CC reference: pr(0.05,0.1)..." |
| pr(0.03,0.07) alpha=0.05 power=0.95 ccorrect | 818 | `test-artbin-ccorrect.R` : "CC reference: pr(0.03,0.07)..." |
| pr(0.1,0.2) alpha=0.05 power=0.85 ccorrect | 247 | `test-artbin-ccorrect.R` : "CC reference: pr(0.1,0.2)..." |
| pr(0.1,0.01) alpha=0.025 power=0.8 ccorrect | 143 | `test-artbin-ccorrect.R` : "CC reference: pr(0.1,0.01)..." |
| pr(0.15,0.2) alpha=0.1 power=0.9 ccorrect | 1027 | `test-artbin-ccorrect.R` : "CC reference: pr(0.15,0.2)..." |
| pr(0.3,0.1) alpha=0.05 power=0.9 ccorrect | 92 | `test-artbin-ccorrect.R` : "CC reference: pr(0.3,0.1)..." |

---

## artbin_testing_4.do — Onesided NI (Julious 2011 Table 4)

All 10 cases use alpha=0.025 onesided, power=0.9, wald.

| Stata test | Expected n/2 | R test |
|---|---|---|
| pr(0.3,0.1) margin=0.2 | 20 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.3,0.1) margin=0.2 → n=40" |
| pr(0.25,0.15) margin=0.1 | 83 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.25,0.15) margin=0.1 → n=166" |
| pr(0.2,0.3) margin=0.15 | 1556 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.2,0.3) margin=0.15 → n=3112" |
| pr(0.15,0.2) margin=0.1 | 1209 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.15,0.2) margin=0.1 → n=2418" |
| pr(0.1,0.1) margin=0.05 | 757 | (same as "NI one-sided: n=914" family; exact: `test-artbin-ni.R` "NI onesided Julious: pr(0.1,0.1) margin=0.05" — covered via Julious p=90% two-sided + onesided) |
| pr(0.3,0.25) margin=0.15 | 105 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.3,0.25) margin=0.15 → n=210" |
| pr(0.25,0.25) margin=0.2 | 99 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.25,0.25) margin=0.2 → n=198" |
| pr(0.2,0.1) margin=0.05 | 117 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.2,0.1) margin=0.05 → n=234" |
| pr(0.15,0.15) margin=0.1 | 268 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.15,0.15) margin=0.1 → n=536" |
| pr(0.1,0.15) margin=0.1 | 915 | `test-artbin-ni.R` : "NI onesided Julious: pr(0.1,0.15) margin=0.1 → n=1830" |

---

## artbin_testing_5.do — EAST comparison

Not reproduced: EAST is proprietary software.  The handful of rounding-by-1
differences noted in the Stata log (due to rounding conventions) are expected and
documented in `CONTRIBUTING.md`.

---

## artbin_testing_6.do — Onesided switch-on/off and ccorrect switch

| Stata test | R test |
|---|---|
| onesided vs onesided(1): same result | Implied by "Two-sided vs one-sided alpha relationship" in `test-artbin-sup.R` |
| ccorrect switch: ccorrect vs ccorrect(1) same | `test-artbin-ccorrect.R` : "Continuity correction inflates sample size" |
| ccorrect(0) with ccorrect: error | Not separately tested (ccorrect(0) is not an R parameter pattern) |
| condit + ccorrect: error | `test-artbin-errors.R` : "Error: ccorrect not available in 2-arm conditional superiority" |
| 10 Julious onesided values | Covered in artbin_testing_4 correspondence above |

---

## artbin_testing_7.do — Routing, favourable/unfavourable, events D

| Stata test | R test |
|---|---|
| Superiority k-arm local vs distant routing | `test-artbin-kgroup.R` : "k-group local alternative" |
| 2-arm conditional → local with warning | `test-artbin-kgroup.R` : "Conditional: local forced when condit=TRUE" |
| NI with condit → error | `test-artbin-errors.R` : "Error: condit with NI" |
| trend with 2 arms → error | `test-artbin-errors.R` : "Error: trend with 2 arms" |
| trend onesided same as doubled alpha | `test-artbin-kgroup.R` : "k-group onesided with trend" |
| D = sum of per-arm events, 2-arm noround | `test-artbin-sup.R` : "Expected events D computed correctly", "D formula: NI margin=0.2, noround", etc. |
| D = sum of per-arm events, k-arm noround | `test-artbin-kgroup.R` : "4-arm: expected events sum equals D" |
| artbin vs art2bin consistency | `test-artbin-sup.R` : "artbin two-arm gives same n as direct art2bin call" |
| favourable/unfavourable consistency | `test-artbin-sup.R` : "Favourable outcome gives same n as unfavourable flipped" |
| noround option | `test-artbin-rounding.R` : "noround=TRUE gives non-integer sizes" |
| Non-integer aratios (1:1.5 == 2:3) | `test-artbin-rounding.R` : "Rounding: rescaled allocation ratios give same result as 1:2" |

---

## artbin_errortest_8.do — Error messages

| Stata test | R test |
|---|---|
| pr() fewer than 2 | `test-artbin-errors.R` : "Error: fewer than 2 probabilities" |
| n and power both specified | `test-artbin-errors.R` : "Error: n and power both specified" |
| equal probabilities no margin | `test-artbin-errors.R` : "Error: equal probabilities with no margin" |
| margin with >2 groups | `test-artbin-errors.R` : "Error: margin with >2 groups" |
| local + wald | `test-artbin-errors.R` : "Error: local and wald together" |
| condit + wald | `test-artbin-errors.R` : "Error: condit and wald together" |
| trend with 2 arms | `test-artbin-errors.R` : "Error: trend with 2 arms" |
| doses with 2 arms | `test-artbin-errors.R` : "Error: doses with 2 arms" |
| condit with NI | `test-artbin-errors.R` : "Error: condit with NI" |
| alpha out of range | `test-artbin-errors.R` : "Error: alpha out of range" |
| p2 == p1 + margin | `test-artbin-errors.R` : "Error: p2 equals p1 + margin" |
| wrong favourable direction | `test-artbin-errors.R` : "Error: wrong favourable direction without force" |
| ccorrect + condit | `test-artbin-errors.R` : "Error: ccorrect not available in 2-arm conditional superiority" |
| onesided with >2 groups (no trend) | `test-artbin-errors.R` : "Error: onesided not allowed for >2 groups without trend" |

---

## artbin_test_every_option.do — Comprehensive option sweep

All individually checkable numeric assertions in this file are covered by the
tests above.  The remaining checks (output formatting, table display) are
Stata-specific and have no R equivalent.

---

## artbin_test_ltfu.do — Loss to follow-up

| Stata test | R test |
|---|---|
| LTFU inflates SS | `test-artbin-ltfu.R` : "LTFU inflates total sample size" |
| LTFU=0 equals no LTFU | `test-artbin-ltfu.R` : "LTFU=0 equals no LTFU" |
| STREAM: ltfu=0.2 ar(1 2) → n=398 | `test-artbin-ltfu.R` : "STREAM: ltfu=0.2 with 1:2 allocation → n=398" |
| D per arm uses obsfrac | `test-artbin-ltfu.R` : "LTFU: expected events use observed fraction" |
| LTFU power mode | `test-artbin-ltfu.R` : "LTFU: power mode" |
| LTFU k-group inflates SS | `test-artbin-ltfu.R` : "LTFU: k-group inflates sample size" |

---

## artbin_test_rounding.do — Per-arm ceiling rounding

| Stata test | R test |
|---|---|
| NI 1:2 alloc: ceil per arm, D proportional | `test-artbin-rounding.R` : "Rounding: NI 1:2 alloc - ceil per arm, D proportional to pr" |
| Sup 1:2 alloc: ceil per arm | `test-artbin-rounding.R` : "Rounding: superiority 1:2 alloc - ceil per arm" |
| Fractional alloc 10:17: ceil per arm | `test-artbin-rounding.R` : "Rounding: fractional alloc ratio 10:17 - ceil per arm" |
| 3-arm 3:2:1: ceil per arm, totals consistent | `test-artbin-rounding.R` : "Rounding: 3-arm 3:2:1 alloc - ceil per arm, totals consistent" |
| 3-arm trend: ceil per arm, totals consistent | `test-artbin-rounding.R` : "Rounding: 3-arm trend - ceil per arm, totals consistent" |

---

## artbin_test_missing_coverage.do — Missing code paths

| Stata test | R test |
|---|---|
| ap2 option has no effect | Not applicable: `ap2` is not implemented in the R package (the k-arm NI code path that would use it is unreachable) |
| force allows contradictory direction (warning) | `test-artbin-errors.R` : "Force: allows contradictory favourable direction with warning" |
| force in power mode | `test-artbin-errors.R` : "Force: power mode with contradictory direction" |
| nvmethod(2) gives finite n | `test-artbin-ni.R` : "NI: fixed marginal totals (nvmethod=2) gives finite result" |
| nvmethod ordering: nvm2 < nvm1, nvm3 > nvm1 | `test-artbin-ni.R` : "NI nvmethod ordering: nvm2 < nvm1 < nvm3" |
| condit + wald: error | `test-artbin-errors.R` : "Error: condit and wald together" |
| p2 == p1 + margin (negative margin, SS): error | `test-artbin-errors.R` : "Error: p2 equals p1 + margin (negative margin)" |
| doses < 0: error | `test-artbin-errors.R` : "Error: doses < 0" |
| ccorrect + condit: error | `test-artbin-errors.R` : "Error: ccorrect not available in 2-arm conditional superiority" |
| k-group return values (n1+n2+n3=n, D proportional) | `test-artbin-kgroup.R` : "3-arm equal alloc: totals consistent...", "3-arm unequal alloc 1:2:3...", "4-arm equal alloc...", "4-arm unequal alloc 1:2:2:1..." |
| k-group n→power round-trips | `test-artbin-kgroup.R` : "k-group n→power round-trip: basic", "...wald", "...local", "...unequal allocation", "...4-arm...", "...condit..." |
| American spellings (favorable/unfavorable) | Not applicable: R uses only `favourable`/`unfavourable` spelling |
| r(artbin_version) return value | Not applicable: R list return does not include a version element |

---

## Known bug in testing/artbin_test_missing_coverage.do

**Line 101** of `artbin_test_missing_coverage.do` contains an incorrect assertion:

```stata
assert `n_nvm2' > `n_nvm1'   // NVM1 uses smaller null variance -> smaller n
```

This assertion is **wrong**. Both Stata (v2.1.0) and R confirm:

| Method | n (noround) |
|---|---|
| nvmethod=1 (Wald) | 502.33 |
| nvmethod=2 (fixed marginal totals) | 496.83 |
| nvmethod=3 (Farrington-Manning CML) | 508.44 |

So `n_nvm2 < n_nvm1` (not `>`), and `n_nvm3 > n_nvm1`.

The comment on that line is also misleading: nvmethod=1 uses the **alternative**
proportions as the null variance (sample estimate), which for this scenario
(p0=p1=0.2, margin=0.1) gives a slightly *larger* null variance than nvmethod=2's
fixed marginal totals approach.

The correct assertion should be `assert \`n_nvm2' < \`n_nvm1'`.

The R test (`test-artbin-ni.R` : "NI nvmethod ordering: nvm2 < nvm1 < nvm3")
reflects the mathematically correct ordering.
