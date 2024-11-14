CREATE TABLE friends (
    id INTEGER,
    name TEXT,
    birthday DATE
);

INSERT INTO friends VALUES
    (1, 'Ororo Munroe', 'May 30th, 1940');

SELECT * FROM friends;

INSERT INTO friends VALUES
    (2, 'John', 'April 10th, 1972'),
    (3, 'Otto', 'June 3th, 1958');

UPDATE friends SET name = 'Storm' WHERE id = 1;

ALTER TABLE friends ADD COLUMN email TEXT;

SELECT * FROM friends;

UPDATE friends SET email = 'storm@codecademy.com' WHERE id = 1;
UPDATE friends SET email = 'john@codecademy.com' WHERE id = 2;
UPDATE friends SET email = 'otto@codecademy.com' WHERE id = 3;

SELECT * FROM friends;

DELETE FROM friends WHERE id = 1;

SELECT * FROM friends;

