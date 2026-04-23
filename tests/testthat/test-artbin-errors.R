test_that("Error: fewer than 2 probabilities", {
  expect_error(artbin(pr = 0.5), "At least two")
})

test_that("Error: n and power both specified", {
  expect_error(artbin(pr = c(0.1, 0.05), n = 100, power = 0.8), "both")
})

test_that("Error: equal probabilities with no margin", {
  expect_error(artbin(pr = c(0.1, 0.1)), "can not be equal")
})

test_that("Error: margin with >2 groups", {
  expect_error(artbin(pr = c(0.1, 0.2, 0.3), margin = 0.1), "margin")
})

test_that("Error: local and wald together", {
  expect_error(artbin(pr = c(0.1, 0.05), local = TRUE, wald = TRUE), "Local and Wald")
})

test_that("Error: condit and wald together", {
  expect_error(artbin(pr = c(0.1, 0.05), condit = TRUE, wald = TRUE), "Conditional and Wald")
})

test_that("Error: trend with 2 arms", {
  expect_error(artbin(pr = c(0.1, 0.05), trend = TRUE), "2-arm")
})

test_that("Error: doses with 2 arms", {
  expect_error(artbin(pr = c(0.1, 0.05), doses = c(0, 1)), "2-arm")
})

test_that("Error: condit with NI", {
  expect_error(
    artbin(pr = c(0.9, 0.9), margin = -0.05, condit = TRUE),
    "conditional"
  )
})

test_that("Error: alpha out of range", {
  expect_error(artbin(pr = c(0.1, 0.05), alpha = 0), "alpha")
  expect_error(artbin(pr = c(0.1, 0.05), alpha = 1), "alpha")
})

test_that("Error: p2 equals p1 + margin", {
  expect_error(artbin(pr = c(0.1, 0.2), margin = 0.1), "p2 can not equal")
})

test_that("Error: wrong favourable direction without force", {
  expect_error(
    artbin(pr = c(0.1, 0.05), favourable = TRUE),
    "unfavourable"
  )
})

test_that("Warning: wrong direction with force", {
  expect_warning(
    artbin(pr = c(0.1, 0.05), favourable = TRUE, force = TRUE),
    "unfavourable"
  )
})

test_that("Error: ccorrect not available in 2-arm conditional superiority", {
  expect_error(
    artbin(pr = c(0.3, 0.5), condit = TRUE, ccorrect = TRUE),
    "ccorrect"
  )
})

test_that("Error: onesided not allowed for >2 groups without trend", {
  expect_error(
    artbin(pr = c(0.1, 0.2, 0.3), onesided = TRUE),
    "[Oo]ne-sided"
  )
})

test_that("Error: >2 groups without enough aratios", {
  expect_error(
    artbin(pr = c(0.1, 0.2, 0.3), aratios = c(1, 2)),
    "aratios"
  )
})

# From artbin_test_missing_coverage.do section 5-6
test_that("Error: p2 equals p1 + margin (negative margin)", {
  expect_error(artbin(pr = c(0.2, 0.1), margin = -0.1), "p2 can not equal")
})

test_that("Error: doses < 0", {
  expect_error(
    artbin(pr = c(0.1, 0.2, 0.3), doses = c(0, 1, -1)),
    "[Dd]ose"
  )
})

# From artbin_test_missing_coverage.do section 1: ap2 has no effect in R
# (ap2 is not implemented in R as it was a Stata-specific k-arm NI option)

# From artbin_test_missing_coverage.do section 2: force allows contradictory direction
test_that("Force: allows contradictory favourable direction with warning", {
  expect_warning(
    r <- artbin(pr = c(0.3, 0.2), favourable = TRUE, force = TRUE),
    "unfavourable"
  )
  expect_true(!is.na(r$n) && r$n > 0)
})

test_that("Force: power mode with contradictory direction", {
  expect_warning(
    r <- artbin(pr = c(0.3, 0.2), favourable = TRUE, force = TRUE, n = 500),
    "unfavourable"
  )
  expect_true(!is.na(r$power) && r$power > 0 && r$power < 1)
})
