test_that("Pocock 1983: 2-arm Wald superiority n=1156", {
  r <- artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 1156)
  expect_equal(r$n1, 578)
  expect_equal(r$n2, 578)
})

test_that("Score test (nvmethod=3): n=1164", {
  r <- artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9)
  expect_equal(r$n, 1164)
})

test_that("Favourable outcome gives same n as unfavourable flipped", {
  r1 <- artbin(pr = c(0.1, 0.05))
  r2 <- artbin(pr = c(0.9, 0.95), favourable = TRUE)
  expect_equal(r1$n, r2$n)
})

test_that("Two-sided vs one-sided alpha relationship", {
  r1 <- artbin(pr = c(0.1, 0.05), alpha = 0.05)
  r2 <- artbin(pr = c(0.1, 0.05), alpha = 0.025, onesided = TRUE)
  expect_equal(r1$n, r2$n)
})

test_that("Power mode: artbin gives correct power for n=1156", {
  r <- artbin(pr = c(0.1, 0.05), alpha = 0.05, n = 1156, wald = TRUE)
  expect_equal(round(r$power, 4), 0.9, tolerance = 0.001)
})

test_that("Power mode: power increases with n", {
  r1 <- artbin(pr = c(0.1, 0.05), n = 500)
  r2 <- artbin(pr = c(0.1, 0.05), n = 1000)
  expect_gt(r2$power, r1$power)
})

test_that("Unequal allocation 1:2", {
  r <- artbin(pr = c(0.1, 0.05), aratios = c(1, 2))
  expect_equal(r$n2, 2 * r$n1)
})

test_that("Expected events D computed correctly", {
  r <- artbin(pr = c(0.1, 0.05), power = 0.8)
  expect_equal(r$D, r$n1 * 0.1 + r$n2 * 0.05)
})

test_that("Superiority: local alternative gives larger n than distant", {
  r_dist  <- artbin(pr = c(0.1, 0.05))
  r_local <- artbin(pr = c(0.1, 0.05), local = TRUE)
  expect_gt(r_local$n, r_dist$n)
})

test_that("nvmethod=2 fixed marginal totals", {
  r <- artbin(pr = c(0.1, 0.05), nvmethod = 2)
  expect_true(is.numeric(r$n) && r$n > 0)
})

test_that("nvmethod=1 same as wald=TRUE for 2-arm", {
  r1 <- artbin(pr = c(0.1, 0.05), wald = TRUE)
  r2 <- artbin(pr = c(0.1, 0.05), nvmethod = 1)
  expect_equal(r1$n, r2$n)
})

# Reference value from artbin_testing_2.do (Sealed Envelope calculator)
test_that("Superiority SealedEnvelope: n=310 (155 per arm)", {
  r <- artbin(pr = c(0.1, 0.2), alpha = 0.1, power = 0.8, wald = TRUE)
  expect_equal(r$n, 310)
  expect_equal(r$n1, 155)
  expect_equal(r$n2, 155)
})

# Power mode round-trip
test_that("Superiority power round-trip: n=310 → power≈0.8", {
  r <- artbin(pr = c(0.1, 0.2), alpha = 0.1, n = 310, wald = TRUE)
  expect_equal(round(r$power, 1), 0.8)
})

# Expected events D formula (artbin_testing_7.do)
test_that("D formula: NI margin=0.2, noround", {
  r <- artbin(pr = c(0.25, 0.35), margin = 0.2, noround = TRUE)
  expect_equal(r$D, r$n1 * 0.25 + r$n2 * 0.35, tolerance = 1e-10)
})

test_that("D formula: SS margin=-0.1, noround", {
  r <- artbin(pr = c(0.3, 0.5), margin = -0.1, noround = TRUE)
  expect_equal(r$D, r$n1 * 0.3 + r$n2 * 0.5, tolerance = 1e-10)
})

test_that("D formula: 1:2 allocation, noround", {
  r <- artbin(pr = c(0.4, 0.6), aratios = c(1, 2), noround = TRUE)
  expect_equal(r$D, r$n * (0.4 + 0.6 * 2) / (1 + 2), tolerance = 1e-10)
})

# artbin vs internal art2bin consistency (artbin_testing_7.do)
test_that("artbin two-arm gives same n as direct art2bin call", {
  r_artbin <- artbin(pr = c(0.1, 0.1), margin = 0.05, noround = TRUE)
  r_art2bin <- artbin:::.art2bin(0.1, 0.1, margin = 0.05, noround = TRUE)
  expect_equal(r_artbin$n, r_art2bin$n, tolerance = 1e-10)
})
