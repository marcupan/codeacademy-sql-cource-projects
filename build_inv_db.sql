-- Create the `manufacturers` table
CREATE TABLE manufacturers (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Create the `parts` table
CREATE TABLE parts (
    id              SERIAL PRIMARY KEY,
    description     TEXT               NOT NULL,
    code            VARCHAR(50) UNIQUE NOT NULL,
    manufacturer_id INT                NOT NULL REFERENCES manufacturers (id)
);

-- Create the `reorder_options` table
CREATE TABLE reorder_options (
    id        SERIAL PRIMARY KEY,
    part_id   INT            NOT NULL REFERENCES parts (id),
    quantity  INT            NOT NULL CHECK (quantity > 0),
    price_usd NUMERIC(10, 2) NOT NULL CHECK (price_usd > 0 AND price_usd / quantity BETWEEN 0.02 AND 25.00)
);

-- Create the `locations` table
CREATE TABLE locations (
    id       SERIAL PRIMARY KEY,
    part_id  INT         NOT NULL REFERENCES parts (id),
    location VARCHAR(50) NOT NULL,
    qty      INT         NOT NULL CHECK (qty > 0),
    UNIQUE (part_id, location)
);

-- Insert mock data into `manufacturers`
INSERT INTO manufacturers (id, name)
VALUES
    (1, 'Pip Industrial'),
    (2, 'NNC Manufacturing'),
    (3, 'Capacitor Corp');

-- Insert mock data into `parts`
INSERT INTO parts (description, code, manufacturer_id)
VALUES
    ('5V resistor', 'R5-001', 1),
    ('3V resistor', 'R3-002', 2),
    ('Capacitor 10uF', 'C10-003', 3);

-- Add the missing manufacturer (id = 9)
INSERT INTO manufacturers (id, name)
VALUES (9, 'Unknown Manufacturer');

-- Insert the new part referencing the manufacturer (id = 9)
INSERT INTO parts (id, description, code, manufacturer_id)
VALUES (54, 'New Part Description', 'V1-009', 9);

-- Add a NOT NULL constraint to ensure description in `parts` is filled
ALTER TABLE parts
    ALTER COLUMN description SET NOT NULL;

-- Ensure all rows have valid descriptions
UPDATE parts
SET description = 'No Description Available'
WHERE description IS NULL
   OR LENGTH(description) <= 1;

-- Insert mock data into `reorder_options`
INSERT INTO reorder_options (part_id, quantity, price_usd)
VALUES
    (1, 100, 15.00),
    (2, 200, 30.00),
    (3, 50, 10.00);

-- Insert mock data into `locations`
INSERT INTO locations (part_id, location, qty)
VALUES
    (1, 'Shelf A1', 10),
    (2, 'Shelf B2', 20),
    (3, 'Shelf C3', 5);

-- Add a unique constraint to `locations` for part_id and location
ALTER TABLE locations
    ADD UNIQUE (part_id, location);

-- Add a new merged manufacturer
INSERT INTO manufacturers (id, name)
VALUES (11, 'Pip-NNC Industrial');

-- Update parts to reference the new manufacturer
UPDATE parts
SET manufacturer_id = 11
WHERE manufacturer_id IN (1, 2);

-- Ensure only valid parts are referenced in `locations`
ALTER TABLE locations
    ADD FOREIGN KEY (part_id) REFERENCES parts (id);

-- Add a foreign key to ensure all parts have valid manufacturers
ALTER TABLE parts
    ADD FOREIGN KEY (manufacturer_id) REFERENCES manufacturers (id);

-- Ensure valid part IDs in `reorder_options`
ALTER TABLE reorder_options
    ADD FOREIGN KEY (part_id) REFERENCES parts (id);

-- Ensure price per unit constraints in `reorder_options`
ALTER TABLE reorder_options
    ADD CHECK (price_usd / quantity >= 0.02 AND price_usd / quantity <= 25.00);

-- Ensure positive quantities in `reorder_options`
ALTER TABLE reorder_options
    ADD CHECK (quantity > 0 AND price_usd > 0);

-- Add a constraint to ensure positive `qty` in `locations`
ALTER TABLE locations
    ADD CHECK (qty > 0);

-- Select data to verify the schema
SELECT *
FROM manufacturers
ORDER BY id;
SELECT *
FROM parts
ORDER BY id;
SELECT *
FROM reorder_options
ORDER BY id;
SELECT *
FROM locations
ORDER BY id;
