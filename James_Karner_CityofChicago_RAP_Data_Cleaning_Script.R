

## THIS SCRIPT IS TO CLEAN THE DATA FROM 2 REPORTS PULLED FROM AGING IS

## THE FIRST CLEANING SECTION IS FOR THE WORKFLOW DATA FROM THE AGINGIS WORKFLOW
## REPORT. CLEAR ALL FIELDS AND RUN THROUGH PAST YEAR (OR TO BEGINNING OF LAST YEAR)
## RUN REPORT BY CLICKING SEARCH

## THE SECOND CLEANING SECTION IS FOR THE QUERRY BUILDER SECTION. FILTER REPORTS
## BY CREATED DATE AND MOST RECENT ESHELL REPORT TITLED "RAP App Dashboard" IS
## WHAT YOU RUN

## FOR BOTH REPORTS, YOU MUST SCROLL TO THE "PRINT LIST" BUTTON AND PRINT TO EXCEL
## TO EXPORT TO YOUR FOLDER (THIS TAKES A FEW MINUTES)

## THE LAST SECTION IS JUST GENERATING A CALENDAR FOR USE IN POWERBI

#______________________________________________________________________________________


## PRESS CTRL + ALT + R TO RUN THIS SCRIPT AND CLEAN THE RAP DATA FOR THE RAP DASHBOARD:

## AFTER YOU RUN SCRIPT, FINAL STEP IS TO MOVE BOTH TO THE FOLDER WHICH YOU 
## SET THIS SCRIPT TO PULL FROM (THE FILE PATH NEAR THE TOP OF THE SCRIPT)


##END INSTRUCTIONS______________________________________________________________

#Loading Libraries:
library(dplyr)
library(tidyverse)
library(readxl)
library(bizdays)
library(lubridate)

#_______________________________________________________________________________________________________

##THIS SECTION IS FOR THE WORKFLOW DATACLEANING

# Setting file path for RAP workflow data (will only need updating if report location(s) change)

#REDACTED setwd(XXXXX)
RAP_Workflow <- read_xls("ClientWorkflowOutcome.xls")


# Creating Intake Location Staffing List (This should be updated as staffing changes):

#REDACTED englewood_staff_list <- c()

#REDACTED garfield_staff_list <- c()

#REDACTED kingcenter_staff_list <- c()
                           
#REDACTED northarea_staff_list <- c()

#REDACTED southchicago_staff_list <- c()

#REDACTED trinadavila_staff_list <- c()


# running script to add column for CSC location for in process applications based on current employee list

RAP_Workflow <- RAP_Workflow %>%
  mutate(
    inprocess_applicant_location = case_when(
      
      # If assigned to user matches employee from location, and completed date is blank, put location
      
      (`Assigned To User` %in% englewood_staff_list & is.na(`Completed Date`)) ~ "Englewood",
      
      # Also, if completed date and assigned to user is blank, and assigned to user group is location, put 
      # location 
      
      is.na(`Completed Date`) &
        is.na(`Assigned To User`) & `Assigned To User Group` == "Englewood" ~ "Englewood",
      
      # Repeating for remaining locations
      
      (`Assigned To User` %in% garfield_staff_list & is.na(`Completed Date`)) ~ "Garfield",
      
      is.na(`Completed Date`) &
        is.na(`Assigned To User`) & `Assigned To User Group` == "Garfield" ~ "Garfield",
      
      (`Assigned To User` %in%  kingcenter_staff_list& is.na(`Completed Date`)) ~ "King Center",
      
      is.na(`Completed Date`) &
        is.na(`Assigned To User`) & `Assigned To User Group` == "King Center" ~ "King Center",
      
      (`Assigned To User` %in% northarea_staff_list & is.na(`Completed Date`)) ~ "North Area",
      
      is.na(`Completed Date`) &
        is.na(`Assigned To User`) & `Assigned To User Group` == "North Area" ~ "North Area",
      
      (`Assigned To User` %in% southchicago_staff_list & is.na(`Completed Date`)) ~ "South Chicago",
      
      is.na(`Completed Date`) &
        is.na(`Assigned To User`) & `Assigned To User Group` == "South Chicago" ~ "South Chicago",
      
      (`Assigned To User` %in% trinadavila_staff_list & is.na(`Completed Date`)) ~ "Trina Davila",
      
      is.na(`Completed Date`) &
        is.na(`Assigned To User`) & `Assigned To User Group` == "Trina Davila" ~ "Trina Davila",
      
      TRUE ~ NA_character_
    )
  )

