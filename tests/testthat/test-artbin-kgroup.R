test_that("4-arm superiority: n=176 (44 per arm)", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  expect_equal(r$n, 176)
  expect_equal(r$n1, 44)
  expect_equal(r$n2, 44)
  expect_equal(r$n3, 44)
  expect_equal(r$n4, 44)
})

test_that("3-arm superiority gives finite positive result", {
  r <- artbin(pr = c(0.2, 0.3, 0.4))
  expect_true(is.finite(r$n))
  expect_gt(r$n, 0)
})

test_that("3-arm: power mode gives valid power", {
  n0 <- artbin(pr = c(0.2, 0.3, 0.4))$n
  r  <- artbin(pr = c(0.2, 0.3, 0.4), n = n0)
  expect_equal(round(r$power, 1), 0.8)
})

test_that("k-group local alternative", {
  r_dist  <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  r_local <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9, local = TRUE)
  expect_true(is.finite(r_local$n) && r_local$n > 0)
})

test_that("Trend test: 3 arms", {
  r <- artbin(pr = c(0.2, 0.3, 0.4), trend = TRUE)
  expect_true(is.finite(r$n) && r$n > 0)
})

test_that("Trend test with doses", {
  r <- artbin(pr = c(0.2, 0.3, 0.4), doses = c(0, 1, 3))
  expect_true(is.finite(r$n) && r$n > 0)
})

test_that("Conditional test: 2-arm superiority", {
  r <- artbin(pr = c(0.3, 0.5), condit = TRUE)
  expect_true(is.finite(r$n) && r$n > 0)
})

test_that("Conditional: local forced when condit=TRUE", {
  expect_message(
    r <- artbin(pr = c(0.3, 0.5), condit = TRUE),
    "local"
  )
})

test_that("k-group: unequal allocation", {
  r <- artbin(pr = c(0.1, 0.2, 0.3), aratios = c(1, 2, 2))
  expect_equal(r$n2, 2 * r$n1)
  expect_equal(r$n3, 2 * r$n1)
})

test_that("k-group onesided with trend", {
  r <- artbin(pr = c(0.2, 0.3, 0.4), trend = TRUE, onesided = TRUE)
  expect_true(is.finite(r$n) && r$n > 0)
})

test_that("4-arm: expected events sum equals D", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  D_sum <- r$D1 + r$D2 + r$D3 + r$D4
  expect_equal(D_sum, r$D, tolerance = 1e-10)
})

# From artbin_test_missing_coverage.do section 8: k-group return values
test_that("3-arm equal alloc: totals consistent and D per arm proportional to pr", {
  r <- artbin(pr = c(0.2, 0.3, 0.4), noround = TRUE)
  expect_equal(r$n, r$n1 + r$n2 + r$n3)
  expect_equal(r$D, r$D1 + r$D2 + r$D3, tolerance = 1e-9)
  expect_equal(r$n1, r$n2, tolerance = 1e-6)  # equal allocation
  expect_equal(r$D1 / r$n1, 0.2, tolerance = 1e-7)
  expect_equal(r$D2 / r$n2, 0.3, tolerance = 1e-7)
  expect_equal(r$D3 / r$n3, 0.4, tolerance = 1e-7)
})

test_that("3-arm unequal alloc 1:2:3: arm sizes in correct ratio", {
  r <- artbin(pr = c(0.2, 0.3, 0.4), aratios = c(1, 2, 3), noround = TRUE)
  expect_equal(r$n, r$n1 + r$n2 + r$n3, tolerance = 1e-7)
  expect_equal(r$n2 / r$n1, 2, tolerance = 1e-6)
  expect_equal(r$n3 / r$n1, 3, tolerance = 1e-6)
})

test_that("4-arm equal alloc: all arm sizes equal, noround", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), noround = TRUE)
  expect_equal(r$n, r$n1 + r$n2 + r$n3 + r$n4)
  expect_equal(r$D, r$D1 + r$D2 + r$D3 + r$D4, tolerance = 1e-9)
  expect_equal(r$n1, r$n2, tolerance = 1e-7)
  expect_equal(r$n1, r$n3, tolerance = 1e-7)
  expect_equal(r$n1, r$n4, tolerance = 1e-7)
})

test_that("4-arm unequal alloc 1:2:2:1: arm size ratios correct", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), aratios = c(1, 2, 2, 1), noround = TRUE)
  expect_equal(r$n, r$n1 + r$n2 + r$n3 + r$n4, tolerance = 1e-9)
  expect_equal(r$n2 / r$n1, 2, tolerance = 1e-6)
  expect_equal(r$n3 / r$n1, 2, tolerance = 1e-6)
  expect_equal(r$n4 / r$n1, 1, tolerance = 1e-6)
})

# From artbin_test_missing_coverage.do section 10: k-group n→power round-trips
test_that("k-group n→power round-trip: basic", {
  r_ss  <- artbin(pr = c(0.1, 0.2, 0.3), power = 0.85, noround = TRUE)
  r_pow <- artbin(pr = c(0.1, 0.2, 0.3), n = r_ss$n)
  expect_equal(r_pow$power, 0.85, tolerance = 0.001)
})

test_that("k-group n→power round-trip: wald", {
  r_ss  <- artbin(pr = c(0.1, 0.2, 0.3), wald = TRUE, power = 0.85, noround = TRUE)
  r_pow <- artbin(pr = c(0.1, 0.2, 0.3), wald = TRUE, n = r_ss$n)
  expect_equal(r_pow$power, 0.85, tolerance = 0.001)
})

test_that("k-group n→power round-trip: local", {
  r_ss  <- artbin(pr = c(0.1, 0.2, 0.3), local = TRUE, power = 0.85, noround = TRUE)
  r_pow <- artbin(pr = c(0.1, 0.2, 0.3), local = TRUE, n = r_ss$n)
  expect_equal(r_pow$power, 0.85, tolerance = 0.001)
})

test_that("k-group n→power round-trip: unequal allocation", {
  r_ss  <- artbin(pr = c(0.1, 0.2, 0.3), aratios = c(1, 2, 1), power = 0.85, noround = TRUE)
  r_pow <- artbin(pr = c(0.1, 0.2, 0.3), aratios = c(1, 2, 1), n = r_ss$n)
  expect_equal(r_pow$power, 0.85, tolerance = 0.001)
})

test_that("4-arm n→power gives valid power", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), n = 400)
  expect_true(!is.na(r$power))
  expect_gt(r$power, 0)
  expect_lt(r$power, 1)
})

test_that("k-group condit n→power round-trip", {
  r_ss  <- artbin(pr = c(0.1, 0.2, 0.3), condit = TRUE, power = 0.85, noround = TRUE)
  r_pow <- artbin(pr = c(0.1, 0.2, 0.3), condit = TRUE, n = r_ss$n)
  expect_equal(r_pow$power, 0.85, tolerance = 0.001)
})
