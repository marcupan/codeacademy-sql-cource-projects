DROP TABLE IF EXISTS organizations;
DROP TABLE IF EXISTS systems;
DROP TABLE IF EXISTS problems;
DROP TABLE IF EXISTS organizations_problems;

-- Create the `organizations` table
CREATE TABLE organizations (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(50)
);

-- Create the `systems` table
CREATE TABLE systems (
    id               SERIAL PRIMARY KEY,
    system           VARCHAR(255),
    type             VARCHAR(50),
    publication_date DATE,
    parameters       BIGINT,
    organization_id  INT REFERENCES organizations (id)
);

-- Create the `problems` table
CREATE TABLE problems (
    id      SERIAL PRIMARY KEY,
    problem VARCHAR(255)
);

-- Create the `organizations_problems` table
CREATE TABLE organizations_problems (
    organization_id INT REFERENCES organizations (id),
    problem_id      INT REFERENCES problems (id)
);

-- Insert mock data into `organizations`
INSERT INTO organizations (name, type)
VALUES
    ('OpenAI', 'Research'),
    ('Google DeepMind', 'Corporate'),
    ('Anthropic', 'Startup'),
    ('Meta AI', 'Corporate'),
    ('Hugging Face', 'Startup');

-- Insert mock data into `systems`
INSERT INTO systems (system, type, publication_date, parameters, organization_id)
VALUES
    ('GPT-4', 'Language model', '2023-03-15', 175000000000, 1),
    ('DALL-E 3', 'Image generation', '2023-09-15', 10000000000, 1),
    ('AlphaZero', 'Reinforcement learning', '2018-12-15', 1000000000, 2),
    ('Claude AI', 'Language model', '2022-11-30', 52000000000, 3),
    ('LLaMA', 'Language model', '2023-02-27', 65000000000, 4),
    ('Stable Diffusion', 'Image generation', '2022-08-01', 7000000000, 5);

-- Insert mock data into `problems`
INSERT INTO problems (problem)
VALUES
    ('Language understanding'),
    ('Image generation'),
    ('Game playing'),
    ('AI ethics'),
    ('Knowledge representation');

-- Insert mock data into `organizations_problems`
INSERT INTO organizations_problems (organization_id, problem_id)
VALUES
    (1, 1), -- OpenAI -> Language understanding
    (1, 2), -- OpenAI -> Image generation
    (2, 3), -- DeepMind -> Game playing
    (3, 4), -- Anthropic -> AI ethics
    (4, 1), -- Meta AI -> Language understanding
    (5, 2);
-- Hugging Face -> Image generation

-- Task 1: Inspect the tables
SELECT *
FROM organizations;
SELECT *
FROM systems;
SELECT *
FROM problems;
SELECT *
FROM organizations_problems;

-- Task 5: Count the number of AI systems created by each organization
SELECT o.name          AS organization_name,
    COUNT(s.system) AS number_of_ai_systems
FROM systems s
    JOIN organizations o
        ON s.organization_id = o.id
GROUP BY o.name
ORDER BY number_of_ai_systems DESC;

-- Task 6: Filter by AI System Type
SELECT o.name          AS organization_name,
    COUNT(s.system) AS number_of_image_generation_ai
FROM systems s
    JOIN organizations o
        ON s.organization_id = o.id
WHERE s.type = 'Image generation'
GROUP BY o.name
ORDER BY number_of_image_generation_ai DESC;

-- Task 6: Add organization type
SELECT o.name          AS organization_name,
       o.type          AS organization_type,
       COUNT(s.system) AS number_of_ai_systems
FROM systems s
    JOIN organizations o
        ON s.organization_id = o.id
GROUP BY o.name, o.type
ORDER BY number_of_ai_systems DESC;

-- Task 7: Investigate AI development over time
SELECT EXTRACT(YEAR FROM s.publication_date) AS publication_year,
       COUNT(s.system)                       AS number_of_ai_systems,
       MAX(s.parameters)                     AS largest_parameter
FROM systems s
GROUP BY publication_year
ORDER BY publication_year;

-- Task 9: Find the top 5 AI problems organizations focus on
SELECT p.problem   AS ai_problem,
    COUNT(o.id) AS number_of_organizations
FROM problems p
    JOIN organizations_problems op
        ON p.id = op.problem_id
    JOIN organizations o
        ON op.organization_id = o.id
WHERE p.problem IS NOT NULL
GROUP BY p.problem
ORDER BY number_of_organizations DESC
LIMIT 5;
