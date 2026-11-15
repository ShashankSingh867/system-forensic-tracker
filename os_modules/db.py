import mysql.connector
from config import DB_CONFIG

def get_connection():
    return mysql.connector.connect(**DB_CONFIG)

def get_or_create_user(username, domain="LOCAL"):
    conn = get_connection(); cur = conn.cursor()
    cur.execute("SELECT user_id FROM User WHERE username=%s AND domain=%s", (username, domain))
    row = cur.fetchone()
    if row: uid = row[0]
    else:
        cur.execute("INSERT INTO User (username, domain) VALUES (%s,%s)", (username, domain))
        conn.commit(); uid = cur.lastrowid
    cur.close(); conn.close(); return uid

def parent_exists(parent_pid):
    if parent_pid is None: return False
    conn = get_connection(); cur = conn.cursor()
    cur.execute("SELECT 1 FROM Process WHERE pid=%s", (parent_pid,))
    exists = cur.fetchone() is not None
    cur.close(); conn.close(); return exists

def upsert_process(pid, name, ppid, user_id, start_time, status="running"):
    safe_ppid = ppid if parent_exists(ppid) else None
    conn = get_connection(); cur = conn.cursor()
    cur.execute("""
        INSERT INTO Process (pid, process_name, parent_pid, user_id, start_time, status)
        VALUES (%s,%s,%s,%s,%s,%s) ON DUPLICATE KEY UPDATE process_name=VALUES(process_name), status=VALUES(status)
    """, (pid, name, safe_ppid, user_id, start_time, status))
    conn.commit(); cur.close(); conn.close()

def insert_file_event(pid, user_id, file_path, event_type):
    conn = get_connection(); cur = conn.cursor()
    cur.execute("INSERT INTO File_Event (pid, user_id, file_path, event_type) VALUES (%s,%s,%s,%s)", (pid, user_id, file_path, event_type))
    conn.commit(); cur.close(); conn.close()