unassigned <- filter(RAP_Workflow, is.na(RAP_Workflow$`Completed Date`) & is.na(RAP_Workflow$inprocess_applicant_location))

unique(unassigned$`Assigned To User`)



#creating csc location for all files based on employee list (not just in process):

RAP_Workflow <- RAP_Workflow %>%
  mutate(
    csc_location = case_when(
      
      (`Assigned To User` %in% englewood_staff_list) ~ "Englewood",
      
      is.na(`Assigned To User`) & `Assigned To User Group` == "Englewood" ~ "Englewood",
      
      (`Assigned To User` %in% garfield_staff_list) ~ "Garfield",
      
      is.na(`Assigned To User`) & `Assigned To User Group` == "Garfield" ~ "Garfield",
      
      (`Assigned To User` %in%  kingcenter_staff_list& is.na(`Completed Date`)) ~ "King Center",
      
      is.na(`Assigned To User`) & `Assigned To User Group` == "King Center" ~ "King Center",
      
      (`Assigned To User` %in% northarea_staff_list) ~ "North Area",
      
      is.na(`Assigned To User`) & `Assigned To User Group` == "North Area" ~ "North Area",
      
      (`Assigned To User` %in% southchicago_staff_list) ~ "South Chicago",
      
      is.na(`Assigned To User`) & `Assigned To User Group` == "South Chicago" ~ "South Chicago",
      
      (`Assigned To User` %in% trinadavila_staff_list) ~ "Trina Davila",
      
      is.na(`Assigned To User`) & `Assigned To User Group` == "Trina Davila" ~ "Trina Davila",
      
      TRUE ~ NA_character_
    )
  )

#converting Created Date to date type column:

RAP_Workflow$'Created Date' <- as.Date(RAP_Workflow$"Created Date", format = "%Y-%m-%d")

#separating names for cleaner display in powerbi:

RAP_Workflow$employeename <- RAP_Workflow$`Assigned To User`
RAP_Workflow <- separate(RAP_Workflow, employeename, into = c("Assigned To Employee", "Info"), sep = "\\(")


#converting created date to date type:

RAP_Workflow$'Created Date' <- as.Date(RAP_Workflow$'Created Date')

filtered_data <- RAP_Workflow %>%
  select(`Created Date`, csc_location)

#removing rows with NA values in 'csc_location' column
filtered_data <- filtered_data[complete.cases(filtered_data), ]

#grouping by 'Created Date' and counting non-NA values for each date
non_na_counts <- filtered_data %>%
  group_by(`Created Date`) %>%
  summarize(non_na_count = sum(!is.na(csc_location)))



#exporting to excel (will go to the set working directory at beginning of script):
writexl::write_xlsx(RAP_Workflow, "RAP_Workflow.xlsx")

writexl::write_xlsx(unassigned, "Unassigned_Workflow.xlsx")

#_________________________________________________________________________________________________________________



##THIS PART IS FOR APPLICATION DATA CLEANING (QUERY DATA)


#Reading in data:

RAP_Applications <- read_excel("QueryResult.xlsx")

#REDACTED filepath_rapapplications <- XXX

#capturing current date for "report date" in powerbi:

date_modified <- file.info(filepath_rapapplications)$mtime

RAP_Applications <- RAP_Applications %>%
  mutate(report_date = as.Date(date_modified))


