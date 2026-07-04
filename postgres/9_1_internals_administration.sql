/*
Level 9: Internals & Administration
This lesson covers MVCC, Vacuuming, Locking, and Maintenance.
Best Practices:
- Monitor "Bloat": Excessive dead tuples that haven't been vacuumed yet.
- Use VACUUM ANALYZE after large data loads to update planner statistics.
- Avoid long-running transactions as they prevent VACUUM from cleaning up dead tuples.
- Understand transaction isolation levels (Read Committed is default).
*/

-- 1. MVCC (Multi-Version Concurrency Control)
-- Every row update creates a new version. Old versions are "dead tuples".
DROP TABLE IF EXISTS internal_demo CASCADE;
CREATE TABLE internal_demo
(
    id  INT PRIMARY KEY,
    val TEXT
);

INSERT INTO internal_demo
VALUES (1, 'initial');

-- Hidden columns: 
-- xmin: Transaction ID that created this row version
-- xmax: Transaction ID that deleted/updated this row version (0 if active)
SELECT xmin, xmax, *
FROM internal_demo;

UPDATE internal_demo
SET val = 'updated'
WHERE id = 1;

-- Now you'd see a new xmin. The old version still exists in the file but is invisible.
SELECT xmin, xmax, *
FROM internal_demo;

-- 2. VACUUM & Bloat
-- VACUUM reclaims space from dead tuples.
-- ANALYZE updates the statistics used by the query optimizer.
VACUUM (ANALYZE, VERBOSE) internal_demo;

-- Autovacuum: A background process that does this automatically.
-- You can tune it per-table:
ALTER TABLE internal_demo
    SET (
        autovacuum_vacuum_scale_factor = 0.01,
        autovacuum_analyze_scale_factor = 0.005
        );

-- 3. Explicit Locking
-- Postgres has many lock levels. 
-- FOR UPDATE locks rows for the duration of the transaction.
BEGIN;
SELECT *
FROM internal_demo
WHERE id = 1 FOR UPDATE;
-- Another session trying to UPDATE id=1 would block until this COMMITs.
COMMIT;

-- 4. Maintenance Views (The DBA's friends)
-- View current activity
SELECT pid, state, query, wait_event_type, wait_event
FROM pg_stat_activity
WHERE state != 'idle';

-- View table sizes (including indexes)
SELECT relname                                       AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- 5. Point-in-Time Recovery (PITR) & WAL
-- Write-Ahead Logging (WAL) ensure durability.
-- PITR allows you to restore to any point by replaying WAL logs over a base backup.
-- Relevant settings in postgresql.conf:
-- wal_level = replica
-- archive_mode = on
-- archive_command = 'cp %p /path/to/archive/%f'
