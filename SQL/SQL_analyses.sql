-- CLEAN 2019 DATASET
SELECT
-- Convert data type and headers from 2019 to match 2020
 CAST(trip_id AS VARCHAR(50)) AS ride_id,
 CAST(bikeid AS VARCHAR(50)) AS rideable_type,
 TRY_CAST(start_time AS DATETIME) AS started_at,
 TRY_CAST(end_time AS DATETIME) AS ended_at,
 from_station_name AS start_station_name,
 to_station_name AS end_station_name,
 TRY_CAST(from_station_id AS INT) AS start_station_id,
 TRY_CAST(to_station_id AS INT) AS end_station_id,
-- Rename member vs subsc to customer vs casual
 CASE
  WHEN usertype = 'Subscriber' THEN 'member'
  WHEN usertype = 'Customer'   THEN 'casual'
  ELSE usertype
  END AS member_casual,
-- Recalculate tripduration from seconds to minutes
 TRY_CAST(tripduration AS FLOAT) / 60.0   AS tripduration
INTO q1_2019_clean
FROM divvy_trips_2019_q1;

--CLEAN 2020 DATASET
SELECT
 ride_id,
 rideable_type,
 TRY_CAST(started_at AS DATETIME) AS started_at,
 TRY_CAST(ended_at AS DATETIME) AS ended_at,
 start_station_name,
 end_station_name,
 TRY_CAST(start_station_id AS INT) AS start_station_id,
 TRY_CAST(end_station_id AS INT) AS end_station_id,
 member_casual,
-- Add a tripduration column
 DATEDIFF(MINUTE, TRY_CAST(started_at AS DATETIME), TRY_CAST(ended_at AS DATETIME)) AS tripduration
INTO Q1_2020_clean
FROM divvy_trips_2020_q1;

-- COMBINE CLEAN DATASETS
SELECT * INTO all_trips
FROM q1_2019_clean
UNION ALL
SELECT * FROM q1_2020_clean;

-- Filter out unnecessary data, if bikes were taken out of docks and checked for quality by Divvy or tripduration was negative
SELECT *
INTO all_trips_filtered
FROM all_trips
WHERE tripduration > 0
 AND start_station_name <> 'HQ QR';

-- Add day_of_week column
ALTER TABLE all_trips_filtered ADD day_of_week VARCHAR(20);

UPDATE all_trips_filtered
SET day_of_week = DATENAME(WEEKDAY, started_at);

-- ANALYSE
-- Overall trip duration stats
SELECT DISTINCT
 member_casual,
 AVG(tripduration) OVER (PARTITION BY member_casual) AS mean_duration,
 PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tripduration)
  OVER (PARTITION BY member_casual) AS median_duration,
   MAX(tripduration) OVER (PARTITION BY member_casual) AS max_duration,
   MIN(tripduration) OVER (PARTITION BY member_casual) AS min_duration
FROM all_trips_filtered;

-- Overall ride frequency
SELECT member_casual,
 COUNT(*) AS total_rides
FROM all_trips_filtered
GROUP BY member_casual;

-- Avg duration by weekday
SELECT 
 member_casual,
 DATENAME(WEEKDAY, started_at) AS day_of_week,
 AVG(tripduration) AS avg_duration
FROM all_trips_filtered
GROUP BY member_casual, DATENAME(WEEKDAY, started_at)
ORDER BY member_casual,
 CASE DATENAME(WEEKDAY, started_at)
  WHEN 'Monday' THEN 1
  WHEN 'Tuesday' THEN 2
  WHEN 'Wednesday' THEN 3
  WHEN 'Thursday' THEN 4
  WHEN 'Friday' THEN 5
  WHEN 'Saturday' THEN 6
  WHEN 'Sunday' THEN 7
 END;
		
-- Weekly ride count
SELECT 
 member_casual,
 DATENAME(WEEKDAY, started_at) AS weekday,
 COUNT(*) AS number_of_rides,
 AVG(tripduration) AS average_duration
FROM all_trips_filtered
GROUP BY member_casual, DATENAME(WEEKDAY, started_at)
ORDER BY member_casual,
 CASE DATENAME(WEEKDAY, started_at)
  WHEN 'Monday' THEN 1
  WHEN 'Tuesday' THEN 2
  WHEN 'Wednesday' THEN 3
  WHEN 'Thursday' THEN 4
  WHEN 'Friday' THEN 5
  WHEN 'Saturday' THEN 6
  WHEN 'Sunday' THEN 7
 END;

-- Ride frequency by month
SELECT member_casual,
 FORMAT(started_at, 'yyyy-MM') AS year_month,
 COUNT(*) AS rides_in_month
FROM all_trips_filtered
GROUP BY member_casual, FORMAT(started_at, 'yyyy-MM')
ORDER BY year_month, member_casual;