#getting month and year that applications are submitted:

RAP_Applications$'Application Date Submitted' <- as.Date(RAP_Applications$"Application Date Submitted")
RAP_Applications$month_application_submitted <- month(RAP_Applications$'Application Date Submitted', label = TRUE)
RAP_Applications$year_application_submitted <- year(RAP_Applications$'Application Date Submitted')
RAP_Applications$monthyear_application_submitted <- as.Date(format(RAP_Applications$`Application Date Submitted`, "%Y-%m-01"))
RAP_Applications$monthyear_application_submitted <- format(as.Date(RAP_Applications$`Application Date Submitted`), "%b-%y")
RAP_Applications$week_application_submitted <- week(RAP_Applications$'Application Date Submitted')



#creating Quarter-Year application submitted, approved, and rejected variable:

RAP_Applications <- RAP_Applications %>%
  mutate(year_quarter_application_submitted = case_when(
    month_application_submitted %in% c("Jan", "Feb", "Mar") ~ paste0(year_application_submitted, "-Q1"),
    month_application_submitted %in% c("Apr", "May", "Jun") ~ paste0(year_application_submitted, "-Q2"),
    month_application_submitted %in% c("Jul", "Aug", "Sep") ~ paste0(year_application_submitted, "-Q3"),
    month_application_submitted %in% c("Oct", "Nov", "Dec") ~ paste0(year_application_submitted, "-Q4"),
    TRUE ~ NA_character_
  ))

RAP_Applications <- RAP_Applications %>%
  mutate(year_quarter_approved = case_when(
    month(`Application Date Approved`) %in% 1:3 ~ paste0(year(`Application Date Approved`), "-Q1"),
    month(`Application Date Approved`) %in% 4:6 ~ paste0(year(`Application Date Approved`), "-Q2"),
    month(`Application Date Approved`) %in% 7:9 ~ paste0(year(`Application Date Approved`), "-Q3"),
    month(`Application Date Approved`) %in% 10:12 ~ paste0(year(`Application Date Approved`), "-Q4"),
    TRUE ~ NA_character_
  ))

RAP_Applications <- RAP_Applications %>%
  mutate(year_quarter_rejected = case_when(
    month(`Application Date Rejected`) %in% 1:3 ~ paste0(year(`Application Date Rejected`), "-Q1"),
    month(`Application Date Rejected`) %in% 4:6 ~ paste0(year(`Application Date Rejected`), "-Q2"),
    month(`Application Date Rejected`) %in% 7:9 ~ paste0(year(`Application Date Rejected`), "-Q3"),
    month(`Application Date Rejected`) %in% 10:12 ~ paste0(year(`Application Date Rejected`), "-Q4"),
    TRUE ~ NA_character_
  ))


#creating indicator variable for previous week to use on weekly visuals:

#getting just current year to identify max week this year only:

current_date <- Sys.Date()
current_year_data <- RAP_Applications %>%
  filter(year_application_submitted == year(current_date))

#finding the most recent week within the maximum year
max_week_in_current_year <- max(current_year_data$week_application_submitted)

#calculating the prior week
last_week <- max_week_in_current_year - 1

#creating indicator variable for previous week
RAP_Applications$previous_week_indicator <- ifelse(RAP_Applications$year_application_submitted == year(current_date) & RAP_Applications$week_application_submitted == last_week, 1, 0)


#converting to date
RAP_Applications$'Application Date Selected For Processing' <- as.Date(RAP_Applications$"Application Date Selected For Processing")
RAP_Applications$'Application Date Approved' <- as.Date(RAP_Applications$"Application Date Approved")
RAP_Applications$'Application Date Rejected' <- as.Date(RAP_Applications$"Application Date Rejected")


#creating a function to count the days to approval and rejection that excludes the days that the
#program was closed/not accepting applications

