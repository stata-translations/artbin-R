\name{artbin}
\alias{artbin}
\title{Sample Size and Power for Binary Outcome Clinical Trials}
\description{
Calculates the power or total sample size for various tests comparing K
anticipated probabilities for binary outcomes. Supports superiority,
non-inferiority, and substantial-superiority trial designs.
}
\usage{
artbin(pr, margin = NULL, alpha = 0.05, power = NULL, n = NULL,
       aratios = NULL, ltfu = NULL, onesided = FALSE,
       favourable = NULL, condit = FALSE, local = FALSE,
       trend = FALSE, doses = NULL, nvmethod = NULL,
       wald = FALSE, ccorrect = FALSE, noround = FALSE,
       force = FALSE, convcrit = 1e-7)
}
\arguments{
  \item{pr}{Numeric vector of length >= 2. Anticipated event probabilities.
    \code{pr[1]} is the control group; \code{pr[2]}, \code{pr[3]}, ... are
    treatment groups.}
  \item{margin}{Numeric or NULL. Non-inferiority or substantial-superiority
    margin. NULL or 0 assumes a superiority design.}
  \item{alpha}{Numeric. Significance level (default 0.05).}
  \item{power}{Numeric or NULL. Desired power. If NULL and \code{n} is NULL,
    defaults to 0.80. Cannot be used with \code{n}.}
  \item{n}{Integer or NULL. Total sample size. If supplied, power is calculated
    instead of sample size. Cannot be used with \code{power}.}
  \item{aratios}{Numeric vector or NULL. Allocation ratios. For a 2-arm trial,
    \code{c(1, 2)} allocates 1 control : 2 treatment. Default is equal
    allocation.}
  \item{ltfu}{Numeric or NULL. Proportion lost to follow-up (0 to <1). The
    recruited sample size is inflated by \code{1 / (1 - ltfu)}.}
  \item{onesided}{Logical. If TRUE the significance level \code{alpha} is
    treated as one-sided (default FALSE).}
  \item{favourable}{Logical or NULL. TRUE = favourable outcome; FALSE =
    unfavourable. If NULL (default) the direction is inferred from \code{pr}
    and \code{margin}.}
  \item{condit}{Logical. If TRUE, applies a conditional test using Peto's
    odds-ratio approximation (default FALSE). Implies \code{local = TRUE}.}
  \item{local}{Logical. If TRUE, calculates under local alternatives (default
    FALSE).}
  \item{trend}{Logical. If TRUE, applies a linear trend test for k-group
    trials (default FALSE).}
  \item{doses}{Numeric vector or NULL. Doses for the trend test. Default is
    0, 1, ..., K-1.}
  \item{nvmethod}{Integer or NULL. Method for estimating null-hypothesis
    variance: 1 = sample estimates (Wald), 2 = fixed marginal totals,
    3 = constrained maximum likelihood (default). Automatically set to 1
    when \code{wald = TRUE}.}
  \item{wald}{Logical. If TRUE, applies a Wald test (default FALSE).}
  \item{ccorrect}{Logical. If TRUE, applies a continuity correction (default
    FALSE).}
  \item{noround}{Logical. If TRUE, per-group sample sizes are not rounded to
    the nearest integer (default FALSE).}
  \item{force}{Logical. If TRUE, overrides the program's inference of the
    favourable/unfavourable direction (default FALSE).}
  \item{convcrit}{Numeric. Convergence criterion for the iterative k-group
    calculation (default 1e-7).}
}
\value{
A named list with elements:
\describe{
  \item{\code{n}}{Total sample size.}
  \item{\code{n1}, \code{n2}, ...}{Sample size per group.}
  \item{\code{power}}{Achieved or designed power.}
  \item{\code{D}}{Total expected events.}
  \item{\code{D1}, \code{D2}, ...}{Expected events per group.}
}
}
\details{
\code{artbin} is based on the Stata \code{artbin} package (v2.1.2) which is
part of the ART (Assessment of Resources for Trials) suite. The translation
preserves the Stata behaviour exactly.

For two-arm trials the calculation routes through an internal \code{.art2bin}
function (translated from \code{art2bin.ado}). For three or more arms, or
when the conditional test is requested with two arms, the calculation uses an
internal k-group function.

\strong{Null variance methods} (two-arm only):
\itemize{
  \item \code{nvmethod = 1}: Sample estimates (Wald test; set automatically
    when \code{wald = TRUE}).
  \item \code{nvmethod = 2}: Fixed marginal totals (Dunnett & Gent, 1977).
  \item \code{nvmethod = 3}: Constrained maximum likelihood (Farrington &
    Manning, 1990). This is the default.
}

\strong{K-group one-sided}: When \code{onesided = TRUE} and the k-group path
is used, \eqn{\alpha} is doubled before computing the chi-squared critical
value, so the test uses \eqn{\chi^2_{1-2\alpha}}.

\strong{LTFU}: The recruited sample size per arm is
\code{n_arm / (1 - ltfu)}, and expected events use the observable fraction.
}
\references{
Farrington, C.P. and Manning, G. (1990). Test statistics and sample size
formulae for comparative binomial trials with null hypothesis of non-zero
risk difference or non-unity relative risk. \emph{Statistics in Medicine},
9(12), 1447-1454.

Pocock, S.J. (1983). \emph{Clinical Trials: A Practical Approach}. Wiley.

Quartagno, M., Walker, A.S., Babiker, A.G., et al. (2020). Handling an
uncertain control group event risk in non-inferiority trials: non-inferiority
frontier approach. \emph{Clinical Trials}, 17(2), 144-154.
}
\examples{
# Superiority, Wald test (replicates Pocock 1983: n=1156)
artbin(pr = c(0.1, 0.05), alpha = 0.05, power = 0.9, wald = TRUE)

# One-sided non-inferiority (n=914, 457 per arm)
artbin(pr = c(0.9, 0.9), margin = -0.05, onesided = TRUE)

# 4-arm superiority trial (n=176, 44 per arm)
artbin(pr = c(0.1, 0.2, 0.3, 0.4), alpha = 0.1, power = 0.9)

# STREAM trial: NI with 1:2 allocation and 20\% LTFU (n=398)
artbin(pr = c(0.7, 0.75), margin = -0.1, wald = TRUE,
       aratios = c(1, 2), ltfu = 0.2)

# Calculate power for a given sample size
artbin(pr = c(0.1, 0.05), n = 1000, wald = TRUE)
}
