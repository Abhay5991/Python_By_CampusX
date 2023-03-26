use task_37;

SELECT * FROM laptopdata;

-- head, tail and sample
SELECT * FROM laptopdata
ORDER BY `index` LIMIT 5;

SELECT * FROM laptopdata
ORDER BY `index` DESC LIMIT 5;

SELECT * FROM laptopdata
ORDER BY rand() LIMIT 5;



WITH cte AS (
  SELECT Price, ROW_NUMBER() OVER (ORDER BY Price) AS row_num, COUNT(*) OVER () AS total_count
  FROM laptopdata
)
SELECT COUNT(*) AS count, 
       MIN(Price) AS min_price, 
       MAX(Price) AS max_price, 
       AVG(Price) AS avg_price, 
       STD(Price) AS std_price, 
       (SELECT Price FROM cte WHERE row_num = CEIL(total_count * 0.25)) AS Q1,
       (SELECT Price FROM cte WHERE row_num = CEIL(total_count * 0.5)) AS Median,
       (SELECT Price FROM cte WHERE row_num = CEIL(total_count * 0.75)) AS Q3
FROM cte
LIMIT 1;

-- missing value
SELECT COUNT(Price)
FROM laptopdata
WHERE Price IS NULL;

-- outliers
SELECT * FROM (SELECT *,
					PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
					PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
					FROM laptopdata) t
WHERE t.Price < t.Q1 - (1.5*(t.Q3 - t.Q1)) OR t.Price > t.Q3 + (1.5*(t.Q3 - t.Q1));



SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY Price) OVER() AS 'Q3'
FROM laptopdata


SELECT t.buckets,REPEAT('*',COUNT(*)/5) FROM (SELECT price,
CASE
WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
ELSE '>100K'
END AS 'buckets'
FROM laptopdata) t
GROUP BY t.buckets;


SELECT price,
CASE
WHEN price BETWEEN 0 AND 25000 THEN '0-25K'
WHEN price BETWEEN 25001 AND 50000 THEN '25K-50K'
WHEN price BETWEEN 50001 AND 75000 THEN '50K-75K'
WHEN price BETWEEN 75001 AND 100000 THEN '75K-100K'
ELSE '>100K'
END AS 'buckets'
FROM laptopdata;

SELECT Company,COUNT(Company) FROM laptopdata
GROUP BY Company;

SELECT cpu_speed,Price FROM laptopdata;

SELECT * FROM laptopdata;

SELECT Company,
SUM(CASE WHEN Touchscreen = 1 THEN 1 ELSE 0 END) AS 'Touchscreen_yes',
SUM(CASE WHEN Touchscreen = 0 THEN 1 ELSE 0 END) AS 'Touchscreen_no'
FROM laptopdata
GROUP BY Company;

SELECT DISTINCT cpu_brand FROM laptopdata;

SELECT Company,
SUM(CASE WHEN cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS 'intel',
SUM(CASE WHEN cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS 'amd',
SUM(CASE WHEN cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS 'samsung'
FROM laptopdata
GROUP BY Company;

-- Categorical Numerical Bivariate analysis
SELECT Company,MIN(price),
MAX(price),AVG(price),STD(price)
FROM laptopdata
GROUP BY Company;

-- Dealing with missing values
SELECT * FROM laptopdata
WHERE price IS NULL;

-- UPDATE laptopdata
-- SET price = NULL
-- WHERE `index` IN (7,869,1148,827,865,821,1056,1043,692,1114);

-- replace missing values with mean of price
UPDATE laptopdata
SET price = (SELECT AVG(price) FROM laptops)
WHERE price IS NULL;

-- replace missing values with mean price of corresponding company
UPDATE laptopdata l1
SET price = (SELECT AVG(price) FROM laptopdata l2
			 WHERE l2.Company = l1.Company)
WHERE price IS NULL;

SELECT * FROM laptopdata
WHERE price IS NULL;

-- corresponsing company + processor
SELECT * FROM laptopdata;

-- Feature Engineering
ALTER TABLE laptopdata ADD COLUMN ppi INTEGER;

UPDATE laptopdata
SET ppi = ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/Inches);

SELECT * FROM laptopdata
ORDER BY ppi DESC;

ALTER TABLE laptopdata ADD COLUMN screen_size VARCHAR(255) AFTER Inches;

UPDATE laptopdata
SET screen_size =
CASE
WHEN Inches < 14.0 THEN 'small'
WHEN Inches >= 14.0 AND Inches < 17.0 THEN 'medium'
ELSE 'large'
END;

SELECT screen_size,AVG(price) FROM laptopdata
GROUP BY screen_size;

-- One Hot Encoding
SELECT gpu_brand,
CASE WHEN gpu_brand = 'Intel' THEN 1 ELSE 0 END AS 'intel',
CASE WHEN gpu_brand = 'AMD' THEN 1 ELSE 0 END AS 'amd',
CASE WHEN gpu_brand = 'nvidia' THEN 1 ELSE 0 END AS 'nvidia',
CASE WHEN gpu_brand = 'arm' THEN 1 ELSE 0 END AS 'arm'
FROM laptopdata



