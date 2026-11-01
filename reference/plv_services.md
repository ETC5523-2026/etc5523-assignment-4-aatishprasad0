# Victorian public library service statistics, 2022-23 to 2024-25

Selected usage measures for each Victorian public library service, taken
from the Public Libraries Victoria (PLV) Annual Statistical Survey. Each
row is one library service in one financial year. Columns were matched
by name across the three yearly sheets, and three services that changed
name were recoded to their current names so each has a continuous
series.

## Usage

``` r
plv_services
```

## Format

A tibble with 156 rows (52 services x 3 years) and 11 columns:

- service:

  Library service name. `"Victoria (Total)"` is the published statewide
  total and `"Vision Australia"` is a statewide service for people with
  print disabilities; neither is a municipal library service.

- financial_year:

  Financial year, a factor with levels `"2022-23"`, `"2023-24"` and
  `"2024-25"`.

- municipal_population:

  Residents of the council areas the service covers. `NA` for Vision
  Australia. The state total also includes Unincorporated Victoria
  (about 950 people).

- branch_visits:

  In-person visits to branch libraries. Counts visits, not unique
  visitors, and excludes mobile, outreach and online use.

- mobile_visits:

  Visits to mobile library vehicles.

- outreach_visits:

  Visits through outreach programs delivered outside library branches.

- active_borrowers:

  Members who borrowed at least once in the year.

- physical_loans:

  Loans of physical items such as books and DVDs.

- ebook_loans:

  Loans of ebooks.

- website_visits:

  Visits to the library service's website. Counts visits, not individual
  users.

- program_attendance:

  Attendance at library programs and events.

## Source

Public Libraries Victoria, *2024-25 PLV Annual Statistical Survey: Final
Datasets 2022-23 to 2024-25*,
<https://www.plv.org.au/resources/earlier-reports-and-surveys/>.
Prepared by `data-raw/plv_services.R`.

## Details

Blank, `"-"` and `"n/a"` cells in the source were treated as not
reported and stored as `NA`.

## Examples

``` r
head(plv_services)
#> # A tibble: 6 × 11
#>   service        financial_year municipal_population branch_visits mobile_visits
#>   <chr>          <fct>                         <dbl>         <dbl>         <dbl>
#> 1 Bayside        2022-23                      102101        366270             0
#> 2 Boroondara     2022-23                      169411        792912             0
#> 3 Brimbank       2022-23                      193146        705558             0
#> 4 Buloke         2022-23                        6110          7137           341
#> 5 Campaspe       2022-23                       38506        110999             0
#> 6 Central Highl… 2022-23                      232011        531640         12437
#> # ℹ 6 more variables: outreach_visits <dbl>, active_borrowers <dbl>,
#> #   physical_loans <dbl>, ebook_loans <dbl>, website_visits <dbl>,
#> #   program_attendance <dbl>

# Statewide branch visits by year
subset(plv_services, service == "Victoria (Total)",
       c(financial_year, branch_visits))
#> # A tibble: 3 × 2
#>   financial_year branch_visits
#>   <fct>                  <dbl>
#> 1 2022-23             20120892
#> 2 2023-24             22896880
#> 3 2024-25             24200961
```
