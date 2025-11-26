-- ================================================================
-- 📊 ROLE-BASED QUERIES FOR FEEDBACK SYSTEM
-- 5 Queries Each: Admin, Faculty, Student, Overall System
-- ================================================================

USE feedback_system;

-- ================================================================
-- 👨‍💼 ADMIN QUERIES (5)
-- ================================================================

-- ADMIN QUERY 1: Complete System Overview Dashboard
SELECT 'ADMIN QUERY 1: System Overview Dashboard' AS '';
SELECT 
    (SELECT COUNT(*) FROM Student) AS total_students,
    (SELECT COUNT(*) FROM Faculty) AS total_faculty,
    (SELECT COUNT(*) FROM Feedback) AS total_feedbacks,
    (SELECT COUNT(*) FROM Feedback WHERE sentiment = 'positive') AS positive_feedbacks,
    (SELECT COUNT(*) FROM Feedback WHERE sentiment = 'negative') AS negative_feedbacks,
    (SELECT COUNT(*) FROM Feedback WHERE createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)) AS feedbacks_this_week,
    (SELECT COUNT(*) FROM Feedback WHERE createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)) AS feedbacks_this_month,
    (SELECT ROUND(AVG((
        JSON_EXTRACT(ratings, '$.communication') +
        JSON_EXTRACT(ratings, '$.clarity') +
        JSON_EXTRACT(ratings, '$.knowledge') +
        JSON_EXTRACT(ratings, '$.punctuality') +
        JSON_EXTRACT(ratings, '$.behavior')
    ) / 5), 2) FROM Feedback) AS overall_system_rating;

-- ADMIN QUERY 2: Top 5 Best Performing Faculty Members
SELECT 'ADMIN QUERY 2: Top 5 Best Performing Faculty' AS '';
SELECT 
    f.id,
    f.name AS faculty_name,
    f.email,
    f.branch AS department,
    COUNT(fb.id) AS total_feedbacks,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS average_rating,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_count,
    ROUND((SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(fb.id) * 100), 1) AS satisfaction_percentage
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
GROUP BY f.id, f.name, f.email, f.branch
HAVING COUNT(fb.id) > 0
ORDER BY average_rating DESC, positive_count DESC
LIMIT 5;

