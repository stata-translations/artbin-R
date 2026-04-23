# Utility functions for artbin

.inrange01 <- function(...) {
  args <- list(...)
  result <- 1
  for (x in args) {
    result <- result * (x > 0) * (x < 1)
  }
  result
}

# Continuity correction: inflate (deflate=FALSE) or deflate (deflate=TRUE) a sample size
.cc <- function(n, adiff, ratio = 1, deflate = FALSE) {
  a <- (ratio + 1) / (adiff * ratio)
  if (deflate) {
    ((2 * n - a)^2) / (4 * n)
  } else {
    cf <- ((1 + sqrt(1 + 2 * a / n))^2) / 4
    n * cf
  }
}

# Find ncp such that pchisq(x, df, ncp) = p  (Stata built-in npnchi2)
.npnchi2 <- function(df, x, p) {
  f <- function(ncp) pchisq(x, df, ncp) - p
  upper <- 1
  while (pchisq(x, df, upper) > p) upper <- upper * 2
  uniroot(f, interval = c(0, upper))$root
}

# Beta (type-II error) for distant-alternative unconditional k-group test
.pe2 <- function(a0, q0, a1, q1, K, n, crit_val) {
  b0 <- a0 + n * q0
  b1 <- a1 + 2 * n * q1
  l  <- b0^2 - K * b1
  f  <- sqrt(l * (l + K * b1))
  l  <- (l + f) / b1
  f  <- crit_val * (K + l) / b0
  pchisq(f, df = K, ncp = l)
}
