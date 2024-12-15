-- Create the places table
CREATE TABLE places (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(255),
    category       VARCHAR(50),
    average_rating NUMERIC(3, 2),
    price_point    VARCHAR(10)
);

-- Create the reviews table
CREATE TABLE reviews (
    id          SERIAL PRIMARY KEY,
    place_id    INT REFERENCES places (id),
    username    VARCHAR(50),
    rating      NUMERIC(3, 2),
    review_date DATE,
    note        TEXT
);

-- Insert sample data into places table
INSERT INTO places (name, category, average_rating, price_point)
VALUES
    ('Burger Palace', 'Restaurant', 4.5, '$'),
    ('Sushi Central', 'Restaurant', 4.8, '$$$'),
    ('Book Haven', 'Bookstore', 4.2, '$$'),
    ('Coffee Corner', 'Cafe', 3.9, '$'),
    ('Pizza Paradise', 'Restaurant', 4.3, '$$');

-- Insert sample data into reviews table
INSERT INTO reviews (place_id, username, rating, review_date, note)
VALUES
    (1, 'user1', 5.0, '2024-01-10', 'Great burgers!'),
    (2, 'user2', 4.5, '2024-01-12', 'Delicious sushi but expensive.'),
    (3, 'user3', 4.0, '2024-01-14', 'Cozy place with a good book selection.'),
    (1, 'user4', 4.0, '2024-01-15', 'Tasty but a bit slow service.'),
    (4, 'user5', 3.5, '2024-01-16', 'Coffee could be better.');

-- Task 1: Check the structure of both tables
SELECT *
FROM places
LIMIT 2;

SELECT *
FROM reviews
LIMIT 2;

-- Task 2: Find all places that cost $20 or less
SELECT *
FROM places
WHERE price_point = '$'
   OR price_point = '$$';

-- Task 3: Identify columns to JOIN the tables
-- Column `id` in places corresponds to `place_id` in reviews.

-- Task 4: INNER JOIN to show all reviews for restaurants
SELECT *
FROM places
    INNER JOIN reviews
        ON places.id = reviews.place_id;

-- Task 5: Log of reviews with selected columns
SELECT places.name,
    places.average_rating,
    reviews.username,
    reviews.rating,
    reviews.review_date,
    reviews.note
FROM places
    INNER JOIN reviews
        ON places.id = reviews.place_id;

-- Task 6: LEFT JOIN to include all places, even those without reviews
SELECT places.name,
    places.average_rating,
    reviews.username,
    reviews.rating,
    reviews.review_date,
    reviews.note
FROM places
    LEFT JOIN reviews
       ON places.id = reviews.place_id;

-- Task 7: Find all places without reviews
SELECT places.id
FROM places
    LEFT JOIN reviews
       ON places.id = reviews.place_id
WHERE reviews.id IS NULL;

-- Task 8: Log of all reviews from 2020
WITH reviews_2020 AS (SELECT *
    FROM reviews
    WHERE EXTRACT(YEAR FROM review_date) = 2020)
SELECT r.*, p.*
FROM reviews_2020 r
         JOIN places p
              ON r.place_id = p.id;

-- Task 9: Reviewer with the most below-average reviews
WITH avg_place_rating AS (SELECT AVG(average_rating) AS avg_rating
        FROM places),
    below_avg_reviews AS (SELECT username, COUNT(*) AS below_avg_count
        FROM reviews r
            JOIN places p
                ON r.place_id = p.id
        WHERE r.rating < (SELECT avg_rating FROM avg_place_rating)
        GROUP BY username)
SELECT username, below_avg_count
FROM below_avg_reviews
ORDER BY below_avg_count DESC
LIMIT 1;
