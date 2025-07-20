DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS riders2;

-- Create the trips table
CREATE TABLE trips (
    id SERIAL PRIMARY KEY,
    rider_id INT NOT NULL,
    car_id INT NOT NULL,
    cost NUMERIC NOT NULL,
    date TIMESTAMP NOT NULL
);

-- Create the riders table
CREATE TABLE riders (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    total_trips INT NOT NULL
);

-- Create the cars table
CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    model VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    trips_completed INT NOT NULL
);

-- Create the riders2 table
CREATE TABLE riders2 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    total_trips INT NOT NULL
);

-- Insert test data into the trips table
INSERT INTO trips (rider_id, car_id, cost, date)
VALUES
    (1, 1, 15.50, '2024-11-14 10:30:00'),
    (2, 2, 22.00, '2024-11-13 14:45:00'),
    (3, 3, 18.75, '2024-11-12 08:20:00');

-- Insert test data into the riders table
INSERT INTO riders (name, total_trips)
VALUES
    ('Alice', 200),
    ('Bob', 150),
    ('Charlie', 500);

-- Insert test data into the cars table
INSERT INTO cars (model, status, trips_completed)
VALUES
    ('Toyota Prius', 'active', 1000),
    ('Tesla Model 3', 'inactive', 800),
    ('Honda Accord', 'active', 1200);

-- Insert test data into the riders2 table
INSERT INTO riders2 (name, total_trips)
VALUES
    ('Dave', 300),
    ('Eve', 400),
    ('Frank', 600);

-- 1. Retrieve the first 2 rows from the trips table
SELECT * FROM trips LIMIT 2;

-- 2. Retrieve the first 2 rows from the riders table
SELECT * FROM riders LIMIT 2;

-- 3. Retrieve the first 2 rows from the cars table
SELECT * FROM cars LIMIT 2;

-- 4. Inner join trips and cars on car_id
SELECT *
FROM trips
    INNER JOIN cars
    ON trips.car_id = cars.id
LIMIT 2;

-- 5. Combine all rows from riders and riders2 tables (UNION)
SELECT *
FROM riders
UNION
SELECT *
FROM riders2;

-- 6. Calculate the average trip cost, rounded to 2 decimal places
SELECT ROUND(AVG(cost), 2) AS average_cost
FROM trips;

-- 7. Combine riders and riders2 tables with a condition on total_trips (UNION)
SELECT *
FROM riders
WHERE total_trips < 500
UNION
SELECT *
FROM riders2
WHERE total_trips < 500;

-- 8. Count the number of active cars
SELECT COUNT(*) AS active_cars
FROM cars
WHERE status = 'active';

-- 9. Retrieve the top 2 cars with the highest trips_completed
SELECT *
FROM cars
ORDER BY trips_completed DESC
LIMIT 2;