-- ADMIN QUERY 3: Faculty Members Needing Attention (Low Ratings)
SELECT 'ADMIN QUERY 3: Faculty Needing Attention (Rating < 3.5)' AS '';
SELECT 
    f.id,
    f.name AS faculty_name,
    f.email,
    f.branch AS department,
    COUNT(fb.id) AS total_feedbacks,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS average_rating,
    SUM(CASE WHEN fb.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_count,
    GROUP_CONCAT(DISTINCT fb.comment SEPARATOR ' | ') AS recent_concerns
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
GROUP BY f.id, f.name, f.email, f.branch
HAVING average_rating < 3.5 AND COUNT(fb.id) > 0
ORDER BY average_rating ASC;

-- ADMIN QUERY 4: Student Engagement Report by Branch
SELECT 'ADMIN QUERY 4: Student Engagement by Branch' AS '';
SELECT 
    s.branch,
    COUNT(DISTINCT s.id) AS total_students,
    COUNT(DISTINCT fb.studentId) AS active_students,
    COUNT(fb.id) AS total_feedbacks,
    ROUND((COUNT(DISTINCT fb.studentId) / COUNT(DISTINCT s.id) * 100), 1) AS engagement_percentage,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS avg_rating_given
FROM Student s
LEFT JOIN Feedback fb ON s.id = fb.studentId
GROUP BY s.branch
ORDER BY engagement_percentage DESC;

-- ADMIN QUERY 5: Monthly Feedback Trends (Last 6 Months)
SELECT 'ADMIN QUERY 5: Monthly Feedback Trends' AS '';
SELECT 
    DATE_FORMAT(createdAt, '%Y-%m') AS month,
    COUNT(*) AS total_feedbacks,
    SUM(CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END) AS positive,
    SUM(CASE WHEN sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral,
    SUM(CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END) AS negative,
    ROUND(AVG((
        JSON_EXTRACT(ratings, '$.communication') +
        JSON_EXTRACT(ratings, '$.clarity') +
        JSON_EXTRACT(ratings, '$.knowledge') +
        JSON_EXTRACT(ratings, '$.punctuality') +
        JSON_EXTRACT(ratings, '$.behavior')
    ) / 5), 2) AS avg_rating,
    COUNT(DISTINCT facultyId) AS faculty_reviewed,
    COUNT(DISTINCT studentId) AS students_participated
FROM Feedback
WHERE createdAt >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(createdAt, '%Y-%m')
ORDER BY month DESC;

-- ================================================================
-- 👨‍🏫 FACULTY QUERIES (5)
-- ================================================================

-- FACULTY QUERY 1: My Complete Performance Dashboard
-- Replace 'FACULTY_ID_HERE' with actual faculty ID
SELECT 'FACULTY QUERY 1: My Performance Dashboard' AS '';
SELECT 
    f.name AS my_name,
    f.email,
    f.branch AS department,
    COUNT(fb.id) AS total_feedbacks_received,
    COUNT(DISTINCT fb.studentId) AS students_taught,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS my_overall_rating,
    ROUND(AVG(JSON_EXTRACT(fb.ratings, '$.communication')), 2) AS communication_rating,
    ROUND(AVG(JSON_EXTRACT(fb.ratings, '$.clarity')), 2) AS clarity_rating,
    ROUND(AVG(JSON_EXTRACT(fb.ratings, '$.knowledge')), 2) AS knowledge_rating,
    ROUND(AVG(JSON_EXTRACT(fb.ratings, '$.punctuality')), 2) AS punctuality_rating,
    ROUND(AVG(JSON_EXTRACT(fb.ratings, '$.behavior')), 2) AS behavior_rating,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_feedbacks,
    SUM(CASE WHEN fb.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_feedbacks,
    ROUND((SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(fb.id) * 100), 1) AS satisfaction_rate
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
WHERE f.id = (SELECT id FROM Faculty LIMIT 1) -- Replace with actual faculty ID
GROUP BY f.id, f.name, f.email, f.branch;

-- FACULTY QUERY 2: Recent Feedbacks I Received (Last 30 Days)
SELECT 'FACULTY QUERY 2: My Recent Feedbacks' AS '';
SELECT 
    fb.id,
    s.name AS student_name,
    s.usn AS student_usn,
    s.branch AS student_branch,
    s.semester,
    fb.comment,
    fb.sentiment,
    ROUND((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5, 2) AS overall_rating,
    JSON_EXTRACT(fb.ratings, '$.communication') AS communication,
    JSON_EXTRACT(fb.ratings, '$.clarity') AS clarity,
    JSON_EXTRACT(fb.ratings, '$.knowledge') AS knowledge,
    JSON_EXTRACT(fb.ratings, '$.punctuality') AS punctuality,
    JSON_EXTRACT(fb.ratings, '$.behavior') AS behavior,
    fb.reply AS my_reply,
    DATE_FORMAT(fb.createdAt, '%Y-%m-%d %H:%i') AS received_at
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id
WHERE fb.facultyId = (SELECT id FROM Faculty LIMIT 1) -- Replace with actual faculty ID
    AND fb.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY fb.createdAt DESC
LIMIT 20;

-- FACULTY QUERY 3: My Strengths and Weaknesses Analysis
SELECT 'FACULTY QUERY 3: My Strengths & Weaknesses' AS '';
SELECT 
    'Communication' AS rating_category,
    ROUND(AVG(JSON_EXTRACT(ratings, '$.communication')), 2) AS average_score,
    COUNT(*) AS total_ratings,
    CASE 
        WHEN AVG(JSON_EXTRACT(ratings, '$.communication')) >= 4.5 THEN 'Excellent'
        WHEN AVG(JSON_EXTRACT(ratings, '$.communication')) >= 4.0 THEN 'Very Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.communication')) >= 3.5 THEN 'Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.communication')) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_level
FROM Feedback
WHERE facultyId = (SELECT id FROM Faculty LIMIT 1)
UNION ALL
SELECT 
    'Clarity' AS rating_category,
    ROUND(AVG(JSON_EXTRACT(ratings, '$.clarity')), 2),
    COUNT(*),
    CASE 
        WHEN AVG(JSON_EXTRACT(ratings, '$.clarity')) >= 4.5 THEN 'Excellent'
        WHEN AVG(JSON_EXTRACT(ratings, '$.clarity')) >= 4.0 THEN 'Very Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.clarity')) >= 3.5 THEN 'Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.clarity')) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END
