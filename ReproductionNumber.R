###############################################################################
# REPRODUCTION NUMBER
# Code by Nel Jason Haw
# Last updated: Nov 15, 2020
# Guide at: https://neljasonhaw.github.io/ReproductionNumber/Reproduction-Number-Code.html#plot-reproduction-number-curve
###############################################################################

# Make sure the this script file and the file `linelist.csv` are in the same working directory.
# It's also important this script file was created as part of an R Project. Follow instructions on the guide.

## Installing packages - only do this once. Once the packages are installed, they are saved on your local computer.
# Remove the # sign so that R reads it as code
# install.packages("tidyverse")
# install.packages("janitor")
# install.packages("R0")
# install.packages("incidence")
# install.packages("writexl")

## Load packages - you need to do this every time you open R
library(tidyverse)      # General data analysis package
library(janitor)        # General data cleaning package
library(R0)             # Reproduction number
library(incidence)      # Generating incidence tables
library(writexl)        # Export to Excel spreadsheet

## Take a peek at the data
linelist <- read.csv("linelist.csv")        # Importing the linelist.csv file
head(linelist)                              # Displaying the first six rows of linelist

## Creating a new variable of imputed onset dates called DateOnset_imputed
# Telling R that the date variables are dates with format YYYY-MM-DD
linelist$DateOnset <- as.Date(linelist$DateOnset, "%Y-%m-%d")     
linelist$DateTested <- as.Date(linelist$DateTested, "%Y-%m-%d") 
linelist$DateReported <- as.Date(linelist$DateReported, "%Y-%m-%d")
# Imputation algorithm
linelist <- linelist %>% 
  mutate(DateOnset_imputed = case_when(is.na(DateOnset) & !is.na(DateTested) ~ DateTested - 2,
                                       is.na(DateOnset) & is.na(DateTested) ~ DateReported - 4,
                                       TRUE ~ DateOnset))
# Counts how many missing values are in DateOnset_imputed
sum(is.na(linelist$DateOnset_imputed))

## Generate incidence table
# Generate incidence table as incidence object (incidence)
incidence <- incidence(linelist$DateOnset_imputed)
# Generate incidence table as frequency table
incidencetable <- data.frame(incidence$dates, incidence$counts)
# Rename columns
colnames(incidencetable) <- c("DateOnset_imputed", "Count")
# Displaying the first six rows of incidence table
head(incidencetable)
# Export incidence table to Excel spreadsheet if you need it elsewhere (optional)
write_xlsx(incidencetable, "incidencetable.xlsx")

## Declare a serial interval distribution (replace based on what values you need)
mGT <- generation.time("weibull", c(7.0, 5.5), nrow(linelist))

## Generate epidemic curve to identify appropriate time period for analysis
ggplot(linelist, aes(x = DateOnset_imputed)) +      # Call data
  geom_histogram(binwidth = 7, fill = "#156A86", color = "black") +
      # Indicate visualization is histogram with bin width 7 days, custom colors
  xlab("Date of Symptom Onset (imputed)") + ylab("Number of Cases")
      # Renaming x and y axis labels
# A reasonable time period is between June 15 and November 1 based on the curve

## Subset incidence table based on the defined time period
incidencetable_subset <- incidencetable %>% 
  filter(DateOnset_imputed >= as.Date("2020-06-15") & DateOnset_imputed <= as.Date("2020-11-01"))
# %>% is a pipe filter in the dplyr package that makes coding more readable

## Estimate reproduction number
Rt <- estimate.R(epid = incidencetable_subset$Count, t = incidencetable_subset$Date, 
                 GT=mGT, method="TD", begin="2020-06-15", end="2020-11-01")
# Replace the dates according to your epidemic curve
# epid declares the incidence counts
# t declares the corresponding dates
# GT declares the serial interval distribution curve generated earlier
# TD indicates the Wallinga and Teunis (2004) method

## Store Rt results
# Retrieve relevant results and generate a data frame
Rt_table <- data.frame(Rt$t, Rt$estimates$TD$R, 
                       Rt$estimates$TD$conf.int$lower, Rt$estimates$TD$conf.int$upper)
