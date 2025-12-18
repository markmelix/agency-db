import os
import random
import csv
from faker import Faker
from datetime import timedelta, date

fake = Faker("ru_RU")
random.seed(42)

N_CLIENTS = 1000
N_AGENTS = 50
N_PROPERTIES = 2000
N_VIEWINGS = 5000
N_DEALS = 1200

WITH_BAD_EMAILS = False

try:
    os.mkdir("csv")
except FileExistsError:
    pass

# clients
clients = []
for i in range(1, N_CLIENTS + 1):
    email = fake.email()
    if WITH_BAD_EMAILS and random.random() < 0.05:  # 5% плохих email
        email = "bad_email"

    clients.append([
        i,
        fake.name(),
        email,
        fake.phone_number()
    ])

with open("csv/clients.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["client_id", "full_name", "email", "phone"])
    writer.writerows(clients)

# agents
agents = []
for i in range(1, N_AGENTS + 1):
    agents.append([
        i,
        fake.name(),
        fake.date_between(start_date="-5y", end_date="today"),
        round(random.uniform(1, 5), 2)
    ])

with open("csv/agents.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["agent_id", "full_name", "hired_at", "commission_rate"])
    writer.writerows(agents)

# properties
properties = []
property_types = ["Квартира", "Дом", "Апартаменты", "Коммерческая"]
cities = ["Москва", "Санкт-Петербург", "Казань", "Екатеринбург"]

for i in range(1, N_PROPERTIES + 1):
    properties.append([
        i,
        random.choice(cities),
        random.randint(3_000_000, 30_000_000),
        random.choice(property_types)
    ])

with open("csv/properties.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["property_id", "city", "price", "property_type"])
    writer.writerows(properties)

# viewings
viewings = []
start_date = date(2022, 1, 1)

for i in range(1, N_VIEWINGS + 1):
    viewings.append([
        i,
        random.randint(1, N_CLIENTS),
        random.randint(1, N_AGENTS),
        random.randint(1, N_PROPERTIES),
        start_date + timedelta(days=random.randint(0, 700))
    ])

with open("csv/viewings.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "viewing_id", "client_id", "agent_id",
        "property_id", "viewing_date"
    ])
    writer.writerows(viewings)

# deals
deals = []
used_viewings = random.sample(viewings, N_DEALS)

for i, v in enumerate(used_viewings, start=1):
    deal_date = v[4] + timedelta(days=random.randint(1, 30))
    deals.append([
        i,
        v[1],  # client_id
        v[2],  # agent_id
        v[3],  # property_id
        deal_date,
        random.randint(3_000_000, 30_000_000)
    ])

with open("csv/deals.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "deal_id", "client_id", "agent_id",
        "property_id", "deal_date", "deal_price"
    ])
    writer.writerows(deals)

print("CSV файлы успешно сгенерированы")
