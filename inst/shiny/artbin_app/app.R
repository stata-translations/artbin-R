library(shiny)
library(artbin)

ui <- fluidPage(
  titlePanel("artbin — Sample Size and Power for Binary Outcome Trials"),

  sidebarLayout(
    sidebarPanel(
      h4("Event probabilities"),
      textInput("pr", "pr (space-separated)", value = "0.1 0.05"),

      h4("Trial type"),
      numericInput("margin", "margin (0 = superiority)", value = 0, step = 0.01),
      radioButtons("outcome", "Outcome direction",
                   choices = c("Infer automatically" = "auto",
                               "Favourable" = "fav",
                               "Unfavourable" = "unfav"),
                   selected = "auto"),

      h4("Power and sample size"),
      radioButtons("mode", "Calculate",
                   choices = c("Sample size" = "ss", "Power" = "pow"),
                   selected = "ss"),
      conditionalPanel("input.mode == 'ss'",
        numericInput("power", "power", value = 0.8, min = 0.01, max = 0.99, step = 0.05)
      ),
      conditionalPanel("input.mode == 'pow'",
        numericInput("n_input", "n (total sample size)", value = 200, min = 2, step = 1)
      ),
      numericInput("alpha", "alpha", value = 0.05, min = 0.001, max = 0.5, step = 0.005),
      textInput("aratios", "aratios (space-separated, blank = equal)", value = ""),
      numericInput("ltfu", "ltfu (proportion, 0 = none)", value = 0, min = 0, max = 0.99, step = 0.01),

      h4("Test options"),
      checkboxInput("onesided", "onesided", value = FALSE),
      checkboxInput("wald", "wald", value = FALSE),
      checkboxInput("ccorrect", "ccorrect", value = FALSE),
      checkboxInput("local", "local", value = FALSE),
      checkboxInput("condit", "condit", value = FALSE),
      checkboxInput("trend", "trend", value = FALSE),
      checkboxInput("noround", "noround", value = FALSE),
      selectInput("nvmethod", "nvmethod",
                  choices = c("3 (constrained ML, default)" = 3,
                              "1 (sample estimate / Wald)" = 1,
                              "2 (fixed marginal totals)" = 2),
                  selected = 3),

      actionButton("run", "Calculate", class = "btn-primary")
    ),

    mainPanel(
      h4("Results"),
      verbatimTextOutput("result"),
      hr(),
      h4("R code"),
      verbatimTextOutput("code")
    )
  )
)

server <- function(input, output, session) {
  result <- eventReactive(input$run, {
    pr_vals <- as.numeric(strsplit(trimws(input$pr), "\\s+")[[1]])
    if (any(is.na(pr_vals)) || length(pr_vals) < 2)
      return(list(error = "Please enter at least two numeric probabilities."))

    aratios_vals <- if (nchar(trimws(input$aratios)) == 0) NULL else
      as.numeric(strsplit(trimws(input$aratios), "\\s+")[[1]])

    margin_val <- if (input$margin == 0) NULL else input$margin
    fav_val    <- switch(input$outcome, auto = NULL, fav = TRUE, unfav = FALSE)
    ltfu_val   <- if (input$ltfu == 0) NULL else input$ltfu
    n_val      <- if (input$mode == "ss") NULL else as.integer(input$n_input)
    pow_val    <- if (input$mode == "ss") input$power else NULL
    nvm_val    <- as.integer(input$nvmethod)

    tryCatch(
      artbin(pr = pr_vals, margin = margin_val, alpha = input$alpha,
             power = pow_val, n = n_val, aratios = aratios_vals,
             ltfu = ltfu_val, onesided = input$onesided,
             favourable = fav_val, condit = input$condit,
             local = input$local, trend = input$trend,
             nvmethod = nvm_val, wald = input$wald,
             ccorrect = input$ccorrect, noround = input$noround),
      error = function(e) list(error = conditionMessage(e))
    )
  })

  output$result <- renderPrint({
    r <- result()
    if (!is.null(r$error)) {
      cat("Error:", r$error, "\n")
    } else {
      cat("Total sample size (n):", r$n, "\n")
      ngroups <- sum(grepl("^n[0-9]+$", names(r)))
      for (i in seq_len(ngroups))
        cat(sprintf("  Group %d (n%d): %g\n", i, i, r[[paste0("n", i)]]))
      cat("Power:", round(r$power, 4), "\n")
      cat("Expected events (D):", round(r$D, 2), "\n")
      for (i in seq_len(ngroups))
        cat(sprintf("  Group %d (D%d): %.2f\n", i, i, r[[paste0("D", i)]]))
    }
  })

  output$code <- renderPrint({
    pr_vals    <- input$pr
    margin_str <- if (input$margin == 0) "" else paste0(", margin = ", input$margin)
    alpha_str  <- if (input$alpha != 0.05) paste0(", alpha = ", input$alpha) else ""
    ps_str     <- if (input$mode == "ss") paste0(", power = ", input$power) else
                  paste0(", n = ", input$n_input)
    ar_str     <- if (nchar(trimws(input$aratios)) == 0) "" else
                  paste0(", aratios = c(", paste(trimws(input$aratios), collapse = ", "), ")")
    ltfu_str   <- if (input$ltfu == 0) "" else paste0(", ltfu = ", input$ltfu)
    flags <- c(
      if (input$onesided) "onesided = TRUE",
      if (input$wald)     "wald = TRUE",
      if (input$ccorrect) "ccorrect = TRUE",
      if (input$local)    "local = TRUE",
      if (input$condit)   "condit = TRUE",
      if (input$trend)    "trend = TRUE",
      if (input$noround)  "noround = TRUE",
      if (input$nvmethod != "3") paste0("nvmethod = ", input$nvmethod)
    )
    fav_str <- switch(input$outcome, auto = "", fav = ", favourable = TRUE",
                      unfav = ", favourable = FALSE")
    flags_str <- if (length(flags)) paste0(", ", paste(flags, collapse = ", ")) else ""
    cat(sprintf('artbin(pr = c(%s)%s%s%s%s%s%s%s)\n',
                pr_vals, margin_str, alpha_str, ps_str, ar_str, ltfu_str,
                fav_str, flags_str))
  })
}

shinyApp(ui = ui, server = server)
