% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compare_plot_report_generic.R
\name{get_plot_chunks}
\alias{get_plot_chunks}
\title{Adding R-code Chunks to include Plots into the Report}
\usage{
get_plot_chunks(ps_right_dir, ps_left_dir, ps_diagram_na_path)
}
\arguments{
\item{ps_right_dir}{directory with plots that appear in the right-hand-side column of the report}

\item{ps_left_dir}{directory with plots that appear in the left-hand-side column of the report}

\item{ps_diagram_na_path}{path to the missing-diagram replacement}
}
\value{
s_code_chunk_result R-code chunks that include the plots into the report
}
\description{
This function extracts the plot files from the directories given by the
arguments \code{ps_right_dir} and \code{ps_left_dir}. Based on the list
of plot files the R-code chunks that include the plots into the report
are generated and added to the result string.
}
