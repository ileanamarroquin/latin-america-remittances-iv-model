# WIID_DATAFRAME: Processing WIID-UNU database
# Research Title: “Remittances vs Public Finance Capacity. 
#                 Impact Assessment in Reducing Income Inequality in Latin America: 
#                 A Quasi-Experimental Analysis”
# Presented on July/2023 by Ileana Marroquin

###############################################################################
# 
### README
# This part will load the CSV data file and clean data to obtain the 
# relevant variables for this study id, country, c3, year, gini, ge0, palma, 
# scale, sharing_unit, region_un_sub, region_wb and incomegroup.

# Input: Downloaded CSV file from WIID-UNU website, more info is in documents folder
# Output: CSV file called "wiid_to_merge.csv" with the above mentioned relevant measurements
# 
###############################################################################

### 0. Settup

# Install Packages
# install.packages("tidyverse")
# install.packages("dplyr")
# install.packages("plm")
# install.packages("tidyr")
# install.packages("here")

#Load data cleaning libraries
library(tidyverse)
library(dplyr)
library(plm)
library(tidyr)
library(stringr)
library(readxl)
library(here)


#Load WIID data
df<-read_csv(
    here("raw_data","wiid.csv"), na = ""
    ) 
glimpse(df)

#Make df a datapanel
wiiddf <- pdata.frame(
          df, index=c("country", "year")
          )
glimpse(wiiddf)


### 1. Basic data frame cleaning

#Selecting the relevant variables
df1 <- select(wiiddf,c(1:7,
                       "palma",
                       resource:reference_unit,
                       "region_un_sub",
                       "region_wb",
                       "incomegroup"))
dim(df1)
head(df1)

#Revising year format
df1$year <- as.numeric(
            as.character(df1$year)
            )

#Subsetting data from 1995 to the most recent
df2<- df1[df1$year >= 1995, ]

#Selecting regional data
lacdata <- df2 %>% 
          filter(region_wb == "Latin America and the Caribbean")

#Looking doe missing Values
lacdata <- lacdata %>% 
            drop_na()

#Converting data types
# lacdata$year <- as.Date(
#                 paste(lacdata$year, "-01-01", sep = "")
#                 )


#Filtering the level of observation 
head(lacdata)
lacdata_1 <- lacdata %>% 
            filter(resource_detailed == "Income, net/gross") %>% 
            filter(scale_detailed == "Per capita") 

#Drop variables that are not relevant
lacdata_2 <- select(lacdata_1,-c(resource:region_wb))


#Rename variables
lacdata_3 <- lacdata_2 %>%
              rename(theil = ge0)


#Checking for duplicates
lacdata_tidy <- lacdata_3 %>% 
                distinct()

### 2. Save the output

#Save the cleaned data
write.csv(lacdata_tidy, file = here("1_processed_data","wiid_to_merge.csv"), row.names = FALSE)
