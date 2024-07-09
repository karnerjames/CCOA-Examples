This R script was written to clean 2 large datasets for the City of Chicago Rental Assistance Program (RAP). 
RAP provides financial assistance directly to renters who are already late on rent or at risk of missing rent payments
to support rental payments for 6 months (sometimes more) to help avoid eviction for tenants.

This program was a smaller program locally funded prior to COVID when large amounts of federal funds were allocated 
towards RAP and other emergency assistance programs. While federal funding has slowed, there are other funding 
sources supporting the program so while the program has closed for a period of a few months before, it is still regularly 
accepting applications and actively providing assistance.

This script cleans and formats the data from the 2 main reports from the RAP data system. One report includes all applications
ever submitted, the other report shows "completed" applications submitted (deemed complete and ready for review) for a specified 
timeframe (I run through the beginning of previous year). This script cleans the two datasets in a way that calculates new
fields and formats for easier/better visuals in a PowerBI dashboard that includes calculations for number of applications 
by month, bi-weekly, and weekly and by location/employee as well as financial/spending estimates and processing times for
application approval and/or rejection. There is also a section creating a calendar to be used in power BI that excludes
weekends and City of Chicago holidays, among other elements for accurate calculations and reporting.The dashboard is able 
to be updated daily using this script to clean the reports pulled from the program system and then refreshing PowerBI visuals. 
The dashboard is used internally by program staff as well as upper management and the DFSS commissioner.
