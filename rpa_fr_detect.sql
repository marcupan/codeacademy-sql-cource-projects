DROP TABLE IF EXISTS transaction_data;

-- Create the transaction_data table
CREATE TABLE transaction_data (
    transaction_id     SERIAL PRIMARY KEY,
    full_name          VARCHAR(100),
    email              VARCHAR(100),
    ip_address         VARCHAR(50),
    zip                INT,
    transaction_amount DECIMAL(10, 2)
);

-- Insert mock data into transaction_data
INSERT INTO transaction_data (full_name, email, ip_address, zip, transaction_amount)
VALUES
    ('John Doe', 'johndoe@example.com', '120.45.67.89', 30301, 100.50),
    ('Jane Smith', 'janesmith@example.com', '10.23.45.67', 20252, 150.75),
    ('Art Vandelay', 'artvandelay@temp_email.com', '192.168.0.1', 90210, 200.00),
    ('Smokey Bear', 'smokeybear@example.com', '8.8.8.8', 20252, 250.00),
    ('Sarah Connor', 'sarahconnor@temp_email.com', '10.11.12.13', 10001, 300.25),
    ('Johnathan Der Smith', 'johnathan.der.smith@example.com', '120.98.76.54', 30305, 75.00),
    ('Mike Ross', 'mike.ross@temp_email.com', '172.16.254.1', 32000, 50.00),
    ('Rachel Zane', 'rachelzane@example.com', '10.0.0.1', 90210, 125.75),
    ('Smokey Bear', 'smokeybear@forest.com', '202.54.77.123', 20252, 85.50),
    ('John Watson', 'johnwatson@example.com', '120.76.45.34', 30315, 60.00);

-- Verify the data
SELECT *
FROM transaction_data;

-- Task 1: Get a feel for the table
SELECT *
FROM transaction_data
LIMIT 10;

-- Task 2: Find the full_names and emails of transactions listing 20252 as the zip code
SELECT full_name, email
FROM transaction_data
WHERE zip = 20252;

-- Task 3: Find the names and emails of transactions with specific pseudonyms
SELECT full_name, email
FROM transaction_data
WHERE full_name = 'Art Vandelay'
   OR full_name LIKE '% der %';

-- Task 4: Find the ip_addresses and emails of transactions from internal-use IP addresses
SELECT ip_address, email
FROM transaction_data
WHERE ip_address LIKE '10.%';

-- Task 5: Find the emails with 'temp_email.com' as a domain
SELECT email
FROM transaction_data
WHERE email LIKE '%@temp_email.com';

-- Task 6: Find the transaction from an IP starting with ‘120.’ and full name starting with ‘John’
SELECT *
FROM transaction_data
WHERE full_name LIKE 'John%'
  AND ip_address LIKE '120.%';

-- Task 7: Find transactions from customers residing in Georgia (GA)
SELECT *
FROM transaction_data
WHERE zip BETWEEN 30000 AND 31999;
