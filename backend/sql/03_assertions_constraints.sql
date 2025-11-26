-- ================================================================
-- ⚡ ASSERTIONS & CONSTRAINTS FOR FEEDBACK SYSTEM
-- ================================================================

-- Note: MySQL doesn't support ASSERTION statements directly like PostgreSQL,
-- but we can implement similar functionality using CHECK constraints,
-- triggers, and stored procedures for validation.

-- ----------------------------------------------------------------
-- 1. CHECK CONSTRAINTS (Table-level validations)
-- ----------------------------------------------------------------

-- First, let's add check constraints to existing tables via ALTER statements
-- (These should be added during table creation, but we can modify existing tables)

-- Student table constraints
ALTER TABLE Student 
ADD CONSTRAINT chk_student_semester 
CHECK (semester >= 1 AND semester <= 8);

ALTER TABLE Student 
ADD CONSTRAINT chk_student_usn_format 
CHECK (usn REGEXP '^[0-9][A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{3}$');

ALTER TABLE Student 
ADD CONSTRAINT chk_student_email_format 
CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

ALTER TABLE Student 
ADD CONSTRAINT chk_student_name_length 
CHECK (CHAR_LENGTH(name) >= 2 AND CHAR_LENGTH(name) <= 100);

-- Faculty table constraints  
ALTER TABLE Faculty 
ADD CONSTRAINT chk_faculty_email_format 
CHECK (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

ALTER TABLE Faculty 
ADD CONSTRAINT chk_faculty_name_length 
CHECK (CHAR_LENGTH(name) >= 2 AND CHAR_LENGTH(name) <= 100);

-- ----------------------------------------------------------------
-- 2. ASSERTION-LIKE VALIDATION FUNCTIONS
-- ----------------------------------------------------------------

DELIMITER $$

-- Function to validate rating values in JSON
CREATE FUNCTION IsValidRatingJSON(rating_json JSON) 
RETURNS BOOLEAN
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE teaching_rating DECIMAL(2,1);
    DECLARE communication_rating DECIMAL(2,1);
    DECLARE punctuality_rating DECIMAL(2,1);
    DECLARE knowledge_rating DECIMAL(2,1);
    DECLARE helpfulness_rating DECIMAL(2,1);
    
    -- Extract ratings
    SET teaching_rating = JSON_EXTRACT(rating_json, '$.teaching');
    SET communication_rating = JSON_EXTRACT(rating_json, '$.communication');
    SET punctuality_rating = JSON_EXTRACT(rating_json, '$.punctuality');
    SET knowledge_rating = JSON_EXTRACT(rating_json, '$.knowledge');
    SET helpfulness_rating = JSON_EXTRACT(rating_json, '$.helpfulness');
    
    -- Validate each rating is between 1 and 5
    IF (teaching_rating IS NULL OR teaching_rating < 1 OR teaching_rating > 5) THEN
        RETURN FALSE;
    END IF;
    
    IF (communication_rating IS NULL OR communication_rating < 1 OR communication_rating > 5) THEN
        RETURN FALSE;
    END IF;
    
    IF (punctuality_rating IS NULL OR punctuality_rating < 1 OR punctuality_rating > 5) THEN
        RETURN FALSE;
    END IF;
    
    IF (knowledge_rating IS NULL OR knowledge_rating < 1 OR knowledge_rating > 5) THEN
        RETURN FALSE;
    END IF;
    
    IF (helpfulness_rating IS NULL OR helpfulness_rating < 1 OR helpfulness_rating > 5) THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 3. ASSERTION TRIGGERS (Complex business rule validation)
-- ----------------------------------------------------------------

DELIMITER $$

-- Trigger to enforce feedback rating validation
CREATE TRIGGER assert_valid_feedback_ratings
    BEFORE INSERT ON Feedback
    FOR EACH ROW
BEGIN
    -- Assert: All ratings must be valid JSON with values 1-5
    IF NOT IsValidRatingJSON(NEW.ratings) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ASSERTION FAILED: All ratings must be between 1 and 5';
    END IF;
    
    -- Assert: Comment must not be empty or too long
    IF CHAR_LENGTH(TRIM(NEW.comment)) < 5 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ASSERTION FAILED: Comment must be at least 5 characters long';
    END IF;
    
    IF CHAR_LENGTH(NEW.comment) > 1000 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ASSERTION FAILED: Comment cannot exceed 1000 characters';
    END IF;
    
    -- Assert: Sentiment must be valid
    IF NEW.sentiment NOT IN ('Positive', 'Negative', 'Neutral') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ASSERTION FAILED: Sentiment must be Positive, Negative, or Neutral';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

-- Trigger to enforce business rule: Student can't give feedback to same faculty more than once per day
CREATE TRIGGER assert_one_feedback_per_day
    BEFORE INSERT ON Feedback
    FOR EACH ROW
BEGIN
    DECLARE feedback_count INT DEFAULT 0;
    
    -- Count existing feedbacks from same student to same faculty today
    SELECT COUNT(*) INTO feedback_count
    FROM Feedback 
    WHERE studentId = NEW.studentId 
        AND facultyId = NEW.facultyId 
        AND DATE(createdAt) = DATE(NOW());
    
    IF feedback_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ASSERTION FAILED: Student can only submit one feedback per faculty per day';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

-- Trigger to enforce: Faculty cannot have more than 1000 feedbacks (business limit)
CREATE TRIGGER assert_faculty_feedback_limit
    BEFORE INSERT ON Feedback
    FOR EACH ROW
BEGIN
    DECLARE total_feedbacks INT DEFAULT 0;
    
    SELECT COUNT(*) INTO total_feedbacks
    FROM Feedback 
    WHERE facultyId = NEW.facultyId;
    
    IF total_feedbacks >= 1000 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ASSERTION FAILED: Faculty cannot have more than 1000 feedbacks';
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 4. DATA INTEGRITY ASSERTION PROCEDURES
-- ----------------------------------------------------------------

DELIMITER $$

-- Procedure to validate complete database integrity
CREATE PROCEDURE ValidateDatabaseIntegrity()
BEGIN
    DECLARE integrity_errors INT DEFAULT 0;
    
    -- Create temporary table for integrity results
    CREATE TEMPORARY TABLE integrity_check_results (
        check_name VARCHAR(100),
        status VARCHAR(20),
        error_count INT,
        details TEXT
    );
    
    -- Check 1: Orphaned feedbacks (feedback without valid student)
    SELECT COUNT(*) INTO @orphaned_student_feedbacks
    FROM Feedback f
    LEFT JOIN Student s ON f.studentId = s.id
    WHERE s.id IS NULL;
    
    INSERT INTO integrity_check_results VALUES (
        'Orphaned Student Feedbacks', 
        CASE WHEN @orphaned_student_feedbacks = 0 THEN 'PASS' ELSE 'FAIL' END,
        @orphaned_student_feedbacks,
        CASE WHEN @orphaned_student_feedbacks = 0 THEN 'All feedbacks have valid students' 
             ELSE CONCAT(@orphaned_student_feedbacks, ' feedbacks have invalid student references') END
    );
    
    -- Check 2: Orphaned feedbacks (feedback without valid faculty)
    SELECT COUNT(*) INTO @orphaned_faculty_feedbacks
    FROM Feedback f
    LEFT JOIN Faculty fa ON f.facultyId = fa.id
    WHERE fa.id IS NULL;
    
    INSERT INTO integrity_check_results VALUES (
        'Orphaned Faculty Feedbacks', 
        CASE WHEN @orphaned_faculty_feedbacks = 0 THEN 'PASS' ELSE 'FAIL' END,
        @orphaned_faculty_feedbacks,
        CASE WHEN @orphaned_faculty_feedbacks = 0 THEN 'All feedbacks have valid faculty' 
             ELSE CONCAT(@orphaned_faculty_feedbacks, ' feedbacks have invalid faculty references') END
    );
    
    -- Check 3: Invalid email formats
    SELECT COUNT(*) INTO @invalid_student_emails
    FROM Student
    WHERE NOT (email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');
    
    INSERT INTO integrity_check_results VALUES (
        'Invalid Student Emails', 
        CASE WHEN @invalid_student_emails = 0 THEN 'PASS' ELSE 'FAIL' END,
        @invalid_student_emails,
        CASE WHEN @invalid_student_emails = 0 THEN 'All student emails are valid' 
             ELSE CONCAT(@invalid_student_emails, ' students have invalid email formats') END
    );
    
    -- Check 4: Invalid USN formats
    SELECT COUNT(*) INTO @invalid_usns
    FROM Student
    WHERE NOT (usn REGEXP '^[0-9][A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{3}$');
    
    INSERT INTO integrity_check_results VALUES (
        'Invalid USN Formats', 
        CASE WHEN @invalid_usns = 0 THEN 'PASS' ELSE 'FAIL' END,
        @invalid_usns,
        CASE WHEN @invalid_usns = 0 THEN 'All USN formats are valid' 
             ELSE CONCAT(@invalid_usns, ' students have invalid USN formats') END
    );
    
    -- Check 5: Invalid semester values
    SELECT COUNT(*) INTO @invalid_semesters
    FROM Student
    WHERE semester < 1 OR semester > 8;
    
    INSERT INTO integrity_check_results VALUES (
        'Invalid Semester Values', 
        CASE WHEN @invalid_semesters = 0 THEN 'PASS' ELSE 'FAIL' END,
        @invalid_semesters,
        CASE WHEN @invalid_semesters = 0 THEN 'All semester values are valid (1-8)' 
             ELSE CONCAT(@invalid_semesters, ' students have invalid semester values') END
    );
    
    -- Check 6: Feedback ratings validation
    SELECT COUNT(*) INTO @invalid_ratings
    FROM Feedback
    WHERE NOT IsValidRatingJSON(ratings);
    
    INSERT INTO integrity_check_results VALUES (
        'Invalid Feedback Ratings', 
        CASE WHEN @invalid_ratings = 0 THEN 'PASS' ELSE 'FAIL' END,
        @invalid_ratings,
        CASE WHEN @invalid_ratings = 0 THEN 'All feedback ratings are valid (1-5)' 
             ELSE CONCAT(@invalid_ratings, ' feedbacks have invalid rating values') END
    );
    
    -- Return results
    SELECT 
        check_name,
        status,
        error_count,
        details,
        NOW() AS checked_at
    FROM integrity_check_results;
    
    -- Summary
    SELECT 
        COUNT(*) AS total_checks,
        SUM(CASE WHEN status = 'PASS' THEN 1 ELSE 0 END) AS passed_checks,
        SUM(CASE WHEN status = 'FAIL' THEN 1 ELSE 0 END) AS failed_checks,
        SUM(error_count) AS total_errors
    FROM integrity_check_results;
    
    DROP TEMPORARY TABLE integrity_check_results;
    
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 5. REFERENTIAL INTEGRITY ASSERTIONS
-- ----------------------------------------------------------------

DELIMITER $$

-- Procedure to check and enforce referential integrity
CREATE PROCEDURE EnforceReferentialIntegrity()
BEGIN
    -- Check for dangling references and provide fix suggestions
    
    -- 1. Clean up feedbacks with invalid student references
    DELETE f FROM Feedback f
    LEFT JOIN Student s ON f.studentId = s.id
    WHERE s.id IS NULL;
    
    -- 2. Clean up feedbacks with invalid faculty references  
    DELETE f FROM Feedback f
    LEFT JOIN Faculty fa ON f.facultyId = fa.id
    WHERE fa.id IS NULL;
    
    -- 3. Update statistics table to ensure all faculty are represented
    INSERT IGNORE INTO Feedback_Stats (faculty_id, total_feedbacks)
    SELECT id, 0 FROM Faculty
    WHERE id NOT IN (SELECT faculty_id FROM Feedback_Stats);
    
    SELECT 
        'Referential integrity enforced' AS status,
        ROW_COUNT() AS rows_affected,
        NOW() AS completed_at;
        
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 6. CUSTOM DOMAIN CONSTRAINTS
-- ----------------------------------------------------------------

-- Create a table to store custom business rules
CREATE TABLE Business_Rules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL UNIQUE,
    rule_description TEXT,
    rule_sql TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert some example business rules
INSERT INTO Business_Rules (rule_name, rule_description, rule_sql) VALUES
('max_feedback_per_student_per_day', 'Student cannot submit more than 3 feedbacks per day', 
 'SELECT COUNT(*) FROM Feedback WHERE studentId = ? AND DATE(createdAt) = CURDATE()'),
('min_rating_average_for_promotion', 'Faculty needs average rating >= 3.5 for promotion eligibility',
 'SELECT AVG((JSON_EXTRACT(ratings, "$.teaching") + JSON_EXTRACT(ratings, "$.communication") + JSON_EXTRACT(ratings, "$.punctuality") + JSON_EXTRACT(ratings, "$.knowledge") + JSON_EXTRACT(ratings, "$.helpfulness"))/5) FROM Feedback WHERE facultyId = ?'),
('feedback_comment_sentiment_match', 'Feedback sentiment should match comment tone',
 'SELECT sentiment FROM Feedback WHERE id = ?');

-- ================================================================
-- 🎯 HOW TO TEST ASSERTIONS:
-- ================================================================

/*
-- Test 1: Try to insert invalid rating (should fail)
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) 
VALUES ('test1', 'student_id', 'faculty_id', 'Test comment', '{"teaching": 6}', 'Positive');

-- Test 2: Try to insert duplicate feedback same day (should fail)
-- First insert
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) 
VALUES ('test2', 'student_id', 'faculty_id', 'Good teaching', '{"teaching": 4, "communication": 4, "punctuality": 4, "knowledge": 4, "helpfulness": 4}', 'Positive');
-- Second insert same day (should fail)
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) 
VALUES ('test3', 'student_id', 'faculty_id', 'Another comment', '{"teaching": 5, "communication": 5, "punctuality": 5, "knowledge": 5, "helpfulness": 5}', 'Positive');

-- Test 3: Validate database integrity
CALL ValidateDatabaseIntegrity();

-- Test 4: Enforce referential integrity
CALL EnforceReferentialIntegrity();

-- Test 5: Try invalid student data
INSERT INTO Student (id, usn, name, email, password, semester, branch)
VALUES ('test_student', 'INVALID_USN', 'Test', 'invalid_email', 'pass', 10, 'CS');
*/

-- ================================================================
-- 🛠 ASSERTION MANAGEMENT COMMANDS
-- ================================================================

-- View all check constraints
-- SELECT * FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_SCHEMA = 'your_database_name';

-- View all triggers
-- SHOW TRIGGERS;

-- Check business rules
-- SELECT * FROM Business_Rules WHERE is_active = TRUE;

-- Remove a constraint
-- ALTER TABLE Student DROP CHECK chk_student_semester;