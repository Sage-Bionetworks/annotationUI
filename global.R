# ------------------------------------------------------------------------------
# Simple Shiny template for annotations utils 
# search, select, merge and download prototype 
# ------------------------------------------------------------------------------
usePackage <- function(p) 
{
  if (!is.element(p, installed.packages()[,1]))
    install.packages(p, dep = TRUE)
  require(p, character.only = TRUE)
}
usePackage("dplyr")
usePackage("tidyr")
usePackage("shiny")
usePackage("ggplot2")
usePackage("openxlsx")
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
library(openxlsx)
library(data.table)
library(synapseClient)
library(shinydashboard)

# ----------------------------------------------------------------------
# login to synapse 
# syn.login('me@nowhere.com', 'secret', rememberMe = TRUE)
# or caching credentials can also be done from the command line client:
# synapse login -u me@nowhere.com -p secret --rememberMe
# ----------------------------------------------------------------------
synapseLogin()

# ----------------------------------------------------------------------
options(stringsAsFactors = FALSE)

# by replacing the global dat variable
# you may use this app using the standard schema but your own melted data 
queryResult <- synTableQuery('select * from syn9968225')
dat <- as.data.frame(queryResult@values)

categories <- lapply(unique(dat$project), function(x) {x})
all.vars <- names(dat)
names(dat) <- c("key", "description", "columnType", "maximumSize", "value", "valueDescription", "source", "project")

# Render latest github release version in title from synapseAnnotations repo
release.version <- gsub(".*/", "", system("git ls-remote --tags https://github.com/Sage-Bionetworks/synapseAnnotations", intern = TRUE)[[1]])

