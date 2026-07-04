/*
Level 2: Data Relationships & Organization
This lesson covers Joins, Aggregations, Schemas, and Views.
Best Practices:
- Use schemas to isolate different modules or multi-tenant data.
- Favor standard-compliant joins over legacy syntax.
- Use Views for security and query simplification.
*/

-- 1. Schemas: Using namespaces to organize tables
CREATE SCHEMA IF NOT EXISTS sales;

-- Managing search_path (Postgres-specific)
-- SHOW search_path;
-- SET search_path TO sales, public;

DROP TABLE IF EXISTS sales.order_items CASCADE;
DROP TABLE IF EXISTS sales.orders CASCADE;
DROP TABLE IF EXISTS sales.customers CASCADE;

CREATE TABLE sales.customers
(
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL,
    email       TEXT UNIQUE
);

CREATE TABLE sales.orders
(
    order_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT REFERENCES sales.customers (customer_id),
    order_date  DATE DEFAULT CURRENT_DATE
);

INSERT INTO sales.customers (name, email)
VALUES ('Alice', 'alice@example.com'),
       ('Bob', 'bob@example.com'),
       ('Charlie', 'charlie@example.com');

INSERT INTO sales.orders (customer_id, order_date)
VALUES (1, '2023-01-01'),
       (1, '2023-02-01'),
       (2, '2023-02-15');

-- 2. Joins: INNER, LEFT, RIGHT, FULL OUTER, CROSS JOIN
-- Postgres handles complex joins efficiently.
-- Finding customers with their orders (INNER JOIN)
SELECT c.name, o.order_date
FROM sales.customers c
         INNER JOIN sales.orders o ON c.customer_id = o.customer_id;

-- Include all customers, even those without orders (LEFT JOIN)
-- Using COALESCE to handle NULLs (Postgres feature)
SELECT c.name, COALESCE(o.order_date::TEXT, 'No orders') as last_order
FROM sales.customers c
         LEFT JOIN sales.orders o ON c.customer_id = o.customer_id;

-- 3. Aggregations: GROUP BY, HAVING, and FILTER (Postgres-specific)
-- The FILTER clause is a cleaner way to perform conditional aggregation
SELECT c.name,
       COUNT(o.order_id)                                            as total_orders,
       COUNT(o.order_id) FILTER (WHERE o.order_date > '2023-01-15') as recent_orders
FROM sales.customers c
         LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.name;

-- 4. Standard Views: Encapsulate complex logic
-- Using SECURITY INVOKER (default) or SECURITY DEFINER (for restricted access)
CREATE OR REPLACE VIEW sales.customer_order_summary AS
SELECT c.customer_id, c.name, COUNT(o.order_id) as total_orders
FROM sales.customers c
         LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

SELECT *
FROM sales.customer_order_summary;
