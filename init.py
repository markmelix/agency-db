from pathlib import Path
import psycopg


DB_CONFIG = {
    "dbname": "real_estate",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": 5432,
}

SQL_FILES_ORDER = [
    "ddl.sql",
    "index.sql",
    "scd2.sql",
    "trigger.sql",
]

BASE_PATH = "sql"

def run_sql_file(conn: psycopg.Connection, path: Path):
    print(f"Выполняется {path.name}")

    sql = path.read_text(encoding="utf-8")

    with conn.cursor() as cur:
        cur.execute(sql, prepare=False)

    print(f"{path.name} выполнен")


def main():
    base_dir = Path(__file__).parent

    with psycopg.connect(**DB_CONFIG) as conn:
        conn.autocommit = True

        for file_name in SQL_FILES_ORDER:
            path = base_dir / BASE_PATH / file_name

            if not path.exists():
                print(f"Файл {file_name} не найден — пропущен")
                continue

            run_sql_file(conn, path)

    print("Все SQL-скрипты выполнены")


if __name__ == "__main__":
    main()
