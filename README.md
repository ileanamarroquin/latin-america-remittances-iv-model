# Replication Instructions of latin-america-remittances-iv-model

------------------------------------------------------------------------

## What this project does and why is usefull?

This README.rmd file provides an overview of the RStudio project for the Latin America Remittances IV Model. The main objective of this project is to provide a reproducible and transparent framework for the thesis presented as a voluntary research performed the past summer. Such file is available `MARROQUIN ILEANA THESIS.pdf` in the `/documentation` folder. The abstract and the main results used for Chapter 5 are available in the `2_thesis_IV_modeling_2SLS_GMM.Rmd` file.

### Data

The data for this project is obtained from two sources: the World Bank's [World Inequality Database](https://wid.world/) via `library(WDI)` and the [WIID-UNU database.](https://www.wider.unu.edu/project/world-income-inequality-database-wiid) The data is processed and cleaned using the `dplyr` and `tidyr` packages. The processed data is saved in the `/1_processed_data` folder.

### Documentation

The data and thesis document references for this project is located in the `documentation` directory.

### Code

The code used for the analysis for this project is located in the `2_code` directory. The code is organized into a series of .R and .Rmd scripts, each of which performs a specific task.

Likewise, note that every script starts with a small README section where a brief description of the objective, inputs and outputs are enlisted.

## How to Reproduce the Results?

-   Fork/Clone this repository to your server

-   The folders and the scripts have a number in the beginning to indicate the execution order, therefore start in `/1_processed_data` and open the `/1_wiid_dataframe.R` as the initial script.

-   Before running the initial script and the following scripts, make sure your cloned repository root is effectively addressed according to the location of the cloned repository. Notice that the directory uses the `library(here)` across the scripts.

-   Run `/1_wiid_dataframe.R`; then follow numerical execution order until arriving to the main modeling and analysis script Rmd file `2_thesis_IV_modeling_2SLS_GMM.Rmd` , winch is the main piece used for the impact assessment champter of the thesis.
