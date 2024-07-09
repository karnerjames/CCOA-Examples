This R script was written to clean 2 large datasets for the City of Chicago Rental Assistance Program (RAP). 
RAP provides financial assistance directly to renters who are already late on rent or at risk of missing rent payments
to support rental payments for 6 months (sometimes more) to help avoid eviction for tenants.

This program was a smaller program locally funded prior to COVID when large amounts of federal funds were allocated 
towards RAP and other emergency assistance programs. While federal funding has slowed, there are other funding 
sources supporting the program so while the program has closed for a period of a few months before, it is still regularly 
accepting applications and actively providing assistance.

This script cleans and formats the data from the 2 main reports from the RAP data system. One report includes all applications
ever submitted, the other report shows applications submitted (deemed complete and ready for review) based on a specified 
timeframe (I run through the beginning of previous year). The script cleans the two datasets in a way that calculates new
fields and formats for easier/better visuals in a PowerBI dashboard that includes calculations for number of applications 
by month, bi-weekly, and weekly and by location/employee as well as financial/spending estimates and processing times for
application approval and/or rejection. The dashboard is able to be updated daily using this script to clean the reports
pulled from the program system and then refreshing PowerBI visuals. The dashboard is used internally by program staff as 
well as upper management and the DFSS commissioner.
