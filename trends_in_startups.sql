DROP TABLE IF EXISTS startups;

-- Create the startups table
CREATE TABLE startups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    category VARCHAR(255),
    valuation NUMERIC,
    raised NUMERIC,
    stage VARCHAR(50),
    founded DATE,
    location VARCHAR(255),
    employees INT
);

-- Insert test data into the startups table
INSERT INTO startups (name, category, valuation, raised, stage, founded, location, employees)
VALUES
    ('TechNova', 'Tech', 1000000, 500000, 'Seed', '2020-01-15', 'San Francisco', 50),
    ('HealthWave', 'Health', 2500000, 1000000, 'Series A', '2018-06-10', 'New York', 120),
    ('EduSmart', 'Education', 1500000, 750000, 'Seed', '2019-09-05', 'Boston', 40),
    ('GreenGrowth', 'Environment', 3000000, 1500000, 'Series B', '2017-03-20', 'Seattle', 200),
    ('DataDriven', 'Analytics', 5000000, 3000000, 'Series C', '2015-11-30', 'Chicago', 600),
    ('InnoEnergy', 'Energy', 10000000, 7000000, 'Series D', '2010-04-22', 'Austin', 1000);

-- Adjusted queries for PostgreSQL
-- 1. Retrieve the first 2 rows from startups
SELECT * FROM startups LIMIT 2;

-- 2. Count the total number of rows in startups
SELECT COUNT(*) FROM startups;

-- 3. Sum of valuations from startups
SELECT SUM(valuation) FROM startups;

-- 4. Name and maximum amount raised
SELECT name, raised FROM startups
WHERE raised = (SELECT MAX(raised) FROM startups);

-- 5. Name and maximum raised where stage is 'Seed'
SELECT name, raised FROM startups
WHERE stage = 'Seed' AND raised = (SELECT MAX(raised) FROM startups WHERE stage = 'Seed');

-- 6. Name and earliest founding date
SELECT name, founded FROM startups
WHERE founded = (SELECT MIN(founded) FROM startups);

-- 7. Category and average valuation, limited to 2 rows
SELECT category, AVG(valuation) AS avg_valuation
FROM startups
GROUP BY category
LIMIT 2;

-- 8. Category and average valuation rounded to 2 decimal places, ordered by valuation, limited to 2
SELECT category, ROUND(AVG(valuation), 2) AS avg_valuation
FROM startups
GROUP BY category
ORDER BY avg_valuation
LIMIT 2;

-- 9. Category and count of startups per category, limited to 2 rows
SELECT category, COUNT(*) AS count
FROM startups
GROUP BY category
LIMIT 2;

-- 10. Categories with more than 3 startups, ordered by count descending
SELECT category, COUNT(*) AS count
FROM startups
GROUP BY category
HAVING COUNT(*) > 3
ORDER BY count DESC;

-- 11. Location and average number of employees, limited to 2 rows
SELECT location, AVG(employees) AS avg_employees
FROM startups
GROUP BY location
LIMIT 2;

-- 12. Locations with an average number of employees greater than 500
SELECT location, AVG(employees) AS avg_employees
FROM startups
GROUP BY location
HAVING AVG(employees) > 500;
