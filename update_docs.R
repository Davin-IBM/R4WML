#!/usr/bin/env Rscript

# Update package documentation
#
# References https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/ and http://r-pkgs.had.co.nz/description.html

#install.packages("devtools")
#devtools::install_github("klutometis/roxygen")

library(devtools)
library(roxygen2)

document()

