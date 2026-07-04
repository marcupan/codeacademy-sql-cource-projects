/*
Level 5: Programmability & Server-Side Logic
This lesson covers PL/pgSQL, Triggers, Custom Types/ENUMs, and Materialized Views.
Best Practices:
- Use SECURITY INVOKER for functions unless they specifically need elevated privileges.
- Always use the `OR REPLACE` clause when developing functions.
- Use Materialized Views for heavy queries that don't need real-time data.
- Add error handling (EXCEPTION) in PL/pgSQL for robustness.
*/

-- 1. Custom Types & ENUMs
DROP TYPE IF EXISTS order_status CASCADE;
CREATE TYPE order_status AS ENUM ('pending', 'shipped', 'delivered', 'cancelled');

-- 2. Setup Tables
CREATE SCHEMA IF NOT EXISTS sales;
DROP TABLE IF EXISTS sales.audit_log CASCADE;
DROP TABLE IF EXISTS sales.orders CASCADE;
DROP TABLE IF EXISTS sales.customers CASCADE;

CREATE TABLE sales.customers
(
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        TEXT NOT NULL
);

CREATE TABLE sales.orders
(
    order_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT REFERENCES sales.customers (customer_id),
    status      order_status DEFAULT 'pending',
    order_date  TIMESTAMPTZ  DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sales.audit_log
(
    log_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name TEXT,
    action     TEXT,
    old_data   JSONB,
    new_data   JSONB,
    changed_by TEXT        DEFAULT current_user,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. PL/pgSQL Function with Error Handling
-- SECURITY INVOKER means it runs with the privileges of the caller.
CREATE OR REPLACE FUNCTION sales.place_order(p_customer_id INT)
    RETURNS INT AS
$$
DECLARE
    v_order_id INT;
BEGIN
    -- Basic validation
    IF NOT EXISTS (SELECT 1 FROM sales.customers WHERE customer_id = p_customer_id) THEN
        RAISE EXCEPTION 'Customer ID % not found', p_customer_id;
    END IF;

    INSERT INTO sales.orders (customer_id)
    VALUES (p_customer_id)
    RETURNING order_id INTO v_order_id;

    RETURN v_order_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'An error occurred: %', SQLERRM;
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY INVOKER;

-- 4. Triggers: Automating Audit Logs
-- Trigger function
CREATE OR REPLACE FUNCTION sales.log_generic_changes()
    RETURNS TRIGGER AS
$$
BEGIN
    INSERT INTO sales.audit_log (table_name, action, old_data, new_data)
    VALUES (TG_TABLE_NAME,
            TG_OP,
            CASE WHEN TG_OP = 'DELETE' OR TG_OP = 'UPDATE' THEN to_jsonb(OLD) END,
            CASE WHEN TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN to_jsonb(NEW) END);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attaching the trigger
CREATE TRIGGER trg_audit_orders
    AFTER INSERT OR UPDATE OR DELETE
    ON sales.orders
    FOR EACH ROW
EXECUTE FUNCTION sales.log_generic_changes();

-- 5. Materialized Views: Physical caching
DROP MATERIALIZED VIEW IF EXISTS sales.daily_order_stats;
CREATE MATERIALIZED VIEW sales.daily_order_stats AS
SELECT order_date::DATE as date,
       status,
       COUNT(*)         as total_orders
FROM sales.orders
GROUP BY 1, 2;

-- To refresh: REFRESH MATERIALIZED VIEW sales.daily_order_stats;
-- For concurrent refresh (requires unique index on MV):
-- CREATE UNIQUE INDEX idx_daily_stats_unique ON sales.daily_order_stats (date, status);
-- REFRESH MATERIALIZED VIEW CONCURRENTLY sales.daily_order_stats;
