CREATE DATABASE session_38_date;
USE session_38_date;

CREATE TABLE uber_rides(
	ride_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER,
    cab_id INTEGER,
    start_time DATETIME,
    end_time DATETIME
);

SELECT * FROM uber_rides;
INSERT INTO uber_rides(user_id,cab_id,start_time,end_time) VALUES
(5,25,'2023-03-21 09-00-00',now());

SELECT current_date();
SELECT current_time();
SELECT now();
SELECT *, DATE(start_time),
TIME(start_time),
YEAR(start_time),
MONTH(start_time),
MONTHNAME(start_time),
DAY(start_time),
DAYOFWEEK(start_time),
DAYOFYEAR(start_time),
QUARTER(start_time),
WEEK(start_time),
WEEKOFYEAR(start_time),
HOUR(start_time),
MINUTE(start_time),
SECOND(start_time),
LAST_DAY(start_time),
DAYNAME(start_time)
FROM uber_rides;

SELECT start_time, DATE_FORMAT(start_time,'%d,%b,%y'),
DATE_FORMAT(start_time,'%d/%b/%y')
FROM uber_rides;

SELECT start_time, DATE_FORMAT(start_time,'%l:%i %p')
FROM uber_rides;

-- Type conversion
-- 1:-implicit type conversion
-- 2.- explicit type conversion

SELECT MONTHNAME('9 mar 2023');

SELECT STR_TO_DATE('9 mar 2023','%e %b %Y');

SELECT DAYNAME(STR_TO_DATE('9 mar 2023','%e %b %Y'));

SELECT DATEDIFF(CURRENT_DATE(),'2022-11-07');

SELECT DATEDIFF(CURRENT_DATE(),'1989-12-25');

SELECT DATEDIFF(end_time,start_time)
FROM uber_rides;

SELECT TIMEDIFF(CURRENT_TIME,'08:00:00');

SELECT TIMEDIFF(end_time,start_time)
FROM uber_rides;

SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 YEAR);
SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 MONTH);
SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 HOUR);
SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 MINUTE);
SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 SECOND);
SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 WEEK);
SELECT NOW(), DATE_ADD(NOW(),INTERVAL 10 QUARTER);

CREATE TABLE post(
	post_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    user_id INTEGER ,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
);

SELECT * FROM post;


INSERT INTO post(user_id,content) VALUES (1,'hello World');

UPDATE post
SET content = 'No more hello world'
WHERE post_id = 1


