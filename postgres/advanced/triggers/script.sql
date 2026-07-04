SET SEARCH_PATH = cc_user;

-- 1. Existing Structure
SELECT *
FROM customers
ORDER BY customer_id;
SELECT *
FROM customers_log;

-- 2. Update Triggers
CREATE TRIGGER customer_updated
    AFTER UPDATE OF first_name, last_name
    ON customers
    FOR EACH ROW
EXECUTE PROCEDURE log_customers_change();

-- 3. Testing the Update Trigger (Success Case)
UPDATE customers
SET first_name = 'Steve'
WHERE customer_id = 1;

SELECT *
FROM customers
ORDER BY customer_id;
SELECT *
FROM customers_log;

-- 4. Testing the Update Trigger (Failure Case)
UPDATE customers
SET years_old = 40
WHERE customer_id = 1;

SELECT *
FROM customers
ORDER BY customer_id;
SELECT *
FROM customers_log;

-- 5. Insert Triggers
CREATE TRIGGER customer_insert
    AFTER INSERT
    ON customers
    FOR EACH STATEMENT
EXECUTE PROCEDURE log_customers_change();

-- 6. Testing the Insert Trigger
INSERT INTO customers (first_name, last_name, email_address, home_phone, city, state_name, years_old)
VALUES ('Jeffrey', 'Cook', 'Jeffrey.Cook@example.com', '202-555-0398', 'Jersey city', 'New Jersey', 66),
       ('Jane', 'Doe', 'jane.doe@example.com', '202-555-0399', 'Jersey city', 'New Jersey', 45),
       ('John', 'Smith', 'john.smith@example.com', '202-555-0400', 'Jersey city', 'New Jersey', 32);

SELECT *
FROM customers
ORDER BY customer_id;
SELECT *
FROM customers_log;

-- 7. Conditionals on your Triggers
CREATE TRIGGER customer_min_age
    BEFORE UPDATE
    ON customers
    FOR EACH ROW
    WHEN (NEW.years_old < 13)
EXECUTE PROCEDURE override_with_min_age();

-- 8. Testing the Conditional Trigger
UPDATE customers
SET years_old = 10
WHERE customer_id = 2;

UPDATE customers
SET years_old = 20
WHERE customer_id = 3;

SELECT *
FROM customers
ORDER BY customer_id;
SELECT *
FROM customers_log;

-- 9. Testing Multiple Column Updates
UPDATE customers
SET first_name = 'Timmy',
    years_old  = 9
WHERE customer_id = 4;

SELECT *
FROM customers
ORDER BY customer_id;
SELECT *
FROM customers_log;

-- 10. Trigger Cleanup
DROP TRIGGER customer_min_age ON customers;

-- 11. Verify Removal
SELECT *
FROM information_schema.triggers
WHERE event_object_table = 'customers';