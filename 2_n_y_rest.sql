DROP TABLE IF EXISTS nomnom;

CREATE TABLE nomnom (
    id INTEGER,
    name TEXT,
    neighborhood TEXT,
    cuisine TEXT,
    review NUMERIC,
    price TEXT,
    health TEXT
);

INSERT INTO nomnom (id, name, neighborhood, cuisine, review, price, health) VALUES
    (1, 'Golden Dragon', 'Chinatown', 'Chinese', 4.5, '$$', 'A'),
    (2, 'Luigi''s Pizzeria', 'Downtown', 'Italian', 4.7, '$$$', 'B'),
    (3, 'Sushi Paradise', 'Midtown', 'Japanese', 4.8, '$$$', 'A'),
    (4, 'Taco Fiesta', 'Uptown', 'Mexican', 4.2, '$', 'C'),
    (5, 'Burger Town', 'Downtown', 'American', 3.8, '$$', 'B');

-- Select first 5 rows
SELECT * FROM nomnom LIMIT 5;

-- Select distinct neighborhoods
SELECT DISTINCT neighborhood FROM nomnom;

-- Select distinct cuisines
SELECT DISTINCT cuisine FROM nomnom;

-- Select rows with cuisine as 'Chinese'
SELECT * FROM nomnom WHERE cuisine = 'Chinese';

-- Select rows with review greater than 4
SELECT * FROM nomnom WHERE review > 4;

-- Select rows with cuisine as 'Italian' and price as '$$$'
SELECT * FROM nomnom WHERE cuisine = 'Italian' AND price = '$$$';

-- Select rows with name containing 'Paradise'
SELECT * FROM nomnom WHERE name ILIKE '%Paradise%';

-- Select rows with specific neighborhoods
SELECT * FROM nomnom WHERE neighborhood IN ('Midtown', 'Downtown', 'Chinatown');

-- Select rows with health as NULL
SELECT * FROM nomnom WHERE health IS NULL;

-- Order rows by review in descending order and limit to 10
SELECT * FROM nomnom ORDER BY review DESC LIMIT 10;

-- Use CASE to classify review scores
SELECT name,
    CASE
       WHEN review > 4.5 THEN 'Extraordinary'
       WHEN review > 4 THEN 'Excellent'
       WHEN review > 3 THEN 'Good'
       WHEN review > 2 THEN 'Fair'
       ELSE 'Poor'
       END AS review_category
FROM nomnom
LIMIT 10;

-- Group by review classification and count
SELECT
    CASE
        WHEN review > 4.5 THEN 'Extraordinary'
        WHEN review > 4 THEN 'Excellent'
        WHEN review > 3 THEN 'Good'
        WHEN review > 2 THEN 'Fair'
        ELSE 'Poor'
        END AS review_category,
    COUNT(*)
FROM nomnom
GROUP BY review_category;
