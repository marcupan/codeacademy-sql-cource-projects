DROP TABLE IF EXISTS met;

-- Create the met table
CREATE TABLE met (
    id         SERIAL PRIMARY KEY,
    department VARCHAR(255),
    category   VARCHAR(255),
    title      VARCHAR(255),
    artist     VARCHAR(255),
    date       VARCHAR(255),
    medium     VARCHAR(255),
    country    VARCHAR(255)
);

-- Insert mock data into the met table
INSERT INTO met (department, category, title, artist, date, medium, country)
VALUES
    ('American Decorative Arts', 'Furniture', 'Wooden Chair', 'John Doe', '1800', 'Wood', 'United States'),
    ('American Decorative Arts', 'Celery Vase', 'Intricate Celery Vase', 'Jane Smith', '1875', 'Glass',
    'United Kingdom'),
    ('American Decorative Arts', 'Silverware', 'Silver Fork', 'George Wilson', '1900', 'Silver', 'United States'),
    ('American Decorative Arts', 'Jewelry', 'Gold Necklace', 'Emily Brown', '1750', 'Gold', 'France'),
    ('American Decorative Arts', 'Pottery', 'Clay Pot', 'Unknown', '1600', 'Clay', 'China'),
    ('American Decorative Arts', 'Celery Vase', 'Victorian Celery Vase', 'Jane Smith', '1865', 'Glass',
    'United States'),
    ('American Decorative Arts', 'Silverware', 'Silver Spoon', 'John Doe', '1920', 'Silver', 'United States'),
    ('American Decorative Arts', 'Jewelry', 'Gold Ring', 'Emily Brown', '1780', 'Gold', 'Italy'),
    ('American Decorative Arts', 'Furniture', 'Oak Table', 'Unknown', '1820', 'Wood', 'Germany'),
    ('American Decorative Arts', 'Jewelry', 'Silver Pendant', 'Emily Brown', '1805', 'Silver', 'Spain');

-- Task 1: Explore the met table
SELECT *
FROM met
LIMIT 10;

-- Task 2: Count the number of pieces in the collection
SELECT COUNT(*) AS total_pieces
FROM met;

-- Task 3: Count pieces where the category includes 'celery'
SELECT COUNT(*) AS celery_pieces
FROM met
WHERE category LIKE '%celery%';

-- Task 4: Find the title and medium of the oldest piece(s) in the collection
SELECT title, medium, date
FROM met
WHERE date = (SELECT MIN(date) FROM met);

-- Task 5: Find the top 10 countries with the most pieces
SELECT country, COUNT(*) AS total_pieces
FROM met
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_pieces DESC
LIMIT 10;

-- Task 6: Find categories having more than 100 pieces
SELECT category, COUNT(*) AS category_count
FROM met
GROUP BY category
HAVING COUNT(*) > 100
ORDER BY category_count DESC
LIMIT 10;

-- Task 7: Count pieces where the medium contains 'gold' or 'silver'
SELECT medium, COUNT(*) AS medium_count
FROM met
WHERE medium LIKE '%gold%'
   OR medium LIKE '%silver%'
GROUP BY medium
ORDER BY medium_count DESC;

-- Bonus: Categorize medium as 'Gold' or 'Silver' and count them
SELECT CASE
       WHEN medium LIKE '%gold%' THEN 'Gold'
       WHEN medium LIKE '%silver%' THEN 'Silver'
       ELSE NULL
       END  AS Bling,
    COUNT(*) AS bling_count
FROM met
WHERE medium LIKE '%gold%'
   OR medium LIKE '%silver%'
GROUP BY Bling
ORDER BY bling_count DESC;
