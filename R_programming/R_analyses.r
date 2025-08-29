#install relevant packages for analysis
install.packages(“tidyverse”)
install.packages(“conflicted”)
install.packages(“lubridate”)

#load libraries
library(tidyverse)
library(conflicted)
library(lubridate)

#Set dplyr::filter and dplyr::lag as the default choices 
conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")

#import datasets
Q1_2019 <- read_csv("C:/Users/LisaW/OneDrive/Documents/Google_Data_analytics/Casestudy/Bike-share/Divvy_Trips_2019_Q1.csv")

Q1_2020 <- read_csv("C:/Users/LisaW/OneDrive/Documents/Google_Data_analytics/Casestudy/Bike-share/Divvy_Trips_2020_Q1.csv")

#Match data type and headers from 2019 to 2020
Q1_2019_clean <- Q1_2019 %>%
rename(ride_id = trip_id, rideable_type = bikeid, started_at = start_time, ended_at = end_time, start_station_name = from_station_name, start_station_id = from_station_id, end_station_name = to_station_name, end_station_id = to_station_id, member_casual = usertype)%>%

#Remove birthyear and gender fields as this data was dropped beginning in 2020 
select(-any_of(c("birthyear", "gender"))) %>%

#Convert date & time to allow adding a column in the 2020 data, and covert ride_id and rideable_type to character so that they can stack correctly, and rename member vs subs/customer vs casual
mutate(started_at = as.POSIXct(started_at, format="%Y-%m-%d %H:%M:%S"),ended_at   = as.POSIXct(ended_at, format="%Y-%m-%d %H:%M:%S"),ride_id = as.character(ride_id),rideable_type = as.character(rideable_type),member_casual = recode(member_casual,"Subscriber" = "member","Customer" = "casual"))

#Add a tripduration column to 2020 dataset which resides in the 2019 data and will be key  for our analyses.
Q1_2020_clean <- Q1_2020 %>%
  mutate(
    started_at = as.POSIXct(started_at, format="%Y-%m-%d %H:%M:%S"),
    ended_at   = as.POSIXct(ended_at, format="%Y-%m-%d %H:%M:%S"),
    tripduration = as.numeric(difftime(ended_at, started_at, units = "secs"))
  ) %>%

#Remove lat and long, birthyear fields as this data was dropped beginning in 2020 
  select(-any_of(c("start_lat", "start_lng", "end_lat", "end_lng")))

#combine cleaned datasets
all_trips <- bind_rows(Q1_2019_clean, Q1_2020_clean) %>%

#The dataframe includes a few hundred entries when bikes were taken out of docks and checked for quality by Divvy or ride_length was negative, so we'll filter out the unncessary data these before analyses.
filter(tripduration > 0, start_station_name != "HQ QR")%>%  

#add a column displaying what day of the week service was utilised
all_trips$day_of_week <- format(as.Date(all_trips$started_at),"%A")%>%

#order day of week from Mon-Sun for easier viewability.
all_trips$day_of_week <- ordered(all_trips$day_of_week, levels=c("Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday")) 

#make sure the proper number of observations were reassigned 
table(all_trips$day_of_week) 

#Overall ride length stats
all_trips %>%
group_by(member_casual) %>%
summarise(mean_duration = mean(tripduration, na.rm = TRUE),median_duration = median(tripduration, na.rm = TRUE),max_duration = max(tripduration, na.rm = TRUE),min_duration = min(tripduration, na.rm = TRUE))

#Compare members and casual users 
all_trips %>%
group_by(member_casual, day_of_week) %>%
summarise(avg_duration = mean(tripduration, na.rm = TRUE))

#Create visualisation for member vs casual and day of week analyses
all_trips %>%
group_by(member_casual, day_of_week) %>%
mutate(weekday = wday(started_at, label = TRUE)) %>% 
group_by(member_casual, weekday) %>% 
summarise(number_of_rides = n(),average_duration = mean(tripduration, na.rm = TRUE)) %>%
arrange(member_casual, weekday) %>% 
ggplot(aes(x = weekday, y = num_of_rides, fill = member_casual)) + geom_col(position = "dodge")

#Create visualisation for average duration 
all_trips %>% 
mutate(weekday = wday(started_at, label = TRUE)) %>% 
group_by(member_casual, weekday) %>% 
summarise(number_of_rides = n(),average_duration = mean(ride_length)) %>% 
arrange(member_casual, weekday) %>% 
ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) + geom_col(position = "dodge") 

#Export 
group_by(member_casual, day_of_week) %>%
summarise(avg_duration = mean(tripduration, na.rm = TRUE)) %>%
write_csv("avg_tripduration.csv")
