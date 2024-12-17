DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS subreddits;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS posts2;

-- Create the users table
CREATE TABLE users (
    id       SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    score    NUMERIC     NOT NULL
);

-- Create the subreddits table
CREATE TABLE subreddits (
    id               SERIAL PRIMARY KEY,
    name             VARCHAR(255) NOT NULL,
    subscriber_count INT          NOT NULL
);

-- Create the posts table
CREATE TABLE posts (
    id           SERIAL PRIMARY KEY,
    user_id      INT REFERENCES users (id),
    subreddit_id INT REFERENCES subreddits (id),
    title        VARCHAR(255) NOT NULL,
    score        NUMERIC      NOT NULL
);

-- Create the posts2 table for UNION example
CREATE TABLE posts2 (
    id           SERIAL PRIMARY KEY,
    user_id      INT REFERENCES users (id),
    subreddit_id INT REFERENCES subreddits (id),
    title        VARCHAR(255) NOT NULL,
    score        NUMERIC      NOT NULL
);

-- Insert sample data into the users table
INSERT INTO users (username, score)
VALUES
    ('user1', 12000),
    ('user2', 8000),
    ('user3', 15000),
    ('user4', 6000),
    ('user5', 10000);

-- Insert sample data into the subreddits table
INSERT INTO subreddits (name, subscriber_count)
VALUES
    ('technology', 500000),
    ('gaming', 750000),
    ('movies', 400000),
    ('music', 300000),
    ('programming', 600000);

-- Insert sample data into the posts table
INSERT INTO posts (user_id, subreddit_id, title, score)
VALUES
    (1, 1, 'The future of AI', 5500),
    (2, 2, 'Top 10 games in 2024', 7000),
    (3, 3, 'Movie recommendations', 3000),
    (4, 4, 'Best music albums this year', 4500),
    (5, 5, 'Why I love Rust programming', 5200);

-- Insert sample data into the posts2 table
INSERT INTO posts2 (user_id, subreddit_id, title, score)
VALUES
    (1, 2, 'Upcoming VR tech', 6000),
    (3, 4, 'Top movie soundtracks', 4900);

-- Task 1: Inspect the tables
SELECT *
FROM users
LIMIT 10;
SELECT *
FROM posts
LIMIT 10;
SELECT *
FROM subreddits
LIMIT 10;

-- Task 2: Count the number of subreddits
SELECT COUNT(*) AS subreddit_count
FROM subreddits;

-- Task 3: Find the user with the highest score
SELECT username, MAX(score) AS highest_score
FROM users
GROUP BY username
ORDER BY highest_score DESC
LIMIT 1;

-- Find the post with the highest score
SELECT title, MAX(score) AS highest_score
FROM posts
GROUP BY title
ORDER BY highest_score DESC
LIMIT 1;

-- Top 5 subreddits by subscriber count
SELECT name
FROM subreddits
ORDER BY subscriber_count DESC
LIMIT 5;

-- Task 4: LEFT JOIN to find post count per user
SELECT users.username, COUNT(posts.id) AS posts_made
FROM users
    LEFT JOIN posts
        ON users.id = posts.user_id
GROUP BY users.id
ORDER BY posts_made DESC;

-- Task 5: INNER JOIN to find active posts and active users
SELECT posts.*
FROM posts
    INNER JOIN users
        ON posts.user_id = users.id;

-- Task 6: UNION to combine posts and posts2 tables
SELECT *
FROM posts
UNION
SELECT *
FROM posts2
ORDER BY score DESC
LIMIT 5;

-- Task 7: Subreddits with popular posts (score >= 5000)
WITH popular_posts AS (SELECT *
    FROM posts
    WHERE score >= 5000)
SELECT subreddits.name, popular_posts.title, popular_posts.score
FROM subreddits
    INNER JOIN popular_posts
        ON subreddits.id = popular_posts.subreddit_id
ORDER BY popular_posts.score DESC
LIMIT 5;

-- Task 8: Highest scoring post for each subreddit
SELECT posts.title,
   subreddits.name  AS subreddit_name,
   MAX(posts.score) AS highest_score
FROM posts
    INNER JOIN subreddits
        ON posts.subreddit_id = subreddits.id
GROUP BY posts.title, subreddits.name
ORDER BY highest_score DESC
LIMIT 5;

-- Task 9: Average score of posts for each subreddit
SELECT subreddits.name,
    ROUND(AVG(posts.score), 2) AS average_score
FROM subreddits
    INNER JOIN posts
        ON subreddits.id = posts.subreddit_id
GROUP BY subreddits.name
ORDER BY average_score DESC
LIMIT 5;
