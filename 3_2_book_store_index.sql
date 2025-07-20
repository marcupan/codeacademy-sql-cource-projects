DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS orders;

-- Create the `customers` table
CREATE TABLE customers (
    id            SERIAL PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    email_address VARCHAR(100)
);

-- Create the `books` table
CREATE TABLE books (
    id                SERIAL PRIMARY KEY,
    title             VARCHAR(255),
    author            VARCHAR(255),
    original_language VARCHAR(50),
    sales_in_millions NUMERIC(10, 2)
);

-- Create the `orders` table
CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers (id),
    book_id     INT REFERENCES books (id),
    order_date  TIMESTAMP
);

-- Insert test data into `customers`
INSERT INTO customers (first_name, last_name, email_address)
VALUES
    ('John', 'Doe', 'john.doe@example.com'),
    ('Jane', 'Smith', 'jane.smith@example.com'),
    ('Alice', 'Johnson', 'alice.johnson@example.com');

-- Insert test data into `books`
INSERT INTO books (title, author, original_language, sales_in_millions)
VALUES
    ('The Great Gatsby', 'F. Scott Fitzgerald', 'English', 25.0),
    ('Les Misérables', 'Victor Hugo', 'French', 50.0),
    ('Don Quixote', 'Miguel de Cervantes', 'Spanish', 30.0),
    ('War and Peace', 'Leo Tolstoy', 'Russian', 20.0),
    ('The Little Prince', 'Antoine de Saint-Exupéry', 'French', 100.0);

-- Insert test data into `orders`
INSERT INTO orders (customer_id, book_id, order_date)
VALUES
    (1, 1, '2023-12-01 10:00:00'),
    (1, 2, '2023-12-02 11:00:00'),
    (2, 3, '2023-12-03 12:00:00'),
    (3, 4, '2023-12-04 13:00:00'),
    (3, 5, '2023-12-05 14:00:00');

-- Task 1: Inspect tables
SELECT *
FROM customers
LIMIT 10;
SELECT *
FROM orders
LIMIT 10;
SELECT *
FROM books
LIMIT 10;

-- Task 2: Check existing indexes
SELECT *
FROM pg_indexes
WHERE tablename = 'customers';
SELECT *
FROM pg_indexes
WHERE tablename = 'orders';
SELECT *
FROM pg_indexes
WHERE tablename = 'books';

-- Task 3: Create indexes for foreign keys in orders
CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_orders_book_id ON orders (book_id);

-- Task 4: Check query runtime for original_language in books
EXPLAIN ANALYZE
SELECT original_language, title, sales_in_millions
FROM books
WHERE original_language = 'French';

-- Task 5: Check the size of the books table
SELECT pg_size_pretty(pg_total_relation_size('books'));

-- Task 6: Create a multicolumn index on books
CREATE INDEX idx_books_language_title_sales
    ON books (original_language, title, sales_in_millions);

-- Task 7: Repeat query to check runtime after creating the index
EXPLAIN ANALYZE
SELECT original_language, title, sales_in_millions
FROM books
WHERE original_language = 'French';

-- Task 8: Drop the multicolumn index to speed up inserts
DROP INDEX IF EXISTS idx_books_language_title_sales;

-- Task 9: Bulk insert into orders and measure time
SELECT NOW();
-- Simulate a bulk insert with mock data
INSERT INTO orders (customer_id, book_id, order_date)
SELECT (i % 3) + 1, (i % 5) + 1, NOW() - (i || ' minutes')::interval
FROM generate_series(1, 1000) AS i;
SELECT NOW();

-- Task 10: Drop indexes before bulk insert, then recreate them
DROP INDEX IF EXISTS idx_orders_customer_id;
DROP INDEX IF EXISTS idx_orders_book_id;

SELECT NOW();
-- Simulate another bulk insert
INSERT INTO orders (customer_id, book_id, order_date)
SELECT (i % 3) + 1, (i % 5) + 1, NOW() - (i || ' minutes')::interval
FROM generate_series(1001, 2000) AS i;
SELECT NOW();

CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_orders_book_id ON orders (book_id);

-- Task 11: Create index for contact queries
CREATE INDEX idx_customers_first_name_email ON customers (first_name, email_address);
