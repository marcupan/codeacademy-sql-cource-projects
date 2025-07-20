DROP TABLE IF EXISTS users;

-- Create the users table
CREATE TABLE users (
    user_id    SERIAL PRIMARY KEY,
    email      VARCHAR(100),
    birthday   DATE,
    created_at DATE,
    test       VARCHAR(50),
    campaign   VARCHAR(50)
);

-- Insert mock data into users
INSERT INTO users (email, birthday, created_at, test, campaign)
VALUES
    ('john.doe@example.com', '1982-05-14', '2016-03-22', 'bears', 'AAA-1'),
    ('jane.smith@example.com', '1987-09-30', '2015-11-15', NULL, 'BBB-2'),
    ('art.vandelay@example.com', '1979-12-25', '2017-06-01', NULL, 'AAA-2'),
    ('sarah.connor@example.com', '1983-07-08', '2014-01-10', 'cats', 'BBB-1'),
    ('mike.ross@example.com', '1990-03-14', '2017-04-29', NULL, NULL),
    ('rachel.zane@example.com', '1985-12-05', '2013-08-22', 'bears', 'BBB-2'),
    ('john.watson@example.com', '1988-02-20', '2016-12-05', 'dogs', 'AAA-2'),
    ('james.bond@example.com', '1981-11-07', '2015-05-30', NULL, NULL),
    ('claire.bennet@example.com', '1984-04-16', '2014-09-09', 'bears', 'BBB-1'),
    ('tony.stark@example.com', '1986-01-12', '2012-03-13', 'cats', 'AAA-1');

-- Task 1: Get a feel for the users table
SELECT *
FROM users
LIMIT 20;

-- Task 2: Find the email addresses and birthdays of users born in the '80s
SELECT email, birthday
FROM users
WHERE birthday BETWEEN '1980-01-01' AND '1989-12-31';

-- Task 3: Find the emails and creation date of users who signed up prior to May 2017
SELECT email, created_at
FROM users
WHERE created_at < '2017-05-01';

-- Task 4: Find the emails of users who received the 'bears' test
SELECT email
FROM users
WHERE test = 'bears';

-- Task 5: Find all the emails of users who received a campaign on website BBB
SELECT email
FROM users
WHERE campaign LIKE 'BBB%';

-- Task 6: Find all the emails of users who received ad copy 2 in their campaign
SELECT email
FROM users
WHERE campaign LIKE '%-2';

-- Task 7: Find the emails for users who received both a campaign and a test
SELECT email
FROM users
WHERE campaign IS NOT NULL
  AND test IS NOT NULL;

-- Challenge: Calculate how old users were when they signed up
SELECT email,
   birthday,
   created_at,
   EXTRACT(YEAR FROM AGE(created_at, birthday)) AS age_at_signup
FROM users;
