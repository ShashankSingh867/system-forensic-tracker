USE forensic_tracker;


SELECT p.pid, p.process_name, p.parent_pid, u.username, p.start_time, p.status
FROM Process p
LEFT JOIN User u ON p.user_id = u.user_id
ORDER BY p.start_time DESC;


SELECT
    p.pid,
    p.process_name,
    f.file_path,
    f.event_type,
    f.timestamp AS file_time,
    n.remote_ip,
    n.remote_port,
    n.timestamp AS net_time
FROM Process p
LEFT JOIN File_Event    f ON f.pid = p.pid
LEFT JOIN Network_Event n ON n.pid = p.pid
WHERE p.pid = 1004;


SELECT * FROM Alert WHERE severity = 'High' ORDER BY timestamp DESC;


SELECT p.pid, p.process_name,
       COUNT(DISTINCT f.event_id) AS file_events,
       COUNT(DISTINCT n.event_id) AS net_events
FROM Process p
LEFT JOIN File_Event    f ON f.pid = p.pid
LEFT JOIN Network_Event n ON n.pid = p.pid
GROUP BY p.pid, p.process_name
ORDER BY file_events DESC;


SELECT * FROM v_suspicious_timeline;