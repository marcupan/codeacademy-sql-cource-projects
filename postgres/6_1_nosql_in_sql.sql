/*
Level 6: Semi-Structured Data (NoSQL in SQL)
This lesson covers JSONB, GIN Indexes, and Arrays.
Best Practices:
- Always use JSONB instead of JSON for storage (faster, supports indexing).
- Use GIN indexes for efficient searching within JSONB or Arrays.
- Avoid deep nesting in JSONB; flat structures are easier to query and index.
- Use the `@>` operator for "contains" queries.
*/

-- 1. JSONB: Binary-optimized JSON storage
DROP TABLE IF EXISTS user_profiles CASCADE;
CREATE TABLE user_profiles
(
    user_id           INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username          TEXT  NOT NULL,
    preferences       JSONB NOT NULL DEFAULT '{}',
    internal_metadata JSONB -- Unstructured data
);

INSERT INTO user_profiles (username, preferences, internal_metadata)
VALUES ('jdoe', '{
  "theme": "dark",
  "notifications": {
    "email": true,
    "sms": false
  },
  "tags": [
    "sql",
    "postgres"
  ]
}', '{
  "last_login_ip": "127.0.0.1"
}'),
       ('asmith', '{
         "theme": "light",
         "notifications": {
           "email": false,
           "sms": false
         },
         "tags": [
           "db",
           "nosql"
         ]
       }', '{
         "notes": "beta tester"
       }');

-- Querying JSONB with operators
-- -> returns JSONB object, ->> returns TEXT
SELECT username, preferences ->> 'theme' as theme
FROM user_profiles
WHERE preferences @> '{"theme": "dark"}';
-- Efficient "contains" check

-- Accessing nested fields
SELECT username, preferences -> 'notifications' ->> 'email' as email_notif
FROM user_profiles;

-- 2. GIN (Generalized Inverted Index): Indexing JSONB
-- There are two main types of GIN indexes for JSONB:
-- a) Default (jsonb_ops): Supports @>, ?, ?&, ?|
CREATE INDEX idx_user_prefs_gin ON user_profiles USING GIN (preferences);

-- b) Path-specific index (Postgres 11+ optimization)
-- Useful for indexing a specific array within a JSONB object
CREATE INDEX idx_user_prefs_tags ON user_profiles USING GIN ((preferences -> 'tags'));

-- 3. Arrays: Storing multiple values in a column
DROP TABLE IF EXISTS posts CASCADE;
CREATE TABLE posts
(
    post_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title   TEXT NOT NULL,
    tags    TEXT[] -- Postgres-native array type
);

INSERT INTO posts (title, tags)
VALUES ('Learning Postgres', ARRAY ['postgres', 'sql', 'tutorial']),
       ('NoSQL in SQL', '{"json", "postgres", "nosql"}');
-- Alternative syntax

-- Querying Arrays
-- Find posts that have a 'postgres' tag
SELECT *
FROM posts
WHERE 'postgres' = ANY (tags);

-- Find posts that have ALL specified tags
SELECT *
FROM posts
WHERE tags @> ARRAY ['postgres', 'sql'];

-- GIN Index on Arrays for performance
CREATE INDEX idx_posts_tags_gin ON posts USING GIN (tags);

-- 4. Combining NoSQL & SQL
-- Postgres allows joining JSONB data with regular tables easily
SELECT p.title, u.username
FROM posts p
         JOIN user_profiles u ON u.preferences -> 'tags' @> to_jsonb(p.tags[1]); -- Using index
