-- ================================================================
-- 5 SQL QUERIES BASED ON YOUR EXACT SCHEMA
-- Database: dbms_feedback_system
-- Tables: Student, Faculty, Feedback
-- ================================================================

-- ================================================================
-- QUERY 1: STUDENT FEEDBACK STATISTICS BY BRANCH
-- Purpose: Show feedback activity and patterns by student branch
-- Tables Used: Student, Feedback
-- Concepts: JOIN, GROUP BY, COUNT, Conditional aggregation
-- ================================================================

SELECT 
    s.branch AS student_branch,
    s.semester,
    COUNT(DISTINCT s.id) AS total_students,
    COUNT(f.id) AS total_feedbacks_given,
    ROUND(COUNT(f.id) / COUNT(DISTINCT s.id), 2) AS avg_feedbacks_per_student,
    SUM(CASE WHEN f.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_feedbacks,
    SUM(CASE WHEN f.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_feedbacks,
    SUM(CASE WHEN f.sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral_feedbacks,
    ROUND(
        (SUM(CASE WHEN f.sentiment = 'positive' THEN 1 ELSE 0 END) * 100.0 / COUNT(f.id)), 2
    ) AS positive_percentage
FROM 
    Student s
LEFT JOIN 
    Feedback f ON s.id = f.studentId
GROUP BY 
    s.branch, s.semester
HAVING 
    COUNT(f.id) > 0
ORDER BY 
    s.branch, s.semester;

-- Expected Output: Branch-wise feedback statistics with sentiment analysis
-- Use Case: Understanding feedback patterns across different branches and semesters


-- ================================================================
-- QUERY 2: FACULTY PERFORMANCE ANALYSIS WITH FEEDBACK DETAILS
-- Purpose: Detailed faculty analysis with feedback sentiment breakdown
-- Tables Used: Faculty, Feedback, Student
-- Concepts: Multiple JOINs, Subqueries, JSON functions (if supported)
-- ================================================================

SELECT 
    f.id AS faculty_id,
    f.name AS faculty_name,
    f.email AS faculty_email,
    f.branch AS faculty_branch,
    COUNT(fb.id) AS total_feedbacks_received,
    COUNT(DISTINCT fb.studentId) AS unique_students_feedback,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_count,
    SUM(CASE WHEN fb.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_count,
    SUM(CASE WHEN fb.sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral_count,
    ROUND(
        (SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) * 100.0 / COUNT(fb.id)), 2
    ) AS positive_feedback_percentage,
    GROUP_CONCAT(
        DISTINCT s.branch ORDER BY s.branch SEPARATOR ', '
    ) AS student_branches_served,
    DATE(MAX(fb.createdAt)) AS last_feedback_date,
    DATE(MIN(fb.createdAt)) AS first_feedback_date
FROM 
    Faculty f
LEFT JOIN 
    Feedback fb ON f.id = fb.facultyId
LEFT JOIN 
    Student s ON fb.studentId = s.id
GROUP BY 
    f.id, f.name, f.email, f.branch
ORDER BY 
    positive_feedback_percentage DESC, total_feedbacks_received DESC;

-- Expected Output: Complete faculty performance report with sentiment analysis
-- Use Case: Faculty evaluation and performance tracking


-- ================================================================
-- QUERY 3: RECENT FEEDBACK TRENDS WITH TEMPORAL ANALYSIS
-- Purpose: Time-based feedback analysis with recent trends
-- Tables Used: Feedback, Student, Faculty
-- Concepts: Date functions, Window functions, Temporal grouping
-- ================================================================

SELECT 
    DATE(fb.createdAt) AS feedback_date,
    COUNT(fb.id) AS daily_feedback_count,
    COUNT(DISTINCT fb.studentId) AS unique_students,
    COUNT(DISTINCT fb.facultyId) AS unique_faculty,
    SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_daily,
    SUM(CASE WHEN fb.sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_daily,
    ROUND(
        (SUM(CASE WHEN fb.sentiment = 'positive' THEN 1 ELSE 0 END) * 100.0 / COUNT(fb.id)), 2
    ) AS daily_positive_percentage,
    LAG(COUNT(fb.id)) OVER (ORDER BY DATE(fb.createdAt)) AS previous_day_count,
    COUNT(fb.id) - LAG(COUNT(fb.id)) OVER (ORDER BY DATE(fb.createdAt)) AS day_over_day_change,
    ROW_NUMBER() OVER (ORDER BY COUNT(fb.id) DESC) AS activity_rank
FROM 
    Feedback fb
WHERE 
    fb.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY 
    DATE(fb.createdAt)
ORDER BY 
    feedback_date DESC;

-- Expected Output: Daily feedback trends with comparative analysis
-- Use Case: Monitoring feedback system usage and engagement patterns


-- ================================================================
-- QUERY 4: CROSS-BRANCH FACULTY-STUDENT FEEDBACK MATRIX
-- Purpose: Show feedback relationships between student and faculty branches
-- Tables Used: Student, Faculty, Feedback
-- Concepts: Complex aggregation, Cross-tabulation style query
-- ================================================================

SELECT 
    s.branch AS student_branch,
    f.branch AS faculty_branch,
    COUNT(fb.id) AS feedback_interactions,
    COUNT(DISTINCT s.id) AS unique_students_giving_feedback,
    COUNT(DISTINCT f.id) AS unique_faculty_receiving_feedback,
    ROUND(AVG(
        CASE 
            WHEN fb.sentiment = 'positive' THEN 3
            WHEN fb.sentiment = 'neutral' THEN 2
            WHEN fb.sentiment = 'negative' THEN 1
            ELSE 0
        END
    ), 2) AS avg_sentiment_score,
    GROUP_CONCAT(
        DISTINCT CONCAT(s.name, ' (Sem ', s.semester, ')') 
        ORDER BY s.semester, s.name 
        SEPARATOR '; '
    ) AS sample_students,
    MAX(fb.createdAt) AS latest_feedback_time,
    MIN(fb.createdAt) AS earliest_feedback_time
FROM 
    Student s
INNER JOIN 
    Feedback fb ON s.id = fb.studentId
INNER JOIN 
    Faculty f ON fb.facultyId = f.id
GROUP BY 
    s.branch, f.branch
ORDER BY 
    s.branch, f.branch, feedback_interactions DESC;

-- Expected Output: Inter-branch feedback interaction matrix
-- Use Case: Understanding cross-departmental feedback patterns


-- ================================================================
-- QUERY 5: COMPREHENSIVE FEEDBACK SEARCH AND ANALYSIS
-- Purpose: Detailed feedback content analysis with full context
-- Tables Used: Student, Faculty, Feedback
-- Concepts: Full text search simulation, Complete data retrieval
-- ================================================================

SELECT 
    fb.id AS feedback_id,
    s.usn AS student_usn,
    s.name AS student_name,
    s.email AS student_email,
    s.branch AS student_branch,
    s.semester AS student_semester,
    f.name AS faculty_name,
    f.email AS faculty_email,
    f.branch AS faculty_branch,
    fb.comment AS feedback_comment,
    fb.ratings AS feedback_ratings_json,
    fb.sentiment AS feedback_sentiment,
    fb.createdAt AS feedback_timestamp,
    CASE 
        WHEN fb.sentiment = 'positive' THEN 'Satisfied'
        WHEN fb.sentiment = 'negative' THEN 'Needs Attention'
        WHEN fb.sentiment = 'neutral' THEN 'Neutral Response'
        ELSE 'Not Analyzed'
    END AS sentiment_category,
    CASE 
        WHEN fb.createdAt >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 'Recent'
        WHEN fb.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 'This Month'
        WHEN fb.createdAt >= DATE_SUB(NOW(), INTERVAL 90 DAY) THEN 'This Quarter'
        ELSE 'Older'
    END AS feedback_age_category,
    CHAR_LENGTH(fb.comment) AS comment_length,
    CASE 
        WHEN CHAR_LENGTH(fb.comment) > 100 THEN 'Detailed'
        WHEN CHAR_LENGTH(fb.comment) > 50 THEN 'Moderate'
        ELSE 'Brief'
    END AS comment_detail_level
FROM 
    Feedback fb
INNER JOIN 
    Student s ON fb.studentId = s.id
INNER JOIN 
    Faculty f ON fb.facultyId = f.id
WHERE 
    -- You can add search conditions here:
    -- fb.comment LIKE '%excellent%' OR 
    -- fb.sentiment = 'positive' OR
    -- s.branch = 'Computer Science'
    fb.createdAt >= DATE_SUB(NOW(), INTERVAL 90 DAY)
ORDER BY 
    fb.createdAt DESC, 
    CASE fb.sentiment 
        WHEN 'negative' THEN 1
        WHEN 'positive' THEN 2
        WHEN 'neutral' THEN 3
        ELSE 4
    END;

-- Expected Output: Complete feedback records with contextual analysis
-- Use Case: Detailed feedback review and content analysis

-- ================================================================
-- BONUS QUERY: SCHEMA INFORMATION
-- Purpose: Show table structure and relationships
-- ================================================================

SELECT 
    'Database Schema Summary' AS info_type,
    'Tables: Student, Faculty, Feedback' AS details
UNION ALL
SELECT 'Student Table', 'Fields: id(cuid), usn(unique), name, email(unique), password, semester, branch'
UNION ALL  
SELECT 'Faculty Table', 'Fields: id(cuid), name, email(unique), password, branch'
UNION ALL
SELECT 'Feedback Table', 'Fields: id(cuid), studentId, facultyId, comment(Text), ratings(JSON), sentiment, createdAt'
UNION ALL
SELECT 'Key Relationships', 'Feedback links Student and Faculty via foreign keys'
UNION ALL
SELECT 'Data Types Used', 'String(cuid), String, Int, JSON, DateTime, Text';

-- ================================================================
-- USAGE INSTRUCTIONS:
-- 1. Run these queries in MySQL Workbench
-- 2. Make sure your database has sample data (run npm run seed)
-- 3. Each query demonstrates different SQL concepts
-- 4. Modify WHERE clauses to filter results as needed
-- 5. Use these for educational demonstrations
-- ================================================================