FROM Feedback
WHERE facultyId = (SELECT id FROM Faculty LIMIT 1)
UNION ALL
SELECT 
    'Knowledge' AS rating_category,
    ROUND(AVG(JSON_EXTRACT(ratings, '$.knowledge')), 2),
    COUNT(*),
    CASE 
        WHEN AVG(JSON_EXTRACT(ratings, '$.knowledge')) >= 4.5 THEN 'Excellent'
        WHEN AVG(JSON_EXTRACT(ratings, '$.knowledge')) >= 4.0 THEN 'Very Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.knowledge')) >= 3.5 THEN 'Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.knowledge')) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END
FROM Feedback
WHERE facultyId = (SELECT id FROM Faculty LIMIT 1)
UNION ALL
SELECT 
    'Punctuality' AS rating_category,
    ROUND(AVG(JSON_EXTRACT(ratings, '$.punctuality')), 2),
    COUNT(*),
    CASE 
        WHEN AVG(JSON_EXTRACT(ratings, '$.punctuality')) >= 4.5 THEN 'Excellent'
        WHEN AVG(JSON_EXTRACT(ratings, '$.punctuality')) >= 4.0 THEN 'Very Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.punctuality')) >= 3.5 THEN 'Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.punctuality')) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END
FROM Feedback
WHERE facultyId = (SELECT id FROM Faculty LIMIT 1)
UNION ALL
SELECT 
    'Behavior' AS rating_category,
    ROUND(AVG(JSON_EXTRACT(ratings, '$.behavior')), 2),
    COUNT(*),
    CASE 
        WHEN AVG(JSON_EXTRACT(ratings, '$.behavior')) >= 4.5 THEN 'Excellent'
        WHEN AVG(JSON_EXTRACT(ratings, '$.behavior')) >= 4.0 THEN 'Very Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.behavior')) >= 3.5 THEN 'Good'
        WHEN AVG(JSON_EXTRACT(ratings, '$.behavior')) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END
FROM Feedback
WHERE facultyId = (SELECT id FROM Faculty LIMIT 1)
ORDER BY average_score DESC;

