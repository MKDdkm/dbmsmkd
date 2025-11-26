-- 📊 MySQL Workbench Queries for DBMS Feedback System
-- Copy and paste these queries in MySQL Workbench to explore your database

-- 🔗 First, connect to your database
USE dbms_feedback_system;

-- ===================================
-- 🔍 BASIC DATA EXPLORATION QUERIES
-- ===================================

-- 1. Show all tables in the database
SHOW TABLES;

-- 2. View database structure
DESCRIBE Student;
DESCRIBE Faculty;
DESCRIBE Feedback;

-- 3. Count records in each table
SELECT 'Students' as Table_Name, COUNT(*) as Record_Count FROM Student
UNION ALL
SELECT 'Faculty' as Table_Name, COUNT(*) as Record_Count FROM Faculty
UNION ALL
SELECT 'Feedback' as Table_Name, COUNT(*) as Record_Count FROM Feedback;

-- ===================================
-- 👥 STUDENT QUERIES
-- ===================================

-- 4. View all students
SELECT * FROM Student;

-- 5. Students by semester
SELECT semester, COUNT(*) as student_count 
FROM Student 
GROUP BY semester 
ORDER BY semester;

-- 6. Students by branch
SELECT branch, COUNT(*) as student_count 
FROM Student 
GROUP BY branch;

-- 7. Find specific student by USN
SELECT * FROM Student WHERE usn = '4SC21CS001';

-- 8. Search students by name pattern
SELECT * FROM Student WHERE name LIKE 'M%';

-- ===================================
-- 👩‍🏫 FACULTY QUERIES
-- ===================================

-- 9. View all faculty
SELECT * FROM Faculty;

-- 10. Faculty by branch
SELECT branch, COUNT(*) as faculty_count 
FROM Faculty 
GROUP BY branch;

-- 11. Faculty with emails containing 'scem'
SELECT name, email FROM Faculty WHERE email LIKE '%scem%';

-- ===================================
-- 💬 FEEDBACK QUERIES
-- ===================================

-- 12. View all feedback (will be empty initially)
SELECT * FROM Feedback;

-- 13. Insert sample feedback (run this to add test data)
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment, createdAt) 
VALUES 
(
    'feedback_001', 
    (SELECT id FROM Student WHERE usn = '4SC21CS001' LIMIT 1),
    (SELECT id FROM Faculty WHERE email = 'vidya@scem.ac.in' LIMIT 1),
    'Excellent teaching methodology and very helpful during doubt sessions.',
    '{"teaching": 5, "communication": 5, "knowledge": 5, "availability": 4}',
    'positive',
    NOW()
),
(
    'feedback_002',
    (SELECT id FROM Student WHERE usn = '4SC21CS002' LIMIT 1),
    (SELECT id FROM Faculty WHERE email = 'ashwini@scem.ac.in' LIMIT 1),
    'Good explanations but could improve interaction with students.',
    '{"teaching": 4, "communication": 3, "knowledge": 5, "availability": 3}',
    'neutral',
    NOW()
),
(
    'feedback_003',
    (SELECT id FROM Student WHERE usn = '4SC21CS003' LIMIT 1),
    (SELECT id FROM Faculty WHERE email = 'vidya@scem.ac.in' LIMIT 1),
    'Amazing teacher! Makes complex concepts easy to understand.',
    '{"teaching": 5, "communication": 5, "knowledge": 5, "availability": 5}',
    'positive',
    NOW()
);

-- 14. View feedback with student and faculty names
SELECT 
    s.name AS student_name,
    s.usn AS student_usn,
    f.name AS faculty_name,
    fb.comment,
    fb.sentiment,
    fb.createdAt
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id
JOIN Faculty f ON fb.facultyId = f.id
ORDER BY fb.createdAt DESC;

-- 15. Feedback statistics by faculty
SELECT 
    f.name AS faculty_name,
    COUNT(fb.id) AS total_feedback,
    AVG(JSON_EXTRACT(fb.ratings, '$.teaching')) AS avg_teaching_rating,
    AVG(JSON_EXTRACT(fb.ratings, '$.communication')) AS avg_communication_rating,
    AVG(JSON_EXTRACT(fb.ratings, '$.knowledge')) AS avg_knowledge_rating,
    AVG(JSON_EXTRACT(fb.ratings, '$.availability')) AS avg_availability_rating
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
GROUP BY f.id, f.name;

