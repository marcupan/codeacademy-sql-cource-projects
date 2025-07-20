DROP TABLE IF EXISTS state_climate;

-- Create the `state_climate` table
CREATE TABLE state_climate (
    id    SERIAL PRIMARY KEY,
    state VARCHAR(50),
    year  INT,
    tempf NUMERIC(5, 2),
    tempc NUMERIC(5, 2)
);

-- Insert mock data into `state_climate`
INSERT INTO state_climate (state, year, tempf, tempc)
VALUES
    ('California', 2000, 68.5, 20.3),
    ('California', 2001, 69.0, 20.6),
    ('California', 2002, 67.8, 19.9),
    ('California', 2003, 70.1, 21.2),
    ('Texas', 2000, 75.3, 24.1),
    ('Texas', 2001, 76.5, 24.7),
    ('Texas', 2002, 74.8, 23.8),
    ('Texas', 2003, 77.2, 25.1),
    ('New York', 2000, 52.1, 11.2),
    ('New York', 2001, 53.0, 11.7),
    ('New York', 2002, 50.8, 10.4),
    ('New York', 2003, 54.2, 12.3);

-- Task 1: Inspect the data
SELECT *
FROM state_climate
LIMIT 10;

-- Task 2: Running average temperature per state
SELECT state,
    year,
    tempc,
    AVG(tempc) OVER (PARTITION BY state ORDER BY year) AS running_avg_temp
FROM state_climate
ORDER BY state, year;

-- Task 3: Lowest temperature per state
SELECT state,
    year,
    tempc,
    FIRST_VALUE(tempc) OVER (PARTITION BY state ORDER BY tempc) AS lowest_temp
FROM state_climate
ORDER BY state, year;

-- Task 4: Highest temperature per state
SELECT state,
    year,
    tempc,
    MAX(tempc) OVER (PARTITION BY state) AS highest_temp
FROM state_climate
ORDER BY state, year;

-- Task 5: Yearly change in temperature for each state
WITH temp_changes AS (SELECT state,
        year,
        tempc,
        tempc - LAG(tempc) OVER (PARTITION BY state ORDER BY year) AS change_in_temp
    FROM state_climate)
SELECT *
FROM temp_changes
ORDER BY ABS(change_in_temp) DESC
LIMIT 10;

-- Task 6: Rank of coldest temperatures across all states and years
SELECT state,
    year,
    tempc,
    RANK() OVER (ORDER BY tempc) AS coldest_rank
FROM state_climate
ORDER BY coldest_rank
LIMIT 10;

-- Task 7: Warmest temperatures ranked by state
SELECT state,
    year,
    tempc,
    RANK() OVER (PARTITION BY state ORDER BY tempc DESC) AS warmest_rank
FROM state_climate
ORDER BY state, warmest_rank
LIMIT 10;

-- Task 8: Average yearly temperatures in quartiles by state
SELECT NTILE(4) OVER (PARTITION BY state ORDER BY tempc) AS quartile,
    year,
    state,
    tempc
FROM state_climate
ORDER BY state, quartile;

-- Task 9: Average yearly temperatures in quintiles across all states
SELECT NTILE(5) OVER (ORDER BY tempc) AS quintile,
    year,
    state,
    tempc
FROM state_climate
ORDER BY quintile, tempc;
