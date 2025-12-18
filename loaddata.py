import subprocess
from pathlib import Path
import psycopg

# Настройки
CONTAINER_NAME = "real_estate_pg"
DB_NAME = "real_estate"
DB_USER = "postgres"
DB_PASSWORD = "postgres"
DB_HOST = "localhost"
DB_PORT = 5432
CSV_DIR = Path("./csv")

TABLES = ["clients", "agents", "properties", "viewings", "deals"]

# Колонки для COPY (не включаем поля с DEFAULT)
COPY_COLUMNS = {
    'clients': 'id, full_name, email, phone',
    'agents': 'id, full_name, hired_at, commission_rate',
    'properties': 'id, city, price, property_type',
    'viewings': 'id, client_id, agent_id, property_id, viewing_date',
    'deals': 'id, client_id, agent_id, property_id, deal_date, deal_price'
}

CONTAINER_PATH = "/"

def copy_csv_to_container(csv_file: Path):
    print(f"{csv_file.name} копируется в Docker контейнер...")
    subprocess.run(
        ["docker", "cp", str(csv_file), f"{CONTAINER_NAME}:{CONTAINER_PATH}{csv_file.name}"],
        check=True
    )
    print(f"{csv_file.name} скопирован")

def copy_to_postgres(conn, table, csv_file_path):
    with conn.cursor() as cur:
        sql = f"""
        COPY {table}({COPY_COLUMNS[table]})
        FROM '{csv_file_path}'
        WITH (FORMAT csv, HEADER true)
        """
        cur.execute(sql)
    conn.commit()
    print(f"Данные из {csv_file_path} загружены в {table}")

def main():
    # Копируем CSV в контейнер
    for table in TABLES:
        csv_file = CSV_DIR / f"{table}.csv"
        copy_csv_to_container(csv_file)

    # Подключаемся к Postgres
    print("Подключение к Postgres...")
    conn = psycopg.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )

    # Загружаем данные через COPY
    print("Загрузка данных через COPY...")
    for table in TABLES:
        csv_file_path = f"{CONTAINER_PATH}{table}.csv"
        copy_to_postgres(conn, table, csv_file_path)

    conn.close()
    print("Готово! Все данные загружены.")

if __name__ == "__main__":
    main()
