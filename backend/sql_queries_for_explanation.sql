-- ================================================
-- 5 SQL QUERIES FOR DBMS EXPLANATION & DEMONSTRATION
-- Feedback Management System - Educational Queries
-- ================================================

-- ================================================
-- QUERY 1: BASIC JOIN WITH AGGREGATION
-- Purpose: Show student feedback summary with ratings
-- Concepts: INNER JOIN, GROUP BY, AVG, COUNT
-- ================================================

SELECT 
    s.usn,
    s.name AS student_name,
    s.email,
    s.department,
    COUNT(f.id) AS total_feedbacks_given,
    ROUND(AVG(f.rating), 2) AS average_rating_given,
    MIN(f.rating) AS lowest_rating,
    MAX(f.rating) AS highest_rating
FROM 
    Student s
LEFT JOIN 
    Feedback f ON s.id = f.student_id
GROUP BY 
    s.id, s.usn, s.name, s.email, s.department
ORDER BY 
    total_feedbacks_given DESC, average_rating_given DESC;

-- Expected Output: Shows each student with their feedback statistics
-- Demonstrates: LEFT JOIN (includes students who haven't given feedback), aggregation functions


-- ================================================
-- QUERY 2: COMPLEX SUBQUERY WITH CONDITIONAL LOGIC
-- Purpose: Find faculty members with above-average ratings
-- Concepts: Subquery, CASE WHEN, HAVING clause
-- ================================================

SELECT 
    fac.name AS faculty_name,
    fac.department,
    fac.subject,
    COUNT(f.id) AS feedback_count,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    CASE 
        WHEN AVG(f.rating) >= 4.5 THEN 'Excellent'
        WHEN AVG(f.rating) >= 4.0 THEN 'Very Good'
        WHEN AVG(f.rating) >= 3.5 THEN 'Good'
        WHEN AVG(f.rating) >= 3.0 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_category,
    ROUND(
        AVG(f.rating) - (
            SELECT AVG(rating) FROM Feedback
        ), 2
    ) AS rating_vs_overall_avg
FROM 
    Faculty fac
INNER JOIN 
    Feedback f ON fac.id = f.faculty_id
GROUP BY 
    fac.id, fac.name, fac.department, fac.subject
HAVING 
    AVG(f.rating) > (SELECT AVG(rating) FROM Feedback)
    AND COUNT(f.id) >= 2
ORDER BY 
    avg_rating DESC, feedback_count DESC;

-- Expected Output: Faculty with above-average ratings and performance categories
-- Demonstrates: Subqueries, CASE statements, HAVING with subquery condition


-- ================================================
-- QUERY 3: ADVANCED WINDOW FUNCTIONS
-- Purpose: Ranking and comparative analysis with row numbers
-- Concepts: ROW_NUMBER(), RANK(), DENSE_RANK(), OVER clause
-- ================================================

SELECT 
    f.id AS feedback_id,
    s.name AS student_name,
    s.usn,
    fac.name AS faculty_name,
    fac.subject,
    f.rating,
    f.comments,
    f.created_at,
    ROW_NUMBER() OVER (ORDER BY f.rating DESC, f.created_at DESC) as overall_rank,
    RANK() OVER (PARTITION BY fac.id ORDER BY f.rating DESC) as faculty_rating_rank,
    DENSE_RANK() OVER (PARTITION BY s.department ORDER BY f.rating DESC) as dept_rating_rank,
    ROUND(
        AVG(f.rating) OVER (PARTITION BY fac.id), 2
    ) as faculty_avg_rating,
    LAG(f.rating) OVER (PARTITION BY s.id ORDER BY f.created_at) as student_previous_rating,
    LEAD(f.rating) OVER (PARTITION BY s.id ORDER BY f.created_at) as student_next_rating
FROM 
    Feedback f
INNER JOIN 
    Student s ON f.student_id = s.id
INNER JOIN 
    Faculty fac ON f.faculty_id = fac.id
WHERE 
    f.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY 
    f.rating DESC, f.created_at DESC;

-- Expected Output: Detailed feedback analysis with rankings and comparisons
-- Demonstrates: Window functions, LAG/LEAD for sequential analysis


-- ================================================
-- QUERY 4: PIVOT-STYLE ANALYSIS WITH CONDITIONAL AGGREGATION
-- Purpose: Department-wise feedback distribution matrix
-- Concepts: Conditional aggregation, multiple GROUP BY levels
-- ================================================

SELECT 
    s.department,
    COUNT(f.id) as total_feedbacks,
    ROUND(AVG(f.rating), 2) as avg_rating,
    SUM(CASE WHEN f.rating = 5 THEN 1 ELSE 0 END) as five_star_count,
    SUM(CASE WHEN f.rating = 4 THEN 1 ELSE 0 END) as four_star_count,
    SUM(CASE WHEN f.rating = 3 THEN 1 ELSE 0 END) as three_star_count,
    SUM(CASE WHEN f.rating = 2 THEN 1 ELSE 0 END) as two_star_count,
    SUM(CASE WHEN f.rating = 1 THEN 1 ELSE 0 END) as one_star_count,
    ROUND(
        (SUM(CASE WHEN f.rating >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(f.id)), 2
    ) as positive_feedback_percentage,
    ROUND(
        (SUM(CASE WHEN f.rating <= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(f.id)), 2
    ) as negative_feedback_percentage,
    GROUP_CONCAT(
        DISTINCT CONCAT(fac.name, ' (', fac.subject, ')') 
        SEPARATOR '; '
    ) as faculty_in_department
FROM 
    Student s
INNER JOIN 
    Feedback f ON s.id = f.student_id
INNER JOIN 
    Faculty fac ON f.faculty_id = fac.id
GROUP BY 
    s.department
ORDER BY 
    avg_rating DESC, positive_feedback_percentage DESC;

-- Expected Output: Department-wise feedback distribution with detailed breakdowns
-- Demonstrates: Conditional aggregation, percentage calculations, GROUP_CONCAT


-- ================================================
-- QUERY 5: COMPREHENSIVE TEMPORAL ANALYSIS
-- Purpose: Time-based feedback trends and patterns
-- Concepts: Date functions, UNION, temporal aggregation
-- ================================================

WITH monthly_trends AS (
    SELECT 
        DATE_FORMAT(f.created_at, '%Y-%m') as month_year,
        COUNT(f.id) as feedback_count,
        ROUND(AVG(f.rating), 2) as avg_rating,
        COUNT(DISTINCT f.student_id) as unique_students,
        COUNT(DISTINCT f.faculty_id) as unique_faculty
    FROM Feedback f
    WHERE f.created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
    GROUP BY DATE_FORMAT(f.created_at, '%Y-%m')
),
daily_recent AS (
    SELECT 
        DATE(f.created_at) as feedback_date,
        COUNT(f.id) as daily_count,
        ROUND(AVG(f.rating), 2) as daily_avg_rating
    FROM Feedback f
    WHERE f.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    GROUP BY DATE(f.created_at)
)
SELECT 
    'Monthly Trend' as analysis_type,
    mt.month_year as time_period,
    mt.feedback_count as count_value,
    mt.avg_rating,
    mt.unique_students as additional_metric_1,
    mt.unique_faculty as additional_metric_2,
    LAG(mt.avg_rating) OVER (ORDER BY mt.month_year) as previous_period_rating,
    ROUND(
        mt.avg_rating - LAG(mt.avg_rating) OVER (ORDER BY mt.month_year), 2
    ) as rating_change
FROM monthly_trends mt

UNION ALL

SELECT 
    'Daily Recent' as analysis_type,
    dr.feedback_date as time_period,
    dr.daily_count as count_value,
    dr.daily_avg_rating as avg_rating,
    NULL as additional_metric_1,
    NULL as additional_metric_2,
    LAG(dr.daily_avg_rating) OVER (ORDER BY dr.feedback_date) as previous_period_rating,
    ROUND(
        dr.daily_avg_rating - LAG(dr.daily_avg_rating) OVER (ORDER BY dr.feedback_date), 2
    ) as rating_change
FROM daily_recent dr

ORDER BY analysis_type, time_period DESC;

-- Expected Output: Combined monthly and daily trend analysis
-- Demonstrates: CTEs (Common Table Expressions), UNION ALL, temporal functions, LAG for trend analysis

-- ================================================
-- BONUS: EXPLANATION QUERY METADATA
-- ================================================

SELECT 
    'Query Explanation Summary' as info_type,
    '5 Educational SQL Queries Created' as details
UNION ALL
SELECT 'Query 1', 'Basic JOINs and Aggregation - Student feedback statistics'
UNION ALL
SELECT 'Query 2', 'Subqueries and Conditional Logic - Above-average faculty analysis'
UNION ALL
SELECT 'Query 3', 'Window Functions - Rankings and comparative analysis'
UNION ALL
SELECT 'Query 4', 'Conditional Aggregation - Department feedback distribution matrix'
UNION ALL
SELECT 'Query 5', 'Temporal Analysis with CTEs - Time-based trends and patterns';

-- ================================================
-- END OF EDUCATIONAL QUERIES
-- These queries demonstrate:
-- 1. Different types of JOINs (INNER, LEFT)
-- 2. Aggregation functions (COUNT, AVG, MIN, MAX, SUM)
-- 3. Subqueries (correlated and non-correlated)
-- 4. Window functions (ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD)
-- 5. Conditional logic (CASE WHEN, conditional aggregation)
-- 6. Date/time functions and temporal analysis
-- 7. Common Table Expressions (CTEs)
-- 8. UNION operations
-- 9. GROUP BY and HAVING clauses
-- 10. String functions (GROUP_CONCAT, DATE_FORMAT)
-- ================================================