# Library usage metrics available in overdue

Lists the metrics that
[`plv_metric()`](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/reference/plv_metric.md)
can calculate, with a readable label and a plain-language definition for
each. Use it to see the options, or to label app controls and plots
consistently.

## Usage

``` r
plv_metric_labels()
```

## Value

A tibble with one row per metric and columns `metric` (the key to pass
to
[`plv_metric()`](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/reference/plv_metric.md)),
`label` and `definition`.

## Examples

``` r
plv_metric_labels()
#> # A tibble: 6 × 3
#>   metric                    label                              definition       
#>   <chr>                     <chr>                              <chr>            
#> 1 branch_visits             Branch visits (total)              Total in-person …
#> 2 visits_per_person         Branch visits per resident         Branch visits di…
#> 3 contacts_per_person       In-person contacts per resident    Branch, mobile l…
#> 4 active_borrower_rate      Active borrowers per 100 residents Members who borr…
#> 5 digital_loan_share        Digital share of loans (%)         eBook loans as a…
#> 6 website_visits_per_person Website visits per resident        Website visits d…
```
