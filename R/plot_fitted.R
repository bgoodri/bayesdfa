#' Plot the trends from a DFA
#'
#' @param modelfit Output from \code{\link{fit_dfa}}, a rstanfit object
#' @param names Optional vector of names for plotting labels
#'
#' @export
#' @seealso plot_loadings fit_dfa rotate_trends
#'
#' @importFrom ggplot2 geom_ribbon facet_wrap
#'
#' @examples
#' \donttest{
#' y <- sim_dfa(num_trends = 2, num_years = 20, num_ts = 4)
#' m <- fit_dfa(y = y, num_trends = 2, iter = 200, chains = 1)
#' p <- plot_fitted(m)
#' print(p)
#' }

plot_fitted <- function(modelfit, names = NULL) {
  n_ts <- dim(modelfit$data)[1]
  n_years <- dim(modelfit$data)[2]

  # pred and Y have same dimensions
  pred <- predicted(modelfit)

  df <- data.frame(
    "ID" = rep(seq_len(n_ts), n_years),
    "Time" = sort(rep(seq_len(n_years), n_ts)),
    "mean" = c(t(apply(pred, c(3, 4), mean))),
    "lo" = c(t(apply(pred, c(3, 4), quantile, 0.025))),
    "hi" = c(t(apply(pred, c(3, 4), quantile, 0.975))),
    "y" = c(modelfit$data)
  )

  if (!is.null(names)) {
    df$ID <- names[df$ID]
  }

  # make faceted ribbon plot of trends
  p1 <- ggplot(df, aes_string(x = "Time", y = "mean")) +
    geom_ribbon(aes_string(ymin = "lo", ymax = "hi"), alpha = 0.4) +
    geom_line() +
    geom_point(
      aes_string(x = "Time", y = "y"),
      col = "red",
      size = 0.5,
      alpha = 0.4
    ) +
    facet_wrap("ID", scales = "free_y") +
    xlab("Time") + ylab("")
  p1
}
