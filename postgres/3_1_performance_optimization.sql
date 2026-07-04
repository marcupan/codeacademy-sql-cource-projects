/*
Level 3: Basic Performance & Optimization
This lesson covers Indexing and Query Analysis (EXPLAIN).
Best Practices:
- Use EXPLAIN ANALYZE to verify if your indexes are actually being used.
- Avoid over-indexing; every index adds overhead to INSERTS/UPDATES.
- Use partial and expression indexes to target specific query patterns.
*/

DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees
(
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email       TEXT NOT NULL,
    department  TEXT,
    salary      NUMERIC,
    is_active   BOOLEAN DEFAULT TRUE,
    metadata    JSONB -- For a demonstration of potential overhead
);

-- Insert dummy data (10,000 rows for better EXPLAIN visualization)
INSERT INTO employees (email, department, salary, is_active)
SELECT 'user' || i || '@example.com',
       (ARRAY ['Sales', 'HR', 'IT', 'Marketing'])[floor(random() * 4 + 1)],
       random() * 100000,
       random() > 0.1
FROM generate_series(1, 10000) s(i);

-- 1. B-Tree Indexes: The default indexing method is
-- Good for equality (=) and range (<, >, BETWEEN) queries
CREATE INDEX idx_employees_department ON employees (department);

-- 2. EXPLAIN & EXPLAIN ANALYZE: Performance diagnostics
-- Use EXPLAIN to see the plan without running it
EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';

-- Use EXPLAIN (ANALYZE, BUFFERS) to run it and get actual timings and cache usage
-- BUFFERS shows how many blocks were read from disk vs. hit in memory
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM employees
WHERE department = 'IT';

-- 3. Partial Indexes: Index only a subset of data
-- Dramatically reduces index size if the condition is selective
CREATE INDEX idx_active_employees_email ON employees (email) WHERE is_active = TRUE;

-- 4. Expression Indexes: Indexing a function result
-- Useful when queries use functions in the WHERE clause
CREATE INDEX idx_employees_lower_email ON employees (LOWER(email));

-- 5. Multi-column (Composite) Indexes
-- Order of columns matters (Leading columns should be most restrictive)
CREATE INDEX idx_dept_salary ON employees (department, salary DESC);

-- Example of a query that uses the composite index
EXPLAIN ANALYZE
SELECT *
FROM employees
WHERE department = 'Sales'
  AND salary > 80000;

-- 6. Statistics: Helping the Query Planner
-- Postgres gathers statistics automatically, but you can trigger it manually
ANALYZE employees;
