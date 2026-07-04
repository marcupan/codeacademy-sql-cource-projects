/*
Level 4: Advanced Querying
This lesson covers CTEs, Recursive CTEs, Window Functions, and Upsert.
Best Practices:
- Use CTEs for readability, but be aware of materialization (Postgres 12+ optimization).
- Use Window Functions for complex analytics without self-joins.
- Use ON CONFLICT for "Upsert" logic to avoid race conditions.
*/

-- Setup: Create a table for employees
DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees
(
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email       TEXT UNIQUE,
    department  TEXT,
    salary      NUMERIC
);

INSERT INTO employees (email, department, salary)
VALUES ('alice@example.com', 'IT', 90000),
       ('bob@example.com', 'IT', 80000),
       ('charlie@example.com', 'HR', 70000),
       ('david@example.com', 'Sales', 85000),
       ('eve@example.com', 'IT', 95000);

-- 1. CTEs (Common Table Expressions)
-- In Postgres 12+, CTEs are not materialized by default if they are used only once.
-- You can force materialization with a MATERIALIZED keyword.
WITH department_stats AS MATERIALIZED (SELECT department, AVG(salary) as avg_salary
                                       FROM employees
                                       GROUP BY department)
SELECT e.email, e.salary, ds.avg_salary
FROM employees e
         JOIN department_stats ds ON e.department = ds.department
WHERE e.salary > ds.avg_salary;

-- 2. Recursive CTEs: Hierarchical data
-- Great for org charts, category trees, etc.
DROP TABLE IF EXISTS org_chart CASCADE;
CREATE TABLE org_chart
(
    id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       TEXT,
    manager_id INT REFERENCES org_chart (id)
);

INSERT INTO org_chart (name, manager_id)
VALUES ('CEO', NULL),
       ('VP Sales', 1),
       ('VP Engineering', 1),
       ('Sales Manager', 2),
       ('Junior Dev', 3);

WITH RECURSIVE subordinates AS (
    -- Anchor member
    SELECT id, name, manager_id, 1 AS level, ARRAY [name] AS path
    FROM org_chart
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT o.id, o.name, o.manager_id, s.level + 1, s.path || o.name
    FROM org_chart o
             INNER JOIN subordinates s ON o.manager_id = s.id)
SELECT *
FROM subordinates
ORDER BY path;

-- 3. Window Functions: Analytics without collapsing rows
-- WINDOW clause (Postgres-specific) to reuse window definitions
SELECT email,
       department,
       salary,
       RANK() OVER w      as salary_rank,
       AVG(salary) OVER w as dept_avg
FROM employees
WINDOW w AS (PARTITION BY department ORDER BY salary DESC);

-- Range Frames: Moving averages (Postgres allows ROWS and RANGE frames)
SELECT email,
       salary,
       SUM(salary) OVER (ORDER BY salary ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) as moving_sum
FROM employees;

-- 4. Upsert (ON CONFLICT): Handle duplicates gracefully
-- `DO UPDATE` can use the special `EXCLUDED` table
INSERT INTO employees (email, department, salary)
VALUES ('alice@example.com', 'IT', 100000)
ON CONFLICT (email)
    DO UPDATE SET salary     = EXCLUDED.salary,
                  department = EXCLUDED.department
WHERE employees.salary < EXCLUDED.salary; -- Only update if the new salary is higher
