/*
Level 10: Specialized Extensions
Postgres' greatest strength is its extensibility.
This lesson covers PostGIS, pgvector, TimescaleDB, and pg_stat_statements.
Best Practices:
- Only enable extensions you actually need.
- Keep extensions updated along with your Postgres version.
- Use specialized extensions instead of trying to "reinvent the wheel" in pure SQL.
*/

-- 1. PostGIS: The industry standard for Geospatial data
-- Installation: CREATE EXTENSION IF NOT EXISTS postgis;
-- Features: Distance calculations, geometry intersections, spatial indexing.

/*
CREATE TABLE user_locations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT,
    location GEOMETRY(Point, 4326) -- 4326 is WGS84 (GPS coordinates)
);

-- Find users within 5km of a point
SELECT username 
FROM user_locations 
WHERE ST_DWithin(location, ST_SetSRID(ST_Point(-122.33, 47.60), 4326), 5000);
*/

-- 2. pgvector: Vector similarity search for AI/ML
-- Installation: CREATE EXTENSION IF NOT EXISTS vector;
-- Features: Storing embeddings from OpenAI, Llama, etc., and performing L2 or Cosine distance search.

/*
CREATE TABLE products_v (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT,
    embedding VECTOR(1536) -- Match your model's dimensions
);

-- Semantic search: Find top 5 similar products using Cosine distance (<=>)
SELECT name 
FROM products_v 
ORDER BY embedding <=> '[0.12, 0.05, ...]' 
LIMIT 5;
*/

-- 3. TimescaleDB: Optimized for Time-Series
-- Installation: CREATE EXTENSION IF NOT EXISTS timescaledb;
-- Features: Hypertable's (automatic partitioning), continuous aggregates, and data compression.

/*
CREATE TABLE sensor_data (
    time TIMESTAMPTZ NOT NULL,
    sensor_id INT,
    temperature DOUBLE PRECISION
);

-- Convert to a hypertable
SELECT create_hypertable('sensor_data', 'time');

-- Fast time-bucketed aggregation
SELECT time_bucket('1 hour', time) AS bucket, avg(temperature)
FROM sensor_data
GROUP BY bucket;
*/

-- 4. pg_stat_statements: Query performance monitoring
-- Installation: 
-- 1. Add to postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
-- 2. Restart Postgres
-- 3. CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

/*
-- Find the top 5 most time-consuming queries in your database
SELECT 
    query, 
    calls, 
    total_exec_time / 1000 as total_seconds,
    mean_exec_time as avg_ms
FROM pg_stat_statements 
ORDER BY total_exec_time DESC 
LIMIT 5;
*/

-- 5. How to list installed extensions
SELECT name, default_version, installed_version, comment
FROM pg_available_extensions
WHERE installed_version IS NOT NULL;
