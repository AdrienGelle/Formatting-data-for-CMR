########## Formatting data for MARK program #################

require(reshape)
require(lubridate)
require(RMark)
library(dplyr)
library(tidyr)

#load data
input.data<-read.csv("Sightings/field.data.csv")#col = date, id
df <- select(input.data, id, date)

#Transform data to encounter histories-----

#checking ID
df$id = as.character(df$id)
df$id <- trimws(df$id)#removing empty spaces

#convert Date
df$date = as.character(df$date)
df$date <- as.Date(df$date,format = "%d/%m/%Y")

# Extract the year from the date
df$year <- format(df$date, "%Y")

#Create a table with animal_id as rows and years as columns
encounter_history <- table(df$id, df$year)

#Convert the table to a data frame
encounter_history_df <- as.data.frame.matrix(encounter_history)

#Replace all NAs with 0 and all values > 0 with 1 to indicate presence or absence
encounter_history_df[is.na(encounter_history_df)] <- 0
encounter_history_df[encounter_history_df > 0] <- 1

#Add id as the first column
encounter_history_df <- cbind(id = rownames(encounter_history_df), encounter_history_df)

#output encounter history
write.csv(encounter_history_df, "outputs/Encounter history format.csv", row.names = F)

#Add covariates (optional)----
covariates = read.csv("Covariates/individuals_covariates.csv",header = T)#load covariates file
output= merge(x=encounter_history_df,y=covariates, by.x=c("id"), by.y=c("id"))#add covariates to life histories

#Filter out all unwanted individuals (e.g. no adults)
output = subset (output, stage != "Adult" & stage != "" & stage != "UNK")#remove all ringed as adults or unknown stage

write.csv(output, "outputs/Encounter history format.csv", row.names = F)#export csv

#----------------------------------------------------------------------------------------------


#Multi-states encounter histories----------
#load data
input.data<-read.csv("Sightings/field.data.csv")#col = date, id
df <- select(input.data, id, date)

#Transform data to encounter histories-

#checking ID
df$id = as.character(df$id)
df$id <- trimws(df$id)#removing empty spaces

#convert Date
df$date = as.character(df$date)
df$date <- as.Date(df$date,format = "%d/%m/%Y")

# Extract the year from the date
df$year <- format(df$date, "%Y")

#Create a table with animal_id as rows and years as columns
encounter_history <- table(df$id, df$year)

#Convert the table to a data frame
encounter_history_df <- as.data.frame.matrix(encounter_history)

#Replace all NAs with 0 and all values > 0 with 1 to indicate presence or absence
encounter_history_df[is.na(encounter_history_df)] <- 0
encounter_history_df[encounter_history_df > 0] <- 1

encounter_history_df <- cbind(id = rownames(encounter_history_df), encounter_history_df)

#replace 1/0 by states based on breeding data

breeding_info = read.csv("Covariates/breeding_info.csv",header = T)
# Loop through each row in the breeding information data frame and update encounter history
for (i in 1:nrow(breeding_info)) {
  individual <- breeding_info$id[i]
  year <- as.character(breeding_info$year[i])
  breeding <- breeding_info$breeding[i]
  
  encounter_history_df[encounter_history_df$id == individual, year] <- ifelse(breeding == "yes", "B", "1")
}
# Replace remaining "1"s with "NB" for non-breeders
encounter_history_df[encounter_history_df == "1"] <- "NB"
output=encounter_history_df

#Add covariates (optional)----
covariates = read.csv("Covariates/individuals_covariates.csv",header = T)#load covariates file
output= merge(x=output,y=covariates, by.x=c("id"), by.y=c("id"))#add covariates to life histories

#Filter out all unwanted individuals (e.g. no adults)
output = subset (output, stage != "Adult" & stage != "" & stage != "UNK")#remove all ringed as adults or unknown stage

#export
write.csv(output, "outputs/Encounter history format_multistate.csv", row.names = F)#export csv
