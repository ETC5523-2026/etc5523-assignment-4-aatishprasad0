# Getting started with overdue

overdue asks one question: **Does the ranking of Victorian public
library services change depending on how library usage is measured?** It
is designed to be used by people learning data analysis, particularly
those exploring how the choice of metric can change a conclusion, and
how switching between metrics interactively reveals this better than a
single static chart.

## Installation

``` r

# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-aatishprasad0")
```

The repository is called `etc5523-assignment-4-aatishprasad0`, but the
package itself is called **overdue**: load it with
[`library(overdue)`](https://etc5523-2026.github.io/etc5523-assignment-4-aatishprasad0/).

``` r

library(overdue)
```

## Launch the app

``` r

run_app()
```

The app opens on **Start here**, which explains the question, the
controls and each metric. Open **Explore the rankings** and use the
controls on the left:

- **Metric A:** the metric to rank services on.
- **Metric B:** a second metric, used in *Compare two metrics*.
- **Year:** 2022-23, 2023-24 or 2024-25.

## Interpret the outputs

**One metric** ranks every service on Metric A. The dashed amber line is
the municipal benchmark; bars past it are above the benchmark.

**Compare two metrics** plots each service on both metrics. Services in
the *High on A only* or *High on B only* corners are the ones whose
standing depends on the metric chosen. The rank correlation above the
chart summarises this: close to 1 means the metrics agree; close to 0
means “busiest” depends on the metric.

For example, the leaders on total branch visits are large services:

``` r

head(plv_metric("branch_visits"), 3)
#> # A tibble: 3 × 4
#>   service        value  rank pct_of_benchmark
#>   <chr>          <dbl> <int>            <dbl>
#> 1 Your Library 1715139     1             354.
#> 2 Geelong      1457189     2             301.
#> 3 Yarra Plenty 1425592     3             295.
```

but per resident, smaller and inner-city services lead:

``` r

head(plv_metric("visits_per_person"), 3)
#> # A tibble: 3 × 4
#>   service     value  rank pct_of_benchmark
#>   <chr>       <dbl> <int>            <dbl>
#> 1 Yarra        6.21     1             179.
#> 2 Hobsons Bay  6.19     2             179.
#> 3 Melbourne    6.17     3             178.
```

Keep in mind that visits count events, not people, and that services
which did not report a measure are left out of its ranking.
