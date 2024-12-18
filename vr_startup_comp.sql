DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS projects;

-- Create the employees table
CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50),
    last_name       VARCHAR(50),
    position        VARCHAR(50),
    personality     VARCHAR(10),
    current_project INT
);

-- Create the projects table
CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(255)
);

-- Insert sample data into employees table
INSERT INTO employees (first_name, last_name, position, personality, current_project)
VALUES
    ('John', 'Doe', 'Developer', 'INFP', 1),
    ('Jane', 'Smith', 'Team Lead', 'ENFP', NULL),
    ('Emily', 'Brown', 'Designer', 'INFJ', 2),
    ('Michael', 'Johnson', 'Developer', 'ISFP', 1),
    ('Chris', 'Davis', 'DBA', 'ENFJ', NULL),
    ('Sarah', 'Miller', 'Developer', 'INFJ', 3),
    ('David', 'Wilson', 'Project Manager', 'ESTJ', 2),
    ('Laura', 'Taylor', 'Developer', 'ENFP', 3);

-- Insert sample data into projects table
INSERT INTO projects (project_name)
VALUES
    ('Virtual Reality Game'),
    ('Augmented Reality App'),
    ('VR Training Program'),
    ('AR Shopping Experience');

-- Task 1: Inspect the tables
SELECT *
FROM employees
LIMIT 2;
SELECT *
FROM projects
LIMIT 2;

-- Task 2: Find employees without a current project
SELECT first_name, last_name
FROM employees
WHERE current_project IS NULL;

-- Task 3: Find projects not chosen by any employees
SELECT project_name
FROM projects
WHERE project_id NOT IN (SELECT current_project
    FROM employees
    WHERE current_project IS NOT NULL);

-- Task 4: Find the project chosen by the most employees
SELECT project_name
FROM projects
    INNER JOIN employees
        ON projects.project_id = employees.current_project
GROUP BY project_name
ORDER BY COUNT(employee_id) DESC
LIMIT 1;

-- Task 5: Find projects chosen by multiple employees
SELECT project_name
FROM projects
    INNER JOIN employees
        ON projects.project_id = employees.current_project
GROUP BY current_project, project_name
HAVING COUNT(current_project) > 1;

-- Task 6: Calculate available positions for developers
SELECT (COUNT(*) * 2) - (SELECT COUNT(*)
    FROM employees
    WHERE current_project IS NOT NULL
        AND position = 'Developer') AS available_positions
FROM projects;

-- Task 7: Find the most common personality type
SELECT personality
FROM employees
GROUP BY personality
ORDER BY COUNT(personality) DESC
LIMIT 1;

-- Task 8: Find projects chosen by employees with the most common personality type
SELECT project_name
FROM projects
    INNER JOIN employees
        ON projects.project_id = employees.current_project
WHERE personality = (SELECT personality
    FROM employees
    GROUP BY personality
    ORDER BY COUNT(personality) DESC
    LIMIT 1);

-- Task 9: Find employees with the most represented personality type for a selected project
SELECT last_name, first_name, personality, project_name
FROM employees
    INNER JOIN projects
        ON employees.current_project = projects.project_id
WHERE personality = (SELECT personality
    FROM employees
    WHERE current_project IS NOT NULL
    GROUP BY personality
    ORDER BY COUNT(personality) DESC
    LIMIT 1);

-- Task 10: For each employee, list their incompatibilities
SELECT last_name,
    first_name,
    personality,
    project_name,
    CASE
        WHEN personality = 'INFP' THEN (SELECT COUNT(*)
            FROM employees
            WHERE personality IN
                ('ISFP', 'ESFP', 'ISTP', 'ESTP', 'ISFJ', 'ESFJ', 'ISTJ', 'ESTJ'))
        WHEN personality = 'ISFP' THEN (SELECT COUNT(*)
            FROM employees
            WHERE personality IN ('INFP', 'ENFP', 'INFJ'))
        -- Add additional personality conditions here as needed
        ELSE 0
        END AS incompatibilities
FROM employees
    LEFT JOIN projects
        ON employees.current_project = projects.project_id
LIMIT 5;
