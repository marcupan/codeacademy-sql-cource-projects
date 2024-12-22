DROP TABLE IF EXISTS stream;
DROP TABLE IF EXISTS chat;

-- Create the `stream` table
CREATE TABLE stream (
    id        SERIAL PRIMARY KEY,
    game      VARCHAR(255),
    viewers   INT,
    country   VARCHAR(50),
    player    VARCHAR(50),
    time      TIMESTAMP,
    device_id INT
);

-- Create the `chat` table
CREATE TABLE chat (
    id        SERIAL PRIMARY KEY,
    messages  INT,
    time      TIMESTAMP,
    device_id INT
);

-- Insert mock data into the `stream` table
INSERT INTO stream (game, viewers, country, player, time, device_id)
VALUES
    ('League of Legends', 50000, 'USA', 'site', '2023-12-20 10:30:00', 1),
    ('Dota 2', 20000, 'Canada', 'android', '2023-12-20 11:00:00', 2),
    ('Counter-Strike: Global Offensive', 15000, 'UK', 'iphone', '2023-12-20 12:30:00', 3),
    ('DayZ', 8000, 'USA', 'site', '2023-12-20 14:00:00', 4),
    ('League of Legends', 60000, 'UK', 'iphone', '2023-12-20 15:00:00', 5),
    ('ARK: Survival Evolved', 7000, 'Canada', 'android', '2023-12-20 16:00:00', 6);

-- Insert mock data into the `chat` table
INSERT INTO chat (messages, time, device_id)
VALUES
    (200, '2023-12-20 10:35:00', 1),
    (150, '2023-12-20 11:05:00', 2),
    (180, '2023-12-20 12:35:00', 3),
    (100, '2023-12-20 14:05:00', 4),
    (220, '2023-12-20 15:05:00', 5),
    (120, '2023-12-20 16:05:00', 6);

-- Task 1: Inspect the data
SELECT *
FROM stream
LIMIT 20;
SELECT *
FROM chat
LIMIT 20;

-- Task 2: Unique games in the stream table
SELECT DISTINCT game
FROM stream;

-- Task 3: Unique channels in the stream table
SELECT DISTINCT country
FROM stream;

-- Task 4: Most popular games by viewer count
SELECT game, SUM(viewers) AS total_viewers
FROM stream
GROUP BY game
ORDER BY total_viewers DESC;

-- Task 5: LoL viewers by country
SELECT country, SUM(viewers) AS lol_viewers
FROM stream
WHERE game = 'League of Legends'
GROUP BY country
ORDER BY lol_viewers DESC;

-- Task 6: Number of streamers by player
SELECT player, COUNT(*) AS stream_count
FROM stream
GROUP BY player
ORDER BY stream_count DESC;

-- Task 7: Add genres to games and group by genre
SELECT CASE
        WHEN game = 'League of Legends' THEN 'MOBA'
        WHEN game = 'Dota 2' THEN 'MOBA'
        WHEN game = 'Heroes of the Storm' THEN 'MOBA'
        WHEN game = 'Counter-Strike: Global Offensive' THEN 'FPS'
        WHEN game = 'DayZ' THEN 'Survival'
        WHEN game = 'ARK: Survival Evolved' THEN 'Survival'
        ELSE 'Other'
        END      AS genre,
    game,
    SUM(viewers) AS total_viewers
FROM stream
GROUP BY genre, game
ORDER BY total_viewers DESC;

-- Task 8: Inspect the time column
SELECT time
FROM stream
LIMIT 10;

-- Task 9: Extract hours and view count by hour
SELECT EXTRACT(HOUR FROM time) AS hour,
       SUM(viewers)            AS total_viewers
FROM stream
WHERE country = 'USA'
GROUP BY hour
ORDER BY hour;

-- Task 11: Join stream and chat tables on device_id
SELECT s.game,
    s.viewers,
    c.messages,
    s.country,
    s.time AS stream_time,
    c.time AS chat_time
FROM stream s
    JOIN chat c
        ON s.device_id = c.device_id;

-- Bonus Task: Insights for specific games
-- Viewer and chat activity for League of Legends
SELECT s.game,
    SUM(s.viewers)  AS total_viewers,
    SUM(c.messages) AS total_messages
FROM stream s
    JOIN chat c
        ON s.device_id = c.device_id
WHERE s.game = 'League of Legends'
GROUP BY s.game;
