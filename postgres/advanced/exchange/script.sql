-- 1. Who's Here? - Find the name of the superuser
SELECT rolname
FROM pg_roles
WHERE rolsuper = true;

-- 2. Find the names of other users and their specific permissions
SELECT rolname, rolcreaterole, rolcanlogin, rolcreatedb
FROM pg_roles
WHERE rolsuper = false;

-- 3. Check the name of the role you are currently using
SELECT current_user;

-- 4. Adding a Publisher - Create a login role without superuser permissions
CREATE ROLE abc_open_data WITH LOGIN NOSUPERUSER;

-- 5. Create a group role named publishers and include abc_open_data as a member
CREATE ROLE publishers NOSUPERUSER;
GRANT publishers TO abc_open_data;

-- 6. Grant USAGE on the analytics schema to the publishers group
GRANT USAGE ON SCHEMA analytics TO publishers;

-- 7. Grant publishers the ability to SELECT on all existing tables in analytics
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO publishers;

-- 8. Check how PostgreSQL recorded the schema permissions
SELECT *
FROM information_schema.table_privileges
WHERE table_schema = 'analytics'
  AND table_name = 'downloads';

-- 9. Confirm abc_open_data can SELECT via inheritance, then reset role
SET ROLE abc_open_data;
SELECT *
FROM analytics.downloads
LIMIT 10;
SET ROLE ccuser;

-- 10. View sample rows from the directory.datasets table
SELECT *
FROM directory.datasets
LIMIT 10;

-- 11. Grant USAGE on the directory schema to publishers
GRANT USAGE ON SCHEMA directory TO publishers;

-- 12. Grant SELECT on all columns EXCEPT data_checksum to publishers
GRANT SELECT (id, create_date, hosting_path, publisher, src_size)
    ON directory.datasets TO publishers;

-- 13. Test querying as the publisher (omitting the restricted data_checksum column)
SET ROLE abc_open_data;
SELECT id, publisher, hosting_path
FROM directory.datasets;
SET ROLE ccuser;

-- 14. Enable Row Level Security (RLS) and create a policy for publishers
ALTER TABLE analytics.downloads
    ENABLE ROW LEVEL SECURITY;

CREATE POLICY publisher_downloads_policy
    ON analytics.downloads
    FOR SELECT
    TO publishers
    USING (owner = current_user);

-- 15. Test Row Level Security to see how results differ between users
-- Query as the current admin user:
SELECT *
FROM analytics.downloads
LIMIT 10;

-- Query as the restricted publisher:
SET ROLE abc_open_data;
SELECT *
FROM analytics.downloads
LIMIT 10;
SET ROLE ccuser;