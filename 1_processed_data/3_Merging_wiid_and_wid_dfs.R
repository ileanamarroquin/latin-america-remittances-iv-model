# MERGING_WIID_AND_WID: Merging both dataframes
# Research Title: “Remittances vs Public Finance Capacity. 
#                 Impact Assessment in Reducing Income Inequality in Latin America: 
#                 A Quasi-Experimental Analysis”
# Presented on July/2023 by Ileana Marroquin

###############################################################################
# 
### README
#Gettingdatareadyforanalysis

# Input: two cleaned dataframes (wiid_to_merge.csv & wid_wb_to_merge.csv)
# Output: CSV file called "merged_database_to_analyze.csv" to perform 
#         the descriptive analysis  
###############################################################################
###
### 0. Settup
###

#Loading all the libraies
library(tidyverse)
library(here)
library(dplyr)
library(Hmisc)


#Loading the two data frames files
unu_df<-read_csv(
  here("1_processed_data","wiid_to_merge.csv"), na = ""
)
wb_df<-read_csv(
  here("1_processed_data","wid_wb_to_merge.csv"), na = ""
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

###
### 1. Merging the Data frames
###

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
glimpse(database)

###
### 2. Generating variables for database: Lagged RM for -1 and -3 years
###

# Renaming som variables
database <- database  %>%
  rename(rm = personal_rm) %>%
  rename(gov_e = gov_cons_exp)

# Transform the variables into numerics
database <- database %>%
            mutate(rm = as.numeric(rm),
                  gov_e = as.numeric(gov_e),
                  debt_s = as.numeric(debt_s),
                  curr_acc_balance = as.numeric(curr_acc_balance)
                  )

#Generating new variables
database1 <- database  %>%
  mutate(Lag(rm, -1)) %>%
  mutate(Lag(rm, -3))

database1 <- database1  %>%
  rename(rm_l1 = `Lag(rm, -1)`) %>%
  rename(rm_l3 = `Lag(rm, -3)`)
  
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

###
### 3. Dealing with duplicated values 
###

# Note: For Duplicated values that are a result of having extra information 
# regarding within cities or geographical distribution sub grouping, resulting in
# two observations per year are displayed on this frame.  Therefore, 
# the strategy will be calculating country-year average.


# Identify duplicate rows within each country-year combination
duplicates <- duplicated(ineq_db[, c("country.x", "year")], fromLast = TRUE) | duplicated(ineq_db[, c("country.x", "year")])

# Subset the duplicated rows
duplicated_rows <- ineq_db[duplicates, ]

# Calculate the mean of selected numeric variables within each country-year combination
mean_values1 <- aggregate(. ~ country.x + year, 
                          data = duplicated_rows,
                          FUN = function(x) if (is.numeric(x)) mean(x, na.rm = TRUE) else x)

# Introduce the calculated averages back to the original data frame
mean_values2 <- ineq_db %>%
                group_by(country.x, year) %>%
                mutate(across(where(is.numeric), ~ mean(., na.rm = TRUE))) %>%
                distinct(country.x, year, .keep_all = TRUE) %>%
                ungroup()

# Update the original data frame with the merged values
ineq_db1 <- pdata.frame(mean_values2,
                        index=c("country.x", "year"))
table(index(ineq_db1), useNA = "ifany") 

# View the updated data frame
glimpse(ineq_db1)

# Conclusions: Duplicated values issue has been solved. Now is time to deal 
# with the missing values.

###
### 4. Dealing with missing observations 
###
# Subset the data of countries based on data availability
unique(ineq_db1$c3)


# Drop countries that lack more that the 50% of observations:
# Values to be dropped
values_to_drop <- c("BHS", "BRB", "BLZ", "CHL", "CUB",
                    "DMA", "GRD", "GUY", "HTI", "JAM", 
                    "PRI", "KNA", "LCA", "NIC", "VCT", 
                    "SUR", "TTO", "TCA", "VEN")

#Dropping rows
filtered_ineq_db1 <- ineq_db1 %>%
                    filter(!c3 %in% values_to_drop)

# Subletting period of time from 1995 to 2020
# Convert "year" column to numeric
filtered_ineq_db1$year <- as.numeric(
                          as.character(filtered_ineq_db1$year)
                          )

# Subset the data for the desired year range
filtered_ineq_db2 <- filtered_ineq_db1[filtered_ineq_db1$year >= 2000 & filtered_ineq_db1$year <= 2019, ]

# View the resulting data frame
glimpse(filtered_ineq_db2)

# Rename the filtered dataframe
ineq_db2 <- filtered_ineq_db2 

###
### 5. Imputing missing values for inequality quantitative indicators
###

#install.packages('mice')
#More info: https://github.com/SpencerPao/Data_Science/blob/main/Data%20Imputations/Mean_Median_MICE.R


library(mice)
library(tidyverse)

# Checking out the NA's that we are working with.
ineq_db2 %>% summarise_all(
                          funs
                          (sum(is.na(.))
                          ))
(34 / 300) * 100 # Approximatley 11.3% of the data is missing

# The main variable we are interested in imputing is gini
unique(ineq_db2$gini) # 9 unique classes

# Let's store a subset of data (Just to keep in mind)
data_gini_subset <- subset(
                    ineq_db2, 
                    is.na(ineq_db2$gini))

#install.packages("VIM")
library(VIM)

#Visuaizing where is the missing data
aggr_plot <- aggr(ineq_db2, col=c('navyblue','red'),
                  numbers=TRUE,
                  sortVars=TRUE,
                  labels=names(ineq_db2),
                  cex.axis=.7,
                  gap=3,
                  ylab=c("Histogram of Numerical Missing data","Pattern"))


#Applying Random Forest to impute gini missing values
set.seed(123)
imputed_data <- mice(ineq_db2, m=5, method = "rf")
                summary(imputed_data)
                imputed_data$imp$gini 
                unique(imputed_data$gini)

#Generating the imputed dataset
finished_imputed_data <- complete(imputed_data,1)

# Check for any missing values
sapply(finished_imputed_data, function(x) sum(is.na(x)))

ineq_db3<- finished_imputed_data
glimpse(ineq_db3)


# Checking the initial missing values
sum(is.na(ineq_db3$incomegroup))  # 34 missing values

# Visualizing where the missing data is
aggr_plot <- aggr(ineq_db3, col=c('navyblue','red'),
                  numbers=TRUE,
                  sortVars=TRUE,
                  labels=names(ineq_db3),
                  cex.axis=.7,
                  gap=3,
                  ylab=c("Histogram of Categorical Missing data","Pattern"))


# Check for any remaining missing values
sum(is.na(ineq_db3$incomegroup))  # 0 missing values now


#Rename Variables
finished_imputed_data <- finished_imputed_data %>%
  rename(country = country.x) %>%
  rename(id = id.x)

#Rename the definite database and export it
ir_data <- pdata.frame(finished_imputed_data, index=c("country", "year"))
glimpse(ir_data)

###
### 7. Save the output
###
#Save the final data for modeling
write.csv(ir_data, file = here("1_processed_data","merged_database_to_analyze.csv"), row.names = FALSE)

