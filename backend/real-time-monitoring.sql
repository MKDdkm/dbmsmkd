-- 🔍 REAL-TIME MONITORING QUERIES FOR MYSQL WORKBENCH
-- Use these to watch data being added from your frontend

USE dbms_feedback_system;

-- ===================================
-- 📈 REAL-TIME DATA MONITORING
-- ===================================

-- 1. Latest feedback (run this after frontend submission)
SELECT 
    'LATEST FEEDBACK' AS data_type,
    fb.comment,
    fb.sentiment,
    fb.createdAt,
    s.name AS student_name,
    f.name AS faculty_name
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id  
JOIN Faculty f ON fb.facultyId = f.id
ORDER BY fb.createdAt DESC
LIMIT 5;

-- 2. Latest student registrations
SELECT 
    'LATEST STUDENTS' AS data_type,
    name,
    usn,
    email,
    semester,
    branch
FROM Student
ORDER BY id DESC
LIMIT 5;

-- 3. Today's activity (feedback submitted today)
SELECT 
    DATE(fb.createdAt) AS feedback_date,
    COUNT(*) AS feedback_count,
    s.name AS student_name,
    f.name AS faculty_name,
    fb.comment
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id
JOIN Faculty f ON fb.facultyId = f.id  
WHERE DATE(fb.createdAt) = CURDATE()
ORDER BY fb.createdAt DESC;

-- 4. Count changes (run before and after frontend actions)
SELECT 
    'CURRENT COUNTS' AS status,
    (SELECT COUNT(*) FROM Student) AS total_students,
    (SELECT COUNT(*) FROM Faculty) AS total_faculty,
    (SELECT COUNT(*) FROM Feedback) AS total_feedback,
    NOW() AS checked_at;

-- 5. Watch for new data (refresh this query)
SELECT 
    'DATA FRESHNESS' AS check_type,
    MAX(createdAt) AS latest_feedback,
    TIMESTAMPDIFF(SECOND, MAX(createdAt), NOW()) AS seconds_ago
FROM Feedback
HAVING latest_feedback IS NOT NULL;

-- ===================================
-- 🔄 AUTO-REFRESH MONITORING
-- ===================================

-- 6. Live feedback stream (refresh every few seconds)
SELECT 
    fb.createdAt AS time_submitted,
    CONCAT(s.name, ' (', s.usn, ')') AS student,
    f.name AS faculty,
    SUBSTRING(fb.comment, 1, 50) AS comment_preview,
    JSON_EXTRACT(fb.ratings, '$.teaching') AS teaching_rating
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id
JOIN Faculty f ON fb.facultyId = f.id
WHERE fb.createdAt >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY fb.createdAt DESC;

-- 7. Database activity log
SELECT 
    table_name,
    CASE 
        WHEN table_name = 'Student' THEN (SELECT COUNT(*) FROM Student)
        WHEN table_name = 'Faculty' THEN (SELECT COUNT(*) FROM Faculty)
        WHEN table_name = 'Feedback' THEN (SELECT COUNT(*) FROM Feedback)
    END AS current_count,
    NOW() AS snapshot_time
FROM information_schema.tables 
WHERE table_schema = 'dbms_feedback_system' 
AND table_name IN ('Student', 'Faculty', 'Feedback');

-- ===================================
-- 🧪 TESTING QUERIES  
-- ===================================

-- 8. Verify specific frontend submission
-- Replace 'test_comment' with actual comment from your frontend
SELECT * FROM Feedback 
WHERE comment LIKE '%test%' 
OR comment LIKE '%frontend%'
ORDER BY createdAt DESC;

-- 9. Check if data arrived (modify USN/email as needed)
SELECT * FROM Student 
WHERE usn = '4SC21CS005' 
OR email LIKE '%test%';

-- 10. Monitor ratings data structure
SELECT 
    id,
    comment,
    ratings,
    JSON_EXTRACT(ratings, '$.teaching') AS teaching,
    JSON_EXTRACT(ratings, '$.communication') AS communication,
    JSON_EXTRACT(ratings, '$.knowledge') AS knowledge,
    JSON_EXTRACT(ratings, '$.availability') AS availability
FROM Feedback
ORDER BY createdAt DESC
LIMIT 3;

-- ===================================
-- 💡 USAGE INSTRUCTIONS
-- ===================================
/*
HOW TO MONITOR FRONTEND DATA:

1. Keep MySQL Workbench open
2. Submit data from your React frontend  
3. Immediately run query #1 or #6
4. You should see your new data instantly!
5. Use query #4 to compare before/after counts
6. Query #3 shows today's activity

REFRESH TIPS:
- Press F5 or Ctrl+Shift+R to re-run queries
- Use query #5 to see how fresh your data is
- Query #6 auto-shows recent submissions
*/