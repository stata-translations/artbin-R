test_that("LTFU inflates total sample size", {
  r_plain <- artbin(pr = c(0.1, 0.05))
  r_ltfu  <- artbin(pr = c(0.1, 0.05), ltfu = 0.1)
  expect_gt(r_ltfu$n, r_plain$n)
})

test_that("LTFU=0 equals no LTFU", {
  r_plain <- artbin(pr = c(0.1, 0.05))
  r_ltfu  <- artbin(pr = c(0.1, 0.05), ltfu = 0)
  expect_equal(r_plain$n, r_ltfu$n)
})

test_that("STREAM: ltfu=0.2 with 1:2 allocation → n=398", {
  r <- artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
              aratios = c(1, 2), ltfu = 0.2)
  expect_equal(r$n, 398)
})

test_that("LTFU: expected events use observed fraction", {
  r <- artbin(pr = c(0.1, 0.05), ltfu = 0.1)
  expect_equal(r$D1, r$n1 * 0.1 * 0.9, tolerance = 1e-10)
  expect_equal(r$D2, r$n2 * 0.05 * 0.9, tolerance = 1e-10)
})

test_that("LTFU: power mode", {
  r_n    <- artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
                   aratios = c(1, 2), ltfu = 0.2)
  r_pow  <- artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
                   aratios = c(1, 2), ltfu = 0.2, n = r_n$n)
  expect_equal(round(r_pow$power, 1), 0.8)
})

test_that("LTFU: k-group inflates sample size", {
  r_plain <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
  r_ltfu  <- artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9, ltfu = 0.1)
  expect_gt(r_ltfu$n, r_plain$n)
})
