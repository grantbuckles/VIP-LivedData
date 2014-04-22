rm(list=ls())
library(stringr)
library(plyr)
library(xts) # also pulls in zoo
library(timeDate)
library(chron)
library(descr)
library(reshape2)
library(ggplot2)
library(xtable)
library(epicalc)
library(stringr)
##Detect problems with ward lookup
#############################

##FUNCTIONS
rename_NA <- function(x){
  rownames(x)[is.na(rownames(x))] <- "NA"
  colnames(x)[is.na(colnames(x))] <- "NA"
  x
}

###
workd <- "/Volumes/Optibay-1TB/RSA_RCT/QA/LiveData/VIP-LivedData/"

setwd(workd)
texFile <- tail(list.files(path=workd, pattern ="tex_2014.*"),1)[1]

exports <- list.files(path=workd, pattern ="contact_2014_[0-9].*")

currentFile <-  tail(exports,1)[1]
setwd(paste0(workd,currentFile))

cat(sprintf("Now loading the exports file from most recent file \\begin{verbatim}"), sprintf(currentFile), sprintf("\\end{verbatim}"), "\n\n")

exportFile <- read.csv("contacts-export.csv", header=TRUE, stringsAsFactors=FALSE,  na.strings="")

#do we want twitter people and what about people that just answered the engagement question?
elecObserveIncentive <- exportFile[exportFile$extras.is_registered %in% c("true") & exportFile$extras.delivery_class %in% c("ussd", "twitter"),
                                   c("msisdn", "extras.is_registered", "extras.delivery_class")] 

#check
elecObserveIncentive[sample(nrow(elecObserveIncentive), 30), c("msisdn", "extras.is_registered", "extras.delivery_class")]

#divide the population into two groups of equal size (unless they are odd numbers. The the incentivzed group has one more person
set.seed(20140422)
noInc <- sample(nrow(elecObserveIncentive),floor(nrow(elecObserveIncentive)/2))

elecObserveIncentive$group <- NA
elecObserveIncentive$group[noInc] <- "noIncentive"
elecObserveIncentive$group[-noInc] <- "Incentive"

#write.csv