calculate_days_excluding_period_and_holidays <- function(start_date, end_date, exclude_start, exclude_end, holidays) {
  #checking for NA or invalid dates
  if (is.na(start_date) || is.na(end_date) || start_date > end_date) {
    return(NA)
  }
  
  #converting all dates to date type for consistency
  start_date <- as.Date(start_date)
  end_date <- as.Date(end_date)
  exclude_start <- as.Date(exclude_start)
  exclude_end <- as.Date(exclude_end)
  holidays <- as.Date(holidays)
  
  #creating a sequence of all days between start_date and end_date
  all_days <- seq(start_date, end_date, by = "day")
  
  #removing weekends and holidays:
  weekdays <- all_days[!weekdays(all_days) %in% c("Saturday", "Sunday")]
  workdays <- weekdays[!weekdays %in% holidays]
  
  #Removing days in the exclusion period
  workdays <- workdays[!(workdays >= exclude_start & workdays <= exclude_end)]
  
  #returning the count of remaining days
  return(length(workdays))
}

#defining City of Chicago holiday list:

holidays <- c("2020-01-01", "2020-01-20", "2020-02-12", "2020-02-17", "2020-03-02", "2020-05-25", "2020-06-19", 
               "2020-09-07", "2020-10-12", "2020-11-11", "2020-11-26", "2020-12-25",
               "2021-01-01", "2021-01-18", "2021-02-12", "2021-02-15", "2021-03-01", "2021-05-31", "2021-06-18", 
               "2021-09-06", "2021-10-11", "2021-11-11", "2021-11-25", "2021-12-24",
               "2022-01-01", "2022-01-17", "2022-02-12", "2022-02-21", "2022-03-07", "2022-05-30", "2022-06-19", 
               "2022-09-05", "2022-10-10", "2022-11-11", "2022-11-24", "2022-12-26",
               "2023-01-01", "2023-01-16", "2023-02-12", "2023-02-20", "2023-03-06", "2023-05-29", "2023-06-19", 
               "2023-09-04", "2023-10-09", "2023-11-10", "2023-11-23", "2023-12-25",
               "2024-01-01", "2024-01-15", "2024-02-12", "2024-02-19", "2024-03-04", "2024-05-27", "2024-06-19", 
               "2024-09-02", "2024-10-14", "2024-11-11", "2024-11-28", "2024-12-25",
               "2025-01-01", "2025-01-20", "2025-02-12", "2025-02-17", "2025-03-03", "2025-05-26", "2025-06-19", 
               "2025-09-01", "2025-10-13", "2025-11-11", "2025-11-27", "2025-12-25",
               "2026-01-01", "2026-01-19", "2026-02-12", "2026-02-16", "2026-03-02", "2026-05-25", "2026-06-19", 
               "2026-09-07", "2026-10-12", "2026-11-11", "2026-11-26", "2026-12-25",
               "2027-01-01", "2027-01-18", "2027-02-12", "2027-02-15", "2027-03-01", "2027-05-31", "2027-06-18", 
               "2027-09-06", "2027-10-11", "2027-11-11", "2027-11-25", "2027-12-24",
               "2028-01-01", "2028-01-17", "2028-02-12", "2028-02-21", "2028-03-06", "2028-05-29", "2028-06-19", 
               "2028-09-04", "2028-10-09", "2028-11-10", "2028-11-23", "2028-12-25",
               "2029-01-01", "2029-01-15", "2029-02-12", "2029-02-19", "2029-03-05", "2029-05-28", "2029-06-18", 
               "2029-09-03", "2029-10-08", "2029-11-12", "2029-11-22", "2029-12-25",
               "2030-01-01", "2030-01-21", "2030-02-12", "2030-02-18", "2030-03-04", "2030-05-27", "2030-06-17", 
               "2030-09-02", "2030-10-14", "2030-11-11", "2030-11-28", "2030-12-25")

# Applying the function to calculate days to approval/rejection excluding weekends, holidays, and closed period:

