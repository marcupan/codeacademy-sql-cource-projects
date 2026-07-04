/*
Level 7: Security & Access Control
This lesson covers Roles, Privileges, and Row-Level Security (RLS).
Best Practices:
- Use Row-Level Security (RLS) for multi-tenant applications.
- Follow the Principle of Least Privilege: only GRANT what is necessary.
- Use Roles to group permissions rather than granting to individual users.
- Always ENABLE ROW LEVEL SECURITY before defining policies.
*/

-- Setup: Create a table for sensitive data
DROP TABLE IF EXISTS employee_salaries CASCADE;
CREATE TABLE employee_salaries
(
    id            INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email         TEXT UNIQUE NOT NULL,
    department    TEXT        NOT NULL,
    salary_amount NUMERIC     NOT NULL
);

INSERT INTO employee_salaries (email, department, salary_amount)
VALUES ('alice@example.com', 'IT', 95000),
       ('bob@example.com', 'Sales', 85000),
       ('manager@example.com', 'IT', 120000);

-- 1. Roles & Grouping Permissions
-- Create a group role (no login)
-- CREATE ROLE department_it;
-- CREATE ROLE department_sales;

-- Create individual user roles that inherit from group roles
-- CREATE ROLE alice LOGIN INHERIT ROLE department_it;
-- CREATE ROLE bob LOGIN INHERIT ROLE department_sales;

-- Granting permissions to the group role
-- GRANT SELECT ON employee_salaries TO department_it;

-- 2. Row-Level Security (RLS): The Power of Postgres Security
-- Step A: Enable RLS on the table
ALTER TABLE employee_salaries
    ENABLE ROW LEVEL SECURITY;

-- Step B: Define a policy for normal employees (can only see their own row)
-- Using current_user to match the email
DROP POLICY IF EXISTS employee_self_view ON employee_salaries;
CREATE POLICY employee_self_view ON employee_salaries
    FOR SELECT
    TO public -- Applies to all roles
    USING (email = current_user);

-- Step C: Define a policy for managers (can see everyone in their department)
-- managers have a special role or attribute (in this case, salary > 110,000)
DROP POLICY IF EXISTS manager_dept_view ON employee_salaries;
CREATE POLICY manager_dept_view ON employee_salaries
    FOR SELECT
    TO public
    USING (
    EXISTS (SELECT 1
            FROM employee_salaries m
            WHERE m.email = current_user
              AND m.department = employee_salaries.department
              AND m.salary_amount > 110000)
    );

-- 3. Security Definer vs. Invoker (Review Level 5)
-- Functions can bypass RLS if they are defined with SECURITY DEFINER and owned by a superuser.
-- Use with extreme caution!

-- 4. Audit Security (Informational)
-- In a production environment, you should also track who changed what (see Level 5 Triggers).
-- Postgres logs (postgresql.conf) can be configured to log all connections and even DDL changes.

-- 5. Connection Security: pg_hba.conf
-- This file is outside the database and controls WHO can connect from WHERE.
-- Best practice: Use 'scram-sha-256' for password encryption.
-- Example entry:
-- host    all             all             10.0.0.0/24             scram-sha-256
