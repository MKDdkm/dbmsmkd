-- ================================================================
-- 🔥 ADVANCED TRIGGERS FOR FEEDBACK SYSTEM
-- ================================================================

-- ----------------------------------------------------------------
-- 1. TRIGGER: Auto-update feedback sentiment based on ratings
-- ----------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER update_feedback_sentiment
    BEFORE INSERT ON Feedback
    FOR EACH ROW
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    
    -- Extract average rating from JSON
    SET avg_rating = (
        JSON_EXTRACT(NEW.ratings, '$.teaching') + 
        JSON_EXTRACT(NEW.ratings, '$.communication') + 
        JSON_EXTRACT(NEW.ratings, '$.punctuality') + 
        JSON_EXTRACT(NEW.ratings, '$.knowledge') + 
        JSON_EXTRACT(NEW.ratings, '$.helpfulness')
    ) / 5;
    
    -- Set sentiment based on average rating
    SET NEW.sentiment = CASE
        WHEN avg_rating >= 4.0 THEN 'Positive'
        WHEN avg_rating >= 3.0 THEN 'Neutral'
        ELSE 'Negative'
    END;
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 2. TRIGGER: Audit Trail for Faculty Updates
-- ----------------------------------------------------------------

-- Create audit table first
CREATE TABLE Faculty_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id VARCHAR(191),
    action_type ENUM('INSERT', 'UPDATE', 'DELETE'),
    old_name VARCHAR(255),
    new_name VARCHAR(255),
    old_email VARCHAR(255),
    new_email VARCHAR(255),
    old_branch VARCHAR(255),
    new_branch VARCHAR(255),
    changed_by VARCHAR(255),
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER faculty_audit_update
    AFTER UPDATE ON Faculty
    FOR EACH ROW
BEGIN
    INSERT INTO Faculty_Audit (
        faculty_id, action_type, 
        old_name, new_name,
        old_email, new_email,
        old_branch, new_branch,
        changed_by
    ) VALUES (
        NEW.id, 'UPDATE',
        OLD.name, NEW.name,
        OLD.email, NEW.email,
        OLD.branch, NEW.branch,
        USER()
    );
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 3. TRIGGER: Prevent deletion of faculty with active feedbacks
-- ----------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER prevent_faculty_deletion
    BEFORE DELETE ON Faculty
    FOR EACH ROW
BEGIN
    DECLARE feedback_count INT;
    
    -- Count feedbacks for this faculty
    SELECT COUNT(*) INTO feedback_count 
    FROM Feedback 
    WHERE facultyId = OLD.id;
    
    -- Prevent deletion if feedbacks exist
    IF feedback_count > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete faculty with existing feedbacks';
    END IF;
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 4. TRIGGER: Auto-generate feedback statistics
-- ----------------------------------------------------------------

-- Create statistics table
CREATE TABLE Feedback_Stats (
    faculty_id VARCHAR(191) PRIMARY KEY,
    total_feedbacks INT DEFAULT 0,
    avg_teaching_rating DECIMAL(3,2) DEFAULT 0,
    avg_communication_rating DECIMAL(3,2) DEFAULT 0,
    avg_punctuality_rating DECIMAL(3,2) DEFAULT 0,
    avg_knowledge_rating DECIMAL(3,2) DEFAULT 0,
    avg_helpfulness_rating DECIMAL(3,2) DEFAULT 0,
    overall_average DECIMAL(3,2) DEFAULT 0,
    positive_count INT DEFAULT 0,
    neutral_count INT DEFAULT 0,
    negative_count INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER update_feedback_stats
    AFTER INSERT ON Feedback
    FOR EACH ROW
BEGIN
    -- Insert or update statistics
    INSERT INTO Feedback_Stats (faculty_id, total_feedbacks) 
    VALUES (NEW.facultyId, 1)
    ON DUPLICATE KEY UPDATE
        total_feedbacks = total_feedbacks + 1,
        avg_teaching_rating = (
            SELECT AVG(JSON_EXTRACT(ratings, '$.teaching')) 
            FROM Feedback 
            WHERE facultyId = NEW.facultyId
        ),
        avg_communication_rating = (
            SELECT AVG(JSON_EXTRACT(ratings, '$.communication')) 
            FROM Feedback 
            WHERE facultyId = NEW.facultyId
        ),
        avg_punctuality_rating = (
            SELECT AVG(JSON_EXTRACT(ratings, '$.punctuality')) 
            FROM Feedback 
            WHERE facultyId = NEW.facultyId
        ),
        avg_knowledge_rating = (
            SELECT AVG(JSON_EXTRACT(ratings, '$.knowledge')) 
            FROM Feedback 
            WHERE facultyId = NEW.facultyId
        ),
        avg_helpfulness_rating = (
            SELECT AVG(JSON_EXTRACT(ratings, '$.helpfulness')) 
            FROM Feedback 
            WHERE facultyId = NEW.facultyId
        ),
        overall_average = (
            SELECT AVG((
                JSON_EXTRACT(ratings, '$.teaching') + 
                JSON_EXTRACT(ratings, '$.communication') + 
                JSON_EXTRACT(ratings, '$.punctuality') + 
                JSON_EXTRACT(ratings, '$.knowledge') + 
                JSON_EXTRACT(ratings, '$.helpfulness')
            ) / 5) FROM Feedback 
            WHERE facultyId = NEW.facultyId
        ),
        positive_count = (
            SELECT COUNT(*) FROM Feedback 
            WHERE facultyId = NEW.facultyId AND sentiment = 'Positive'
        ),
        neutral_count = (
            SELECT COUNT(*) FROM Feedback 
            WHERE facultyId = NEW.facultyId AND sentiment = 'Neutral'
        ),
        negative_count = (
            SELECT COUNT(*) FROM Feedback 
            WHERE facultyId = NEW.facultyId AND sentiment = 'Negative'
        );
END$$

DELIMITER ;

-- ----------------------------------------------------------------
-- 5. TRIGGER: Student activity logging
-- ----------------------------------------------------------------

CREATE TABLE Student_Activity_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(191),
    activity_type VARCHAR(50),
    activity_details TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_student_timestamp (student_id, timestamp)
);

-- ----------------------------------------------------------------
-- HOW TO TEST THESE TRIGGERS:
-- ----------------------------------------------------------------

/*
-- Test feedback sentiment trigger
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) 
VALUES (
    'test_feedback_1', 
    'student_id_here', 
    'faculty_id_here',
    'Excellent teaching!',
    '{"teaching": 5, "communication": 4, "punctuality": 5, "knowledge": 5, "helpfulness": 4}',
    ''
);

-- Check if sentiment was auto-set
SELECT * FROM Feedback WHERE id = 'test_feedback_1';

-- Check if statistics were updated
SELECT * FROM Feedback_Stats;

-- Test faculty audit trail
UPDATE Faculty SET name = 'Updated Name' WHERE id = 'faculty_id_here';

-- Check audit log
SELECT * FROM Faculty_Audit ORDER BY change_timestamp DESC LIMIT 5;

-- Test deletion prevention
-- This should fail if faculty has feedbacks
DELETE FROM Faculty WHERE id = 'faculty_id_here';
*/

-- ================================================================
-- 🎯 TRIGGER MANAGEMENT COMMANDS
-- ================================================================

-- Show all triggers
-- SHOW TRIGGERS;

-- Drop a trigger if needed
-- DROP TRIGGER IF EXISTS update_feedback_sentiment;

-- Show trigger definition
-- SHOW CREATE TRIGGER update_feedback_sentiment;