RAP_Applications$days_to_approval <- mapply(calculate_days_excluding_period_and_holidays,
                                            RAP_Applications$`Application Date Selected For Processing`,
                                            RAP_Applications$`Application Date Approved`,
                                            MoreArgs = list(exclude_start = as.Date("2023-06-30"),
                                                            exclude_end = as.Date("2023-11-19"),
                                                            holidays = holidays))

RAP_Applications$days_to_rejection <- mapply(calculate_days_excluding_period_and_holidays,
                                             RAP_Applications$`Application Date Selected For Processing`,
                                             RAP_Applications$`Application Date Rejected`,
                                             MoreArgs = list(exclude_start = as.Date("2023-06-30"),
                                                             exclude_end = as.Date("2023-11-19"),
                                                             holidays = holidays))

#calculating weeks to approval/rejection:
RAP_Applications$weeks_to_approval <- round(RAP_Applications$days_to_approval / 5, 1)
RAP_Applications$weeks_to_rejection <- round(RAP_Applications$days_to_rejection / 5, 1)



#creating indicator variable for 30 days or less to approval and 30
#days or less to rejection 1 if yes, 0 if no:

RAP_Applications <- RAP_Applications %>%
  mutate(approval_30orlessdays_indicator = ifelse(days_to_approval < 31, 1, 0)) %>%
  mutate(rejection_30orlessdays_indicator = ifelse(days_to_rejection < 31, 1, 0))



#getting funding information:

#creating total_amount column for sum of amount1-6 columns:

RAP_Applications <- RAP_Applications %>%
  mutate(total_amount = rowSums(select(., c("Application Amount1", "Application Amount2", "Application Amount3", "Application Amount4", "Application Amount5", "Application Amount6")), na.rm = TRUE))


#converting to date format:
RAP_Applications$`Application Date Approved` <- as.Date(RAP_Applications$`Application Date Approved`, format = "%m/%d/%Y")

#creating new columns for week and month:
RAP_Applications <- RAP_Applications %>%
  mutate(week = week(`Application Date Approved`),
         month = month(`Application Date Approved`, label = TRUE))


#calculating acceptance and rejection rate

#calculating total approved or rejected 
total_approved_or_rejected <- RAP_Applications %>%
  filter(`Application Application Status` %in% c("Approved", "Rejected")) %>%
  nrow()

# Calculate total number of applications with approved status
total_approved <- RAP_Applications %>%
  filter(`Application Application Status` == "Approved") %>%
  nrow()

# Calculate rejection rate
rejection_rate <- (total_approved_or_rejected - total_approved) / total_approved_or_rejected

#calculating total number of applications with rejected status
total_rejected <- RAP_Applications %>%
  filter(`Application Application Status` == "Rejected") %>%
  nrow()

#calculating approval rate
approval_rate <- (total_approved_or_rejected - total_rejected) / total_approved_or_rejected


#creating column for approval and rejection rate to use in PowerBI:

RAP_Applications <- RAP_Applications %>%
  mutate(application_approval_rate = approval_rate) %>%
  mutate(application_rejection_rate = rejection_rate)

#creating outgoing applications indicator column for all approved and rejected applications
RAP_Applications$outgoing_applications_indicator <- ifelse(RAP_Applications$'Application Application Status' %in% c("Approved", "Rejected"), 1, 0)

RAP_Workflow$location <- ifelse(RAP_Workflow$'Workflow Outcome Name' == "Englewood Start Verification", "Englewood",
                                    ifelse(RAP_Workflow$'Workflow Outcome Name' == "South Chicago Start Verification", "South Chicago",
                                    ifelse(RAP_Workflow$'Workflow Outcome Name' == "King Center Start Verification", "King Center",
                                    ifelse(RAP_Workflow$'Workflow Outcome Name' == "Garfield Start Verification", "Garfield",
                                    ifelse(RAP_Workflow$'Workflow Outcome Name' == "Trina Davila Start Verification", "Trina Davila",
                                    ifelse(RAP_Workflow$'Workflow Outcome Name' == "North Area Start Verification", "North Area",
                                    "Unassigned"))))))


