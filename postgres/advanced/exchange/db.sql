-- Clear between dumps

DROP SCHEMA IF EXISTS analytics CASCADE;
DROP SCHEMA IF EXISTS directory CASCADE;

SET client_min_messages TO WARNING;

DO
$$
    BEGIN
        DROP ROLE publishers;
    EXCEPTION
        WHEN undefined_object THEN null;
    END
$$;

DO
$$
    BEGIN
        DROP ROLE abc_open_data;
    EXCEPTION
        WHEN undefined_object THEN null;
    END
$$;

-- Ensure the owner/admin role exists locally. On Codecademy this role is
-- provided by the platform; here we create it so that ALTER ... OWNER TO
-- ccuser and the SET ROLE ccuser calls in script.sql resolve. Idempotent.
DO
$$
    BEGIN
        CREATE ROLE ccuser NOSUPERUSER;
    EXCEPTION
        WHEN duplicate_object THEN null;
    END
$$;

--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: ccuser
--

CREATE SCHEMA analytics;


ALTER SCHEMA analytics OWNER TO ccuser;

--
-- Name: directory; Type: SCHEMA; Schema: -; Owner: ccuser
--

CREATE SCHEMA directory;


ALTER SCHEMA directory OWNER TO ccuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: downloads; Type: TABLE; Schema: analytics; Owner: ccuser
--

CREATE TABLE analytics.downloads
(
    dataset_id         text,
    owner              text,
    download_timestamp timestamp without time zone
);


ALTER TABLE analytics.downloads
    OWNER TO ccuser;

--
-- Name: datasets; Type: TABLE; Schema: directory; Owner: ccuser
--

CREATE TABLE directory.datasets
(
    id            text,
    create_date   date,
    hosting_path  text,
    publisher     text,
    src_size      text,
    data_checksum text
);


ALTER TABLE directory.datasets
    OWNER TO ccuser;

--
-- Data for Name: downloads; Type: TABLE DATA; Schema: analytics; Owner: ccuser
--

INSERT INTO analytics.downloads (dataset_id, owner, download_timestamp) VALUES
    ('0c6e725a-a298-406e-b005-33fe631266c3', 'dataio', '2020-02-02 09:14:00'),
    ('de2ac3a6-adc1-4ba5-8ee6-a7e72a024dda', 'codecademy', '2020-02-07 14:01:00'),
    ('40052b4e-707a-4fd2-97bd-a60901e54853', 'abc_open_data', '2020-02-07 17:37:00'),
    ('a8a6540f-7224-46af-8954-36f26d50da32', 'dataio', '2020-02-07 20:00:00'),
    ('1e93a40e-9b25-4fe7-a47d-caea273c119d', 'abc_open_data', '2020-02-12 01:59:00'),
    ('2566b4bb-0298-4a39-ba0b-d90e279e953b', 'codecademy', '2020-02-12 13:11:00'),
    ('5f9c582f-c1c3-4bc5-af86-942e26a371bd', 'dataio', '2020-02-13 05:19:00'),
    ('9fc59433-d3f1-4878-89bc-21126da67a69', 'codecademy', '2020-02-14 11:26:00'),
    ('2b8b616e-a684-4ba4-8ea4-119206794f2a', 'abc_open_data', '2020-02-20 14:59:00'),
    ('b3bb619a-f76a-411e-8238-99c93c746ccb', 'xyz_industries', '2020-02-21 12:24:00'),
    ('2473a450-322c-43dc-8532-d647da5c5f2b', 'xyz_industries', '2020-02-24 08:36:00'),
    ('54574bc2-8815-4015-b55f-a159bb48ea6b', 'dataio', '2020-02-24 08:39:00'),
    ('0bd65fd0-94b7-429c-8ac3-5fabc2c25e71', 'abc_open_data', '2020-02-24 13:50:00'),
    ('2566b4bb-0298-4a39-ba0b-d90e279e953b', 'codecademy', '2020-02-28 19:07:00'),
    ('0bd65fd0-94b7-429c-8ac3-5fabc2c25e71', 'abc_open_data', '2020-03-01 15:21:00'),
    ('5f6baa32-723a-4823-ae05-7d3ff2b0db30', 'xyz_industries', '2020-03-02 16:03:00');


