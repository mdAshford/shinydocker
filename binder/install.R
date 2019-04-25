### install regular packages

install.packages("reticulate") # python support in RMarkdown
# install.packages("ggplot2") # for plotting
install.packages(c("rmarkdown", "caTools", "bitops")) # for knitting
install.packages("shiny")
install.packages("tidyverse")
install.packages("ggthemes")
install.packages("ggrepel")

### install bioconductor packages
# install.packages("BiocManager")
# BiocManager::install("package")

### install GitHub packages (tag = commit, branch or release tag)
# install.packages("devtools")
# devtools::install_github("user/repo", ref = "tag")

###
# dyn.load(paste("CoolProp", .Platform$dynlib.ext, sep=""))
# source("CoolProp.R")
# cacheMetaData(1)
