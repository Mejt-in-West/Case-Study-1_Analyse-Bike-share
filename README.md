Case Study 1: How Does A Bike-Share Navigate Speedy Success?

--Study & resources provided by Google Data Analytics Professional Certificate

Scenario 
I'm are a junior data analyst working on the marketing analyst team at a fictional company, "Cyclistic", a bike-share company in Chicago. Cycilistic is a bike-share program that features more than 5,800 bicycles and 600 docking stations. They set themselves apart by also offering reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike. The majority of riders opt for traditional bikes; about 8% of riders use the assistive options. Cyclistic users are more likely to ride for leisure, but about 30% use the bikes to commute to work each day. 

The director of marketing believes the company’s future success depends on maximizing the number of annual memberships. Therefore, my team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, my team will design a new marketing strategy to convert casual riders into annual members. But first, Cyclistic executives must approve my recommendations, so they must be backed up with compeling data insights and professional data visualizations. 

To help guide the marketing strategies for this company, we’re going to take the data available through the 6 Data Analysis process phase:

- Phase 1: ASK - Define the problem and confirm stakeholders' expectations
- Phase 2: PREPARE - Collect and store data for analysis
- Phase 3: PROCESS - Clean and transform data to ensure integrity
- Phase 4: ANALYSE - Use data analysis tools to draw conclusions
- Phase 5: SHARE - Interpret and communicate results to others to make data-driven decisions
- Phase 6: ACT - Put my insight to work in order to solve the original problem

ASK
Business task:
Lily Moreno,The director of marketing, has asked me to answer “How do annual members and casual riders use Cyclistic bikes differently?”
My analysis will help the company take a data-driven decision to why casual riders would buy Cyclistic annual memberships, and how Cyclistic can use digital media to influence casual riders to become members.

Key stakeholders:
- Lily Moreno (Director of Marketing) - Moreno is responsible for the development of campaigns and initiatives to promote the bike-share program. These may include email, social media, and other channels. 
- Cyclistic marketing analytics team - A team of data analysts who are responsible for colecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy. You joined this team six months ago and have been busy learning about Cyclistic’s mission and business goals—as wel as how you, as a junior data analyst, can help Cyclistic achieve them. 
- Cyclistic executive team - The notoriously detail-oriented executive team will decide whether to approve the recommended marketing program. 

PREPARE
I've been provided 2 datasets to draw my analysis from. 
- Divvy_Trips_2019_Q1.csv
- Divvy_Trips_2020_Q1.csv
The data has been made available by Motivate International Inc, under the license (Data License Agreement | Divvy Bikes). This is public data that can be used to explore how different customer types are using Cyclistic bikes.

Credibility & limitations:
I'll be using the ROCCC method to check if there are issues with bias or credibility in the data:
- Reliable: The public data set is reliable for this fictional scenario. However, data privacy har been maintained by revealing no personal identifiers. This means that I won’t be able to check if it's bias, and connect pass purchases to credit card numbers to determine if casual riders live in the Cyclistic service area or if they have purchased multiple single passes.
- Original:  The data is not original as the dataset is not from Cyclistic
Comprehensive:  The data provided can not be seen as comprehensive as it's limited by not covering a whole year, but instead cover the first quarter of each year (Q1 2019 & Q1 2020).
- Current: The data is not current as it's dated 2019-2020.
- Cited: No, the origin of where the data was collected is not revealed.

From a quick overview, I noticed the two datasets differ in data types used for various columns, column-names are all different between the two sets, and “customer” vs “subscriber” have changed name to “casual” and “member” in the 2020 dataset. I will need to reformat and apply these amendments in the 2019 dataset to match the 2020 dataset before merging the two sources for analysis.

PROCESS
Process – I'll be using R-progamming via Rstudio to analyse and visualise the data, and will repeat the same using SQL via Visual Studio Code, utilising the SQL Server Manager (SSMS) extension.
Since SQL is limited to analysing only, I will be using Tableau to visualise the cleaned and processed data. I'll be documenting the cleaning process via the comment option in the code, as per steps below:

Steps taken:
1. Standardized column names and data types across 2019 & 2020 datasets.
2. Remove columns which fields was dropped beginning of 2020
3. Recalculate tripduration from seconds to minutes
4. Converted user type labels:
   - Subscriber = member
   - Customer = casual
4. Audit made changes
5. Calculate Tripduration into the 2020 dataset, as per calculated in the 2019 dataset.
6. Merge cleaned datasets into one for analysis
7. Extract day_of_week from start time.
8. Filter out unncessary data 
9. Compare members and casual users
  - Overall tripduration stats
  - Overall ride frequency
  - Ride frequency by week
  - Ride frequency by month
10. Visualise results
11. Export results

ANALYSE
Key Insights
1. Ride length differences
   - Casual riders: avg. 90 minutes (median: 23 mins)
   - Members: avg. 13 minutes (median: 8.5 mins)
Casual riders take much longer rides on average than members

2. Ride frequency
   - Casual riders: 67 873 rides
   - Members: 720 301 rides
Members generate 10× more trips than casual users.
  
3. Day-of-week patterns
Members ride mostly on weekdays, especially Mon–Fri, suggests commuting during weekdays.
Casuals peak strongly on weekends (Saturday & Sunday), with fewer weekday rides. Suggests leisure/recreational riding.

4. Monthly patterns (*altho data is limited to only display the first quarter of the year)
members hold a steady monthly usage (23-26k rides per month in Jan-Mar).
Casual riders slowly grow from 12k to 14k in January to February, to a sudden increase in March of 40k rides. Strenghen the leisure/recreational riding theory.

SHARE
- Members’ trips are typically short and consistent, while casuals have higher averages and much larger max durations.
- Members ride often, mostly short trips during the week, they’re your regular commuters.
- Casual riders ride less often, but take much longer rides on average than members, espeially on weekends. The increate might depend on trourist and leisure users.

Answer to the main question: “How do annual members and casual riders use Cyclistic bikes differently?”
Annual members use Cyclistic bikes for short, frequent, weekday rides (commuting), while casual riders use them less frequently, but for much longer durations, especially on weekends (leisure/tourism). 

ACT
1. Turn casual weekend riders into weekday commuters
   - Campaign idea: “Turn your weekend rides into everyday rides.”
   - Focus on showing how memberships save money and make commuting easier.
2. Offer seasonal and commuter-friendly promos
   - Roll out discounted trial memberships during busy leisure months.
   - Great way to turn tourists and weekend riders into regular weekday members.
3. Step up digital targeting
   - Run geo-targeted ads at popular weekend stations.
   - Send app notifications with membership offers right after longer casual rides.
   - Corporare a game-app for members only, inspired on how Pokemon Go functioned.