--
-- Data for Name: datasets; Type: TABLE DATA; Schema: directory; Owner: ccuser
--

INSERT INTO directory.datasets (id, create_date, hosting_path, publisher, src_size, data_checksum) VALUES
    ('6d9e44cf-46da-423a-a43a-48d969b321c5', '2020-01-03', 's3://this-bucket-dne/dataio/6d9e44cf-46da-423a-a43a-48d969b321c5.csv', 'dataio', '321 MB', '3403326f1ebf488188da6a8f24e6f897'),
    ('b0f5bdb9-2653-44c3-8d6c-997e8758eedc', '2020-01-30', 's3://this-bucket-dne/dataio/b0f5bdb9-2653-44c3-8d6c-997e8758eedc.csv', 'dataio', '49 MB', '9609103b9e484081a70acdd308baf1eb'),
    ('c2b315f3-7406-42f4-951e-a4fc58b2e927', '2020-01-02', 's3://this-bucket-dne/dataio/c2b315f3-7406-42f4-951e-a4fc58b2e927.csv', 'dataio', '480 MB', 'd3c82e7d3c92468b9d578b4f29d84041'),
    ('aba83a3c-2ee4-4ce7-bd44-d4fbf93180aa', '2020-01-20', 's3://this-bucket-dne/xyz_industries/aba83a3c-2ee4-4ce7-bd44-d4fbf93180aa.csv', 'xyz_industries', '140 MB', '4829d029a469476da2a3b19df7b29046'),
    ('6f370673-1de7-4623-a2b9-a3d944a745e3', '2020-01-02', 's3://this-bucket-dne/abc_open_data/6f370673-1de7-4623-a2b9-a3d944a745e3.csv', 'abc_open_data', '152 MB', '801ff254230843fb89dab5494640d311'),
    ('f0336fac-99f9-47d0-a1f1-e5320273de75', '2020-01-08', 's3://this-bucket-dne/codecademy/f0336fac-99f9-47d0-a1f1-e5320273de75.csv', 'codecademy', '332 MB', 'b4afdb17ce70464b9d6d6229de33f2c4'),
    ('a8f6118b-ff1e-4180-9b88-6f026ee43cbf', '2020-01-25', 's3://this-bucket-dne/abc_open_data/a8f6118b-ff1e-4180-9b88-6f026ee43cbf.csv', 'abc_open_data', '491 MB', 'bf32c7542e5142f5bacc3161ec17031b'),
    ('b87b3f05-e2a0-4478-9134-07c5f56a53c2', '2020-01-30', 's3://this-bucket-dne/xyz_industries/b87b3f05-e2a0-4478-9134-07c5f56a53c2.csv', 'xyz_industries', '119 MB', '83ab819578cd4fa5a627839893b58b6d'),
    ('56ce78c8-674d-4382-82d7-75b16b1591cb', '2020-01-03', 's3://this-bucket-dne/dataio/56ce78c8-674d-4382-82d7-75b16b1591cb.csv', 'dataio', '216 MB', '99481af1613945648d3369e9ee82f288'),
    ('58823a0e-fab4-4f77-a210-33707ca66284', '2020-01-20', 's3://this-bucket-dne/xyz_industries/58823a0e-fab4-4f77-a210-33707ca66284.csv', 'xyz_industries', '324 MB', 'a72cdcbd3aed4827a98546d4413c80a7'),
    ('2473a450-322c-43dc-8532-d647da5c5f2b', '2020-01-18', 's3://this-bucket-dne/xyz_industries/2473a450-322c-43dc-8532-d647da5c5f2b.csv', 'xyz_industries', '545 MB', 'ce448d45f16846b78ca0669436cea7e2'),
    ('0bd65fd0-94b7-429c-8ac3-5fabc2c25e71', '2020-01-02', 's3://this-bucket-dne/abc_open_data/0bd65fd0-94b7-429c-8ac3-5fabc2c25e71.csv', 'abc_open_data', '292 MB', '461d9935c0ce4b47965208193c2e12d1');


--
-- PostgreSQL database dump complete
--

