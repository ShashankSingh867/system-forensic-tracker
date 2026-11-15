from flask import Flask, jsonify
from flask_cors import CORS
import mysql.connector
from datetime import datetime

app = Flask(__name__)
CORS(app)


DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "shashank282206@", 
    "database": "forensic_tracker"
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

@app.route('/api')
def get_everything():
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        
        cur.execute("""
            SELECT p.pid, p.process_name, p.parent_pid, u.username, p.start_time, p.status 
            FROM Process p LEFT JOIN User u ON p.user_id = u.user_id 
            ORDER BY p.start_time DESC LIMIT 300
        """)
        processes = cur.fetchall()
        
    
        cur.execute("SELECT * FROM File_Event ORDER BY timestamp DESC LIMIT 100")
        files = cur.fetchall()
        
        
        cur.execute("SELECT * FROM Network_Event ORDER BY timestamp DESC LIMIT 100")
        network = cur.fetchall()
        

        cur.execute("SELECT * FROM Alert ORDER BY timestamp DESC LIMIT 100")
        alerts = cur.fetchall()
        
        
        cur.execute("SELECT * FROM v_suspicious_timeline LIMIT 100")
        timeline = cur.fetchall()
        
        cur.close()
        conn.close()
        
        def serialize(data):
            return [{k: str(v) if isinstance(v, datetime) else v for k, v in row.items()} for row in data]

        return jsonify({
            "processes": serialize(processes),
            "file_events": serialize(files),
            "network_events": serialize(network),
            "alerts": serialize(alerts),
            "timeline": serialize(timeline)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    print("[+] Flask Backend running safely on http://localhost:5000")
    app.run(debug=True, port=5000)