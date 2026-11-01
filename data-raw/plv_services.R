# Prepares `plv_services` from the PLV Annual Statistical Survey
# Source: https://www.plv.org.au/resources/earlier-reports-and-surveys/
# File: 06. 2024-25 PLV Annual Statistical Survey – Final Datasets 2022-23 to 2024-25

library(tidyverse)
library(readxl)

path <- "data-raw/06.-2024-25-PLV-Annual-Statistical-Survey-Final-Datasets-2022-23-to-2024-25.xlsx"
years <- c("2022-23", "2023-24", "2024-25")

read_year <- function(yr) {
  read_excel(
    path,
    sheet = yr,
    skip = 3, # headers are on row 4
    na = c("", "-", "n/a"), # all three mean "not reported"
    .name_repair = "unique_quiet" # silences blank-column messages
  ) |>
    select(
      service = Name,
      municipal_population = matches("Municipal population"),
      branch_visits = matches("branch library visits"),
      mobile_visits = matches("mobile library visits"),
      outreach_visits = matches("outreach program visits"),
      active_borrowers = matches("active borrowers"),
      physical_loans = matches("loans of physical items"),
      ebook_loans = matches("loans of ebooks"),
      website_visits = matches("website visits"),
      program_attendance = matches("Program/event attendance")
    ) |>
    filter(!is.na(service), service != "Note") |>
    mutate(
      across(-service, as.numeric),
      financial_year = yr
    )
}

plv_services <- map_dfr(years, read_year) |>
  mutate(
    service = recode(
      service,
      "Connected Libraries (Casey)" = "Connected Libraries",
      "Your Library (Eastern)" = "Your Library",
      "Wodonga" = "Hyphen"
    ),
    financial_year = factor(financial_year, levels = years)
  ) |>
  relocate(service, financial_year)

# Sanity checks: one row per service per year, 52 rows per year
stopifnot(
  !anyDuplicated(plv_services[c("service", "financial_year")]),
  all(table(plv_services$financial_year) == 52)
)

usethis::use_data(plv_services, overwrite = TRUE)
