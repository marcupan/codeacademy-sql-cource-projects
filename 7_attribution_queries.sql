-- Create the attribution_data table
CREATE TABLE attribution_data (
    user_id INT,
    timestamp TIMESTAMP,
    campaign VARCHAR(255),
    source VARCHAR(255),
    page_name VARCHAR(255)
);

-- Insert mock data into attribution_data
INSERT INTO attribution_data (user_id, timestamp, campaign, source, page_name)
VALUES
    (1, '2024-11-15 08:00:00', 'Campaign A', 'Facebook', '1 - landing'),
    (1, '2024-11-15 08:05:00', 'Campaign A', 'Facebook', '2 - product'),
    (1, '2024-11-15 08:10:00', 'Campaign A', 'Facebook', '4 - purchase'),
    (2, '2024-11-15 09:00:00', 'Campaign B', 'Google', '1 - landing'),
    (2, '2024-11-15 09:10:00', 'Campaign B', 'Google', '3 - cart'),
    (3, '2024-11-15 09:30:00', 'Campaign C', 'Instagram', '1 - landing'),
    (3, '2024-11-15 09:45:00', 'Campaign C', 'Instagram', '2 - product'),
    (3, '2024-11-15 10:00:00', 'Campaign C', 'Instagram', '4 - purchase'),
    (4, '2024-11-15 10:15:00', 'Campaign A', 'Facebook', '1 - landing'),
    (4, '2024-11-15 10:20:00', 'Campaign A', 'Facebook', '3 - cart'),
    (5, '2024-11-15 11:00:00', 'Campaign D', 'Twitter', '1 - landing'),
    (5, '2024-11-15 11:15:00', 'Campaign D', 'Twitter', '2 - product'),
    (6, '2024-11-15 12:00:00', 'Campaign B', 'Google', '1 - landing');

-- Task 1: Campaigns and Sources

-- Number of distinct campaigns
SELECT COUNT(DISTINCT campaign) AS distinct_campaigns
FROM attribution_data;

-- Number of distinct sources
SELECT COUNT(DISTINCT source) AS distinct_sources
FROM attribution_data;

-- Relationship between campaigns and sources
SELECT campaign, source, COUNT(*) AS occurrences
FROM attribution_data
GROUP BY campaign, source
ORDER BY campaign, occurrences DESC;

-- Task 2: Website Pages

-- Distinct values of page_name
SELECT DISTINCT page_name
FROM attribution_data;

-- Task 3: First Touch Attribution

-- Number of first touches for each campaign
WITH first_touch AS (
    SELECT user_id, MIN(timestamp) AS first_touch_time
    FROM attribution_data
    GROUP BY user_id
)
SELECT a.campaign, COUNT(*) AS first_touch_count
FROM attribution_data a
         JOIN first_touch ft ON a.user_id = ft.user_id AND a.timestamp = ft.first_touch_time
GROUP BY a.campaign
ORDER BY first_touch_count DESC;

-- Task 4: Last Touch Attribution

-- Number of last touches for each campaign
WITH last_touch AS (
    SELECT user_id, MAX(timestamp) AS last_touch_time
    FROM attribution_data
    GROUP BY user_id
)
SELECT a.campaign, COUNT(*) AS last_touch_count
FROM attribution_data a
         JOIN last_touch lt ON a.user_id = lt.user_id AND a.timestamp = lt.last_touch_time
GROUP BY a.campaign
ORDER BY last_touch_count DESC;

-- Task 5: Visitors Who Make a Purchase

-- Count of distinct users who visited the purchase page
SELECT COUNT(DISTINCT user_id) AS purchasers
FROM attribution_data
WHERE page_name = '4 - purchase';

-- Task 6: Last Touch on the Purchase Page by Campaign

-- Number of last touches on the purchase page for each campaign
WITH last_touch AS (
    SELECT user_id, MAX(timestamp) AS last_touch_time
    FROM attribution_data
    GROUP BY user_id
)
SELECT a.campaign, COUNT(*) AS last_touch_purchase_count
FROM attribution_data a
         JOIN last_touch lt ON a.user_id = lt.user_id AND a.timestamp = lt.last_touch_time
WHERE a.page_name = '4 - purchase'
GROUP BY a.campaign
ORDER BY last_touch_purchase_count DESC;
