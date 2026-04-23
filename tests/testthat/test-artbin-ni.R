test_that("NI one-sided: n=914 (457 per arm)", {
  r <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)
  expect_equal(r$n, 914)
  expect_equal(r$n1, 457)
  expect_equal(r$n2, 457)
})

test_that("NI Blackwelder: n=78", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, power = 0.9, wald = TRUE)
  expect_equal(r$n, 78)
})

test_that("STREAM trial: n=398 with 133 + 265", {
  r <- artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
              aratios = c(1, 2), ltfu = 0.2)
  expect_equal(r$n,  398)
  expect_equal(r$n1, 133)
  expect_equal(r$n2, 265)
})

test_that("NI trial: unfavourable outcome with positive margin", {
  r <- artbin(pr = c(0.2, 0.25), margin = 0.1, favourable = FALSE)
  expect_true(r$n > 0)
})

test_that("NI: power mode gives power < 1", {
  r <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE, n = 400)
  expect_gt(r$power, 0)
  expect_lt(r$power, 1)
})

test_that("NI: higher power requires larger n", {
  r80 <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE, power = 0.8)
  r90 <- artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE, power = 0.9)
  expect_gt(r90$n, r80$n)
})

test_that("Substantial-superiority: negative margin favourable", {
  r <- artbin(pr = c(0.3, 0.1), margin = -0.1, favourable = FALSE)
  expect_true(r$n > 0)
})

test_that("NI: constrained ML (nvmethod=3) gives finite result", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.1, nvmethod = 3)
  expect_true(is.finite(r$n))
})

test_that("NI: fixed marginal totals (nvmethod=2) gives finite result", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.1, nvmethod = 2)
  expect_true(is.finite(r$n))
})

# Reference values from artbin_testing_1.do (Julious 2011, Pocock 2003, Blackwelder 1982)
test_that("NI Julious p=70%: n=3532 (1766 per arm)", {
  r <- artbin(pr = c(0.3, 0.3), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 3532)
  expect_equal(r$n1, 1766)
})

test_that("NI Pocock 2003: n=240 (120 per arm)", {
  r <- artbin(pr = c(0.15, 0.15), margin = 0.15, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 240)
  expect_equal(r$n1, 120)
})

test_that("NI SealedEnvelope: n=290 (145 per arm)", {
  r <- artbin(pr = c(0.2, 0.2), margin = 0.1, alpha = 0.2, power = 0.8, wald = TRUE)
  expect_equal(r$n, 290)
  expect_equal(r$n1, 145)
})

test_that("NI Julious p=90%: n=1514 (757 per arm)", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 1514)
  expect_equal(r$n1, 757)
})

test_that("NI Julious p=75%: n=198 (99 per arm)", {
  r <- artbin(pr = c(0.25, 0.25), margin = 0.2, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 198)
  expect_equal(r$n1, 99)
})

test_that("NI Julious p=80%: n=300 (150 per arm)", {
  r <- artbin(pr = c(0.2, 0.2), margin = 0.15, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 300)
  expect_equal(r$n1, 150)
})

test_that("NI Julious p=85%: n=2144 (1072 per arm)", {
  r <- artbin(pr = c(0.15, 0.15), margin = 0.05, alpha = 0.05, power = 0.9, wald = TRUE)
  expect_equal(r$n, 2144)
  expect_equal(r$n1, 1072)
})

# Substantial-superiority reference value (Palisade 2018)
test_that("SS Palisade 2018: n=391 with 1:3 allocation", {
  r <- artbin(pr = c(0.2, 0.5), margin = 0.15, aratios = c(1, 3))
  expect_equal(r$n, 391)
  expect_equal(r$n1, 98)
  expect_equal(r$n2, 293)
})

# Reference values from artbin_testing_4.do (Julious 2011 onesided NI)
test_that("NI onesided Julious: pr(0.3,0.1) margin=0.2 → n=40", {
  r <- artbin(pr = c(0.3, 0.1), margin = 0.2, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 20)
  expect_equal(r$n, 40)
})

test_that("NI onesided Julious: pr(0.25,0.15) margin=0.1 → n=166", {
  r <- artbin(pr = c(0.25, 0.15), margin = 0.1, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 83)
  expect_equal(r$n, 166)
})

test_that("NI onesided Julious: pr(0.2,0.3) margin=0.15 → n=3112", {
  r <- artbin(pr = c(0.2, 0.3), margin = 0.15, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 1556)
  expect_equal(r$n, 3112)
})

test_that("NI onesided Julious: pr(0.15,0.2) margin=0.1 → n=2418", {
  r <- artbin(pr = c(0.15, 0.2), margin = 0.1, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 1209)
  expect_equal(r$n, 2418)
})

test_that("NI onesided Julious: pr(0.3,0.25) margin=0.15 → n=210", {
  r <- artbin(pr = c(0.3, 0.25), margin = 0.15, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 105)
  expect_equal(r$n, 210)
})

test_that("NI onesided Julious: pr(0.2,0.1) margin=0.05 → n=234", {
  r <- artbin(pr = c(0.2, 0.1), margin = 0.05, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 117)
  expect_equal(r$n, 234)
})

test_that("NI onesided Julious: pr(0.15,0.15) margin=0.1 → n=536", {
  r <- artbin(pr = c(0.15, 0.15), margin = 0.1, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 268)
  expect_equal(r$n, 536)
})

test_that("NI onesided Julious: pr(0.1,0.15) margin=0.1 → n=1830", {
  r <- artbin(pr = c(0.1, 0.15), margin = 0.1, alpha = 0.025, power = 0.9,
              onesided = TRUE, wald = TRUE)
  expect_equal(r$n1, 915)
  expect_equal(r$n, 1830)
})

# Power round-trips for NI reference cases
test_that("NI Blackwelder power round-trip: n=78 → power≈0.9", {
  r <- artbin(pr = c(0.1, 0.1), margin = 0.2, alpha = 0.1, n = 78, wald = TRUE)
  expect_equal(round(r$power, 1), 0.9)
})

test_that("NI nvmethod ordering: nvm2 < nvm1 < nvm3", {
  r1 <- artbin(pr = c(0.2, 0.2), margin = 0.1, nvmethod = 1, noround = TRUE)
  r2 <- artbin(pr = c(0.2, 0.2), margin = 0.1, nvmethod = 2, noround = TRUE)
  r3 <- artbin(pr = c(0.2, 0.2), margin = 0.1, nvmethod = 3, noround = TRUE)
  expect_lt(r2$n, r1$n)
  expect_gt(r3$n, r1$n)
})