-- FACULTY QUERY 4: Feedbacks Requiring My Reply
SELECT 'FACULTY QUERY 4: Feedbacks Needing Reply' AS '';
SELECT 
    fb.id,
    s.name AS student_name,
    s.usn,
    s.email AS student_email,
    fb.sentiment,
    fb.comment,
    ROUND((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5, 2) AS rating,
    DATE_FORMAT(fb.createdAt, '%Y-%m-%d') AS feedback_date,
    DATEDIFF(NOW(), fb.createdAt) AS days_pending
FROM Feedback fb
JOIN Student s ON fb.studentId = s.id
WHERE fb.facultyId = (SELECT id FROM Faculty LIMIT 1) -- Replace with actual faculty ID
    AND (fb.reply IS NULL OR fb.reply = '')
    AND fb.sentiment IN ('negative', 'neutral')
ORDER BY fb.createdAt ASC
LIMIT 10;

-- FACULTY QUERY 5: My Performance Comparison with Department Average
SELECT 'FACULTY QUERY 5: My Performance vs Department Average' AS '';
SELECT 
    'My Performance' AS comparison,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS overall_rating,
    COUNT(fb.id) AS total_feedbacks,
    ROUND((SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(fb.id) * 100), 1) AS satisfaction_percentage
FROM Feedback fb
WHERE fb.facultyId = (SELECT id FROM Faculty LIMIT 1)
UNION ALL
SELECT 
    'Department Average' AS comparison,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS overall_rating,
    COUNT(fb.id) AS total_feedbacks,
    ROUND((SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(fb.id) * 100), 1) AS satisfaction_percentage
FROM Feedback fb
JOIN Faculty f ON fb.facultyId = f.id
WHERE f.branch = (SELECT branch FROM Faculty WHERE id = (SELECT id FROM Faculty LIMIT 1));

-- ================================================================
-- 👨‍🎓 STUDENT QUERIES (5)
-- ================================================================

-- STUDENT QUERY 1: My Feedback History
-- Replace 'STUDENT_ID_HERE' with actual student ID
SELECT 'STUDENT QUERY 1: My Feedback History' AS '';
SELECT 
    fb.id,
    f.name AS faculty_name,
    f.email AS faculty_email,
    f.branch AS department,
    fb.comment AS my_feedback,
    fb.sentiment,
    ROUND((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5, 2) AS my_overall_rating,
    JSON_EXTRACT(fb.ratings, '$.communication') AS communication,
    JSON_EXTRACT(fb.ratings, '$.clarity') AS clarity,
    JSON_EXTRACT(fb.ratings, '$.knowledge') AS knowledge,
    JSON_EXTRACT(fb.ratings, '$.punctuality') AS punctuality,
    JSON_EXTRACT(fb.ratings, '$.behavior') AS behavior,
    fb.reply AS faculty_reply,
    DATE_FORMAT(fb.createdAt, '%Y-%m-%d') AS submitted_on,
    DATE_FORMAT(fb.repliedAt, '%Y-%m-%d') AS replied_on
FROM Feedback fb
JOIN Faculty f ON fb.facultyId = f.id
WHERE fb.studentId = (SELECT id FROM Student LIMIT 1) -- Replace with actual student ID
ORDER BY fb.createdAt DESC;

-- STUDENT QUERY 2: Faculty I Can Rate (Haven't Given Feedback Yet)
SELECT 'STUDENT QUERY 2: Faculty Available to Rate' AS '';
SELECT 
    f.id,
    f.name AS faculty_name,
    f.email,
    f.branch AS department,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM Feedback fb 
            WHERE fb.facultyId = f.id 
            AND fb.studentId = (SELECT id FROM Student LIMIT 1)
        ) THEN 'Already Rated'
        ELSE 'Not Yet Rated'
    END AS feedback_status,
    (SELECT COUNT(*) FROM Feedback WHERE facultyId = f.id) AS total_feedbacks_received,
    (SELECT ROUND(AVG((
        JSON_EXTRACT(ratings, '$.communication') +
        JSON_EXTRACT(ratings, '$.clarity') +
        JSON_EXTRACT(ratings, '$.knowledge') +
        JSON_EXTRACT(ratings, '$.punctuality') +
        JSON_EXTRACT(ratings, '$.behavior')
    ) / 5), 2) FROM Feedback WHERE facultyId = f.id) AS faculty_avg_rating
FROM Faculty f
WHERE NOT EXISTS (
    SELECT 1 FROM Feedback fb 
    WHERE fb.facultyId = f.id 
    AND fb.studentId = (SELECT id FROM Student LIMIT 1)
)
ORDER BY f.name;

-- STUDENT QUERY 3: My Feedback Impact - Faculty Replies Received
SELECT 'STUDENT QUERY 3: Faculty Replies to My Feedback' AS '';
SELECT 
    f.name AS faculty_name,
    f.email,
    fb.comment AS my_original_feedback,
    fb.sentiment AS my_sentiment,
    fb.reply AS faculty_response,
    DATE_FORMAT(fb.createdAt, '%Y-%m-%d') AS my_feedback_date,
    DATE_FORMAT(fb.repliedAt, '%Y-%m-%d') AS faculty_reply_date,
    DATEDIFF(fb.repliedAt, fb.createdAt) AS response_time_days
FROM Feedback fb
JOIN Faculty f ON fb.facultyId = f.id
WHERE fb.studentId = (SELECT id FROM Student LIMIT 1) -- Replace with actual student ID
    AND fb.reply IS NOT NULL 
    AND fb.reply != ''
ORDER BY fb.repliedAt DESC;

-- STUDENT QUERY 4: My Feedback Statistics Summary
SELECT 'STUDENT QUERY 4: My Feedback Statistics' AS '';
SELECT 
    s.name AS my_name,
    s.usn AS my_usn,
    s.branch AS my_branch,
    s.semester AS my_semester,
    COUNT(fb.id) AS total_feedbacks_given,
    COUNT(DISTINCT fb.facultyId) AS faculty_rated_count,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS my_avg_rating_given,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_feedbacks_given,
    SUM(CASE WHEN fb.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_feedbacks_given,
    SUM(CASE WHEN fb.reply IS NOT NULL AND fb.reply != '' THEN 1 ELSE 0 END) AS replies_received,
    DATE_FORMAT(MAX(fb.createdAt), '%Y-%m-%d') AS last_feedback_date
FROM Student s
LEFT JOIN Feedback fb ON s.id = fb.studentId
WHERE s.id = (SELECT id FROM Student LIMIT 1) -- Replace with actual student ID
GROUP BY s.id, s.name, s.usn, s.branch, s.semester;

-- STUDENT QUERY 5: Top Rated Faculty in My Branch/Semester
SELECT 'STUDENT QUERY 5: Top Rated Faculty in My Branch' AS '';
SELECT 
    f.id,
    f.name AS faculty_name,
    f.email,
    f.branch AS department,
    COUNT(fb.id) AS total_ratings,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS average_rating,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_count,
    ROUND((SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(fb.id) * 100), 1) AS satisfaction_rate,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM Feedback 
            WHERE facultyId = f.id 
            AND studentId = (SELECT id FROM Student LIMIT 1)
        ) THEN 'You Rated'
        ELSE 'Not Rated Yet'
    END AS my_status
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
WHERE f.branch = (SELECT branch FROM Student WHERE id = (SELECT id FROM Student LIMIT 1))
GROUP BY f.id, f.name, f.email, f.branch
HAVING COUNT(fb.id) > 0
ORDER BY average_rating DESC, positive_count DESC
LIMIT 10;

-- ================================================================
-- 🌐 OVERALL SYSTEM QUERIES (5)
-- ================================================================

-- OVERALL QUERY 1: Complete System Health Report
SELECT 'OVERALL QUERY 1: System Health Report' AS '';
SELECT 
    'System Statistics' AS metric_category,
    'Total Users' AS metric_name,
    (SELECT COUNT(*) FROM Student) + (SELECT COUNT(*) FROM Faculty) AS value,
    '-' AS percentage
UNION ALL
SELECT 'System Statistics', 'Total Students', COUNT(*), '-' FROM Student
UNION ALL
SELECT 'System Statistics', 'Total Faculty', COUNT(*), '-' FROM Faculty
UNION ALL
SELECT 'Feedback Statistics', 'Total Feedbacks', COUNT(*), '-' FROM Feedback
UNION ALL
SELECT 'Feedback Statistics', 'Positive Feedbacks', 
    COUNT(*), 
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM Feedback) * 100), 1), '%') 
FROM Feedback WHERE sentiment = 'positive'
UNION ALL
SELECT 'Feedback Statistics', 'Negative Feedbacks', 
    COUNT(*), 
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM Feedback) * 100), 1), '%') 
FROM Feedback WHERE sentiment = 'negative'
UNION ALL
SELECT 'Engagement', 'Active Students (gave feedback)', 
    COUNT(DISTINCT studentId), 
    CONCAT(ROUND((COUNT(DISTINCT studentId) / (SELECT COUNT(*) FROM Student) * 100), 1), '%')
