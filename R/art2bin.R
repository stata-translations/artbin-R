# Internal two-arm sample size / power function
# Translated from art2bin.ado v1.01

.art2bin <- function(p0, p1, margin = 0, ar = NULL, alpha = 0.05, power = 0.8,
                     n = 0, n0 = 0, n1 = 0, nvmethod = NULL,
                     onesided = FALSE, ccorrect = FALSE, local = FALSE,
                     wald = FALSE, noround = FALSE,
                     favourable = NULL, force = FALSE) {

  if (alpha <= 0 || alpha >= 1) stop("alpha() out of range")
  if (p0 <= 0 || p0 >= 1)      stop("Control event probability out of range")
  if (p1 <= 0 || p1 >= 1)      stop("Intervention event probability out of range")
  if (power <= 0 || power >= 1) stop("power() out of range")

  # Parse allocation ratio
  if (is.null(ar) ||
      (length(ar) == 1 && ar == 1) ||
      (length(ar) == 2 && ar[1] == 1 && ar[2] == 1)) {
    allocr <- "equal group sizes"
    ar10   <- 1
  } else if (length(ar) == 1) {
    allocr <- paste0("1:", ar[1])
    ar10   <- ar[1]
  } else if (length(ar) == 2) {
    allocr <- paste0(ar[1], ":", ar[2])
    ar10   <- ar[2] / ar[1]
  } else {
    stop("Invalid allocation ratio")
  }

  # Option compatibility
  if (wald && !is.null(nvmethod) && nvmethod != 1)
    stop("Need nvm(1) if Wald specified")
  if (wald && is.null(nvmethod)) nvmethod <- 1
  if (local && wald) stop("Local and Wald not allowed together")
  if (is.null(nvmethod) || nvmethod < 1 || nvmethod > 3) nvmethod <- 3
  if (local && nvmethod != 3) stop("Need nvm(3) if local specified")

  # If user specifies n, turn noround on
  if (n > 0) noround <- TRUE

  # Determine sample size mode
  ss <- (n == 0 && n0 == 0 && n1 == 0)
  if (!ss && n > 0 && n0 == 0 && n1 == 0) {
    n0 <- n / (1 + ar10)
    n1 <- n - n0
  } else if (!ss && n == 0) {
    if (n1 == 0)      n1 <- n0 * ar10
    else if (n0 == 0) n0 <- n1 / ar10
    else {
      allocr <- paste0(n0, ":", n1)
      ar10   <- n1 / n0
    }
  }

  # Favourable / unfavourable and trial type
  mrg       <- margin
  threshold <- p0 + mrg

  if (is.null(favourable)) {
    if (p1 < threshold)      trialoutcome <- "Unfavourable"
    else if (p1 > threshold) trialoutcome <- "Favourable"
    else stop("p2 can not equal p1 + margin")
  } else {
    trialoutcome <- if (isTRUE(favourable)) "Favourable" else "Unfavourable"
  }
  if (p1 == threshold) stop("p2 can not equal p1 + margin")

  if (trialoutcome == "Unfavourable" && threshold < p1) {
    if (!force) stop("artbin thinks your outcome is favourable. Please check your command. If your command is correct then consider using the force option.")
    warning("artbin thinks your outcome should be favourable.")
  }
  if (trialoutcome == "Favourable" && threshold > p1) {
    if (!force) stop("artbin thinks your outcome is unfavourable. Please check your command. If your command is correct then consider using the force option.")
    warning("artbin thinks your outcome should be unfavourable.")
  }

  # Null hypothesis event probabilities
  if (nvmethod == 1) {
    p0null <- p0
    p1null <- p1
  } else if (nvmethod == 2) {
    p0null <- (p0 + ar10 * p1 - ar10 * mrg) / (1 + ar10)
    p1null <- (p0 + ar10 * p1 + mrg)         / (1 + ar10)
    if (.inrange01(p0null, p1null) == 0)
      stop("Event probabilities and/or non-inferiority/superiority margin are incompatible with the requested fixed marginal totals method")
  } else {
    a   <- 1 + ar10
    b   <- mrg * (ar10 + 2) - 1 - ar10 - p0 - ar10 * p1
    cc  <- (mrg - 1 - ar10 - 2 * p0) * mrg + p0 + ar10 * p1
    d   <- p0 * mrg * (1 - mrg)
    v   <- (b / (3 * a))^3 - (b * cc) / (6 * a^2) + d / (2 * a)
    u   <- sign(v) * sqrt((b / (3 * a))^2 - cc / (3 * a))
    toosmall <- 1e-12
    cos_val  <- if (abs(v) <= toosmall && abs(u^3) <= toosmall) 0 else v / u^3
    w        <- (pi + acos(cos_val)) / 3
    p0null   <- 2 * u * cos(w) - b / (3 * a)
    p1null   <- p0null + mrg
  }

  # Core quantities
  D_diff <- abs(p1 - p0 - mrg)
  za     <- if (onesided) qnorm(1 - alpha) else qnorm(1 - alpha / 2)
  zb     <- qnorm(power)
  snull  <- sqrt(p0null * (1 - p0null) + p1null * (1 - p1null) / ar10)
  salt   <- sqrt(p0 * (1 - p0) + p1 * (1 - p1) / ar10)

  if (ss) {
    m <- ((za * snull + zb * salt) / D_diff)^2
    if (local) m <- ((za * snull + zb * snull) / D_diff)^2
    if (wald)  m <- ((za * salt  + zb * salt)  / D_diff)^2

    if (ccorrect) m <- .cc(m, adiff = D_diff, ratio = ar10)

    if (noround) {
      n0 <- m
      n1 <- ar10 * m
    } else {
      n0 <- ceiling(m)
      n1 <- ceiling(ar10 * m)
    }
    n_total <- n0 + n1
    D       <- n0 * p0 + n1 * p1
    Power   <- power
  } else {
    n0_eff <- if (ccorrect) .cc(n0, adiff = D_diff, ratio = ar10, deflate = TRUE) else n0
    Power  <- pnorm((D_diff * sqrt(n0_eff) - za * snull) / salt)
    if (local) Power <- pnorm((D_diff * sqrt(n0_eff) - za * snull) / snull)
    if (wald)  Power <- pnorm((D_diff * sqrt(n0_eff) - za * salt)  / salt)
    n_total <- n0 + n1
    D       <- n0 * p0 + n1 * p1
  }

  list(n = n_total, n0 = n0, n1 = n1, power = Power,
       alpha = alpha, allocr = allocr, Dart = D)
}
