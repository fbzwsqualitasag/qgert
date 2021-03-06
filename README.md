
<!-- README.md is generated from README.Rmd. Please edit that file -->

# QGERT

<!-- badges: start -->
<!-- badges: end -->

QGERT stands for **Qualitas Genetic Evaluation Routine Tools**. The goal
of QGERT is to provide a set of standardized tools to prepare data and
to post-process results of the routine genetic evaluation. The main
focus of the post-processing is on quality assurance and on results
checking. As a consequence of that, principles of reproducibility of all
tasks are followed as closely as possible.

The package website is available at:
<https://fbzwsqualitasag.github.io/qgert/>

## Installation

Because the package is only useful in the context of the genetic
evaluations done at [Qualitas AG](https://qualitasag.ch), the package
will not be released to CRAN. The development version can be installed
from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fbzwsqualitasag/qgert")
```

## Example

Examples of basic use cases are shown in the different articles that are
available from this site. A short description of all available articles
is listed below.

-   [Getting
    Started](https://fbzwsqualitasag.github.io/qgert/articles/qgert_getting_started.html):
    Description of basic usage of the functionality provided by `qgert`.
-   [Comparison
    Plots](https://fbzwsqualitasag.github.io/qgert/articles/comparison_plots.html):
    Explanation of what a comparison plot is.
-   [Comparison Plot
    Report](https://fbzwsqualitasag.github.io/qgert/articles/comparison_plot_report.html):
    Combination of comparison plots in a single report. Reports can be
    generated from within R or with a wrapper bash-script.
-   [Spinning bash
    script](https://fbzwsqualitasag.github.io/qgert/articles/spin_bash_script.html):
    Conversion of specially annotated bash scripts into an HTML page.
-   [Split gsRuns According To Predicted
    Runtimes](https://fbzwsqualitasag.github.io/qgert/articles/split_gsruns_sorted_rt.html):
    A list of computing jobs is split into smaller computation batches
    according to estimated runtimes from a previous evaluation.

## Latest Change

    #> Mon Apr 26 17:34:50 2021 CEST  --  pvr