FROM Feedback
UNION ALL
SELECT 'Engagement', 'Active Faculty (received feedback)', 
    COUNT(DISTINCT facultyId), 
    CONCAT(ROUND((COUNT(DISTINCT facultyId) / (SELECT COUNT(*) FROM Faculty) * 100), 1), '%')
FROM Feedback
UNION ALL
SELECT 'Response Rate', 'Faculty Replies', 
    COUNT(*), 
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM Feedback) * 100), 1), '%')
FROM Feedback WHERE reply IS NOT NULL AND reply != '';

-- OVERALL QUERY 2: Department-wise Complete Analysis
SELECT 'OVERALL QUERY 2: Department-wise Analysis' AS '';
SELECT 
    COALESCE(f.branch, 'Unknown') AS department,
    COUNT(DISTINCT f.id) AS total_faculty,
    COUNT(DISTINCT s.id) AS total_students,
    COUNT(fb.id) AS total_feedbacks,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS avg_rating,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_feedbacks,
    SUM(CASE WHEN fb.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_feedbacks,
    ROUND((SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) / COUNT(fb.id) * 100), 1) AS satisfaction_rate,
    ROUND((COUNT(fb.id) / COUNT(DISTINCT f.id)), 1) AS feedbacks_per_faculty
FROM Faculty f
LEFT JOIN Feedback fb ON f.id = fb.facultyId
LEFT JOIN Student s ON s.branch = f.branch
GROUP BY f.branch
ORDER BY avg_rating DESC;

-- OVERALL QUERY 3: Semester-wise Student Participation
SELECT 'OVERALL QUERY 3: Semester-wise Student Participation' AS '';
SELECT 
    s.semester,
    COUNT(DISTINCT s.id) AS total_students,
    COUNT(DISTINCT fb.studentId) AS active_students,
    COUNT(fb.id) AS total_feedbacks_given,
    ROUND((COUNT(DISTINCT fb.studentId) / COUNT(DISTINCT s.id) * 100), 1) AS participation_rate,
    ROUND(AVG((
        JSON_EXTRACT(fb.ratings, '$.communication') +
        JSON_EXTRACT(fb.ratings, '$.clarity') +
        JSON_EXTRACT(fb.ratings, '$.knowledge') +
        JSON_EXTRACT(fb.ratings, '$.punctuality') +
        JSON_EXTRACT(fb.ratings, '$.behavior')
    ) / 5), 2) AS avg_rating_given,
    ROUND((COUNT(fb.id) / COUNT(DISTINCT fb.studentId)), 1) AS feedbacks_per_student
