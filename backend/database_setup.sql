-- Database Setup Script for MySQL Workbench
-- Run these commands in MySQL Workbench to set up your database

-- 1. Create the database
CREATE DATABASE IF NOT EXISTS dbms_feedback_system;

-- 2. Use the database
USE dbms_feedback_system;

-- 3. Create a dedicated user for the application (optional but recommended)
CREATE USER IF NOT EXISTS 'dbms_user'@'localhost' IDENTIFIED BY 'dbms_password123';

-- 4. Grant privileges to the user
GRANT ALL PRIVILEGES ON dbms_feedback_system.* TO 'dbms_user'@'localhost';

-- 5. Flush privileges
FLUSH PRIVILEGES;

-- 6. Show databases to confirm creation
SHOW DATABASES;

-- Note: The actual tables will be created by Prisma migrations
-- This script only sets up the database and user