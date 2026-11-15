    USE forensic_tracker;

    -- Users
    INSERT INTO User (username, domain) VALUES
    ('alice', 'LOCAL'),
    ('bob',   'LOCAL'),
    ('SYSTEM','NT AUTHORITY');

    -- Processes
    INSERT INTO Process (pid, process_name, parent_pid, user_id, start_time, status) VALUES
    (1000, 'explorer.exe',  1,    1, NOW() - INTERVAL 10 MINUTE, 'running'),
    (1001, 'chrome.exe',    1000, 1, NOW() - INTERVAL 8  MINUTE, 'running'),
    (1002, 'notepad.exe',   1000, 2, NOW() - INTERVAL 5  MINUTE, 'running'),
    (1003, 'cmd.exe',       1000, 2, NOW() - INTERVAL 2  MINUTE, 'running'),
    (1004, 'powershell.exe',1003, 3, NOW() - INTERVAL 1  MINUTE, 'running');

    -- File events
    INSERT INTO File_Event (pid, user_id, file_path, event_type, timestamp) VALUES
    (1002, 2, 'C:/Users/bob/Documents/report.docx', 'create', NOW() - INTERVAL 4 MINUTE),
    (1002, 2, 'C:/Users/bob/Documents/report.docx', 'modify', NOW() - INTERVAL 3 MINUTE),
    (1004, 3, 'C:/Windows/System32/config/SAM',     'access', NOW() - INTERVAL 30 SECOND),
    (1003, 2, 'C:/Users/bob/temp.txt',              'delete', NOW() - INTERVAL 20 SECOND);

    -- Network events
    INSERT INTO Network_Event (pid, user_id, local_ip, remote_ip, local_port, remote_port, protocol) VALUES
    (1001, 1, '192.168.1.10', '142.250.190.46', 51000, 443, 'TCP'),
    (1004, 3, '192.168.1.10', '45.133.1.99',    51001, 8080,'TCP');

    -- Alerts (manual ones)
    INSERT INTO Alert (rule_name, severity, pid, description) VALUES
    ('Sensitive File Access', 'High',   1004, 'SYSTEM file accessed by powershell'),
    ('Suspicious Child Process','Medium',1003, 'cmd.exe spawned by user process');