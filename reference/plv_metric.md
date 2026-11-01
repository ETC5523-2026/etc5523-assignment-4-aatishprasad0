# Calculate and rank a library usage metric

Calculates one usage metric for every municipal library service in a
financial year, ranks the services, and compares each with a municipal
benchmark. Calling it with different metrics shows how the ranking of
services depends on how usage is measured.

## Usage

``` r
plv_metric(metric, year = "2024-25", data = overdue::plv_services)
```

## Arguments

- metric:

  The metric to calculate. One of the `metric` values from
  [`plv_metric_labels()`](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/reference/plv_metric_labels.md).

- year:

  A financial year in the data, such as `"2024-25"`.

- data:

  A data frame shaped like
  [plv_services](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/reference/plv_services.md).
  Defaults to the bundled data.

## Value

A tibble with one row per municipal service, sorted by rank, with
columns:

- service:

  Library service name.

- value:

  The metric value. `NA` when the value or its denominator is missing or
  zero.

- rank:

  Rank among services with a value, where 1 is the highest.

- pct_of_benchmark:

  The value as a percentage of the benchmark; 100 means equal to the
  benchmark.

The result also carries attributes `metric`, `year`, `benchmark` and
`missing_services` (the services that could not be ranked).

## Details

`"Victoria (Total)"` and `"Vision Australia"` are excluded because they
are not municipal library services. The benchmark is calculated from the
municipal services only: for the total-count metric it is the average
per service, and for rates and shares it is the pooled value (the sum of
the numerator divided by the sum of the denominator).

For `"contacts_per_person"`, missing mobile and outreach visits are
treated as zero, because many services do not run them; services with
missing branch visits are left unranked.

## Examples

``` r
# The leaders change when visits are adjusted for population
head(plv_metric("branch_visits"))
#> # A tibble: 6 × 4
#>   service                 value  rank pct_of_benchmark
#>   <chr>                   <dbl> <int>            <dbl>
#> 1 Your Library          1715139     1             354.
#> 2 Geelong               1457189     2             301.
#> 3 Yarra Plenty          1425592     3             295.
#> 4 Melbourne             1167795     4             241.
#> 5 Wyndham                989686     5             204.
#> 6 Whitehorse Manningham  981419     6             203.
head(plv_metric("visits_per_person"))
#> # A tibble: 6 × 4
#>   service     value  rank pct_of_benchmark
#>   <chr>       <dbl> <int>            <dbl>
#> 1 Yarra        6.21     1             179.
#> 2 Hobsons Bay  6.19     2             179.
#> 3 Melbourne    6.17     3             178.
#> 4 Boroondara   5.46     4             157.
#> 5 Gannawarra   5.21     5             150.
#> 6 Indigo       5.15     6             149.

# The benchmark and any unranked services travel with the result
result <- plv_metric("digital_loan_share", year = "2023-24")
attr(result, "benchmark")
#> [1] 23.69831
attr(result, "missing_services")
#> character(0)
```
