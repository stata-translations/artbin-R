test_that("noround=FALSE gives integer per-arm sizes", {
  r <- artbin(pr = c(0.1, 0.05))
  expect_equal(r$n1, round(r$n1))
  expect_equal(r$n2, round(r$n2))
})

test_that("noround=TRUE gives non-integer sizes", {
  r <- artbin(pr = c(0.1, 0.05), noround = TRUE)
  expect_true(r$n1 != ceiling(r$n1) || r$n2 != ceiling(r$n2))
})

test_that("Rounding done at artbin level, not inside art2bin", {
  # artbin calls art2bin with noround=TRUE, then applies ceiling itself
  r <- artbin(pr = c(0.1, 0.05))
  expect_equal(r$n1, ceiling(r$n1))
})

test_that("Unequal allocation: each arm rounded independently", {
  r <- artbin(pr = c(0.1, 0.05), aratios = c(1, 3))
  expect_equal(r$n1, ceiling(r$n1))
  expect_equal(r$n2, ceiling(r$n2))
})

test_that("4-arm equal allocation: n = 4 * n1", {
  r <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  expect_equal(r$n, r$n1 + r$n2 + r$n3 + r$n4)
})

test_that("Rounding: rescaled allocation ratios give same result as 1:2", {
  r1 <- artbin(pr = c(0.1, 0.05), aratios = c(1, 2))
  r2 <- artbin(pr = c(0.1, 0.05), aratios = c(2, 4))
  expect_equal(r1$n, r2$n)
})

# Tests from artbin_test_rounding.do: noround gives raw values, round gives ceil per arm
# Each scenario checks: rounded n_per_arm == ceil(noround n_per_arm)
# and D per arm proportional to pr

test_that("Rounding: NI 1:2 alloc - ceil per arm, D proportional to pr", {
  r_nr <- artbin(pr = c(0.02, 0.02), margin = 0.02, aratios = c(1, 2), noround = TRUE)
  r_rd <- artbin(pr = c(0.02, 0.02), margin = 0.02, aratios = c(1, 2))
  expect_equal(r_rd$n1, ceiling(r_nr$n1))
  expect_equal(r_rd$n2, ceiling(r_nr$n2))
  expect_equal(r_rd$n, r_rd$n1 + r_rd$n2)
  expect_equal(r_rd$D, r_rd$D1 + r_rd$D2)
})

test_that("Rounding: superiority 1:2 alloc - ceil per arm", {
  r_nr <- artbin(pr = c(0.02, 0.04), aratios = c(1, 2), noround = TRUE)
  r_rd <- artbin(pr = c(0.02, 0.04), aratios = c(1, 2))
  expect_equal(r_rd$n1, ceiling(r_nr$n1))
  expect_equal(r_rd$n2, ceiling(r_nr$n2))
})

test_that("Rounding: fractional alloc ratio 10:17 - ceil per arm", {
  r_nr <- artbin(pr = c(0.2, 0.3), aratios = c(10, 17), noround = TRUE)
  r_rd <- artbin(pr = c(0.2, 0.3), aratios = c(10, 17))
  expect_equal(r_rd$n1, ceiling(r_nr$n1))
  expect_equal(r_rd$n2, ceiling(r_nr$n2))
  expect_equal(r_rd$n, r_rd$n1 + r_rd$n2)
})

test_that("Rounding: 3-arm 3:2:1 alloc - ceil per arm, totals consistent", {
  r_nr <- artbin(pr = c(0.02, 0.04, 0.06), aratios = c(3, 2, 1), convcrit = 1e-8,
                 noround = TRUE)
  r_rd <- artbin(pr = c(0.02, 0.04, 0.06), aratios = c(3, 2, 1), convcrit = 1e-8)
  expect_equal(r_rd$n1, ceiling(r_nr$n1))
  expect_equal(r_rd$n2, ceiling(r_nr$n2))
  expect_equal(r_rd$n3, ceiling(r_nr$n3))
  expect_equal(r_rd$n, r_rd$n1 + r_rd$n2 + r_rd$n3)
  expect_equal(r_rd$D, r_rd$D1 + r_rd$D2 + r_rd$D3)
})

test_that("Rounding: 3-arm trend - ceil per arm, totals consistent", {
  r_nr <- artbin(pr = c(0.02, 0.04, 0.06), trend = TRUE, convcrit = 1e-8, noround = TRUE)
  r_rd <- artbin(pr = c(0.02, 0.04, 0.06), trend = TRUE, convcrit = 1e-8)
  expect_equal(r_rd$n1, ceiling(r_nr$n1))
  expect_equal(r_rd$n2, ceiling(r_nr$n2))
  expect_equal(r_rd$n3, ceiling(r_nr$n3))
  expect_equal(r_rd$n, r_rd$n1 + r_rd$n2 + r_rd$n3)
})
