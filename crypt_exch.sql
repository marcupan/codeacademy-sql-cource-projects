DROP TABLE IF EXISTS transactions;

-- Create the transactions table
CREATE TABLE transactions (
    id        SERIAL PRIMARY KEY,
    date      DATE        NOT NULL,
    currency  VARCHAR(10) NOT NULL,
    money_in  NUMERIC(10, 2),
    money_out NUMERIC(10, 2)
);

-- Insert mock data into the transactions table
INSERT INTO transactions (date, currency, money_in, money_out)
VALUES
    ('2024-01-01', 'BIT', 5000.00, NULL),
    ('2024-01-01', 'ETH', 3000.00, NULL),
    ('2024-01-02', 'BIT', NULL, 2000.00),
    ('2024-01-02', 'LTC', 1000.00, NULL),
    ('2024-01-03', 'ETH', NULL, 1500.00),
    ('2024-01-03', 'BIT', 7000.00, NULL),
    ('2024-01-04', 'LTC', NULL, 1200.00),
    ('2024-01-04', 'BIT', 6000.00, NULL),
    ('2024-01-05', 'ETH', NULL, 3200.00),
    ('2024-01-05', 'BIT', NULL, 4000.00);

-- 1. Check out the transactions table
SELECT *
FROM transactions
LIMIT 10;

-- 2. Calculate the total money_in in the table
SELECT SUM(money_in) AS total_money_in
FROM transactions;

-- 3. Calculate the total money_out in the table
SELECT SUM(money_out) AS total_money_out
FROM transactions;

-- 4. Bitcoin transactions

-- Count total money_in transactions
SELECT COUNT(money_in) AS total_money_in_transactions
FROM transactions;

-- Count money_in transactions where currency is 'BIT'
SELECT COUNT(money_in) AS bitcoin_money_in_transactions
FROM transactions
WHERE currency = 'BIT';

-- 5. Find the largest transaction in the whole table
-- Was it money_in or money_out?
SELECT CASE
       WHEN MAX(money_in) > MAX(money_out) THEN 'Money In'
       ELSE 'Money Out'
       END AS largest_transaction_type,
   GREATEST(MAX(money_in), MAX(money_out)) AS largest_transaction
FROM transactions;

-- 6. Average money_in for Ethereum (ETH)
SELECT AVG(money_in) AS average_money_in_eth
FROM transactions
WHERE currency = 'ETH';

-- 7. Ledger for different dates
SELECT date,
   AVG(money_in)  AS avg_money_in,
   AVG(money_out) AS avg_money_out
FROM transactions
GROUP BY date;

-- 8. Round averages to 2 decimal places and add column aliases
SELECT date AS "Date",
   ROUND(AVG(money_in), 2)  AS "Average Buy",
   ROUND(AVG(money_out), 2) AS "Average Sell"
FROM transactions
GROUP BY date;
