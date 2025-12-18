CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    created_at TIMESTAMP DEFAULT now()
);

CREATE TABLE IF NOT EXISTS agents (
    id SERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    hired_at DATE NOT NULL,
    commission_rate NUMERIC(5,2)
);

CREATE TABLE IF NOT EXISTS properties (
    id SERIAL PRIMARY KEY,
    city TEXT,
    price NUMERIC(12,2),
    property_type TEXT
);

CREATE TABLE IF NOT EXISTS viewings (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),
    agent_id INT REFERENCES agents(id),
    property_id INT REFERENCES properties(id),
    viewing_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS deals (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(id),
    agent_id INT REFERENCES agents(id),
    property_id INT REFERENCES properties(id),
    deal_date DATE,
    deal_price NUMERIC(12,2)
);
