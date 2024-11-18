DROP TABLE IF EXISTS hacker_news;

-- Create the hacker_news table
CREATE TABLE hacker_news (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    url TEXT,
    score INT NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP NOT NULL
);

-- Insert test data into the hacker_news table
INSERT INTO hacker_news (title, url, score, user_name, timestamp)
VALUES
    ('PostgreSQL Guide', 'https://github.com/pg-guide', 517, 'alice', '2024-11-15 08:45:00'),
    ('Machine Learning Basics', 'https://medium.com/ml-basics', 309, 'bob', '2024-11-14 10:30:00'),
    ('Breaking News', 'https://nytimes.com/news', 304, 'charlie', '2024-11-13 11:15:00'),
    ('React Tutorial', 'https://github.com/react', 282, 'dave', '2024-11-12 12:50:00'),
    ('Funny Video', 'https://youtube.com/watch?v=dQw4w9WgXcQ', 250, 'eve', '2024-11-11 13:10:00'),
    ('Docker Tips', 'https://github.com/docker', 220, 'alice', '2024-11-10 14:00:00'),
    ('Tech Trends', 'https://medium.com/tech-trends', 180, 'bob', '2024-11-09 15:25:00');

-- 1. Retrieve the top 5 stories by score
SELECT *
FROM hacker_news
ORDER BY score DESC
LIMIT 5;

-- 2. Retrieve the title and score of the top 5 stories by score
SELECT title, score
FROM hacker_news
ORDER BY score DESC
LIMIT 5;

-- 3. Calculate the total score of all stories
SELECT SUM(score) AS total_score
FROM hacker_news;

-- 4. Users with total score greater than 200, ordered by total score descending
SELECT user_name, SUM(score) AS total_user_score
FROM hacker_news
GROUP BY user_name
HAVING SUM(score) > 200
ORDER BY total_user_score DESC;

-- 5. Calculate the result of a custom arithmetic operation
SELECT (517 + 309 + 304 + 282) / 6366.0 AS custom_calculation;

-- 6. Users who posted stories containing a specific YouTube video, sorted by the number of posts
SELECT user_name, COUNT(*) AS post_count
FROM hacker_news
WHERE url LIKE '%watch?v=dQw4w9WgXcQ%'
GROUP BY user_name
ORDER BY post_count DESC;

-- 7. Categorize stories based on their source (e.g., GitHub, Medium, NYTimes)
SELECT CASE
       WHEN url LIKE '%github%' THEN 'Github'
       WHEN url LIKE '%medium.com%' THEN 'Medium'
       WHEN url LIKE '%nytimes.com%' THEN 'New York Times'
       ELSE 'Other'
       END AS source,
   COUNT(*) AS story_count
FROM hacker_news
GROUP BY source;

-- 8. Retrieve the timestamp of the first 5 stories
SELECT timestamp
FROM hacker_news
LIMIT 5;

-- 9. Retrieve the hour from the timestamp for the first 5 stories
SELECT timestamp,
    EXTRACT(HOUR FROM timestamp) AS hour
FROM hacker_news
LIMIT 5;

-- 10. Average score and count of stories grouped by hour, ordered by average score descending
SELECT EXTRACT(HOUR FROM timestamp) AS hour,
    ROUND(AVG(score), 1) AS average_score,
    COUNT(*) AS number_of_stories
FROM hacker_news
WHERE timestamp IS NOT NULL
GROUP BY hour
ORDER BY average_score DESC;
