	create database sparkdb;

create table USERS (
id int primary key auto_increment,
email  VARCHAR(100) NOT NULL UNIQUE,
f_name VARCHAR(255) NOT NULL,
m_name VARCHAR(255) NULL,
l_name VARCHAR(255) NOT NULL,
suffix VARCHAR(255) NULL,
occupation VARCHAR(255),
password VARCHAR(255) NOT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);