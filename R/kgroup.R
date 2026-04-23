# Internal k-group sample size / power function
# Translated from artbin.ado v2.1.2 (k-group sections)

.artbin_kgroup <- function(pr, margin = NULL, alpha = 0.05, power = 0.8,
                           n = 0, aratios = NULL, onesided = FALSE,
                           favourable = NULL, condit = FALSE, local = FALSE,
                           trend = FALSE, doses = NULL, nvmethod = NULL,
                           wald = FALSE, ccorrect = FALSE, noround = FALSE,
                           force = FALSE, convcrit = 1e-7) {

  ngroups <- length(pr)
  K       <- ngroups - 1
  niss    <- !is.null(margin) && margin != 0

  # Additional validation
  if (alpha <= 0 || alpha >= 1) stop("alpha() out of range")
  if (n < 0) stop("n() out of range")
  if (niss && ngroups > 2)
    stop("Only two groups allowed for non-inferiority/substantial superiority designs")
  if (ccorrect && ngroups > 2)
    stop("Correction for continuity not allowed in comparison of > 2 groups")
  if (onesided && ngroups > 2 && !trend && is.null(doses))
    stop("One-sided not allowed in comparison of > 2 groups unless trend/doses specified")

  ss <- (n == 0)

  # For k-group, onesided doubles alpha for chi-squared critical value
  if (onesided) alpha <- 2 * alpha

  # NI/sub-sup 2-arm via art2bin (when reached via k-group path, e.g. condit=TRUE)
  if (niss) {
    mrg  <- margin
    ar21 <- if (!is.null(aratios) && length(aratios) >= 2) aratios[2] / aratios[1] else 1
    p1   <- pr[1]
    p2   <- pr[2]
    if (ss) {
      res <- .art2bin(p1, p2, margin = mrg, ar = aratios, alpha = alpha,
                      power = power, nvmethod = nvmethod, onesided = (onesided != 0),
                      ccorrect = ccorrect, local = local, wald = wald, noround = TRUE,
                      favourable = favourable, force = force)
      n_raw <- res$n
    } else {
      n0 <- floor(n / (1 + ar21))
      n1 <- floor(n * ar21 / (1 + ar21))
      res <- .art2bin(p1, p2, margin = mrg, ar = aratios, alpha = alpha,
                      n0 = n0, n1 = n1, nvmethod = nvmethod, onesided = (onesided != 0),
                      ccorrect = ccorrect, local = local, wald = wald, noround = TRUE,
                      favourable = favourable, force = force)
      power <- res$power
      n_raw <- n
    }
    D <- n_raw * (p1 + p2 * ar21) / (1 + ar21)
    return(list(n = n_raw, power = if (ss) power else res$power, D = D,
                allocr = res$allocr, artcalcused = "2-arm"))
  }

  # Superiority k-group
  PI  <- pr
  if (is.null(aratios)) {
    AR  <- rep(1 / ngroups, ngroups)
    allocr <- "equal group sizes"
  } else {
    raw    <- aratios
    AR     <- raw / sum(raw)
    allocr <- paste(raw, collapse = ":")
  }

  pibar <- sum(PI * AR)
  s     <- pibar * (1 - pibar)
  S     <- PI * (1 - PI)
  sbar  <- sum(S * AR)
  MU    <- PI - pibar

  beta  <- 1 - power

  # For 2-group superiority via k-group: always use trend (as Stata does)
  if (ngroups == 2) trend <- TRUE

  if (!is.null(doses) && !trend) trend <- TRUE

  if (trend || !is.null(doses)) {
    # Trend test
    if (is.null(doses)) {
      DOSE <- seq(0, ngroups - 1)
    } else {
      DOSE <- doses
      if (any(DOSE < 0)) stop("Dose < 0 not allowed")
    }
    DOSE <- DOSE - sum(DOSE * AR)

    tr <- sum(MU * DOSE * AR)
    q0 <- sum(DOSE^2 * AR) * s
    if (local) {
      q1 <- q0
    } else {
      q1 <- sum(DOSE^2 * S * AR)
    }

    if (wald) {
      a_crit <- sqrt(q1) * qnorm(1 - alpha / 2)
    } else {
      a_crit <- sqrt(q0) * qnorm(1 - alpha / 2)
    }

    if (ss) {
      a_crit <- a_crit + sqrt(q1) * qnorm(power)
      n <- (a_crit / tr)^2
    } else {
      a_val <- abs(tr) * sqrt(n) - a_crit
      beta  <- 1 - pnorm(a_val / sqrt(q1))
    }
    D <- n * pibar

  } else if (condit) {
    # Conditional test (Peto's log-odds approximation)
    v   <- pibar * (1 - pibar)
    LOR <- log(PI / (1 - PI)) - log(PI[1] / (1 - PI[1]))
    LOR[1] <- 0
    LOR <- LOR - sum(LOR * AR)

    if (!is.null(doses)) {
      # Conditional trend
      DOSE <- doses
      if (any(DOSE < 0)) stop("Dose < 0 not allowed")
      DOSE <- DOSE - sum(DOSE * AR)

      tr   <- sum(DOSE * LOR * AR)
      q0   <- sum(DOSE^2 * AR)
      z_alpha <- qnorm(1 - alpha / 2)

      if (ss) {
        a_val  <- sqrt(q0) * (z_alpha + qnorm(power))
        lambda <- (a_val / tr)^2
        d      <- lambda
        l      <- sqrt(d * (d - 4 * v))
        d      <- (d + l) / (2 * (1 - pibar))
        n      <- d / pibar
      } else {
        d     <- n * pibar
        l     <- d * (n - d) / (n - 1)
        a_val <- abs(tr) * sqrt(l / q0) - z_alpha
        beta  <- 1 - pnorm(a_val)
      }
      D <- d
    } else {
      # Conditional chi-squared
      q0       <- sum(LOR^2 * AR)
      crit_val <- qchisq(1 - alpha, df = K)

      if (ss) {
        lambda <- .npnchi2(K, crit_val, beta)
        d      <- lambda
        l      <- sqrt(d * (d - 4 * q0 * v))
        d      <- (d + l) / (2 * q0 * (1 - pibar))
        n      <- d / pibar
      } else {
        d    <- n * pibar
        l    <- d * (n - d) * q0 / (n - 1)
        beta <- pchisq(crit_val, df = K, ncp = l)
      }
      D <- d
    }

  } else if (local || wald) {
    # Unconditional local / Wald
    if (wald) {
      VA <- matrix(0, K, K)
      for (k in seq_len(K)) {
        for (l in seq_len(K)) {
          kk <- k + 1
          ll <- l + 1
          VA[k, l] <- S[kk] * ((k == l) / AR[kk] - 1) - S[ll] + sbar
        }
      }
      MU_sub <- MU[-1]
      q0 <- as.numeric(MU_sub %*% solve(VA) %*% MU_sub)
    } else {
      q0 <- sum(MU^2 * AR) / s
    }

    crit_val <- qchisq(1 - alpha, df = K)

    if (ss) {
      lambda <- .npnchi2(K, crit_val, beta)
      n <- lambda / q0
      D <- n * pibar
    } else {
      beta  <- pchisq(crit_val, df = K, ncp = n * q0)
      D     <- n * pibar
    }

  } else {
    # Unconditional distant alternative (default)
    W  <- 1 - 2 * AR
    q0 <- sum(MU^2 * AR) / s
    a0 <- (sum(S) - sbar) / s
    q1 <- sum(MU^2 * S * AR) / s^2
    a1 <- (sum(S^2 * W) + sbar^2) / s^2

    crit_val <- qchisq(1 - alpha, df = K)

    if (ss) {
      n0_est  <- .npnchi2(K, crit_val, beta) / q0
      beta0   <- .pe2(a0, q0, a1, q1, K, n0_est, crit_val)

      if (abs(beta0 - beta) <= convcrit) {
        n <- n0_est
      } else {
        if (beta0 < beta) {
          nu <- n0_est
          nl <- n0_est / 2
        } else {
          nl <- n0_est
          nu <- 2 * n0_est
        }
        repeat {
          n_mid    <- (nl + nu) / 2
          beta_mid <- .pe2(a0, q0, a1, q1, K, n_mid, crit_val)
          if (abs(beta_mid - beta) <= convcrit) break
          if (beta_mid < beta) nu <- n_mid else nl <- n_mid
          if ((nu - nl) <= convcrit) break
        }
        n <- n_mid
      }
      D <- n * pibar
    } else {
      beta <- .pe2(a0, q0, a1, q1, K, n, crit_val)
      D    <- n * pibar
    }
  }

  power <- 1 - beta
  list(n = n, power = power, D = D, allocr = allocr, artcalcused = "k-arm")
}