FROM Student s
LEFT JOIN Feedback fb ON s.id = fb.studentId
GROUP BY s.semester
ORDER BY s.semester;

-- OVERALL QUERY 4: Rating Category Analysis (System-wide)
SELECT 'OVERALL QUERY 4: Rating Category Analysis' AS '';
SELECT 
    'Communication' AS rating_category,
    ROUND(AVG(JSON_EXTRACT(ratings, '$.communication')), 2) AS system_average,
    ROUND(MIN(JSON_EXTRACT(ratings, '$.communication')), 2) AS lowest_rating,
    ROUND(MAX(JSON_EXTRACT(ratings, '$.communication')), 2) AS highest_rating,
    COUNT(*) AS total_ratings
FROM Feedback
UNION ALL
SELECT 
    'Clarity',
    ROUND(AVG(JSON_EXTRACT(ratings, '$.clarity')), 2),
    ROUND(MIN(JSON_EXTRACT(ratings, '$.clarity')), 2),
    ROUND(MAX(JSON_EXTRACT(ratings, '$.clarity')), 2),
    COUNT(*)
FROM Feedback
UNION ALL
SELECT 
    'Knowledge',
    ROUND(AVG(JSON_EXTRACT(ratings, '$.knowledge')), 2),
    ROUND(MIN(JSON_EXTRACT(ratings, '$.knowledge')), 2),
    ROUND(MAX(JSON_EXTRACT(ratings, '$.knowledge')), 2),
    COUNT(*)
FROM Feedback
UNION ALL
SELECT 
    'Punctuality',
    ROUND(AVG(JSON_EXTRACT(ratings, '$.punctuality')), 2),
    ROUND(MIN(JSON_EXTRACT(ratings, '$.punctuality')), 2),
    ROUND(MAX(JSON_EXTRACT(ratings, '$.punctuality')), 2),
    COUNT(*)
FROM Feedback
UNION ALL
SELECT 
    'Behavior',
    ROUND(AVG(JSON_EXTRACT(ratings, '$.behavior')), 2),
    ROUND(MIN(JSON_EXTRACT(ratings, '$.behavior')), 2),
    ROUND(MAX(JSON_EXTRACT(ratings, '$.behavior')), 2),
    COUNT(*)
FROM Feedback
ORDER BY system_average DESC;

-- OVERALL QUERY 5: Recent Activity Timeline (Last 7 Days)
SELECT 'OVERALL QUERY 5: Recent Activity Timeline' AS '';
SELECT 
    DATE(createdAt) AS activity_date,
    COUNT(*) AS feedbacks_submitted,
    COUNT(DISTINCT studentId) AS unique_students,
    COUNT(DISTINCT facultyId) AS unique_faculty,
    SUM(CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_count,
    SUM(CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_count,
    ROUND(AVG((
        JSON_EXTRACT(ratings, '$.communication') +
        JSON_EXTRACT(ratings, '$.clarity') +
        JSON_EXTRACT(ratings, '$.knowledge') +
        JSON_EXTRACT(ratings, '$.punctuality') +
        JSON_EXTRACT(ratings, '$.behavior')
    ) / 5), 2) AS avg_rating,
    GROUP_CONCAT(DISTINCT 
        CONCAT(
            (SELECT name FROM Faculty WHERE id = Feedback.facultyId), 
            ' (', sentiment, ')'
        ) 
        SEPARATOR ', '
    ) AS faculty_activity
FROM Feedback
WHERE createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(createdAt)
ORDER BY activity_date DESC;

-- ================================================================
-- 📝 SUMMARY
-- ================================================================

SELECT '=== 📊 QUERY SUMMARY ===' AS '';
SELECT '✅ Admin Queries: 5 (System overview, top faculty, low performers, engagement, trends)' AS '';
SELECT '✅ Faculty Queries: 5 (Dashboard, recent feedback, strengths/weaknesses, pending replies, comparison)' AS '';
SELECT '✅ Student Queries: 5 (History, available faculty, replies received, statistics, top rated)' AS '';
SELECT '✅ Overall Queries: 5 (Health report, department analysis, semester participation, rating categories, timeline)' AS '';
SELECT '✅ Total: 20 Comprehensive SQL Queries' AS '';
