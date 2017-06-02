# ------------------------------------------------------------------------------
# Simple Shiny template for annotations utils 
# search, display, merge, and download prototype 
# ------------------------------------------------------------------------------
usePackage <- function(p) 
{
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
usePackage("dplyr")
usePackage("openxlsx")
usePackage("shiny")
usePackage("ggplot2")
usePackage("shinydashboard")
usePackage("data.table")



# source('http://depot.sagebase.org/CRAN.R')
# pkgInstall("synapseClient")
# or for R newer versions pull from git 
library(devtools)
# install_github('Sage-Bionetworks/rSynapseClient', ref='develop')
# install_github("ebailey78/shinyBS")
library(dplyr)
library(tidyr)
library(shiny)
library(shinyBS)
library(ggplot2)
library(openxlsx)
library(data.table)
library(synapseClient)
library(shinydashboard)

# ----------------------------------------------------------------------
# login to synapse 
# syn.login('me@nowhere.com', 'secret', rememberMe=True)
# or caching credentials can also be done from the command line client:
# synapse login -u me@nowhere.com -p secret --rememberMe
# ----------------------------------------------------------------------
synapseLogin()

# ----------------------------------------------------------------------
options(stringsAsFactors = FALSE)

queryResult <- synTableQuery('select * from syn9894838')
dat <- as.data.frame(queryResult@values)

categories <- lapply(unique(dat$project), function(x) {x})
all.vars <- names(dat)
names(dat) <- c("key", "description", "columnType", "maximumSize", "value", "valueDescription", "valueSource", "project")

# TODO: render github release version in title from synapse annotations for project annotation consensus 
# https://github.com/Sage-Bionetworks/synapseAnnotations/releases
release.version <- "v1.0.0" 

