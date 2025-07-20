DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS orders;

-- Create the `customers` table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email_address VARCHAR(100)
);

-- Create the `books` table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),
    original_language VARCHAR(50),
    sales_in_millions NUMERIC(10, 2)
);

-- Create the `orders` table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    book_id INT REFERENCES books(book_id),
    quantity INT,
    price_base NUMERIC(10, 2)
);

-- Insert data into `customers`
INSERT INTO customers (first_name, last_name, email_address)
VALUES
    ('John', 'Doe', 'john.doe@example.com'),
    ('Jane', 'Smith', 'jane.smith@example.com'),
    ('Alice', 'Johnson', 'alice.johnson@example.com');

-- Insert data into `books`
INSERT INTO books (title, author, original_language, sales_in_millions)
VALUES
    ('The Great Gatsby', 'F. Scott Fitzgerald', 'English', 25.0),
    ('Les Misérables', 'Victor Hugo', 'French', 50.0),
    ('Don Quixote', 'Miguel de Cervantes', 'Spanish', 30.0),
    ('War and Peace', 'Leo Tolstoy', 'Russian', 20.0),
    ('The Little Prince', 'Antoine de Saint-Exupéry', 'French', 100.0);

-- Insert data into `orders`
INSERT INTO orders (customer_id, book_id, quantity, price_base)
VALUES
    (1, 1, 5, 10.0),
    (1, 2, 20, 15.0),
    (2, 3, 15, 12.0),
    (3, 4, 25, 20.0),
    (3, 5, 18, 25.0);

-- Task 1: Inspect tables
SELECT * FROM customers LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM books LIMIT 10;

-- Task 2: Check existing indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'customers';

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders';

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'books';

-- Task 3: Analyze query performance for large orders
EXPLAIN ANALYZE SELECT customer_id, quantity
    FROM orders
    WHERE quantity > 18;

-- Task 4: Create a partial index for large orders
CREATE INDEX orders_big_sales_idx
    ON orders (customer_id, quantity)
    WHERE quantity > 18;

-- Task 5: Analyze query performance with the new index
EXPLAIN ANALYZE SELECT customer_id, quantity
    FROM orders
    WHERE quantity > 18;

-- Task 6: Ensure `customers` table is ordered by primary key
CLUSTER customers USING customers_pkey;

-- Verify reorganization
SELECT *
FROM customers
LIMIT 10;

-- Task 8: Create a multicolumn index for customer_id and book_id in orders
CREATE INDEX orders_customer_id_book_id_idx
    ON orders (customer_id, book_id);

-- Task 9: Add quantity to the multicolumn index
DROP INDEX IF EXISTS orders_customer_id_book_id_idx;

CREATE INDEX orders_customer_id_book_id_quantity_idx
    ON orders (customer_id, book_id, quantity);

-- Task 10: Combine author and title indexes in books
DROP INDEX IF EXISTS books_author_idx;
DROP INDEX IF EXISTS books_title_idx;

CREATE INDEX books_author_title_idx
    ON books (author, title);

-- Task 11: Analyze query performance for high total price orders
EXPLAIN ANALYZE SELECT *
    FROM orders
    WHERE quantity * price_base > 100;

-- Task 12: Create an index for high total price orders
CREATE INDEX orders_quantity_price_base_idx
    ON orders (quantity, price_base)
    WHERE quantity * price_base > 100;

-- Task 13: Verify index impact on query performance
EXPLAIN ANALYZE SELECT *
    FROM orders
    WHERE quantity * price_base > 100;

-- Task 14: Experiment with indexes
CREATE INDEX customers_last_name_first_name_email_address
    ON customers (last_name, first_name, email_address);

-- Check all indexes
SELECT *
FROM pg_indexes
WHERE tablename IN ('customers', 'books', 'orders')
ORDER BY tablename, indexname;