#creating clean months requested column for visual (cap at 12):

RAP_Applications <- RAP_Applications %>%
  mutate(months_requested = case_when(
    `Application Eligibility Intake Housing Type Number Of Month Rent Covered` >= 13 ~ 999,
    `Application Eligibility Intake Housing Type Number Of Month Rent Covered` >= 1 & `Application Eligibility Intake Housing Type Number Of Month Rent Covered` <= 12 ~ `Application Eligibility Intake Housing Type Number Of Month Rent Covered`,
    `Application Eligibility Intake Housing Type Number Of Month Rent Covered` <= 0 ~ 0
  ))


#getting clean outgoing_date based on approved or rejected date for application tracking visual:

RAP_Applications <- RAP_Applications %>%
  mutate(outgoing_date = case_when(
    !is.na(`Application Date Approved`) ~ as.Date(`Application Date Approved`),
    !is.na(`Application Date Rejected`) ~ as.Date(`Application Date Rejected`),
    TRUE ~ as.Date(NA)
  ))


#separating zip codes with second part so only 6 digits for all:

RAP_Applications <- RAP_Applications %>%
  separate(`Applicant Zip`, into = c("Applicant Zip", "Applicant_2nd_zip"), sep = "-")

#exporting to excel

writexl::write_xlsx(RAP_Applications, "RAP_Applications.xlsx")


#Removing duplicates based on applicant applicant ID column and keeping most
#recent row based on application date submitted column:


RAP_Applications_duplicates_removed <- RAP_Applications %>%
  arrange(`Applicant Applicant ID`, desc(`Application Date Submitted`)) %>%
  distinct(`Applicant Applicant ID`, .keep_all = TRUE)


writexl::write_xlsx(RAP_Applications_duplicates_removed, "RAP_Applications_Duplicates_Removed.xlsx")




#_____________________________________________________________________________

## THIS SECTION CREATES THE CALENDAR THAT IS USED IN POWERBI AND CAPTURES
## CURRENT WEEK AND PREVIOUS WEEK INDICATORS ALSO USED IN PROCESSING TIME
## CALCULATIONS


# Updating date list for last week indicator:

#creating a sequence of dates from January 1, 2020, to December 31, 2030
dates <- seq(as.Date("2020-01-01"), as.Date("2030-12-31"), by = "day")

#creating a data frame to store date-related information
date_data <- data.frame(Date = as.Date(dates))  # Ensure date format is yyyy-mm-dd

#adding a column for the day of the week
date_data$Day_of_Week <- weekdays(date_data$Date)

#initializing the "day_of_week" column with "Weekday"
date_data$day_of_week <- "Weekday"