# Note that you replace TD with the method you ended up using from R0. 
# Use the command str(Rt) to identify what values you exactly need
# Assign column names
colnames(Rt_table) <- c("date", "Rt", "lowerCI", "upperCI")
# Remove last row since that is zero (it messes up the graph)
Rt_table <- slice(Rt_table, 1:(n()-1))
# Save as Excel file if you need it elsewhere (optional)
write_xlsx(Rt_table, "Rt_table.xlsx")

## Plot Rt results and save as image
rt_plot <- ggplot(Rt_table, aes(x = date, y = Rt)) + geom_line(color="#156A86", lwd = 2) +   
  # Plot the line with point estimates, custom colors
  geom_ribbon(aes(ymax = upperCI, ymin = lowerCI), fill="#156A86", alpha = 0.2) + 
  # Plot the 95% confidence intervals, custom colors
  xlab("Date of symptom onset (imputed)") + ylab("Reproduction number")
rt_plot
ggsave(file="rt_plot.png", rt_plot, width = 160, height = 90, unit = "mm") 
# You may customize dimensions as you wish

## Filter analysis by Municipality C
linelist_C <- linelist %>% filter(Municipality == "Municipality C")
ggplot(linelist_C, aes(x = DateOnset_imputed)) +                  # Call data
  geom_histogram(binwidth = 7, fill = "#156A86", color = "black") +  
  # Indicate visualizaiton is histogram with bin width 7 days, custom colors
  # Plot the 95% confidence intervals, custom colors
  xlab("Date of symptom onset (imputed)") + ylab("Reproduction number") +
  # Renaming x and y axis labels
  geom_hline(yintercept = 1) +
  # Add a horizontal line indicating Rt = 1
  ylim(c(0,5))
  # Limit the scale of the y-axis

# A reasonable time period is between June 15 and October 25 based on the curve
# Filter linelist by chosen dates
linelist_C_subset <- 
  linelist_C %>% filter(DateOnset_imputed >= as.Date("2020-06-15") & 
                          DateOnset_imputed <= as.Date("2020-10-25"))
# Generate incidence table as incidence object (incidence_C)
incidence_C <- incidence(linelist_C_subset$DateOnset_imputed)
# Generate incidence table as frequency table
incidencetable_C <- data.frame(incidence_C$dates, incidence_C$counts)
# Rename columns
colnames(incidencetable_C) <- c("DateOnset_imputed", "Count")
# Displaying the first six rows of incidence table
head(incidencetable_C)
# Export incidence table to CSV if you need it elsewhere (optional)
write_xlsx(incidencetable_C, "incidencetable_C.xlsx")
# Estimate reproduction number
Rt_C <- estimate.R(epid = incidencetable_C$Count, t = incidencetable_C$Date, 
                   GT=mGT, method="TD", begin="2020-06-15", end="2020-10-25")
# Store the results
Rt_C_table <- data.frame(Rt_C$t, Rt_C$estimates$TD$R, 
                         Rt_C$estimates$TD$conf.int$lower, Rt_C$estimates$TD$conf.int$upper)
# Note that you replace TD with the method you ended up using from R0. 
# Use the command str(Rt) to identify what values you exactly need
# Assign column names
colnames(Rt_C_table) <- c("date", "Rt", "lowerCI", "upperCI")
# Remove last row since that is zero (it messes up the graph)
Rt_C_table <- slice(Rt_table, 1:(n()-1))
# Save as Excel file if you need it elsewhere (optional)
write_xlsx(Rt_C_table, "Rt_C_table.xlsx")
# Plot Rt results and save as image
rt_C_plot <- ggplot(Rt_C_table, aes(x = date, y = Rt)) + geom_line(color="#156A86", lwd = 2) +   
  geom_ribbon(aes(ymax = upperCI, ymin = lowerCI), fill="#156A86", alpha = 0.2) + 
  xlab("Date of symptom onset (imputed)") + ylab("Time-dependent reproduction number") +
  geom_hline(yintercept = 1) + ylim(c(0,5))
rt_C_plot
ggsave(file="rt_plot_C.png", rt_plot, width = 160, height = 90, unit = "mm")