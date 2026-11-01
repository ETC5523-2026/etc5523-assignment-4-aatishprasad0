#' Victorian public library service statistics, 2022-23 to 2024-25
#'
#' Selected usage measures for each Victorian public library service, taken
#' from the Public Libraries Victoria (PLV) Annual Statistical Survey. Each
#' row is one library service in one financial year. Columns were matched by
#' name across the three yearly sheets, and three services that changed name
#' were recoded to their current names so each has a continuous series.
#'
#' Blank, `"-"` and `"n/a"` cells in the source were treated as not reported
#' and stored as `NA`.
#'
#' @format A tibble with 156 rows (52 services x 3 years) and 11 columns:
#' \describe{
#'   \item{service}{Library service name. `"Victoria (Total)"` is the published
#'     statewide total and `"Vision Australia"` is a statewide service for
#'     people with print disabilities; neither is a municipal library service.}
#'   \item{financial_year}{Financial year, a factor with levels `"2022-23"`,
#'     `"2023-24"` and `"2024-25"`.}
#'   \item{municipal_population}{Residents of the council areas the service
#'     covers. `NA` for Vision Australia. The state total also includes
#'     Unincorporated Victoria (about 950 people).}
#'   \item{branch_visits}{In-person visits to branch libraries. Counts visits,
#'     not unique visitors, and excludes mobile, outreach and online use.}
#'   \item{mobile_visits}{Visits to mobile library vehicles.}
#'   \item{outreach_visits}{Visits through outreach programs delivered
#'     outside library branches.}
#'   \item{active_borrowers}{Members who borrowed at least once in the year.}
#'   \item{physical_loans}{Loans of physical items such as books and DVDs.}
#'   \item{ebook_loans}{Loans of ebooks.}
#'   \item{website_visits}{Visits to the library service's website. Counts
#'     visits, not individual users.}
#'   \item{program_attendance}{Attendance at library programs and events.}
#' }
#'
#' @source Public Libraries Victoria, *2024-25 PLV Annual Statistical Survey:
#'   Final Datasets 2022-23 to 2024-25*,
#'   \url{https://www.plv.org.au/resources/earlier-reports-and-surveys/}.
#'   Prepared by `data-raw/plv_services.R`.
#'
#' @examples
#' head(plv_services)
#'
#' # Statewide branch visits by year
#' subset(plv_services, service == "Victoria (Total)",
#'        c(financial_year, branch_visits))
"plv_services"
