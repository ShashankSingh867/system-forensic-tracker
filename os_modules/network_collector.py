import subprocess
import time
import datetime
from db import get_connection

def collect_network():
    print("[+] Network Collector started (Using Windows netstat)...")
    while True:
        try:
            conn = get_connection()
            cur = conn.cursor()
            count = 0

            
            output = subprocess.check_output(['netstat', '-ano'], text=True, encoding='utf-8', errors='ignore')
            
            for line in output.split('\n'):
                parts = line.strip().split()
                if len(parts) >= 5 and parts[0] == 'TCP':
                    try:
                        local_addr = parts[1]
                        remote_addr = parts[2]
                        state = parts[3]
                        pid = int(parts[4])

                       
                        if state == 'LISTENING' or remote_addr.startswith('0.0.0.0') or remote_addr.startswith('[::]'):
                            continue

                        local_ip, local_port = local_addr.rsplit(':', 1)
                        remote_ip, remote_port = remote_addr.rsplit(':', 1)

                        local_ip = local_ip.replace('[', '').replace(']', '')
                        remote_ip = remote_ip.replace('[', '').replace(']', '')

                      
                        cur.execute("""
                            INSERT INTO Network_Event 
                            (pid, local_ip, remote_ip, local_port, remote_port, protocol, status)
                            VALUES (%s, %s, %s, %s, %s, %s, %s)
                        """, (pid, local_ip, int(local_port), remote_ip, int(remote_port), 'TCP', state))
                        count += 1
                    except Exception:
                        continue
            
            conn.commit()
            cur.close()
            conn.close()
            print(f"[+] Saved {count} live network connections at {datetime.datetime.now()}")
            
        except Exception as e:
            print(f"[!] Error: {e}")
            
        time.sleep(3)  

if __name__ == "__main__":
    collect_network()