-- 16. Sentiment analysis
SELECT 
    sentiment,
    COUNT(*) as count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Feedback)), 2) as percentage
FROM Feedback 
GROUP BY sentiment;

-- ===================================
-- 🔍 ADVANCED QUERIES
-- ===================================

-- 17. Top rated faculty (after adding feedback)
SELECT 
    f.name AS faculty_name,
    f.branch,
    COUNT(fb.id) AS feedback_count,
    ROUND(AVG(
        (JSON_EXTRACT(fb.ratings, '$.teaching') + 
         JSON_EXTRACT(fb.ratings, '$.communication') + 
         JSON_EXTRACT(fb.ratings, '$.knowledge') + 
         JSON_EXTRACT(fb.ratings, '$.availability')) / 4
    ), 2) AS overall_avg_rating
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
GROUP BY f.id, f.name, f.branch
HAVING feedback_count > 0
ORDER BY overall_avg_rating DESC;

-- 18. Students who haven't given feedback
SELECT s.name, s.usn, s.email
FROM Student s
LEFT JOIN Feedback fb ON s.id = fb.studentId
WHERE fb.id IS NULL;

-- 19. Faculty with no feedback
SELECT f.name, f.email, f.branch
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
WHERE fb.id IS NULL;

-- 20. Recent feedback (last 7 days)
SELECT 
    s.name AS student_name,
    f.name AS faculty_name,
    fb.comment,
    fb.sentiment,
    fb.createdAt
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id
JOIN Faculty f ON fb.facultyId = f.id
WHERE fb.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY fb.createdAt DESC;

-- ===================================
-- 🔧 DATABASE MAINTENANCE QUERIES
-- ===================================

-- 21. Check database size
SELECT 
    table_name AS 'Table',
    round(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'dbms_feedback_system';

-- 22. Show indexes on tables
SHOW INDEX FROM Student;
SHOW INDEX FROM Faculty;
SHOW INDEX FROM Feedback;

-- 23. Backup commands (run these if needed)
-- mysqldump -u root -p dbms_feedback_system > backup.sql

-- 24. Show current database connections
SHOW PROCESSLIST;

-- ===================================
-- 📈 REPORTING QUERIES
-- ===================================

-- 25. Monthly feedback summary
SELECT 
    DATE_FORMAT(createdAt, '%Y-%m') AS month,
    COUNT(*) AS feedback_count,
    AVG(JSON_EXTRACT(ratings, '$.teaching')) AS avg_teaching
FROM Feedback
GROUP BY DATE_FORMAT(createdAt, '%Y-%m')
ORDER BY month;

-- 26. Branch-wise feedback analysis
SELECT 
    f.branch,
    COUNT(fb.id) AS total_feedback,
    ROUND(AVG(JSON_EXTRACT(fb.ratings, '$.teaching')), 2) AS avg_teaching_rating
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
GROUP BY f.branch;

-- ===================================
-- 🎯 QUICK TESTS
-- ===================================

-- 27. Test login credentials
SELECT 'STUDENT LOGIN TEST' AS test_type;
SELECT name, email, usn FROM Student WHERE email = 'mourya@student.scem';

SELECT 'FACULTY LOGIN TEST' AS test_type;
SELECT name, email, branch FROM Faculty WHERE email = 'vidya@scem.ac.in';

-- 28. Verify data integrity
SELECT 'DATA INTEGRITY CHECK' AS test_type;
SELECT 
    (SELECT COUNT(*) FROM Student) AS total_students,
    (SELECT COUNT(*) FROM Faculty) AS total_faculty,
    (SELECT COUNT(*) FROM Feedback) AS total_feedback;

-- 29. Clear all feedback (DANGER - only for testing)
-- DELETE FROM Feedback; -- Uncomment only if you want to clear feedback data

-- 30. Reset auto-increment (if needed)
-- ALTER TABLE Feedback AUTO_INCREMENT = 1;