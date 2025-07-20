DROP TABLE IF EXISTS orders;

-- Create the orders table
CREATE TABLE orders (
    id                   SERIAL PRIMARY KEY,
    order_date           DATE         NOT NULL,
    item_name            VARCHAR(255) NOT NULL,
    special_instructions TEXT,
    restaurant_id        INT          NOT NULL,
    user_id              INT          NOT NULL
);

-- Insert test data into the orders table
INSERT INTO orders (order_date, item_name, special_instructions, restaurant_id, user_id)
VALUES
    ('2024-01-01', 'Cheeseburger', 'Extra sauce, no pickles', 1, 101),
    ('2024-01-02', 'Veggie Burger', 'No sauce', 1, 102),
    ('2024-01-03', 'Chicken Burger', 'Leave at the door', 2, 103),
    ('2024-01-04', 'Double Cheeseburger', NULL, 1, 104),
    ('2024-01-05', 'Bacon Burger', 'Extra crispy bacon', 2, 105),
    ('2024-01-06', 'Fries', 'Extra ketchup', 1, 101),
    ('2024-01-07', 'Milkshake', 'Put it in a box', 1, 106),
    ('2024-01-08', 'Salad', NULL, 2, 107),
    ('2024-01-09', 'Hotdog', 'Door delivery only', 2, 108),
    ('2024-01-10', 'Fish Burger', 'Box it up, no onions', 1, 109);

-- 1. What are the column names?
SELECT *
FROM orders
LIMIT 10;

-- 2. How recent is this data? Find unique order_date values
SELECT DISTINCT order_date
FROM orders;

-- 3. Select only the special_instructions column, limited to 20 rows
SELECT special_instructions
FROM orders
LIMIT 20;

-- 4. Return only the special instructions that are not empty
SELECT special_instructions
FROM orders
WHERE special_instructions IS NOT NULL;

-- 5. Sort the special instructions alphabetically (A-Z)
SELECT special_instructions
FROM orders
WHERE special_instructions IS NOT NULL
ORDER BY special_instructions;

-- 6. Search for special instructions that have the word ‘sauce’
SELECT special_instructions
FROM orders
WHERE special_instructions LIKE '%sauce%';

-- 7. Search for special instructions that have the word ‘door’
SELECT special_instructions
FROM orders
WHERE special_instructions LIKE '%door%';

-- 8. Search for special instructions that have the word ‘box’
SELECT special_instructions
FROM orders
WHERE special_instructions LIKE '%box%';

-- 9. Return order ids along with special instructions
-- Rename id as '#' and special_instructions as 'Notes'
SELECT id AS "#",
   special_instructions AS "Notes"
FROM orders
WHERE special_instructions LIKE '%box%';

-- 10. Query the customer who made the phrase
-- Return the item_name, restaurant_id, and user_id
SELECT item_name,
    restaurant_id,
    user_id
FROM orders
WHERE special_instructions LIKE '%box%';
