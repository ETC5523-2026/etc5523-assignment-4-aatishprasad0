#' Library usage metrics available in overdue
#'
#' Lists the metrics that [plv_metric()] can calculate, with a readable
#' label and a plain-language definition for each.
#' Use it to see the options, or to label app controls and plots consistently.
#'
#' @return A tibble with one row per metric and columns `metric` (the key to
#' pass to [plv_metric()]), `label` and `definition`.
#' @export
#'
#' @examples
#' plv_metric_labels()
plv_metric_labels <- function() {
  dplyr::tibble(
    metric = c(
      "branch_visits",
      "visits_per_person",
      "contacts_per_person",
      "active_borrower_rate",
      "digital_loan_share",
      "website_visits_per_person"
    ),
    label = c(
      "Branch visits (total)",
      "Branch visits per resident", 
      "In-person contacts per resident",
      "Active borrowers per 100 residents",
      "Digital share of loans (%)",
      "Website visits per resident"
    ),
    definition = c(
      "Total in-person visits to branch libraries.",
      "Branch visits divided by municipal population.",
      "Branch, mobile library and outreach visits divided by municipal population.",
      "Members who borrowed in the year, per 100 residents.",
      "eBook loans as a percentage of physical plus eBook loans.",
      "Website visits divided by municipal population. Counts visits, not users."
    )
  )
}

#' Calculate and rank a library usage metric
#'
#' Calculates one usage metric for every municipal library service in a
#' financial year, ranks the services, and compares each with a municipal
#' benchmark. Calling it with different metrics shows how the ranking of
#' services depends on how usage is measured.
#'
#' `"Victoria (Total)"` and `"Vision Australia"` are excluded because they are
#' not municipal library services. The benchmark is calculated from the
#' municipal services only: for the total-count metric it is the average per
#' service, and for rates and shares it is the pooled value (the sum of the
#' numerator divided by the sum of the denominator).
#'
#' For `"contacts_per_person"`, missing mobile and outreach visits are
#' treated as zero, because many services do not run them; services with
#' missing branch visits are left unranked.
#'
#' @param metric The metric to calculate. One of the `metric` values from
#'   [plv_metric_labels()].
#' @param year A financial year in the data, such as `"2024-25"`.
#' @param data A data frame shaped like [plv_services]. Defaults to the
#'   bundled data.
#'
#' @return A tibble with one row per municipal service, sorted by rank, with
#'   columns:
#'   \describe{
#'     \item{service}{Library service name.}
#'     \item{value}{The metric value. `NA` when the value or its denominator
#'       is missing or zero.}
#'     \item{rank}{Rank among services with a value, where 1 is the highest.}
#'     \item{pct_of_benchmark}{The value as a percentage of the benchmark;
#'       100 means equal to the benchmark.}
#'   }
#'   The result also carries attributes `metric`, `year`, `benchmark` and
#'   `missing_services` (the services that could not be ranked).
#'
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' # The leaders change when visits are adjusted for population
#' head(plv_metric("branch_visits"))
#' head(plv_metric("visits_per_person"))
#'
#' # The benchmark and any unranked services travel with the result
#' result <- plv_metric("digital_loan_share", year = "2023-24")
#' attr(result, "benchmark")
#' attr(result, "missing_services")
plv_metric <- function(metric, year = "2024-25", data = overdue::plv_services) {
  # Validate inputs
  metrics <- plv_metric_labels()$metric
  if (missing(metric) || length(metric) != 1 || !metric %in% metrics) {
    stop(
      "`metric` must be one of: ",
      paste(metrics, collapse = ", "),
      ". See plv_metric_labels().",
      call. = FALSE
    )
  }

  years <- levels(factor(data$financial_year))
  if (length(year) != 1 || !year %in% years) {
    stop(
      "`year` must be one of: ",
      paste(years, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  # Keep municipal services in the chosen year
  non_municipal <- c("Victoria (Total)", "Vision Australia")
  services <- data |>
    dplyr::filter(
      .data$financial_year == year,
      !.data$service %in% non_municipal
    )

  pop <- services$municipal_population
  zero_if_na <- function(x) dplyr::coalesce(x, 0)

  # Numerator, denominator and scale for each metric
  parts <- switch(
    metric,
    branch_visits = list(
      num = services$branch_visits,
      den = rep(1, nrow(services)),
      scale = 1
    ),
    visits_per_person = list(
      num = services$branch_visits,
      den = pop,
      scale = 1
    ),
    contacts_per_person = list(
      num = services$branch_visits +
        zero_if_na(services$mobile_visits) +
        zero_if_na(services$outreach_visits),
      den = pop,
      scale = 1
    ),
    active_borrower_rate = list(
      num = services$active_borrowers,
      den = pop,
      scale = 100
    ),
    digital_loan_share = list(
      num = services$ebook_loans,
      den = services$physical_loans + services$ebook_loans,
      scale = 100
    ),
    website_visits_per_person = list(
      num = services$website_visits,
      den = pop,
      scale = 1
    )
  )

  # Values, guarding against missing or zero denominators
  usable <- !is.na(parts$num) & !is.na(parts$den) & parts$den > 0
  value <- ifelse(usable, parts$num / parts$den * parts$scale, NA_real_)

  # Benchmark from municipal services only
  benchmark <- if (!any(usable)) {
    NA_real_
  } else if (metric == "branch_visits") {
    mean(value[usable])
  } else {
    sum(parts$num[usable]) / sum(parts$den[usable]) * parts$scale
  }

  # Assemble, rank and sort
  out <- dplyr::tibble(
    service = services$service,
    value = value
  ) |>
    dplyr::mutate(
      rank = dplyr::min_rank(dplyr::desc(.data$value)),
      pct_of_benchmark = .data$value / benchmark * 100
    ) |>
    dplyr::arrange(.data$rank)

  attr(out, "metric") <- metric
  attr(out, "year") <- year
  attr(out, "benchmark") <- benchmark
  attr(out, "missing_services") <- services$service[!usable]
  out
}
