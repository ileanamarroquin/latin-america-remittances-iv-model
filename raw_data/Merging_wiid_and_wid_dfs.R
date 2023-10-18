# MERGING_WIID_AND_WID: Merging both dataframes
# Research Title: “Remittances vs Public Finance Capacity. 
#                 Impact Assessment in Reducing Income Inequality in Latin America: 
#                 A Quasi-Experimental Analysis”
# Presented on July/2023 by Ileana Marroquin

###############################################################################
# 
### README

# Input: two cleaned dataframes (wiid_tidy.csv & wid_wb_tidy.csv)
# Output: CSV file database to analyse 
#

#######
### 0. Settup
#######

#Loading all the libraies
library(tidyverse)
library(dplyr)
library(Hmisc)


#Loading the two data frames files
unu_df<-read_csv(
  here("processed_data","wiid_tidy.csv"), na = ""
)
wb_df<-read_csv(
  here("processed_data","wid_wb_tidy.csv"), na = ""
)

#Observing the type and name of the variables
glimpse(unu_df)
glimpse(wb_df)

#Renaming variables
wb_df <- wb_df %>%
         mutate(id = row_number()) %>%
         select(id, everything()) %>%
         rename(c3 = iso3c)
glimpse(unu_df)
glimpse(wb_df) 

#######
### 1. Merging the Data frames
#######

# Merging data frames using left_join
merged_df <- left_join(
              wb_df, unu_df, by = c("c3", 
                                    "year")
              )

# Replacing unmatched values with NA
merged_df <- merged_df %>%
              mutate(
                    across(c("id.y",
                             "country.y",
                             "c2",
                             "gini",
                             "theil",
                             "palma",
                             "incomegroup"),
                     ~ replace_na(., NA)
                          )
                     )

# View the merged data frame
glimpse(merged_df)
unique(merged_df$country.x)

# Drop variables that will not be used
database <- select(
            merged_df,c(1:9,gini:incomegroup)
            )

#######
### 2. Generating variables for database: Lagged RM for -1 and -3 years
#######

database1 <- database  %>%
            mutate(Lag(personal_rm, -1)) %>%
            mutate(Lag(personal_rm, -3))

database1 <- database1  %>%
            rename(rm_l1 = `Lag(personal_rm, -1)`) %>%
            rename(rm_l3 = `Lag(personal_rm, -3)`) %>%
            rename(rm = personal_rm) %>%
            rename(gov_e = gov_cons_exp)

head(database1)

database1 <- database1 %>%
              mutate(incomegroup = factor(incomegroup,
                                          levels = c("Lower middle income",
                                                     "Upper middle income",
                                                     "High income")))
str(database1)

#Calling the packages
library(plm)

#Panel data transformation
ineq_db <- pdata.frame(database1, index=c("country.x", "year"))
table(index(ineq_db), useNA = "ifany") 

#######
### 3. Dealing with duplicated and missing values 
#######

# Note: For Duplicated values that are a result of having the strategy will be Calculating country-year average for duplicates

# Identify duplicate rows within each country-year combination
duplicates <- duplicated(ineq_db[, c("country.x", "year")], fromLast = TRUE) | duplicated(ineq_db[, c("country.x", "year")])

# Subset the duplicated rows
duplicated_rows <- ineq_db[duplicates, ]

# Calculate the mean of selected numeric variables within each country-year combination
mean_values1 <- aggregate(. ~ country.x + year, data = duplicated_rows,
                          FUN = function(x) if (is.numeric(x)) mean(x, na.rm = TRUE) else x)

# Introduce the calculated averages back to the original data frame
mean_values2 <- ineq_db %>%
  group_by(country.x, year) %>%
  mutate(across(where(is.numeric), ~ mean(., na.rm = TRUE))) %>%
  distinct(country.x, year, .keep_all = TRUE) %>%
  ungroup()

# Update the original data frame with the merged values
ineq_db1 <- pdata.frame(mean_values2, index=c("country.x", "year"))
table(index(ineq_db1), useNA = "ifany") 

# View the updated data frame
glimpse(ineq_db1)

#Part 3.2- Subset the data set of countries based on data availability
unique(ineq_db1$c3)

