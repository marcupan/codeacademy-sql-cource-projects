DROP TABLE IF EXISTS store;

-- Create the `store` table with the correct structure
CREATE TABLE store (
    order_id       SERIAL PRIMARY KEY,
    order_date     DATE           NOT NULL,
    customer_id    INT            NOT NULL,
    customer_email VARCHAR(255)   NOT NULL,
    customer_phone VARCHAR(50)    NOT NULL,
    item_1_id      INT            NOT NULL,
    item_1_name    VARCHAR(255)   NOT NULL,
    item_1_price   NUMERIC(10, 2) NOT NULL,
    item_2_id      INT,
    item_2_name    VARCHAR(255),
    item_2_price   NUMERIC(10, 2),
    item_3_id      INT,
    item_3_name    VARCHAR(255),
    item_3_price   NUMERIC(10, 2)
);

-- Insert valid data into the `store` table
INSERT INTO store (order_date, customer_id, customer_email, customer_phone,
                   item_1_id, item_1_name, item_1_price,
                   item_2_id, item_2_name, item_2_price,
                   item_3_id, item_3_name, item_3_price)
VALUES ('2019-07-01', 1, 'john.doe@example.com', '123-456-7890', 1, 'Chair', 49.99, 2, 'Table', 149.99, 3, 'Lamp',
        19.99),
       ('2019-07-02', 2, 'jane.smith@example.com', '987-654-3210', 1, 'Chair', 49.99, 3, 'Lamp', 19.99, NULL, NULL,
        NULL),
       ('2019-07-03', 1, 'john.doe@example.com', '123-456-7890', 2, 'Table', 149.99, 3, 'Lamp', 19.99, NULL, NULL,
        NULL),
       ('2019-07-04', 3, 'alice.johnson@example.com', '456-789-1234', 4, 'Sofa', 299.99, 1, 'Chair', 49.99, 5,
        'Bookshelf', 89.99),
       ('2019-07-05', 4, 'bob.brown@example.com', '321-654-9870', 3, 'Lamp', 19.99, NULL, NULL, NULL, NULL, NULL, NULL);

-- Task 1: Inspect the data
SELECT *
FROM store
LIMIT 10;

-- Task 2: Count distinct orders and customers
SELECT COUNT(DISTINCT (order_id)) AS orders_count
FROM store;
SELECT COUNT(DISTINCT (customer_id)) AS customers_count
FROM store;

-- Task 3: Inspect repeated customer data
SELECT customer_id, customer_email, customer_phone
FROM store
WHERE customer_id = 1;

-- Task 4: Inspect repeated item data
SELECT item_1_id, item_1_name, item_1_price
FROM store
WHERE item_1_id = 4;

-- Task 5: Create the `customers` table
CREATE TABLE customers AS
SELECT DISTINCT customer_id, customer_email, customer_phone
FROM store;

-- Task 6: Add primary key to `customers`
ALTER TABLE customers
    ADD PRIMARY KEY (customer_id);

-- Task 7: Create the `items` table
CREATE TABLE items AS
SELECT DISTINCT item_1_id    AS item_id,
                item_1_name  AS name,
                item_1_price AS price
FROM store
UNION
SELECT DISTINCT item_2_id    AS item_id,
                item_2_name  AS name,
                item_2_price AS price
FROM store
WHERE item_2_id IS NOT NULL
UNION
SELECT DISTINCT item_3_id    AS item_id,
                item_3_name  AS name,
                item_3_price AS price
FROM store
WHERE item_3_id IS NOT NULL;

-- Task 8: Add primary key to `items`
ALTER TABLE items
    ADD PRIMARY KEY (item_id);

-- Task 9: Create the `orders_items` table
CREATE TABLE orders_items AS
SELECT order_id, item_1_id AS item_id
FROM store
UNION ALL
SELECT order_id, item_2_id AS item_id
FROM store
WHERE item_2_id IS NOT NULL
UNION ALL
SELECT order_id, item_3_id AS item_id
FROM store
WHERE item_3_id IS NOT NULL;

-- Task 10: Create the `orders` table
CREATE TABLE orders AS
SELECT DISTINCT order_id, order_date, customer_id
FROM store;

-- Task 11: Add primary key to `orders`
ALTER TABLE orders
    ADD PRIMARY KEY (order_id);

-- Task 12: Add foreign key constraints
ALTER TABLE orders
    ADD FOREIGN KEY (customer_id) REFERENCES customers (customer_id);
ALTER TABLE orders_items
    ADD FOREIGN KEY (item_id) REFERENCES items (item_id);

-- Task 13: Add foreign key from `orders_items` to `orders`
ALTER TABLE orders_items
    ADD FOREIGN KEY (order_id) REFERENCES orders (order_id);

-- Task 14: Query customers who ordered after July 25, 2019 (non-normalized)
SELECT customer_email
FROM store
WHERE order_date > '2019-07-25';

-- Task 15: Query customers who ordered after July 25, 2019 (normalized)
SELECT customers.customer_email
FROM customers
         JOIN orders ON customers.customer_id = orders.customer_id
WHERE order_date > '2019-07-25';

-- Task 16: Count orders containing each unique item (non-normalized)
WITH all_items AS (SELECT item_1_id AS item_id
                   FROM store
                   UNION ALL
                   SELECT item_2_id AS item_id
                   FROM store
                   WHERE item_2_id IS NOT NULL
                   UNION ALL
                   SELECT item_3_id AS item_id
                   FROM store
                   WHERE item_3_id IS NOT NULL)
SELECT item_id, COUNT(*) AS order_count
FROM all_items
GROUP BY item_id;

-- Task 17: Count orders containing each unique item (normalized)
SELECT item_id, COUNT(*) AS order_count
FROM orders_items
GROUP BY item_id;

-- Task 18: Experiment with queries

-- Query 1: Customers with more than one order
SELECT customers.customer_id,
       customers.customer_email,
       COUNT(orders.order_id) AS orders_count
FROM customers
         JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.customer_id, customers.customer_email
HAVING COUNT(orders.order_id) > 1;

-- Query 2: Orders containing "Lamp" after a specific date
SELECT orders.order_id, orders.order_date, items.name
FROM orders
         JOIN orders_items ON orders.order_id = orders_items.order_id
         JOIN items ON orders_items.item_id = items.item_id
WHERE items.name = 'Lamp'
  AND order_date > '2019-07-01';

-- Query 3: Count orders containing "Chair"
SELECT COUNT(orders.order_id) AS order_count
FROM orders
         JOIN orders_items ON orders.order_id = orders_items.order_id
         JOIN items ON orders_items.item_id = items.item_id
WHERE items.name = 'Chair';
