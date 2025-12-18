CREATE TABLE IF NOT EXISTS etl_log (
    log_id SERIAL PRIMARY KEY,
    log_dttm TIMESTAMP DEFAULT now(),
    message TEXT
);

CREATE OR REPLACE FUNCTION validate_client_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email !~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$' THEN
        INSERT INTO etl_log(message)
        VALUES ('Invalid email: ' || NEW.email);
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_email
BEFORE INSERT OR UPDATE ON clients
FOR EACH ROW
EXECUTE FUNCTION validate_client_email();
