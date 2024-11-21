DROP TABLE IF EXISTS survey;
DROP TABLE IF EXISTS quiz;
DROP TABLE IF EXISTS home_try_on;
DROP TABLE IF EXISTS purchase;

-- Create the survey table
CREATE TABLE survey (
    user_id SERIAL PRIMARY KEY,
    question_id INT NOT NULL,
    response TEXT,
    timestamp TIMESTAMP NOT NULL
);

-- Create the quiz table
CREATE TABLE quiz (
    user_id SERIAL PRIMARY KEY,
    quiz_result TEXT,
    timestamp TIMESTAMP NOT NULL
);

-- Create the home_try_on table
CREATE TABLE home_try_on (
    user_id INT PRIMARY KEY,
    number_of_pairs INT NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

-- Create the purchase table
CREATE TABLE purchase (
    user_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

-- Insert test data into the survey table
INSERT INTO survey (question_id, response, timestamp)
VALUES
    (1, 'Glasses', '2024-11-15 08:00:00'),
    (2, 'Medium', '2024-11-15 08:05:00'),
    (3, 'Round', '2024-11-15 08:10:00'),
    (4, 'Black', '2024-11-15 08:15:00'),
    (5, '1 Year', '2024-11-15 08:20:00'),
    (1, 'Sunglasses', '2024-11-16 09:00:00'),
    (2, 'Small', '2024-11-16 09:05:00'),
    (3, 'Square', '2024-11-16 09:10:00');

-- Insert test data into the quiz table
INSERT INTO quiz (quiz_result, timestamp)
VALUES
    ('Round, Black', '2024-11-15 08:30:00'),
    ('Square, Brown', '2024-11-16 09:30:00');

-- Insert test data into the home_try_on table
INSERT INTO home_try_on (user_id, number_of_pairs, timestamp)
VALUES
    (1, 3, '2024-11-16 10:00:00'),
    (2, 5, '2024-11-16 11:00:00');

-- Insert test data into the purchase table
INSERT INTO purchase (user_id, product_id, timestamp)
VALUES
    (1, 101, '2024-11-16 12:00:00'),
    (2, 102, '2024-11-16 13:00:00');

-- Task 1: Select all columns from the first 10 rows of survey
SELECT *
FROM survey
LIMIT 10;

-- Task 2: Create a quiz funnel using GROUP BY
SELECT question_id, COUNT(*) AS response_count
FROM survey
GROUP BY question_id
ORDER BY question_id;

-- Task 3: Calculate completion rates using exported data
-- Export result of the above query and calculate percentages in a spreadsheet.

-- Task 4: Examine the first 5 rows of each table
SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

-- Task 5: Create a new table with user funnel data
SELECT
    q.user_id,
    CASE WHEN h.user_id IS NOT NULL THEN True ELSE False END AS is_home_try_on,
    h.number_of_pairs,
    CASE WHEN p.user_id IS NOT NULL THEN True ELSE False END AS is_purchase
FROM quiz q
         LEFT JOIN home_try_on h ON q.user_id = h.user_id
         LEFT JOIN purchase p ON q.user_id = p.user_id
LIMIT 10;

-- Task 6: Analyze the data

-- Quiz → Home Try-On conversion rate
SELECT
    ROUND(COUNT(DISTINCT h.user_id)::NUMERIC / COUNT(DISTINCT q.user_id), 2) AS quiz_to_home_try_on_rate
FROM quiz q
         LEFT JOIN home_try_on h ON q.user_id = h.user_id;

-- Home Try-On → Purchase conversion rate
SELECT
    ROUND(COUNT(DISTINCT p.user_id)::NUMERIC / COUNT(DISTINCT h.user_id), 2) AS home_try_on_to_purchase_rate
FROM home_try_on h
         LEFT JOIN purchase p ON h.user_id = p.user_id;

-- Impact of number_of_pairs on purchase rates
SELECT
    h.number_of_pairs,
    ROUND(COUNT(DISTINCT p.user_id)::NUMERIC / COUNT(DISTINCT h.user_id), 2) AS purchase_rate
FROM home_try_on h
         LEFT JOIN purchase p ON h.user_id = p.user_id
GROUP BY h.number_of_pairs;
