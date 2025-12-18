CREATE TABLE IF NOT EXISTS clients_scd2 (
    client_sk SERIAL PRIMARY KEY,
    client_id INT,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    start_dttm TIMESTAMP,
    end_dttm TIMESTAMP,
    is_current BOOLEAN
);

CREATE OR REPLACE PROCEDURE load_clients_scd2()
LANGUAGE plpgsql
AS $$
BEGIN
    -- закрываем старые версии
    UPDATE clients_scd2 s
    SET end_dttm = now(),
        is_current = false
    FROM clients c
    WHERE s.client_id = c.id
      AND s.is_current = true
      AND (s.full_name, s.email, s.phone)
          IS DISTINCT FROM
          (c.full_name, c.email, c.phone);

    -- вставляем новые версии
    INSERT INTO clients_scd2 (
        client_id, full_name, email, phone,
        start_dttm, end_dttm, is_current
    )
    SELECT
        c.id,
        c.full_name,
        c.email,
        c.phone,
        now(),
        '9999-12-31',
        true
    FROM clients c
    LEFT JOIN clients_scd2 s
      ON s.client_id = c.id AND s.is_current = true
    WHERE s.client_id IS NULL
       OR (s.full_name, s.email, s.phone)
          IS DISTINCT FROM
          (c.full_name, c.email, c.phone);
END;
$$;
