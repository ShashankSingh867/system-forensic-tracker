from db import get_connection

try:
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM Process")
    count = cur.fetchone()[0]
    print(f"Connected to MySQL! Process table has {count} rows.")
    conn.close()
except Exception as e:
    print("Connection failed:", e)