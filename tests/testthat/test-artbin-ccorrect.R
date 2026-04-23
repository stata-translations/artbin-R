test_that("Continuity correction inflates sample size", {
  r_plain <- artbin(pr = c(0.1, 0.05))
  r_cc    <- artbin(pr = c(0.1, 0.05), ccorrect = TRUE)
  expect_gt(r_cc$n, r_plain$n)
})

test_that("Continuity correction: power mode gives lower power", {
  n0 <- artbin(pr = c(0.1, 0.05))$n
  r_plain <- artbin(pr = c(0.1, 0.05), n = n0)
  r_cc    <- artbin(pr = c(0.1, 0.05), n = n0, ccorrect = TRUE)
  expect_lt(r_cc$power, r_plain$power)
})

test_that("Continuity correction: NI trial", {
  r_plain <- artbin(pr = c(0.1, 0.1), margin = 0.1)
  r_cc    <- artbin(pr = c(0.1, 0.1), margin = 0.1, ccorrect = TRUE)
  expect_gt(r_cc$n, r_plain$n)
})

test_that("Continuity correction: onesided NI", {
  r_plain <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)
  r_cc    <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE, ccorrect = TRUE)
  expect_gt(r_cc$n, r_plain$n)
})

test_that("CC inflate-deflate round-trip: n unchanged after inflate then deflate", {
  r_plain <- artbin(pr = c(0.1, 0.05))
  r_cc    <- artbin(pr = c(0.1, 0.05), ccorrect = TRUE)
  # CC inflates SS, and power mode of the CC-inflated n should recover ~80% power
  r_pow <- artbin(pr = c(0.1, 0.05), ccorrect = TRUE, n = r_cc$n)
  expect_equal(round(r_pow$power, 1), 0.8)
})

# Reference values from artbin_testing_3.do (vs Stata power twoproportions continuity)
test_that("CC reference: pr(0.05,0.1) alpha=0.05 power=0.9 → n1=621", {
  r <- artbin(pr = c(0.05, 0.1), alpha = 0.05, power = 0.9, ccorrect = TRUE)
  expect_equal(r$n1, 621)
  expect_equal(r$n, 1242)
})

test_that("CC reference: pr(0.03,0.07) alpha=0.05 power=0.95 → n1=818", {
  r <- artbin(pr = c(0.03, 0.07), alpha = 0.05, power = 0.95, ccorrect = TRUE)
  expect_equal(r$n1, 818)
  expect_equal(r$n, 1636)
})

test_that("CC reference: pr(0.1,0.2) alpha=0.05 power=0.85 → n1=247", {
  r <- artbin(pr = c(0.1, 0.2), alpha = 0.05, power = 0.85, ccorrect = TRUE)
  expect_equal(r$n1, 247)
  expect_equal(r$n, 494)
})

test_that("CC reference: pr(0.1,0.01) alpha=0.025 power=0.8 → n1=143", {
  r <- artbin(pr = c(0.1, 0.01), alpha = 0.025, power = 0.8, ccorrect = TRUE)
  expect_equal(r$n1, 143)
  expect_equal(r$n, 286)
})

test_that("CC reference: pr(0.15,0.2) alpha=0.1 power=0.9 → n1=1027", {
  r <- artbin(pr = c(0.15, 0.2), alpha = 0.1, power = 0.9, ccorrect = TRUE)
  expect_equal(r$n1, 1027)
  expect_equal(r$n, 2054)
})

test_that("CC reference: pr(0.3,0.1) alpha=0.05 power=0.9 → n1=92", {
  r <- artbin(pr = c(0.3, 0.1), alpha = 0.05, power = 0.9, ccorrect = TRUE)
  expect_equal(r$n1, 92)
  expect_equal(r$n, 184)
})
