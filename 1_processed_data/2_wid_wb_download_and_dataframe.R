# WID_WB_DATAFRAME: Importing indicators from the WID database
# Research Title: “Remittances vs Public Finance Capacity. 
#                 Impact Assessment in Reducing Income Inequality in Latin America: 
#                 A Quasi-Experimental Analysis”
# Presented on July/2023 by Ileana Marroquin

###############################################################################
# 
### README
# This part obtains key variable data taking as a source the 
# World Development Indicators (‘WDI’). The key variables to use and then merge 
# to other relevant variables from the wiid_to_merge.csv file

# Input: The World Bank Rstudio library named (WDI)
# Output: CSV file called "wid_wb_to_merge.csv" dataframe 
#
###############################################################################

### 0. Settup

#Load data cleaning libraries
library(tidyverse)
library(dplyr)
library(plm)


### 1. Importing the data

# Load the WDI package and library
# install.packages("WDI")
library(WDI)

download_data <- WDI(
  country = c("AR", "BS", "BZ", "BO", "BR", "BB", "CL", "CO", "CR", "CU", "DM", 
              "DO", "EC", "GD", "GT", "GY", "HN", "HT", "JM", "KN", "LC", "MX", 
              "NI", "PA", "PE", "PR", "PY", "SV", "SR", "TC", "TT", "UY", "VC", 
              "VE"),
  indicator = c("personal_rm"="BX.TRF.PWKR.DT.GD.ZS", # Personal remittances, received (% of GDP)	
                "health_exp"="SH.XPD.CHEX.GD.ZS", # Current health expenditure (% of GDP)	
                "prim_edu_exp"="SE.XPD.PRIM.ZS", # Expenditure on primary education (% of government expenditure on education)
                "sec_edu_exp"="SE.XPD.SECO.ZS", # Expenditure on secondary education (% of government expenditure on education)
                "tri_edu_exp"="SE.XPD.TERT.ZS", # Expenditure on tertiary education (% of government expenditure on education)
                "gov_cons_exp"="NE.CON.GOVT.ZS", # General government final consumption expenditure (% of GDP)
                "curr_acc_balance"="BN.CAB.XOKA.GD.ZS", # Current account balance (% of GDP)
                "debt_s"="DT.TDS.DECT.EX.ZS", # Total debt service (% of exports of goods, services and primary income) 
                "edu_exp"="SE.XPD.TOTL.GD.ZS", # Government expenditure on education, total (% of GDP)
                "gross_exp"="NE.DAB.TOTL.ZS", # Gross national expenditure (% of GDP)	
                "rd_exp"="GB.XPD.RSDV.GD.ZS", # Research and development expenditure (% of GDP)
                "pov_gap"="SI.POV.GAPS" # Poverty gap at $2.15 a day (2017 PPP) (%)
                ),
                start = 1990,
                end = 2021,
                extra = FALSE,
                cache = NULL)
glimpse(download_data)


# Reframing to Panel Dataframe
wdidata <- pdata.frame(
          download_data, 
          index=c("country", "year")
          )
glimpse(wdidata)

# Select Relevant final variables
wdidata1 <- select(
            wdidata, -c(6:9)
            )
glimpse(wdidata1)

### 2. Save the output

write.csv(wdidata1, file = here("1_processed_data","wid_wb_to_merge.csv"), row.names = FALSE)
