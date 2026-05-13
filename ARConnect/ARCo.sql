CREATE DATABASE myapp_db;
USE myapp_db;

-- Users
CREATE TABLE users (
    u_id        INT AUTO_INCREMENT PRIMARY KEY,
    u_num_id    VARCHAR(100) NOT NULL UNIQUE,
    u_first     VARCHAR(100) NOT NULL,
    u_middle    VARCHAR(100),
    u_last      VARCHAR(100) NOT NULL,
    u_suffix    VARCHAR(20),
    u_password  VARCHAR(255) NOT NULL,
    u_ms_id     VARCHAR(255) UNIQUE,           -- for Microsoft 365 login
    u_email     VARCHAR(255),
    u_role      ENUM('student', 'faculty', 'admin') DEFAULT 'student',
    u_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Feedback
CREATE TABLE feedback (
    f_id         INT AUTO_INCREMENT PRIMARY KEY,
    f_user_id    INT,                           -- FK to users
    f_name       VARCHAR(100) NOT NULL,
    f_email      VARCHAR(255),
    f_rate       TINYINT NOT NULL CHECK (f_rate BETWEEN 1 AND 5),
    f_message    TEXT NOT NULL,
    f_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (f_user_id) REFERENCES users(u_id) ON DELETE SET NULL
);

select * from feedback;

-- Chatbot logs
CREATE TABLE chatbot_logs (
    c_id         INT AUTO_INCREMENT PRIMARY KEY,
    c_user_id    INT,                           -- FK to users
    c_session    VARCHAR(255) NOT NULL,
    c_message    TEXT NOT NULL,                 -- user message
    c_response   TEXT NOT NULL,                 -- AI response
    c_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (c_user_id) REFERENCES users(u_id) ON DELETE SET NULL
);
select * from chatbot_logs;
-- Discussion room reservations
CREATE TABLE reserve_disc (
    r_id         INT AUTO_INCREMENT PRIMARY KEY,
    r_user_id    INT NOT NULL,                  -- FK to users
    r_room       VARCHAR(50) NOT NULL,
    r_date       DATE NOT NULL,
    r_time_start TIME NOT NULL,
    r_time_end   TIME NOT NULL,
    r_status     ENUM('pending', 'approved', 'cancelled') DEFAULT 'pending',
    r_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (r_user_id) REFERENCES users(u_id) ON DELETE CASCADE
);
select * from reserve_disc;
-- Book borrow queue
CREATE TABLE borrow_queue (
    q_id          INT AUTO_INCREMENT PRIMARY KEY,
    q_user_id     INT NOT NULL,
    q_ticket_no   VARCHAR(10) NOT NULL,
    q_status      ENUM('in queue', 'being served', 'done', 'cancelled') DEFAULT 'in queue',
    q_issued_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    q_served_at   TIMESTAMP NULL,
    FOREIGN KEY (q_user_id) REFERENCES users(u_id) ON DELETE CASCADE
);

select * from borrow_queue;