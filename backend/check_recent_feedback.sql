-- SQL Queries to Check Recent Feedback in DBMS Feedback System

-- 1. Get all recent feedback (last 7 days)
SELECT 
    f.id,
    f.comment,
    f.ratings,
    f.sentiment,
    f.createdAt,
    s.name as student_name,
    s.usn as student_usn,
    s.semester,
    s.branch,
    fac.name as faculty_name,
    fac.branch as faculty_department
FROM Feedback f
JOIN Student s ON f.studentId = s.id
JOIN Faculty fac ON f.facultyId = fac.id
WHERE f.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY f.createdAt DESC;

-- 2. Get recent feedback with ratings breakdown
SELECT 
    f.id,
    f.comment,
    JSON_EXTRACT(f.ratings, '$.communication') as communication_rating,
    JSON_EXTRACT(f.ratings, '$.clarity') as clarity_rating,
    JSON_EXTRACT(f.ratings, '$.knowledge') as knowledge_rating,
    JSON_EXTRACT(f.ratings, '$.punctuality') as punctuality_rating,
    JSON_EXTRACT(f.ratings, '$.behavior') as behavior_rating,
    f.sentiment,
    f.createdAt,
    s.name as student_name,
    fac.name as faculty_name
FROM Feedback f
JOIN Student s ON f.studentId = s.id
JOIN Faculty fac ON f.facultyId = fac.id
WHERE f.createdAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY f.createdAt DESC;

-- 3. Count feedback by faculty (recent)
SELECT 
    fac.name as faculty_name,
    fac.branch as department,
    COUNT(f.id) as feedback_count,
    AVG(JSON_EXTRACT(f.ratings, '$.communication')) as avg_communication,
    AVG(JSON_EXTRACT(f.ratings, '$.clarity')) as avg_clarity,
    AVG(JSON_EXTRACT(f.ratings, '$.knowledge')) as avg_knowledge,
    MAX(f.createdAt) as latest_feedback
FROM Faculty fac
LEFT JOIN Feedback f ON fac.id = f.facultyId 
    AND f.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY fac.id, fac.name, fac.branch
ORDER BY feedback_count DESC, latest_feedback DESC;

-- 4. Get feedback with semester/subject information (extracted from comment)
SELECT 
    f.id,
    s.name as student_name,
    s.semester as student_semester,
    fac.name as faculty_name,
    f.comment,
    -- Extract semester from comment
    CASE 
        WHEN f.comment LIKE '%Semester: 1%' THEN '1st Semester'
        WHEN f.comment LIKE '%Semester: 2%' THEN '2nd Semester'
        WHEN f.comment LIKE '%Semester: 3%' THEN '3rd Semester'
        WHEN f.comment LIKE '%Semester: 4%' THEN '4th Semester'
        WHEN f.comment LIKE '%Semester: 5%' THEN '5th Semester'
        WHEN f.comment LIKE '%Semester: 6%' THEN '6th Semester'
        WHEN f.comment LIKE '%Semester: 7%' THEN '7th Semester'
        WHEN f.comment LIKE '%Semester: 8%' THEN '8th Semester'
        ELSE 'Not Specified'
    END as feedback_semester,
    -- Extract subject from comment
    CASE 
        WHEN f.comment LIKE '%DBMS%' OR f.comment LIKE '%Database%' THEN 'DBMS'
        WHEN f.comment LIKE '%Automata%' THEN 'Automata Theory'
        WHEN f.comment LIKE '%Secure Coding%' THEN 'Secure Coding Practices'
        WHEN f.comment LIKE '%Computer Networks%' OR f.comment LIKE '%Networks%' THEN 'Computer Networks'
        WHEN f.comment LIKE '%Machine Learning%' OR f.comment LIKE '%ML%' THEN 'Machine Learning'
        ELSE 'Other'
    END as subject,
    f.createdAt
FROM Feedback f
JOIN Student s ON f.studentId = s.id
JOIN Faculty fac ON f.facultyId = fac.id
WHERE f.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY f.createdAt DESC;

-- 5. Recent feedback summary statistics
SELECT 
    COUNT(*) as total_feedback_count,
    COUNT(DISTINCT f.facultyId) as faculties_with_feedback,
    COUNT(DISTINCT f.studentId) as active_students,
    AVG(JSON_EXTRACT(f.ratings, '$.communication')) as avg_communication,
    AVG(JSON_EXTRACT(f.ratings, '$.clarity')) as avg_clarity,
    AVG(JSON_EXTRACT(f.ratings, '$.knowledge')) as avg_knowledge,
    AVG(JSON_EXTRACT(f.ratings, '$.punctuality')) as avg_punctuality,
    AVG(JSON_EXTRACT(f.ratings, '$.behavior')) as avg_behavior,
    MIN(f.createdAt) as earliest_feedback,
    MAX(f.createdAt) as latest_feedback
FROM Feedback f
WHERE f.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- 6. Today's feedback only
SELECT 
    f.id,
    s.name as student_name,
    s.usn,
    fac.name as faculty_name,
    f.comment,
    f.ratings,
    TIME(f.createdAt) as submission_time
FROM Feedback f
JOIN Student s ON f.studentId = s.id
JOIN Faculty fac ON f.facultyId = fac.id
WHERE DATE(f.createdAt) = CURDATE()
ORDER BY f.createdAt DESC;

-- 7. Feedback trends by hour (for today)
SELECT 
    HOUR(f.createdAt) as hour_of_day,
    COUNT(*) as feedback_count
FROM Feedback f
WHERE DATE(f.createdAt) = CURDATE()
GROUP BY HOUR(f.createdAt)
ORDER BY hour_of_day;