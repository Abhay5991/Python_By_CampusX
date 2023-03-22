CREATE DATABASE flight_38;
use flight_38;

SELECT * FROM flights;
-- 1. Find the month with most number of flights
SELECT MONTHNAME(date_of_journey),COUNT(*)
FROM flights
GROUP BY MONTHNAME(date_of_journey)
ORDER BY COUNT(*) DESC LIMIT 1;

-- 2. Which week day has most costly flights
SELECT DAYNAME(date_of_journey),AVG(price) FROM flights
GROUP BY DAYNAME(date_of_journey)
ORDER BY AVG(price) DESC LIMIT 1;

-- Find number of indigo flights every month
SELECT MONTHNAME(date_of_journey),COUNT(*) FROM flights
WHERE airline = 'Indigo'
GROUP BY MONTHNAME(date_of_journey)
ORDER BY MONTH(date_of_journey) ASC;

SELECT MONTHNAME(date_of_journey), COUNT(*) 
FROM flights
WHERE airline = 'Indigo'
GROUP BY MONTH(date_of_journey)
ORDER BY MONTH(date_of_journey) ASC;

-- this is working in my pc
SELECT MONTHNAME(MIN(date_of_journey)), COUNT(*)  
FROM flights 
WHERE airline = 'Indigo' 
GROUP BY MONTH(date_of_journey) 
ORDER BY MONTH(date_of_journey) ASC;

-- 4. Find list of all flights that depart between 10AM and 2PM from Delhi to Banglore
SELECT * FROM flights
WHERE source = 'Banglore' AND
destination = 'Delhi' AND
dep_time > '10:00:00' AND dep_time < '14:00:00';

-- --5. Find the number of flights departing on weekends from Bangalore
SELECT COUNT(*) FROM flights
WHERE source = 'banglore' AND
DAYNAME(date_of_journey) IN ('saturday','sunday');

-- --6. Calculate the arrival time for all flights by adding the duration to the departure time.
ALTER TABLE flights ADD COLUMN departure DATETIME;

UPDATE flights
SET departure = STR_TO_DATE(CONCAT(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i');

ALTER TABLE flights
ADD COLUMN duration_mins INTEGER,
ADD COLUMN arrival DATETIME;

SELECT * FROM flights;

SELECT Duration,
REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','')*60 +
CASE
WHEN SUBSTRING_INDEX(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0
ELSE REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
END AS 'mins'
FROM flights;
-- this code is not working for me
-- UPDATE flights
-- SET duration_mins = REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','')*60 +
-- CASE
-- 	WHEN SUBSTRING_INDEX(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0
-- 	ELSE REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
-- END;

SELECT * FROM flights;

UPDATE flights
SET duration_mins = REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','')*60 +
    CASE
        WHEN SUBSTRING_INDEX(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0
        WHEN SUBSTRING_INDEX(duration,' ',-1) REGEXP '^[0-9]+$' THEN SUBSTRING_INDEX(duration,' ',-1)
        ELSE REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
    END
WHERE duration REGEXP '^[0-9]+h [0-9]+m$' OR duration REGEXP '^[0-9]+h$';
    
SELECT DISTINCT duration FROM flights;

SELECT * FROM flights;

UPDATE flights
SET arrival = DATE_ADD(departure,INTERVAL duration_mins MINUTE);

SELECT * FROM flights;

SELECT TIME(arrival) FROM flights;

-- 7. Calculate the arrival date for all the flights
SELECT DATE(arrival) FROM flights;

SELECT * FROM flights;

-- 8. Find the number of flights which travel on multiple dates.
SELECT COUNT(*) FROM flights
WHERE DATE(departure) != DATE(arrival);

-- Answer from chatgpt
SELECT COUNT(*) AS num_multi_date_flights
FROM (
    SELECT Airline, Source, Destination, COUNT(DISTINCT Date_of_Journey) AS num_dates
    FROM flights
    GROUP BY Airline, Source, Destination
    HAVING num_dates > 1
) AS multi_date_flights;

-- 9. Calculate the average duration of flights between all city pairs. The answer should In xh ym format
SELECT source,destination,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' FROM
flights
GROUP BY source,destination;

-- 10. Find all flights which departed before midnight but arrived at their destination after midnight having only 0 stops.
SELECT * FROM flights
WHERE total_stops = 'non-stop' AND
DATE(departure) < DATE(arrival);

-- 11.Find quarter wise number of flights for each airline
SELECT airline,QUARTER(departure),COUNT(*)
FROM flights
GROUP BY airline,QUARTER(departure);

-- 12.find the longest flight distance (between city in terms of time) in india
SELECT Source, Destination, MAX(Duration) AS longest_duration
FROM flights
WHERE Source IN (SELECT DISTINCT Source FROM flights WHERE Source LIKE '%India%')
AND Destination IN (SELECT DISTINCT Destination FROM flights WHERE Destination LIKE '%India%')
GROUP BY Source, Destination
ORDER BY longest_duration DESC
LIMIT 1;



-- 13.Average time duration for flights that have 1 stop vs more than 1 stops
WITH temp_table AS (SELECT *,
CASE
WHEN total_stops = 'non-stop' THEN 'non-stop'
ELSE 'with stop'
END AS 'temp'
FROM flights)
SELECT temp,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration',
AVG(price) AS 'avg_price'
FROM temp_table
GROUP BY temp;

-- 14. Find all Air India flights in a given date range originating from Delhi
-- 1st Mar 2019 to 10th Mar 2019
SELECT * FROM flights
WHERE source = 'Delhi' AND
DATE(departure) BETWEEN '2019-03-01' AND '2019-03-10';

-- 15.Find the longest flight of each airline
SELECT airline,
TIME_FORMAT(SEC_TO_TIME(MAX(duration_mins)*60),'%kh %im') AS 'max_duration'
FROM flights
GROUP BY airline
ORDER BY MAX(duration_mins) DESC;

-- 16. Find all the pair of cities having average time duration > 3 hours
SELECT source,destination,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' FROM
flights
GROUP BY source,destination
HAVING AVG(duration_mins) > 180;

-- 17. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi
SELECT DAYNAME(departure) AS weekday,
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM - 6AM',
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM - 12PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM - 6PM',
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM - 12AM'
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure), DAYOFWEEK(departure)
ORDER BY DAYOFWEEK(departure) ASC;

-- 18. Make a weekday vs time grid showing avg flight price from Banglore and Delhi
SELECT DAYNAME(departure), 
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM - 6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM - 12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM - 6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM - 12PM'
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure), departure
ORDER BY DAYOFWEEK(departure) ASC;

