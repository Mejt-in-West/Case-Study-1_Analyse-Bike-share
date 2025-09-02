#install relevant packages for analysis
install.packages(“tidyverse”) #collection of packages for data manipulation, exploration, & visualisation (incl. ggplot2, tibble, tidyr, readr, purr, dplyr, stringr, forcats)
install.packages(“conflicted”) #helps manage conflicts
install.packages(“lubridate”) #simplifies handling dates, extracting weekdays, months, etc.

#load libraries
library(tidyverse)
library(conflicted)
library(lubridate)

#Set 'dplyr: filter' as the default choice, as it was flagged for conflict with 'stats: filter'
conflict_prefer("filter", "dplyr")

#import datasets
Q1_2019 <- read_csv("C:/Users/LisaW/OneDrive/Documents/Google_Data_analytics/Casestudy/Bike-share/Divvy_Trips_2019_Q1.csv")

Q1_2020 <- read_csv("C:/Users/LisaW/OneDrive/Documents/Google_Data_analytics/Casestudy/Bike-share/Divvy_Trips_2020_Q1.csv")

#CLEAN 2019 DATASET:
#Match data type and headers from 2019 to 2020
Q1_2019_clean <- Q1_2019 %>%
rename( 
ride_id = trip_id, 
rideable_type = bikeid, 
started_at = start_time, 
ended_at = end_time, 
start_station_name = from_station_name, 
end_station_name = to_station_name, 
start_station_id = from_station_id, 
end_station_id = to_station_id, 
member_casual = usertype
)%>%

#Remove birthyear and gender fields as this data was dropped beginning of 2020 
select(-any_of(c("birthyear", "gender"))
) %>%

#Reclass date & time for easier separation, and to later allow adding a matching column in the 2020 data
mutate(
started_at = as.POSIXct(started_at, format="%Y-%m-%d %H:%M:%S"),
ended_at = as.POSIXct(ended_at, format="%Y-%m-%d %H:%M:%S"),

#Convert ride_id and rideable_type to character so that they can stack correctly,
ride_id = as.character(ride_id),
rideable_type = as.character(rideable_type),

#Rename member vs subs/customer vs casual
member_casual = recode(member_casual,
"Subscriber" = "member",
"Customer" = "casual")
)

#Recalculate tripduration from seconds to minutes
Q1_2019_clean$tripduration <- Q1_2019_clean$tripduration / 60

#Inspect changes to the 2019 dataset
colnames(Q1_2019_clean) #List all column names
str(all_trips) #See list of columns and data types
head(Q1_2019_clean$tripduration) #check tripduration conversion to minutes was successful 
table(Q1_2019_clean$member_casual) #Check conversion of member/casual was successful, and the proper number of observations were reassigned 

#CLEAN 2020 DATASET
#Add a tripduration column to the 2020 dataset
Q1_2020_clean <- Q1_2020 %>%
mutate(
started_at = as.POSIXct(started_at, format="%Y-%m-%d %H:%M:%S"),
ended_at   = as.POSIXct(ended_at, format="%Y-%m-%d %H:%M:%S"),
tripduration = as.numeric(difftime(ended_at, started_at, units = "min"))
) %>%

#Remove lat and long, birthyear fields as this data was dropped beginning of 2020 
select(-any_of(c("start_lat", "start_lng", "end_lat", "end_lng"))
)

#Inspect changes to the 2020 dataset
colnames(Q1_2020_clean) #List all column names
head(Q1_2020_clean$tripduration) #check tripduration conversion to minutes was successful 


#COMBINE CLEAN DATASETS
all_trips <- bind_rows(Q1_2019_clean, Q1_2020_clean) %>%

#filter our unnecessary data, if bikes were taken out of docks and checked for quality by Divvy or tripduration was negative
filter(tripduration > 0, start_station_name != "HQ QR")

#add a column displaying what day of the week service was utilised
all_trips$day_of_week <- format(as.Date(all_trips$started_at),"%A")

#order day of week from Mon-Sun for easier view.
all_trips$day_of_week <- ordered(all_trips$day_of_week, levels=c("Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday")) 

#make sure the proper number of observations were reassigned 
table(all_trips$day_of_week) 

#ANALYSE
#Overall tripduration stats
all_trips %>%
group_by(member_casual) %>%
summarise(
mean_duration = mean(tripduration, na.rm = TRUE),
median_duration = median(tripduration, na.rm = TRUE), 
max_duration = max(tripduration, na.rm = TRUE),
min_duration = min(tripduration, na.rm = TRUE))

#Overall ride frequency by member vs casual
all_trips %>%
group_by(member_casual) %>%
summarise(total_rides = n())

#Ride frequency by week
all_trips %>%
group_by(member_casual, day_of_week) %>%
summarise(avg_duration = mean(tripduration, na.rm = TRUE))

#Ride frequency by month
all_trips %>%
mutate(month = month(started_at, label = TRUE)) %>%
group_by(member_casual, month) %>%
summarise(total_rides = n(), .groups = "drop")

#Create visualisation for weekly number of rides by member vs casual 
all_trips %>%  
mutate(weekday = wday(started_at, label = TRUE)) %>% 
group_by(member_casual, weekday) %>% 
summarise(number_of_rides = n(),average_duration = mean(tripduration), .groups = "drop") %>% 
arrange(member_casual, weekday) %>% 
ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) + 
geom_col(position = "dodge") +
geom_text(aes(label = number_of_rides),
position = position_dodge(
width = 0.9), 
vjust = -0.3, 
size = 2)

#Create visualisation for average duration  
all_trips %>% 
mutate(weekday = wday(started_at, label = TRUE)) %>%
group_by(member_casual, weekday) %>% 
summarise(number_of_rides = n(),
average_duration = mean(tripduration)) %>%
arrange(member_casual, weekday) %>% 
ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) + geom_col(position = "dodge") + 
geom_text(aes(label = number_of_rides),
position = position_dodge(
width = 1), 
vjust = -0.3, 
size = 1.5)

#Export 
all_trips %>% 
group_by(member_casual, day_of_week) %>%
summarise(avg_duration = mean(tripduration, na.rm = TRUE)) %>%
write_csv("avg_trip.csv")


