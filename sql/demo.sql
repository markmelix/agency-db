-- Демонстрационный скрипт для защиты и сдачи проекта

-- 1. Просмотр первых 100 строк таблиц

SELECT * FROM clients LIMIT 100;
SELECT * FROM agents LIMIT 100;
SELECT * FROM properties LIMIT 100;
SELECT * FROM viewings LIMIT 100;
SELECT * FROM deals LIMIT 100;
SELECT * FROM clients_scd2 LIMIT 100;


-- 2. Подсчёт количества строк

SELECT COUNT(*) AS cnt_clients FROM clients;
SELECT COUNT(*) AS cnt_agents FROM agents;
SELECT COUNT(*) AS cnt_properties FROM properties;
SELECT COUNT(*) AS cnt_viewings FROM viewings;
SELECT COUNT(*) AS cnt_deals FROM deals;
SELECT COUNT(*) AS cnt_clients_scd2 FROM clients_scd2;


-- 3. Проверка триггера на валидацию email

-- Вставка валидного email (должна пройти)
INSERT INTO clients(id, full_name, email, phone)
VALUES (1002, 'Валидный Клиент', 'valid@example.com', '123456789');

-- Вставка невалидного email (должна вызвать ошибку)
INSERT INTO clients(full_name, email, phone)
VALUES ('Невалидный Клиент', 'invalid-email', '987654321');


-- 4. Демонстрация SCD2-загрузки

-- Загрузка новых данных
CALL load_clients_scd2();

-- Обновление клиента (закрываем старую версию и добавляем новую)
UPDATE clients
SET phone = '111222333'
WHERE email = 'valid@example.com';

CALL load_clients_scd2();

-- Проверка SCD2 таблицы
SELECT * FROM clients_scd2
WHERE client_id = (SELECT id FROM clients WHERE email = 'valid@example.com' LIMIT 1)
ORDER BY start_dttm;


-- 5. Аналитические запросы

-- Эффективность агентов (используется индекс idx_viewings_agent)
SELECT
    a.id,
    a.full_name,
    COUNT(DISTINCT d.id) AS deals_cnt,
    COUNT(DISTINCT v.id) AS viewings_cnt,
    ROUND(
        COUNT(DISTINCT d.id)::numeric /
        NULLIF(COUNT(DISTINCT v.id), 0), 2
    ) AS conversion_rate,
    AVG(d.deal_price) AS avg_check
FROM agents a
LEFT JOIN viewings v ON v.agent_id = a.id
LEFT JOIN deals d ON d.agent_id = a.id
GROUP BY a.id, a.full_name;

EXPLAIN ANALYZE
SELECT
    a.id,
    a.full_name,
    COUNT(DISTINCT d.id) AS deals_cnt,
    COUNT(DISTINCT v.id) AS viewings_cnt,
    ROUND(
        COUNT(DISTINCT d.id)::numeric /
        NULLIF(COUNT(DISTINCT v.id), 0), 2
    ) AS conversion_rate,
    AVG(d.deal_price) AS avg_check
FROM agents a
LEFT JOIN viewings v ON v.agent_id = a.id
LEFT JOIN deals d ON d.agent_id = a.id
GROUP BY a.id, a.full_name;

-- Клиенты с нетипично долгим циклом (оконные функции)
WITH stats AS (
    SELECT
        c.id AS client_id,
        COUNT(v.id) AS views_before_deal
    FROM clients c
    JOIN viewings v ON v.client_id = c.id
    JOIN deals d ON d.client_id = c.id
    WHERE v.viewing_date <= d.deal_date
    GROUP BY c.id
),
calc AS (
    SELECT *,
           AVG(views_before_deal) OVER () AS avg_views,
           STDDEV(views_before_deal) OVER () AS std_views
    FROM stats
)
SELECT *
FROM calc
WHERE views_before_deal > avg_views + 2 * std_views;

EXPLAIN ANALYZE
WITH stats AS (
    SELECT
        c.id AS client_id,
        COUNT(v.id) AS views_before_deal
    FROM clients c
    JOIN viewings v ON v.client_id = c.id
    JOIN deals d ON d.client_id = c.id
    WHERE v.viewing_date <= d.deal_date
    GROUP BY c.id
),
calc AS (
    SELECT *,
           AVG(views_before_deal) OVER () AS avg_views,
           STDDEV(views_before_deal) OVER () AS std_views
    FROM stats
)
SELECT *
FROM calc
WHERE views_before_deal > avg_views + 2 * std_views;
