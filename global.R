# ------------------------------------------------------------------------------
# Simple Shiny template for annotations utils 
# search, select, merge and download prototype 
# ------------------------------------------------------------------------------
usePackage <- function(p, github, repos = getOption("repos"), ...) {
  if (!missing(github)) {
    ## Install from github -- devtools::install_github will automatically skip
    ## if SHA of most recent commit matches what's installed already
    devtools::install_github(paste(github, p, sep = "/"), ...)
  }
  if (!is.element(p, installed.packages()[,1])) {
    install.packages(p, repos = repos, dependencies = TRUE)
  }
  library(p, character.only = TRUE)
}

usePackage("devtools")
usePackage("dplyr")
usePackage("tidyr")
usePackage("shiny")
usePackage("shinyBS", github = "ebailey78")
usePackage("shinythemes")
usePackage("ggplot2")
usePackage("shinydashboard")
usePackage("jsonlite")
usePackage("data.table")
usePackage("DT")
usePackage("syndccutils", github = "Sage-Bionetworks", subdir = "R")
usePackage("synapser", repos = "https://sage-bionetworks.github.io/ran")

# ----------------------------------------------------------------------
# login to synapse 
# synLogin('me@nowhere.com', 'secret', rememberMe = TRUE)
# or caching credentials can also be done from the command line client:
# synapse login -u me@nowhere.com -p secret --rememberMe
# ----------------------------------------------------------------------
synLogin()

# ----------------------------------------------------------------------
options(stringsAsFactors = FALSE)

# by replacing the global dat variable
# you may use this app using the standard schema but your own melted data 
dat <- get_synapse_annotations()
print(head(dat))

categories <- lapply(unique(dat$module), function(x) {x})
key <- unique(dat$key)
value <- unique(dat$value)

dat <- dat %>% mutate_all(as.character)

# Get release version from syanpe table annotations
release.version <- synGetAnnotations("syn10242922")$annotationReleaseVersion[[1]]