#listing of all City of Chicago holidays through 2030
holidays <- c("2020-01-01", "2020-01-20", "2020-02-12", "2020-02-17", "2020-03-02", "2020-05-25", "2020-06-19", 
              "2020-09-07", "2020-10-12", "2020-11-11", "2020-11-26", "2020-12-25",
              "2021-01-01", "2021-01-18", "2021-02-12", "2021-02-15", "2021-03-01", "2021-05-31", "2021-06-18", 
              "2021-09-06", "2021-10-11", "2021-11-11", "2021-11-25", "2021-12-24",
              "2022-01-01", "2022-01-17", "2022-02-12", "2022-02-21", "2022-03-07", "2022-05-30", "2022-06-19", 
              "2022-09-05", "2022-10-10", "2022-11-11", "2022-11-24", "2022-12-26",
              "2023-01-01", "2023-01-16", "2023-02-12", "2023-02-20", "2023-03-06", "2023-05-29", "2023-06-19", 
              "2023-09-04", "2023-10-09", "2023-11-10", "2023-11-23", "2023-12-25",
              "2024-01-01", "2024-01-15", "2024-02-12", "2024-02-19", "2024-03-04", "2024-05-27", "2024-06-19", 
              "2024-09-02", "2024-10-14", "2024-11-11", "2024-11-28", "2024-12-25",
              "2025-01-01", "2025-01-20", "2025-02-12", "2025-02-17", "2025-03-03", "2025-05-26", "2025-06-19", 
              "2025-09-01", "2025-10-13", "2025-11-11", "2025-11-27", "2025-12-25",
              "2026-01-01", "2026-01-19", "2026-02-12", "2026-02-16", "2026-03-02", "2026-05-25", "2026-06-19", 
              "2026-09-07", "2026-10-12", "2026-11-11", "2026-11-26", "2026-12-25",
              "2027-01-01", "2027-01-18", "2027-02-12", "2027-02-15", "2027-03-01", "2027-05-31", "2027-06-18", 
              "2027-09-06", "2027-10-11", "2027-11-11", "2027-11-25", "2027-12-24",
              "2028-01-01", "2028-01-17", "2028-02-12", "2028-02-21", "2028-03-06", "2028-05-29", "2028-06-19", 
              "2028-09-04", "2028-10-09", "2028-11-10", "2028-11-23", "2028-12-25",
              "2029-01-01", "2029-01-15", "2029-02-12", "2029-02-19", "2029-03-05", "2029-05-28", "2029-06-18", 
              "2029-09-03", "2029-10-08", "2029-11-12", "2029-11-22", "2029-12-25",
              "2030-01-01", "2030-01-21", "2030-02-12", "2030-02-18", "2030-03-04", "2030-05-27", "2030-06-17", 
              "2030-09-02", "2030-10-14", "2030-11-11", "2030-11-28", "2030-12-25")

#updating "day_of_week" column for holidays
date_data$day_of_week[date_data$Date %in% as.Date(holidays)] <- "Holiday"

#if a holiday falls on a weekend, observe it on the following Monday
weekend_holidays <- c("2020-07-04", "2020-12-25", "2021-01-01", "2021-07-04", "2021-12-25", 
                      "2022-01-01", "2022-07-04", "2022-12-25", "2023-01-01", "2023-07-04", 
                      "2023-12-25", "2024-01-01", "2024-07-04", "2024-12-25", "2025-01-01", 
                      "2025-07-04", "2025-12-25", "2026-01-01", "2026-07-04", "2026-12-25", 
                      "2027-01-01", "2027-07-04", "2027-12-25", "2028-01-01", "2028-07-04", 
                      "2028-12-25", "2029-01-01", "2029-07-04", "2029-12-25", "2030-01-01", 
                      "2030-07-04", "2030-12-25")

monday_holidays <- as.Date(weekend_holidays) + ifelse(weekdays(as.Date(weekend_holidays)) == "Saturday", 2, 1)

#updating "day_of_week" column for holidays observed on Monday
date_data$day_of_week[date_data$Date %in% monday_holidays] <- "Holiday"

#adding a column for the start of the week
date_data$Start_of_Week <- date_data$Date - lubridate::wday(date_data$Date) + 1

#adding a column for the week number
date_data$Week_Number <- lubridate::week(date_data$Date)


today <- Sys.Date()

#getting last week and 2 weeks ago indicators
most_recent_week <- lubridate::floor_date(today, "week")
last_week <- most_recent_week - lubridate::weeks(1)
two_weeks_ago <- most_recent_week - lubridate::weeks(2)


#adding a column indicating last week or last 2 weeks
date_data$Last_Week_Indicator <- ifelse(date_data$Start_of_Week == last_week, 1, 0)
date_data$Last_two_Weeks_Indicator <- ifelse(date_data$Start_of_Week == last_week | date_data$Start_of_Week == two_weeks_ago, 1, 0)


writexl::write_xlsx(date_data,"date_data_for_powerbi.xlsx")

