DROP TABLE IF EXISTS subscriptions;

-- Create the subscriptions table
CREATE TABLE subscriptions (
    id                 SERIAL PRIMARY KEY,
    subscription_start DATE NOT NULL,
    subscription_end   DATE,
    segment            INT  NOT NULL
);

-- Insert mock data into the subscriptions table
INSERT INTO subscriptions (subscription_start, subscription_end, segment)
VALUES
    ('2024-01-01', '2024-02-15', 87),
    ('2024-01-10', '2024-03-01', 30),
    ('2024-01-15', NULL, 87),
    ('2024-02-01', '2024-03-10', 30),
    ('2024-02-15', '2024-04-01', 87),
    ('2024-03-01', NULL, 30),
    ('2024-03-15', '2024-04-15', 87),
    ('2024-03-20', NULL, 30);

-- Task 1: Inspect the first 100 rows
SELECT *
FROM subscriptions
LIMIT 100;

-- Count distinct segments
SELECT DISTINCT segment
FROM subscriptions;

-- Task 2: Determine the range of months
SELECT MIN(subscription_start) AS earliest_start,
   MAX(subscription_end) AS latest_end
FROM subscriptions;

-- Task 3: Create a temporary table of months
WITH months AS (SELECT GENERATE_SERIES(
       '2024-01-01'::DATE,
       '2024-03-01'::DATE,
       '1 MONTH'
   ) AS first_day)
SELECT *
FROM months;

-- Task 4: Create a cross join temporary table
WITH months AS (SELECT GENERATE_SERIES(
        '2024-01-01'::DATE,
        '2024-03-01'::DATE,
        '1 MONTH'
    ) AS first_day)
SELECT *
FROM subscriptions
    CROSS JOIN months;

-- Task 5: Create the status temporary table
WITH months AS (SELECT GENERATE_SERIES(
       '2024-01-01'::DATE,
       '2024-03-01'::DATE,
       '1 MONTH'
    ) AS first_day),
cross_join AS (SELECT s.*, m.first_day
    FROM subscriptions s
        CROSS JOIN months m)
SELECT id,
    first_day AS month,
    CASE
       WHEN segment = 87 AND subscription_start < first_day
           AND (subscription_end IS NULL OR subscription_end >= first_day)
           THEN 1
       ELSE 0
       END AS is_active_87,
    CASE
       WHEN segment = 30 AND subscription_start < first_day
           AND (subscription_end IS NULL OR subscription_end >= first_day)
           THEN 1
       ELSE 0
       END AS is_active_30
FROM cross_join;

-- Task 6: Add cancellation columns to status
WITH months AS (SELECT GENERATE_SERIES(
       '2024-01-01'::DATE,
       '2024-03-01'::DATE,
       '1 MONTH'
    ) AS first_day),
cross_join AS (SELECT s.*, m.first_day
    FROM subscriptions s
        CROSS JOIN months m)
SELECT id,
    first_day AS month,
    CASE
        WHEN segment = 87 AND subscription_start < first_day
           AND (subscription_end IS NULL OR subscription_end >= first_day)
           THEN 1
        ELSE 0
        END AS is_active_87,
    CASE
        WHEN segment = 30 AND subscription_start < first_day
           AND (subscription_end IS NULL OR subscription_end >= first_day)
           THEN 1
        ELSE 0
        END AS is_active_30,
    CASE
        WHEN segment = 87 AND subscription_end >= first_day
           AND subscription_end < first_day + INTERVAL '1 month'
           THEN 1
        ELSE 0
        END AS is_canceled_87,
    CASE
        WHEN segment = 30 AND subscription_end >= first_day
           AND subscription_end < first_day + INTERVAL '1 month'
           THEN 1
        ELSE 0
        END AS is_canceled_30
FROM cross_join;

-- Task 7: Create status_aggregate
WITH months AS (SELECT GENERATE_SERIES(
        '2024-01-01'::DATE,
        '2024-03-01'::DATE,
        '1 MONTH'
    ) AS first_day),
    cross_join AS (SELECT s.*, m.first_day
        FROM subscriptions s
        CROSS JOIN months m),
    status AS (SELECT id,
    first_day AS month,
    CASE
        WHEN segment = 87 AND subscription_start < first_day
           AND (subscription_end IS NULL OR subscription_end >= first_day)
           THEN 1
        ELSE 0
        END AS is_active_87,
    CASE
        WHEN segment = 30 AND subscription_start < first_day
           AND (subscription_end IS NULL OR subscription_end >= first_day)
           THEN 1
        ELSE 0
        END AS is_active_30,
    CASE
        WHEN segment = 87 AND subscription_end >= first_day
           AND subscription_end < first_day + INTERVAL '1 month'
           THEN 1
        ELSE 0
        END AS is_canceled_87,
    CASE
        WHEN segment = 30 AND subscription_end >= first_day
           AND subscription_end < first_day + INTERVAL '1 month'
           THEN 1
        ELSE 0
        END AS is_canceled_30
    FROM cross_join)
SELECT month,
    SUM(is_active_87) AS sum_active_87,
    SUM(is_active_30) AS sum_active_30,
    SUM(is_canceled_87) AS sum_canceled_87,
    SUM(is_canceled_30) AS sum_canceled_30
FROM status
GROUP BY month
ORDER BY month;

-- Task 8: Calculate churn rates
WITH months AS (SELECT GENERATE_SERIES(
        '2024-01-01'::DATE,
        '2024-03-01'::DATE,
        '1 MONTH'
    ) AS first_day),
    cross_join AS (SELECT s.*, m.first_day
        FROM subscriptions s
            CROSS JOIN months m),
    status AS (SELECT id,
        first_day AS month,
        CASE
            WHEN segment = 87 AND subscription_start < first_day
                AND (subscription_end IS NULL OR subscription_end >= first_day)
                THEN 1
            ELSE 0
            END AS is_active_87,
        CASE
            WHEN segment = 30 AND subscription_start < first_day
                AND (subscription_end IS NULL OR subscription_end >= first_day)
                THEN 1
            ELSE 0
            END AS is_active_30,
        CASE
            WHEN segment = 87 AND subscription_end >= first_day
                AND subscription_end < first_day + INTERVAL '1 month'
                THEN 1
            ELSE 0
            END AS is_canceled_87,
        CASE
            WHEN segment = 30 AND subscription_end >= first_day
                AND subscription_end < first_day + INTERVAL '1 month'
                THEN 1
            ELSE 0
            END AS is_canceled_30
    FROM cross_join),
    status_aggregate AS (SELECT month,
        SUM(is_active_87) AS sum_active_87,
        SUM(is_active_30) AS sum_active_30,
        SUM(is_canceled_87) AS sum_canceled_87,
        SUM(is_canceled_30) AS sum_canceled_30
    FROM status
    GROUP BY month)
SELECT month,
    ROUND(SUM(sum_canceled_87)::NUMERIC / NULLIF(SUM(sum_active_87), 0), 4) AS churn_rate_87,
    ROUND(SUM(sum_canceled_30)::NUMERIC / NULLIF(SUM(sum_active_30), 0), 4) AS churn_rate_30
FROM status_aggregate
GROUP BY month
ORDER BY month;
