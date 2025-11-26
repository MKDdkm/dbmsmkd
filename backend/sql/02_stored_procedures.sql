-- ================================================================
-- 🚀 STORED PROCEDURES FOR FEEDBACK SYSTEM
-- ================================================================

-- ----------------------------------------------------------------
-- 1. PROCEDURE: Get Faculty Dashboard Analytics
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE GetFacultyAnalytics(IN faculty_id VARCHAR(191))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE total_feedback_count INT DEFAULT 0;
    
    -- Get comprehensive faculty analytics
    SELECT 
        f.name AS faculty_name,
        f.email AS faculty_email,
        f.branch AS faculty_branch,
        COALESCE(fs.total_feedbacks, 0) AS total_feedbacks,
        COALESCE(fs.overall_average, 0) AS overall_rating,
        COALESCE(fs.avg_teaching_rating, 0) AS teaching_rating,
        COALESCE(fs.avg_communication_rating, 0) AS communication_rating,
        COALESCE(fs.avg_punctuality_rating, 0) AS punctuality_rating,
        COALESCE(fs.avg_knowledge_rating, 0) AS knowledge_rating,
        COALESCE(fs.avg_helpfulness_rating, 0) AS helpfulness_rating,
        COALESCE(fs.positive_count, 0) AS positive_feedback_count,
        COALESCE(fs.neutral_count, 0) AS neutral_feedback_count,
        COALESCE(fs.negative_count, 0) AS negative_feedback_count,
        CASE 
            WHEN COALESCE(fs.overall_average, 0) >= 4.5 THEN 'Excellent'
            WHEN COALESCE(fs.overall_average, 0) >= 4.0 THEN 'Very Good'
            WHEN COALESCE(fs.overall_average, 0) >= 3.5 THEN 'Good'
            WHEN COALESCE(fs.overall_average, 0) >= 3.0 THEN 'Average'
            ELSE 'Needs Improvement'
        END AS performance_grade,
        fs.last_updated
    FROM Faculty f
    LEFT JOIN Feedback_Stats fs ON f.id = fs.faculty_id
    WHERE f.id = faculty_id;
    
    -- Get recent feedback trends (last 30 days)
    SELECT 
        DATE(fb.createdAt) as feedback_date,
        COUNT(*) as daily_count,
        AVG((
            JSON_EXTRACT(fb.ratings, '$.teaching') + 
            JSON_EXTRACT(fb.ratings, '$.communication') + 
            JSON_EXTRACT(fb.ratings, '$.punctuality') + 
            JSON_EXTRACT(fb.ratings, '$.knowledge') + 
            JSON_EXTRACT(fb.ratings, '$.helpfulness')
        ) / 5) as daily_average
    FROM Feedback fb
    WHERE fb.facultyId = faculty_id 
        AND fb.createdAt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    GROUP BY DATE(fb.createdAt)
    ORDER BY feedback_date DESC;
    
    -- Get top students who provided feedback
    SELECT 
        s.name as student_name,
        s.usn as student_usn,
        s.branch as student_branch,
        COUNT(fb.id) as feedback_count,
        AVG((
            JSON_EXTRACT(fb.ratings, '$.teaching') + 
            JSON_EXTRACT(fb.ratings, '$.communication') + 
            JSON_EXTRACT(fb.ratings, '$.punctuality') + 
            JSON_EXTRACT(fb.ratings, '$.knowledge') + 
            JSON_EXTRACT(fb.ratings, '$.helpfulness')
        ) / 5) as avg_rating_given
    FROM Feedback fb
    JOIN Student s ON fb.studentId = s.id
    WHERE fb.facultyId = faculty_id
    GROUP BY s.id, s.name, s.usn, s.branch
    ORDER BY feedback_count DESC, avg_rating_given DESC
    LIMIT 10;
    
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 2. PROCEDURE: Advanced Feedback Search with Filters
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE SearchFeedbacks(
    IN search_faculty_id VARCHAR(191),
    IN search_sentiment VARCHAR(20),
    IN min_rating DECIMAL(2,1),
    IN max_rating DECIMAL(2,1),
    IN search_branch VARCHAR(100),
    IN search_semester INT,
    IN date_from DATE,
    IN date_to DATE,
    IN search_limit INT
)
BEGIN
    SELECT 
        fb.id,
        fb.comment,
        fb.sentiment,
        fb.createdAt,
        s.name AS student_name,
        s.usn AS student_usn,
        s.branch AS student_branch,
        s.semester AS student_semester,
        f.name AS faculty_name,
        JSON_EXTRACT(fb.ratings, '$.teaching') AS teaching_rating,
        JSON_EXTRACT(fb.ratings, '$.communication') AS communication_rating,
        JSON_EXTRACT(fb.ratings, '$.punctuality') AS punctuality_rating,
        JSON_EXTRACT(fb.ratings, '$.knowledge') AS knowledge_rating,
        JSON_EXTRACT(fb.ratings, '$.helpfulness') AS helpfulness_rating,
        (
            JSON_EXTRACT(fb.ratings, '$.teaching') + 
            JSON_EXTRACT(fb.ratings, '$.communication') + 
            JSON_EXTRACT(fb.ratings, '$.punctuality') + 
            JSON_EXTRACT(fb.ratings, '$.knowledge') + 
            JSON_EXTRACT(fb.ratings, '$.helpfulness')
        ) / 5 AS overall_rating
    FROM Feedback fb
    JOIN Student s ON fb.studentId = s.id
    JOIN Faculty f ON fb.facultyId = f.id
    WHERE 
        (search_faculty_id IS NULL OR fb.facultyId = search_faculty_id)
        AND (search_sentiment IS NULL OR fb.sentiment = search_sentiment)
        AND (search_branch IS NULL OR s.branch = search_branch)
        AND (search_semester IS NULL OR s.semester = search_semester)
        AND (date_from IS NULL OR DATE(fb.createdAt) >= date_from)
        AND (date_to IS NULL OR DATE(fb.createdAt) <= date_to)
        AND (
            min_rating IS NULL OR 
            ((JSON_EXTRACT(fb.ratings, '$.teaching') + 
              JSON_EXTRACT(fb.ratings, '$.communication') + 
              JSON_EXTRACT(fb.ratings, '$.punctuality') + 
              JSON_EXTRACT(fb.ratings, '$.knowledge') + 
              JSON_EXTRACT(fb.ratings, '$.helpfulness')) / 5) >= min_rating
        )
        AND (
            max_rating IS NULL OR 
            ((JSON_EXTRACT(fb.ratings, '$.teaching') + 
              JSON_EXTRACT(fb.ratings, '$.communication') + 
              JSON_EXTRACT(fb.ratings, '$.punctuality') + 
              JSON_EXTRACT(fb.ratings, '$.knowledge') + 
              JSON_EXTRACT(fb.ratings, '$.helpfulness')) / 5) <= max_rating
        )
    ORDER BY fb.createdAt DESC
    LIMIT search_limit;
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 3. PROCEDURE: Generate Faculty Performance Report
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE GenerateFacultyReport(
    IN report_faculty_id VARCHAR(191),
    IN report_start_date DATE,
    IN report_end_date DATE
)
BEGIN
    DECLARE total_feedbacks INT DEFAULT 0;
    DECLARE avg_rating DECIMAL(3,2) DEFAULT 0;
    
    -- Summary Statistics
    SELECT 
        COUNT(*) INTO total_feedbacks
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date;
    
    SELECT 
        f.name AS faculty_name,
        f.email AS faculty_email,
        f.branch AS faculty_branch,
        total_feedbacks AS feedback_count,
        report_start_date AS report_from,
        report_end_date AS report_to,
        NOW() AS report_generated_at
    FROM Faculty f
    WHERE f.id = report_faculty_id;
    
    -- Detailed Rating Breakdown
    SELECT 
        'Teaching' AS rating_category,
        AVG(JSON_EXTRACT(ratings, '$.teaching')) AS average_rating,
        MIN(JSON_EXTRACT(ratings, '$.teaching')) AS min_rating,
        MAX(JSON_EXTRACT(ratings, '$.teaching')) AS max_rating,
        COUNT(*) AS rating_count
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date
    
    UNION ALL
    
    SELECT 
        'Communication' AS rating_category,
        AVG(JSON_EXTRACT(ratings, '$.communication')) AS average_rating,
        MIN(JSON_EXTRACT(ratings, '$.communication')) AS min_rating,
        MAX(JSON_EXTRACT(ratings, '$.communication')) AS max_rating,
        COUNT(*) AS rating_count
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date
    
    UNION ALL
    
    SELECT 
        'Punctuality' AS rating_category,
        AVG(JSON_EXTRACT(ratings, '$.punctuality')) AS average_rating,
        MIN(JSON_EXTRACT(ratings, '$.punctuality')) AS min_rating,
        MAX(JSON_EXTRACT(ratings, '$.punctuality')) AS max_rating,
        COUNT(*) AS rating_count
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date
    
    UNION ALL
    
    SELECT 
        'Knowledge' AS rating_category,
        AVG(JSON_EXTRACT(ratings, '$.knowledge')) AS average_rating,
        MIN(JSON_EXTRACT(ratings, '$.knowledge')) AS min_rating,
        MAX(JSON_EXTRACT(ratings, '$.knowledge')) AS max_rating,
        COUNT(*) AS rating_count
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date
    
    UNION ALL
    
    SELECT 
        'Helpfulness' AS rating_category,
        AVG(JSON_EXTRACT(ratings, '$.helpfulness')) AS average_rating,
        MIN(JSON_EXTRACT(ratings, '$.helpfulness')) AS min_rating,
        MAX(JSON_EXTRACT(ratings, '$.helpfulness')) AS max_rating,
        COUNT(*) AS rating_count
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date;
    
    -- Sentiment Distribution
    SELECT 
        sentiment,
        COUNT(*) AS count,
        ROUND((COUNT(*) * 100.0 / total_feedbacks), 2) AS percentage
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date
    GROUP BY sentiment;
    
    -- Monthly Trend
    SELECT 
        YEAR(createdAt) AS year,
        MONTH(createdAt) AS month,
        MONTHNAME(createdAt) AS month_name,
        COUNT(*) AS feedback_count,
        AVG((
            JSON_EXTRACT(ratings, '$.teaching') + 
            JSON_EXTRACT(ratings, '$.communication') + 
            JSON_EXTRACT(ratings, '$.punctuality') + 
            JSON_EXTRACT(ratings, '$.knowledge') + 
            JSON_EXTRACT(ratings, '$.helpfulness')
        ) / 5) AS monthly_average
    FROM Feedback
    WHERE facultyId = report_faculty_id
        AND DATE(createdAt) BETWEEN report_start_date AND report_end_date
    GROUP BY YEAR(createdAt), MONTH(createdAt)
    ORDER BY year, month;
    
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 4. PROCEDURE: Bulk Import Students with Validation
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE BulkImportStudents(
    IN student_data JSON
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_count INT DEFAULT 0;
    DECLARE success_count INT DEFAULT 0;
    DECLARE error_count INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    
    DECLARE current_usn VARCHAR(50);
    DECLARE current_name VARCHAR(255);
    DECLARE current_email VARCHAR(255);
    DECLARE current_branch VARCHAR(100);
    DECLARE current_semester INT;
    DECLARE current_password VARCHAR(255);
    
    -- Get total number of students to import
    SELECT JSON_LENGTH(student_data) INTO student_count;
    
    -- Create temporary results table
    CREATE TEMPORARY TABLE import_results (
        usn VARCHAR(50),
        name VARCHAR(255),
        status VARCHAR(20),
        error_message TEXT
    );
    
    -- Loop through each student
    WHILE i < student_count DO
        -- Extract student data
        SET current_usn = JSON_UNQUOTE(JSON_EXTRACT(student_data, CONCAT('$[', i, '].usn')));
        SET current_name = JSON_UNQUOTE(JSON_EXTRACT(student_data, CONCAT('$[', i, '].name')));
        SET current_email = JSON_UNQUOTE(JSON_EXTRACT(student_data, CONCAT('$[', i, '].email')));
        SET current_branch = JSON_UNQUOTE(JSON_EXTRACT(student_data, CONCAT('$[', i, '].branch')));
        SET current_semester = JSON_EXTRACT(student_data, CONCAT('$[', i, '].semester'));
        SET current_password = JSON_UNQUOTE(JSON_EXTRACT(student_data, CONCAT('$[', i, '].password')));
        
        -- Validate and insert
        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            BEGIN
                SET error_count = error_count + 1;
                INSERT INTO import_results VALUES (current_usn, current_name, 'ERROR', 'Duplicate USN or Email');
            END;
            
            -- Insert student
            INSERT INTO Student (id, usn, name, email, password, semester, branch)
            VALUES (UUID(), current_usn, current_name, current_email, current_password, current_semester, current_branch);
            
            SET success_count = success_count + 1;
            INSERT INTO import_results VALUES (current_usn, current_name, 'SUCCESS', 'Imported successfully');
        END;
        
        SET i = i + 1;
    END WHILE;
    
    -- Return results
    SELECT 
        student_count AS total_students,
        success_count AS successful_imports,
        error_count AS failed_imports;
    
    SELECT * FROM import_results;
    
    DROP TEMPORARY TABLE import_results;
    
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 5. PROCEDURE: Cleanup Old Data
-- ----------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE CleanupOldData(
    IN days_to_keep INT
)
BEGIN
    DECLARE deleted_feedbacks INT DEFAULT 0;
    DECLARE deleted_logs INT DEFAULT 0;
    
    -- Delete old feedback data
    DELETE FROM Feedback 
    WHERE createdAt < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    SET deleted_feedbacks = ROW_COUNT();
    
    -- Delete old activity logs
    DELETE FROM Student_Activity_Log 
    WHERE timestamp < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    SET deleted_logs = ROW_COUNT();
    
    -- Delete old audit records
    DELETE FROM Faculty_Audit 
    WHERE change_timestamp < DATE_SUB(NOW(), INTERVAL days_to_keep DAY);
    
    SELECT 
        deleted_feedbacks AS feedbacks_deleted,
        deleted_logs AS activity_logs_deleted,
        NOW() AS cleanup_completed_at;
        
END$$

DELIMITER ;

-- ================================================================
-- 🎯 HOW TO EXECUTE STORED PROCEDURES:
-- ================================================================

/*
-- 1. Get faculty analytics
CALL GetFacultyAnalytics('faculty_id_here');

-- 2. Search feedbacks with filters
CALL SearchFeedbacks(
    'faculty_id_here',    -- Faculty ID (NULL for all)
    'Positive',           -- Sentiment filter
    4.0,                  -- Min rating
    5.0,                  -- Max rating
    'Computer Science',   -- Branch filter
    6,                    -- Semester filter
    '2024-01-01',        -- Date from
    '2024-12-31',        -- Date to
    50                    -- Limit
);

-- 3. Generate faculty report
CALL GenerateFacultyReport(
    'faculty_id_here',
    '2024-01-01',
    '2024-12-31'
);

-- 4. Bulk import students
CALL BulkImportStudents('[
    {"usn": "4SC21CS100", "name": "John Doe", "email": "john@example.com", "branch": "CS", "semester": 6, "password": "pass123"},
    {"usn": "4SC21CS101", "name": "Jane Smith", "email": "jane@example.com", "branch": "CS", "semester": 6, "password": "pass123"}
]');

-- 5. Cleanup old data (keep last 365 days)
CALL CleanupOldData(365);
*/

-- ================================================================
-- 🛠 PROCEDURE MANAGEMENT COMMANDS
-- ================================================================

-- Show all procedures
-- SHOW PROCEDURE STATUS WHERE Db = 'your_database_name';

-- Drop a procedure
-- DROP PROCEDURE IF EXISTS GetFacultyAnalytics;

-- Show procedure definition
-- SHOW CREATE PROCEDURE GetFacultyAnalytics;