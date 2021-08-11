#' @title qgert: Qualitas Genetic Evaluation Routine Tools (QGERT)
#'
#' @description
#' The package `qgert` provides R-functions and shell-scripts that are
#' considered to be useful in the context of routine genetic evaluations.
#' The set of provided tools can be grouped into different focus categories.
#' So far, we are focusing on providing tools to generate reporting-type of
#' documents for the purpose of quality assurence of the evaluations.
#'
#' An important quality assurance tool for any given genetic evaluation are the
#' scatter plots showing the results of two subsequent evaluations. Together with
#' the plot the correlation between the results of the two evaluations are computed.
#' An important quality criterion of any new evaluation is that the changes of
#' the results when compared to the previous evaluation need to be very small.
#' As a consequence most points defined by the two evaluation results from the
#' two subsequent evaluations need to lay on the 45-degree line in the first
#' plotting quadrant. Furthermore the correlation between the results of the
#' two subsequent evaluations must be greater than .99. Such scatter plots
#' of results are done for each evaluation. Therefore it might be helpful
#' to compare the scatter plots of two subsequent evaluation runs. The result
#' of such a comparison is a report that is called comparison plot report.
#'
#' Installation: The package is installed using `devtools::install_github()` functionality.
#' The bash scripts the run the creation of the reports must be copied into
#' the appropriate program or script directory. This can be done using the script
#' `install_script.sh`.
#'
#' @examples
#' \dontrun{
#' # Installation and Update
#' devtools::install_github("pvrqualitasag/qgert")
#' }
#'
#' @docType package
#' @name qgert
NULL
