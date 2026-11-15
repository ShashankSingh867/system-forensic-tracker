DROP DATABASE IF EXISTS forensic_tracker;
CREATE DATABASE forensic_tracker;
USE forensic_tracker;

CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    domain VARCHAR(100) DEFAULT 'LOCAL',
    first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user (username, domain)
) ENGINE=InnoDB;

CREATE TABLE Process (
    pid INT PRIMARY KEY,
    process_name VARCHAR(255) NOT NULL,
    parent_pid INT DEFAULT NULL,
    user_id INT,
    start_time DATETIME,
    end_time DATETIME DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'running',
    CONSTRAINT fk_process_user FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_process_parent FOREIGN KEY (parent_pid) REFERENCES Process(pid) ON DELETE SET NULL,
    INDEX idx_process_name (process_name)
) ENGINE=InnoDB;

CREATE TABLE File_Event (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    pid INT,
    user_id INT,
    file_path VARCHAR(512) NOT NULL,
    event_type ENUM('create','modify','delete','access') NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_file_process FOREIGN KEY (pid) REFERENCES Process(pid) ON DELETE SET NULL,
    CONSTRAINT fk_file_user FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE SET NULL,
    INDEX idx_file_time (timestamp)
) ENGINE=InnoDB;

CREATE TABLE Network_Event (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    pid INT,
    user_id INT,
    local_ip VARCHAR(45),
    remote_ip VARCHAR(45),
    local_port INT,
    remote_port INT,
    protocol ENUM('TCP','UDP','OTHER') DEFAULT 'TCP',
    status VARCHAR(30) DEFAULT 'ESTABLISHED',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_net_process FOREIGN KEY (pid) REFERENCES Process(pid) ON DELETE SET NULL,
    CONSTRAINT fk_net_user FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE SET NULL,
    INDEX idx_net_time (timestamp)
) ENGINE=InnoDB;

CREATE TABLE Alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(150) NOT NULL,
    severity ENUM('Low','Medium','High') NOT NULL,
    pid INT,
    event_id INT,
    description TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_severity CHECK (severity IN ('Low','Medium','High')),
    CONSTRAINT fk_alert_process FOREIGN KEY (pid) REFERENCES Process(pid) ON DELETE SET NULL,
    INDEX idx_alert_time (timestamp)
) ENGINE=InnoDB;

CREATE OR REPLACE VIEW v_suspicious_timeline AS
SELECT a.timestamp AS event_time, a.severity, a.rule_name, p.process_name, u.username, a.description
FROM Alert a LEFT JOIN Process p ON a.pid = p.pid LEFT JOIN User u ON p.user_id = u.user_id
ORDER BY a.timestamp DESC;

DELIMITER //
CREATE TRIGGER trg_network_alert
AFTER INSERT ON Network_Event
FOR EACH ROW
BEGIN
    IF NEW.remote_ip NOT LIKE '127.%' AND NEW.remote_ip NOT LIKE '192.168.%' AND NEW.remote_ip NOT LIKE '10.%' AND NEW.remote_ip IS NOT NULL THEN
        INSERT INTO Alert (rule_name, severity, pid, event_id, description)
        VALUES ('External Network Connection', 'High', NEW.pid, NEW.event_id, CONCAT('Process connected to external IP ', NEW.remote_ip));
    END IF;
END//
DELIMITER ;

-- DBMS Phase 3: Threat Engine and Blacklist Logic Added

-- CREATE TABLE IF NOT EXISTS Blacklist (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     malicious_ip VARCHAR(45) NOT NULL,
--     threat_name VARCHAR(100)
-- );

-- CREATE INDEX idx_remote_ip ON Network_Event(remote_ip);


-- DBMS Update: Modified Alert severity ENUM to include 'Critical'
-- ALTER TABLE Alert MODIFY COLUMN severity ENUM('Low','Medium','High','Critical') NOT NULL;