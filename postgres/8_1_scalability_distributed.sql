/*
Level 8: Scalability & Distributed Systems
This lesson covers Partitioning, Foreign Data Wrappers (FDW), and Pub/Sub (LISTEN/NOTIFY).
Best Practices:
- Use Partitioning for very large tables (hundreds of GBs) to improve maintenance and performance.
- Use LIST or RANGE partitioning based on your access patterns.
- Keep Foreign Data Wrapper (FDW) usage minimal as it can be slower than local queries.
- Use LISTEN/NOTIFY for lightweight async task signaling, not for heavy data transfer.
*/

-- 1. Declarative Table Partitioning (Postgres 10+)
-- We'll use Range Partitioning by date, a very common pattern.
DROP TABLE IF EXISTS sales_measurements CASCADE;
CREATE TABLE sales_measurements
(
    id        INT GENERATED ALWAYS AS IDENTITY,
    sale_date DATE NOT NULL,
    amount    NUMERIC,
    region    TEXT
) PARTITION BY RANGE (sale_date);

-- Create specific partitions (Tables themselves)
CREATE TABLE sales_y2022 PARTITION OF sales_measurements
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE sales_y2023 PARTITION OF sales_measurements
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Default partition for values that don't fit anywhere else
CREATE TABLE sales_default PARTITION OF sales_measurements DEFAULT;

-- Indexes on partitioned tables are automatically created on partitions (Postgres 11+)
CREATE INDEX idx_sales_date ON sales_measurements (sale_date);

-- 2. Foreign Data Wrappers (FDW)
-- Allows querying external databases as if they were local tables.
-- Requires an extension.
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Setup involves:
-- 1. CREATE SERVER (Define remote host/db)
-- 2. CREATE USER MAPPING (Define credentials)
-- 3. IMPORT FOREIGN SCHEMA or CREATE FOREIGN TABLE

-- Example (Theoretical):
-- CREATE SERVER remote_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '10.0.0.1', dbname 'warehouse');
-- CREATE USER MAPPING FOR current_user SERVER remote_server OPTIONS (user 'reporter', password 'secret');
-- CREATE FOREIGN TABLE remote_sales (...) SERVER remote_server OPTIONS (schema_name 'public', table_name 'sales');

-- 3. Pub/Sub (LISTEN/NOTIFY): Lightweight async communication
-- Postgres acts as a message broker.
-- In Session A: LISTEN order_events;
-- In Session B: NOTIFY order_events, '{"order_id": 123, "status": "paid"}';

-- Using a Trigger to automate notifications
CREATE OR REPLACE FUNCTION notify_new_sale()
    RETURNS TRIGGER AS
$$
BEGIN
    -- the payload must be a string, so we convert to JSON
    PERFORM pg_notify('sale_channel', json_build_object(
            'id', NEW.id,
            'amount', NEW.amount,
            'region', NEW.region
                                      )::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sale_notify
    AFTER INSERT
    ON sales_measurements
    FOR EACH ROW
EXECUTE FUNCTION notify_new_sale();

-- 4. Logical Replication (Informational)
-- Allows replicating specific tables between databases.
-- Essential for zero-downtime migrations or data warehousing.
-- CREATE PUBLICATION my_pub FOR TABLE sales_measurements;
-- CREATE SUBSCRIPTION my_sub CONNECTION '...' PUBLICATION my_pub;
