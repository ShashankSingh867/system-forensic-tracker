"""
OS Concept: Process Management, PCB (PID, PPID, state, owner)
Collects running processes and stores them in MySQL.
"""
import psutil, time, datetime
from db import get_or_create_user, upsert_process

def collect_processes():
    print("[+] Process Collector started...")
    while True:
        for proc in psutil.process_iter(['pid','name','ppid','username','create_time','status']):
            try:
                info = proc.info
                username = (info['username'] or 'unknown').split('\\')[-1]
                uid = get_or_create_user(username)
                start = datetime.datetime.fromtimestamp(info['create_time']) \
                        if info['create_time'] else datetime.datetime.now()
                upsert_process(
                    pid=info['pid'],
                    name=info['name'] or 'unknown',
                    ppid=info['ppid'],
                    user_id=uid,
                    start_time=start,
                    status=info['status'] or 'running'
                )
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
        print(f"[+] Snapshot saved at {datetime.datetime.now()}")
        time.sleep(5) 

if __name__ == "__main__":
    collect_processes()