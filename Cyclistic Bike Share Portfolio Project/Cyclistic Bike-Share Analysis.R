#Install and Attach Packages

library(tidyverse)
library(lubridate)
library(janitor)
library(skimr)
library(dplyr)

#Collect Data

Trips_Sept_21 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202109.csv")
Trips_Oct_21 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202110.csv")
Trips_Nov_21 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202111.csv")
Trips_Dec_21 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202112.csv")
Trips_Jan_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202201.csv")
Trips_Feb_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202202.csv")
Trips_Mar_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202203.csv")
Trips_Apr_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202204.csv")
Trips_May_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202205.csv")
Trips_Jun_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202206.csv")
Trips_Jul_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202207.csv")
Trips_Aug_22 <- read.csv("C:\\Users\\twadh\\OneDrive\\Desktop\\Google Project\\Capstone Project\\Capstone Project Data\\Case Study 1\\Data\\tripdata_202208.csv")

#Check Coloumn Names of Data set

colnames(Trips_Sept_21)
colnames(Trips_Oct_21)
colnames(Trips_Nov_21)
colnames(Trips_Dec_21)
colnames(Trips_Jan_22)
colnames(Trips_Feb_22)
colnames(Trips_Mar_22)
colnames(Trips_Apr_22)
colnames(Trips_May_22)
colnames(Trips_Jun_22)
colnames(Trips_Jul_22)
colnames(Trips_Aug_22)

#Check Structure & Data Type of columns

str(Trips_Sept_21)
str(Trips_Oct_21)
str(Trips_Nov_21)
str(Trips_Dec_21)
str(Trips_Jan_22)
str(Trips_Feb_22)
str(Trips_Mar_22)
str(Trips_Apr_22)
str(Trips_May_22)
str(Trips_Jun_22)
str(Trips_Jul_22)
str(Trips_Aug_22)

# Comparing all the data sets, to find any mismatches before binding them into a single file.
# <0 rows> indicates that no mismatch is there.

compare_df_cols(Trips_Sept_21,Trips_Oct_21,Trips_Nov_21,Trips_Dec_21,Trips_Jan_22,Trips_Feb_22,Trips_Mar_22,Trips_Apr_22,Trips_May_22,Trips_Jun_22,Trips_Jul_22,Trips_Aug_22, return = "mismatch")

# Combing all the datasets into a single 'yearly_trips' dataset.

yearly_trips <- rbind(Trips_Sept_21, Trips_Oct_21, Trips_Nov_21, Trips_Dec_21, Trips_Jan_22, Trips_Feb_22, Trips_Mar_22,Trips_Apr_22,Trips_May_22,Trips_Jun_22,Trips_Jul_22,Trips_Aug_22)

# Remove Columns that wouldn't be used for analysis.

yearly_trips <- yearly_trips %>% 
  select(-c(start_station_id,end_station_id))

colnames(yearly_trips) #Show column names
dim(yearly_trips) #Dimensions of Dataframe
head(yearly_trips) #First 6 rows of data frame
str(yearly_trips) #Structure & Data Type
summary(yearly_trips) #Statistics of Data Frame


# Convert data type of start_date and end_date column from 'character' to 'date'.

yearly_trips$started_at = as.POSIXct(yearly_trips$started_at, format= '%Y-%m-%d %H:%M:%S', tz= Sys.timezone())

yearly_trips$ended_at = as.POSIXct(yearly_trips$ended_at, format= '%Y-%m-%d %H:%M:%S', tz= Sys.timezone())


# Create Month, Day, Year and Day of the Week columns from Date.

yearly_trips$Date <- as.Date(yearly_trips$started_at)

yearly_trips$Month <- format(as.Date(yearly_trips$Date), "%m")

yearly_trips$Day <- format(as.Date(yearly_trips$Date), "%d")

yearly_trips$Year <- format(as.Date(yearly_trips$Date), "%Y")

yearly_trips$day_of_week <- format(as.Date(yearly_trips$Date), "%A")


# Adding ride_length column

yearly_trips$ride_length_sec <- difftime(yearly_trips$ended_at,yearly_trips$started_at)

# To check if ride_length_sec is numeric type.

is.factor(yearly_trips$ride_length_sec)

# Convert ride_length_sec to numeric.

yearly_trips$ride_length_sec <- as.numeric((as.character((yearly_trips$ride_length_sec))))

# To check if ride_length_sec is numeric type.
is.numeric(yearly_trips$ride_length_sec)


skim(yearly_trips$ride_length_sec) #Data Summary

# Remove rows having ride_length less than zero.

yearly_trips <- yearly_trips[!(yearly_trips$ride_length_sec < 0),]

skim(yearly_trips)

summary(yearly_trips)

#Export file in csv format.
write.csv(yearly_trips, "yearly_trips.csv")



