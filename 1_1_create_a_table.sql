DROP TABLE IF EXISTS friends;

-- Create the friend's table
CREATE TABLE friends (
    id INTEGER,
    name TEXT,
    birthday DATE
);

-- Insert a single row into the friend's table
INSERT INTO friends (id, name, birthday) VALUES
    (1, 'Ororo Munroe', '1940-05-30');

-- Select all rows from the friend's table
SELECT * FROM friends;

-- Insert multiple rows into the friend's table
INSERT INTO friends (id, name, birthday) VALUES
    (2, 'John', '1972-04-10'),
    (3, 'Otto', '1958-06-03');

-- Update the name of the friend with id 1
UPDATE friends SET name = 'Storm' WHERE id = 1;

-- Add a new column for email addresses
ALTER TABLE friends ADD COLUMN email TEXT;

-- Select all rows from the friend's table to check the changes
SELECT * FROM friends;

-- Update email addresses for each friend
UPDATE friends SET email = 'storm@codecademy.com' WHERE id = 1;
UPDATE friends SET email = 'john@codecademy.com' WHERE id = 2;
UPDATE friends SET email = 'otto@codecademy.com' WHERE id = 3;

-- Select all rows from the friend's table to confirm updates
SELECT * FROM friends;

-- Delete the friend with id 1
DELETE FROM friends WHERE id = 1;

-- Select all remaining rows from the friend's table
SELECT * FROM friends;
