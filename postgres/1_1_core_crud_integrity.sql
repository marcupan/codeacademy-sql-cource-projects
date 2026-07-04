/*
Level 1: The Foundation (Core CRUD & Integrity)
This lesson covers basic data types, CRUD operations, and standard constraints in PostgreSQL.
Best Practices:
- Use gen_random_uuid() for primary keys if you need non-sequential IDs.
- Use TIMESTAMPTZ (timestamp with time zone) instead of TIMESTAMP for global apps.
- Use CHECK constraints to enforce business logic at the database level.
*/

-- 1. Basic Data Types: INT, TEXT, BOOLEAN, UUID, TIMESTAMPTZ
-- PostgreSQL supports rich data types. UUIDs are great for distributed systems.
-- TIMESTAMPTZ is the gold standard for time.

DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;

-- Using a DOMAIN for reusable validation (Postgres-specific)
DROP DOMAIN IF EXISTS positive_numeric CASCADE;
CREATE DOMAIN positive_numeric AS NUMERIC(10, 2) CHECK (VALUE > 0);

CREATE TABLE products
(
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT NOT NULL,
    price      positive_numeric,                          -- Using our custom DOMAIN
    is_active  BOOLEAN          DEFAULT TRUE,
    created_at TIMESTAMPTZ      DEFAULT CURRENT_TIMESTAMP -- Always use WITH TIME ZONE
);

-- 2. CRUD Operations: INSERT, SELECT, UPDATE, DELETE
-- RETURNING clause: A Postgres-specific feature to get data back from a `write`
INSERT INTO products (name, price)
VALUES ('Postgres Mug', 12.99),
       ('SQL Guide', 25.00)
RETURNING product_id, created_at;

-- SELECT with pattern matching (ILIKE for case-insensitive)
SELECT *
FROM products
WHERE name ILIKE '%postgres%';

-- UPDATE with RETURNING
UPDATE products
SET price = 15.00
WHERE name = 'Postgres Mug'
RETURNING name, price AS new_price;

-- DELETE
DELETE
FROM products
WHERE name = 'SQL Guide';

-- 3. Standard Constraints: NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY
CREATE TABLE orders
(
    order_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,            -- Modern Postgres way (SQL Standard)
    product_id UUID REFERENCES products (product_id) ON DELETE CASCADE, -- FOREIGN KEY with CASCADE
    quantity   INT NOT NULL CHECK (quantity > 0),
    order_date TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ACID Compliance: Basic transaction control
-- BEGIN, COMMIT, and ROLLBACK ensure atomicity.
BEGIN;

-- Savepoint for more granular control within a transaction
SAVEPOINT before_insert;

INSERT INTO orders (product_id, quantity)
SELECT product_id, 1
FROM products
WHERE name = 'Postgres Mug';

-- If we wanted to undo ONLY the last insert:
-- ROLLBACK TO SAVEPOINT before_insert;

COMMIT;

-- Verify
SELECT *
FROM orders;
