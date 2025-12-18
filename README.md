## Сервис подбора недвижимости (агентство)

Таблицы: clients, agents, properties, viewings (просмотры), deals.

Аналитические запросы:

1. Эффективность агентов: количество сделок, конверсия просмотров в сделки, средний чек.

2. Для клиентов — количество просмотров до сделки, выявить клиентов с нетипично долгим циклом.

### Схемы

Концептуальная модель:

![erd](./erdplus.png)

Логическая модель:

```mermaid
erDiagram
    clients {
        int id PK
        text full_name "not null"
        text email "unique"
        text phone
        timestamp created_at "default now()"
    }

    agents {
        int id PK
        text full_name "not null"
        date hired_at "not null"
        numeric commission_rate
    }

    properties {
        int id PK
        text city
        numeric price
        text property_type
    }

    viewings {
        int id PK
        int client_id FK "not null"
        int agent_id FK "not null"
        int property_id FK "not null"
        date viewing_date "not null"
    }

    deals {
        int id PK
        int client_id FK "not null"
        int agent_id FK "not null"
        int property_id FK "not null"
        date deal_date
        numeric deal_price
    }

    clients ||--o{ viewings : "made_viewings"
    agents ||--o{ viewings : "conducted_viewings"
    properties ||--o{ viewings : "viewed_properties"

    clients ||--o{ deals : "made_deals"
    agents ||--o{ deals : "closed_deals"
    properties ||--o{ deals : "sold_properties"
```
