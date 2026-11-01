# Library usage metrics available in overdue

Lists the metrics that
[`plv_metric()`](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/reference/plv_metric.md)
can calculate, with a readable ' label, a plain-language definition and
the analytical idea each one ' illustrates. Use it to see the options,
or to label app controls and plots consistently.

## Usage

``` r
plv_metric_labels()
```

## Value

A tibble with one row per metric and columns `metric` (the key to pass
to
[`plv_metric()`](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/reference/plv_metric.md)),
`label`, `definition` and `concept`.

## Examples

``` r
plv_metric_labels()
#> # A tibble: 6 × 4
#>   metric                    label                             definition concept
#>   <chr>                     <chr>                             <chr>      <chr>  
#> 1 branch_visits             Branch visits (total)             Total in-… Raw co…
#> 2 visits_per_person         Branch visits per resident        Branch vi… Normal…
#> 3 contacts_per_person       In-person contacts per resident   Branch, m… Metric…
#> 4 active_borrower_rate      Active borrowers per 100 residen… Members w… Rates  
#> 5 digital_loan_share        Digital share of loans (%)        eBook loa… Propor…
#> 6 website_visits_per_person Website visits per resident       Website v… Proxy …
```
