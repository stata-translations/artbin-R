#' Sample Size and Power for Binary Outcome Clinical Trials
#'
#' Calculates the power or total sample size for various tests comparing K
#' anticipated probabilities for binary outcomes. Supports superiority,
#' non-inferiority, and substantial-superiority trial designs.
#'
#' @param pr numeric vector of length >= 2. Anticipated event probabilities.
#'   `pr[1]` is the control group probability; `pr[2]`, `pr[3]`, ... are the
#'   treatment group probabilities.
#' @param margin numeric or NULL. Non-inferiority or substantial-superiority
#'   margin. If NULL or 0, a superiority design is assumed.
#' @param alpha numeric. Significance level (default 0.05).
#' @param power numeric or NULL. Desired power. If NULL and `n` is NULL,
#'   defaults to 0.80. Supply either `power` or `n`, not both.
#' @param n integer or NULL. Total sample size. If supplied, power is calculated
#'   instead of sample size.
#' @param aratios numeric vector or NULL. Allocation ratio(s). For a 2-arm
#'   trial `c(1, 2)` means 1 control : 2 treatment. Default is equal allocation.
#' @param ltfu numeric or NULL. Proportion lost to follow-up (0 to <1). The
#'   total sample size will be inflated accordingly.
#' @param onesided logical. If TRUE, the significance level `alpha` is treated
#'   as one-sided (default FALSE).
#' @param favourable logical or NULL. If TRUE the outcome is favourable
#'   (higher probability is better); if FALSE it is unfavourable. If NULL
#'   (default) the program infers the direction.
#' @param condit logical. If TRUE applies a conditional test using Peto's
#'   odds-ratio approximation (default FALSE).
#' @param local logical. If TRUE calculates under local alternatives; valid
#'   only for small treatment effects (default FALSE).
#' @param trend logical. If TRUE applies a linear trend test for k-group trials
#'   (default FALSE).
#' @param doses numeric vector or NULL. Doses for the linear trend test.
#'   Default is 0, 1, ..., K-1.
#' @param nvmethod integer or NULL. Method for estimating null-hypothesis
#'   variance. 1 = sample estimates (Wald), 2 = fixed marginal totals,
#'   3 = constrained maximum likelihood (default). Set automatically to 1
#'   when `wald = TRUE`.
#' @param wald logical. If TRUE applies a Wald test instead of the score test
#'   (default FALSE).
#' @param ccorrect logical. If TRUE applies a continuity correction
#'   (default FALSE).
#' @param noround logical. If TRUE the per-group sample sizes are not rounded
#'   up to the nearest integer (default FALSE).
#' @param force logical. If TRUE overrides the program's inference of the
#'   favourable/unfavourable outcome direction (default FALSE).
#' @param convcrit numeric. Convergence criterion for the iterative k-group
#'   calculation (default 1e-7).
#'
#' @return A list with elements:
#'   \describe{
#'     \item{`n`}{Total sample size.}
#'     \item{`n1`, `n2`, ...}{Sample size per group (named `n1`, `n2`, ...).}
#'     \item{`power`}{Power (designed or calculated).}
#'     \item{`D`}{Total expected events.}
#'     \item{`D1`, `D2`, ...}{Expected events per group.}
#'   }
#'
#' @examples
#' # Superiority, Wald test (Pocock 1983: 1156 per Wald)
#' artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9, wald = TRUE)
#'
#' # One-sided non-inferiority
#' artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)
#'
#' # 4-arm superiority
#' artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)
#'
#' # STREAM trial (NI with LTFU and unequal allocation)
#' artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
#'        aratios = c(1, 2), ltfu = 0.2)
#'
#' @export
artbin <- function(pr, margin = NULL, alpha = 0.05, power = NULL, n = NULL,
                   aratios = NULL, ltfu = NULL, onesided = FALSE,
                   favourable = NULL, condit = FALSE, local = FALSE,
                   trend = FALSE, doses = NULL, nvmethod = NULL,
                   wald = FALSE, ccorrect = FALSE, noround = FALSE,
                   force = FALSE, convcrit = 1e-7) {

  # ---------- Input validation ----------
  npr <- length(pr)
  if (npr < 2) stop("At least two event probabilities required")
  if (!is.null(margin) && margin != 0 && npr > 2)
    stop("Can not have margin with >2 groups")
  if (!is.null(n) && !is.null(power))
    stop("You can't specify both n() and power()")
  if (is.null(power) && is.null(n)) power <- 0.8
  if (npr == 2 && min(pr) == max(pr) && (is.null(margin) || margin == 0))
    stop("Event probabilities can not be equal")

  niss <- !is.null(margin) && margin != 0

  if (!is.null(aratios)) {
    nar <- length(aratios)
    if (npr > 2 && nar < npr)
      stop("Please specify the same number of aratios() as pr() for >2 groups")
  } else {
    nar <- npr
  }

  # Option compatibility
  if (local && wald)  stop("Local and Wald not allowed together")
  if (condit && wald) stop("Conditional and Wald not allowed together")
  if (wald && !is.null(nvmethod) && nvmethod != 1)
    stop("Need nvm(1) if Wald specified")
  if (wald && is.null(nvmethod)) nvmethod <- 1
  if (is.null(nvmethod) || nvmethod < 1 || nvmethod > 3) nvmethod <- 3
  if (local && nvmethod != 3) stop("Need nvm(3) if local specified")
  if (niss && condit)
    stop("Can not select conditional option for non-inferiority/substantial-superiority trial")
  if (npr == 2 && trend) stop("Can not select trend option for a 2-arm trial")
  if (npr == 2 && !is.null(doses)) stop("Can not select doses option for a 2-arm trial")
  if (condit && !local) {
    message("NOTE: As conditional has been selected local will be used.")
    local <- TRUE
  }
  if (npr == 2 && (is.null(margin) || margin == 0) && condit && ccorrect)
    stop("ccorrect is not currently available in the 2-arm superiority conditional case")

  # LTFU
  obsfrac <- if (!is.null(ltfu)) 1 - ltfu else 1

  # If user specifies n → power mode; handle LTFU on n
  ssize <- is.null(n)
  if (!ssize) {
    noround <- TRUE
    ntotal  <- n
    if (!is.null(ltfu)) n <- round(ntotal * obsfrac)
  }

  # Allocation ratio vectors
  if (!is.null(aratios)) {
    allr <- aratios
    if (length(allr) < npr) allr <- c(allr, rep(allr[length(allr)], npr - length(allr)))
  } else {
    allr <- rep(1, npr)
  }
  totalallr <- sum(allr[seq_len(npr)])

  # ---------- 2-arm favourable/unfavourable inference ----------
  if (npr == 2) {
    if (is.null(margin)) margin <- 0
    w1        <- pr[1]
    w2        <- pr[2]
    threshold <- w1 + margin

    if (is.null(favourable)) {
      if (w2 < threshold)      trialoutcome <- "unfavourable"
      else if (w2 > threshold) trialoutcome <- "favourable"
      else stop("p2 can not equal p1 + margin")
    } else {
      trialoutcome <- if (isTRUE(favourable)) "favourable" else "unfavourable"
    }
    if (w2 == threshold) stop("p2 can not equal p1 + margin")

    if (trialoutcome == "unfavourable" && threshold < w2) {
      if (!force) stop("artbin thinks your outcome is favourable. Please check your command. If your command is correct then consider using the force option.")
      warning("artbin thinks your outcome should be favourable.")
    }
    if (trialoutcome == "favourable" && threshold > w2) {
      if (!force) stop("artbin thinks your outcome is unfavourable. Please check your command. If your command is correct then consider using the force option.")
      warning("artbin thinks your outcome should be unfavourable.")
    }
    fav_arg <- (trialoutcome == "favourable")
  } else {
    fav_arg  <- favourable
    margin   <- if (is.null(margin)) 0 else margin
  }

  # ---------- Routing ----------
  # 2-arm → art2bin unless condit
  use_art2bin <- (npr == 2) && !condit

  if (use_art2bin) {
    if (ssize) {
      res <- .art2bin(w1, w2, margin = margin, ar = aratios,
                      alpha = alpha, power = power, nvmethod = nvmethod,
                      onesided = onesided, ccorrect = ccorrect,
                      local = local, wald = wald, noround = TRUE,
                      favourable = fav_arg, force = force)
      n_raw <- res$n
    } else {
      ar10 <- if (!is.null(aratios) && length(aratios) >= 2) aratios[2] / aratios[1] else
              if (!is.null(aratios)) aratios[1] else 1
      n0   <- floor(n / (1 + ar10))
      n1   <- floor(n * ar10 / (1 + ar10))
      res  <- .art2bin(w1, w2, margin = margin, ar = aratios,
                       alpha = alpha, n0 = n0, n1 = n1, nvmethod = nvmethod,
                       onesided = onesided, ccorrect = ccorrect,
                       local = local, wald = wald, noround = TRUE,
                       favourable = fav_arg, force = force)
      power <- res$power
      n_raw <- n
    }
    allocr <- res$allocr
    Power  <- res$power

  } else {
    # K-group path
    n_in <- if (ssize) 0 else n
    res  <- .artbin_kgroup(pr = pr, margin = if (niss) margin else NULL,
                           alpha = alpha, power = if (ssize) power else 0.8,
                           n = n_in, aratios = aratios, onesided = onesided,
                           favourable = fav_arg, condit = condit, local = local,
                           trend = trend, doses = doses, nvmethod = nvmethod,
                           wald = wald, ccorrect = ccorrect, noround = noround,
                           force = force, convcrit = convcrit)
    n_raw  <- res$n
    Power  <- res$power
    allocr <- res$allocr
    if (!ssize) power <- Power
  }

  # ---------- Rounding and per-arm sample sizes ----------
  # Special case: 2-arm with only 1 allocation ratio given
  if (npr == 2 && nar == 1) {
    allr[2]   <- allr[1]
    allr[1]   <- 1
    totalallr <- 2
  }

  # Rescale so allr[1] == 1
  if (allr[1] != 1) {
    base      <- allr[1]
    allr      <- allr / base
    totalallr <- totalallr / base
  }

  nbygroup <- n_raw / totalallr

  ntotal <- 0
  D_total <- 0
  n_per   <- numeric(npr)
  D_per   <- numeric(npr)

  for (a in seq_len(npr)) {
    if (ssize) {
      if (noround) {
        n_per[a] <- nbygroup * allr[a] / obsfrac
      } else {
        n_per[a] <- ceiling(nbygroup * allr[a] / obsfrac)
      }
      ntotal <- ntotal + n_per[a]
    } else {
      n_per[a] <- ntotal * allr[a] / totalallr
    }
    D_per[a] <- n_per[a] * pr[a] * obsfrac
    D_total  <- D_total + D_per[a]
  }

  if (!ssize) ntotal <- if (!is.null(ltfu)) ntotal_from_user <- n else n

  # Build return list
  result        <- list(n = if (ssize) ntotal else ntotal)
  result$power  <- if (ssize) power else Power
  result$D      <- D_total
  for (a in seq_len(npr)) {
    result[[paste0("n", a)]] <- n_per[a]
    result[[paste0("D", a)]] <- D_per[a]
  }
  result
}

#' Launch the artbin Shiny application
#'
#' @export
run_artbin_app <- function() {
  app_dir <- system.file("shiny", "artbin_app", package = "artbin")
  if (app_dir == "") stop("Could not find Shiny app directory.")
  shiny::runApp(app_dir, display.mode = "normal")
}
