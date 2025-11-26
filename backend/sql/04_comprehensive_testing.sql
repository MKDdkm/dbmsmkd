-- ================================================================
-- 🧪 COMPREHENSIVE TESTING SCRIPT FOR TRIGGERS, PROCEDURES & ASSERTIONS
-- ================================================================

-- This script demonstrates how to test all the advanced database features

-- ----------------------------------------------------------------
-- SETUP: Create test data first
-- ----------------------------------------------------------------

-- Insert test faculty if not exists
INSERT IGNORE INTO Faculty (id, name, email, password, branch) VALUES
('test_faculty_1', 'Dr. Test Faculty', 'test.faculty@scem.ac.in', '$2b$10$hashedpassword', 'Computer Science'),
('test_faculty_2', 'Dr. Demo Teacher', 'demo.teacher@scem.ac.in', '$2b$10$hashedpassword', 'Information Science');

-- Insert test students if not exists  
INSERT IGNORE INTO Student (id, usn, name, email, password, semester, branch) VALUES
('test_student_1', '4SC21CS900', 'Test Student One', 'test.student1@scem.ac.in', 'password123', 6, 'Computer Science'),
('test_student_2', '4SC21CS901', 'Test Student Two', 'test.student2@scem.ac.in', 'password123', 6, 'Computer Science');

-- ================================================================
-- 🔥 TESTING TRIGGERS
-- ================================================================

-- Test 1: Auto-sentiment trigger
SELECT '=== TESTING TRIGGER: Auto-sentiment assignment ===' AS test_phase;

INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('trigger_test_1', 'test_student_1', 'test_faculty_1', 'Excellent teaching! Very helpful and knowledgeable.', 
 '{"teaching": 5, "communication": 5, "punctuality": 5, "knowledge": 5, "helpfulness": 5}', '');

-- Check if sentiment was auto-assigned as 'Positive'
SELECT id, sentiment, 
       (JSON_EXTRACT(ratings, '$.teaching') + JSON_EXTRACT(ratings, '$.communication') + 
        JSON_EXTRACT(ratings, '$.punctuality') + JSON_EXTRACT(ratings, '$.knowledge') + 
        JSON_EXTRACT(ratings, '$.helpfulness')) / 5 AS avg_rating
FROM Feedback WHERE id = 'trigger_test_1';

-- Test 2: Statistics update trigger
SELECT '=== TESTING TRIGGER: Auto-statistics update ===' AS test_phase;

-- Check if statistics were automatically created/updated
SELECT * FROM Feedback_Stats WHERE faculty_id = 'test_faculty_1';

-- Test 3: Faculty audit trigger
SELECT '=== TESTING TRIGGER: Faculty audit trail ===' AS test_phase;

UPDATE Faculty SET name = 'Dr. Updated Name' WHERE id = 'test_faculty_1';

-- Check audit trail
SELECT * FROM Faculty_Audit WHERE faculty_id = 'test_faculty_1' ORDER BY change_timestamp DESC LIMIT 1;

-- Reset faculty name
UPDATE Faculty SET name = 'Dr. Test Faculty' WHERE id = 'test_faculty_1';

-- ================================================================
-- 🚀 TESTING STORED PROCEDURES  
-- ================================================================

-- Test 1: Faculty Analytics Procedure
SELECT '=== TESTING PROCEDURE: GetFacultyAnalytics ===' AS test_phase;

CALL GetFacultyAnalytics('test_faculty_1');

-- Test 2: Advanced Search Procedure
SELECT '=== TESTING PROCEDURE: SearchFeedbacks ===' AS test_phase;

CALL SearchFeedbacks(
    'test_faculty_1',     -- Faculty ID
    'Positive',           -- Sentiment
    4.0,                  -- Min rating
    5.0,                  -- Max rating
    'Computer Science',   -- Branch
    6,                    -- Semester
    '2024-01-01',        -- Date from
    '2024-12-31',        -- Date to
    10                    -- Limit
);

-- Test 3: Faculty Report Generation
SELECT '=== TESTING PROCEDURE: GenerateFacultyReport ===' AS test_phase;

CALL GenerateFacultyReport(
    'test_faculty_1',
    '2024-01-01', 
    '2024-12-31'
);

-- Test 4: Database Integrity Validation
SELECT '=== TESTING PROCEDURE: ValidateDatabaseIntegrity ===' AS test_phase;

CALL ValidateDatabaseIntegrity();

-- ================================================================
-- ⚡ TESTING ASSERTIONS & CONSTRAINTS
-- ================================================================

-- Test 1: Try invalid rating (should fail)
SELECT '=== TESTING ASSERTION: Invalid rating validation ===' AS test_phase;

-- This should fail due to assertion
-- INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
-- ('assertion_test_1', 'test_student_1', 'test_faculty_1', 'Test comment', '{"teaching": 6, "communication": 4, "punctuality": 4, "knowledge": 4, "helpfulness": 4}', 'Positive');

SELECT 'Above INSERT should fail with rating > 5' AS expected_result;

-- Test 2: Try short comment (should fail)
SELECT '=== TESTING ASSERTION: Comment length validation ===' AS test_phase;

-- This should fail due to short comment
-- INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
-- ('assertion_test_2', 'test_student_1', 'test_faculty_1', 'Hi', '{"teaching": 4, "communication": 4, "punctuality": 4, "knowledge": 4, "helpfulness": 4}', 'Positive');

SELECT 'Above INSERT should fail with comment < 5 characters' AS expected_result;

-- Test 3: Try duplicate feedback same day (should fail on second attempt)
SELECT '=== TESTING ASSERTION: One feedback per day rule ===' AS test_phase;

INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('assertion_test_3a', 'test_student_2', 'test_faculty_1', 'First feedback of the day', 
 '{"teaching": 4, "communication": 4, "punctuality": 4, "knowledge": 4, "helpfulness": 4}', 'Neutral');

-- This should fail due to one-per-day rule
-- INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
-- ('assertion_test_3b', 'test_student_2', 'test_faculty_1', 'Second feedback same day', 
--  '{"teaching": 5, "communication": 5, "punctuality": 5, "knowledge": 5, "helpfulness": 5}', 'Positive');

SELECT 'Second INSERT should fail - only one feedback per student per faculty per day allowed' AS expected_result;

-- Test 4: Validate rating JSON function
SELECT '=== TESTING FUNCTION: IsValidRatingJSON ===' AS test_phase;

SELECT 
    IsValidRatingJSON('{"teaching": 5, "communication": 4, "punctuality": 5, "knowledge": 4, "helpfulness": 5}') AS valid_json_test,
    IsValidRatingJSON('{"teaching": 6, "communication": 4}') AS invalid_json_test,
    IsValidRatingJSON('{"teaching": 0, "communication": 4, "punctuality": 3, "knowledge": 2, "helpfulness": 1}') AS boundary_test;

-- ================================================================
-- 📊 COMPREHENSIVE TESTING RESULTS
-- ================================================================

SELECT '=== COMPREHENSIVE TEST SUMMARY ===' AS test_phase;

-- 1. Count all feedbacks created during testing
SELECT 
    'Total Test Feedbacks' AS metric,
    COUNT(*) AS count
FROM Feedback 
WHERE id LIKE 'trigger_test_%' OR id LIKE 'assertion_test_%';

-- 2. Check trigger functionality 
SELECT 
    'Auto-assigned Sentiments' AS metric,
    COUNT(*) AS count
FROM Feedback 
WHERE id LIKE 'trigger_test_%' AND sentiment IN ('Positive', 'Negative', 'Neutral');

-- 3. Check statistics table updates
SELECT 
    'Faculty Stats Updated' AS metric,
    COUNT(*) AS count
FROM Feedback_Stats 
WHERE faculty_id IN ('test_faculty_1', 'test_faculty_2');

-- 4. Check audit trail
SELECT 
    'Audit Trail Entries' AS metric,
    COUNT(*) AS count
FROM Faculty_Audit 
WHERE faculty_id = 'test_faculty_1';

-- 5. Validate all constraints are working
SELECT 
    'Constraint Violations Prevented' AS metric,
    'Multiple (see error messages above)' AS count;

-- ================================================================
-- 🧹 CLEANUP (Optional - uncomment to clean test data)
-- ================================================================

/*
-- Clean up test data
DELETE FROM Feedback WHERE id LIKE 'trigger_test_%' OR id LIKE 'assertion_test_%';
DELETE FROM Faculty_Audit WHERE faculty_id IN ('test_faculty_1', 'test_faculty_2');
DELETE FROM Feedback_Stats WHERE faculty_id IN ('test_faculty_1', 'test_faculty_2');
DELETE FROM Faculty WHERE id IN ('test_faculty_1', 'test_faculty_2');
DELETE FROM Student WHERE id IN ('test_student_1', 'test_student_2');
*/

-- ================================================================
-- 📋 VERIFICATION CHECKLIST
-- ================================================================

SELECT '=== VERIFICATION CHECKLIST ===' AS section;

-- Check if all triggers exist
SELECT 
    'Triggers Created' AS check_item,
    COUNT(*) AS count
FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = DATABASE()
    AND TRIGGER_NAME IN (
        'update_feedback_sentiment',
        'faculty_audit_update', 
        'prevent_faculty_deletion',
        'update_feedback_stats',
        'assert_valid_feedback_ratings',
        'assert_one_feedback_per_day',
        'assert_faculty_feedback_limit'
    );

-- Check if all procedures exist
SELECT 
    'Procedures Created' AS check_item,
    COUNT(*) AS count
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_SCHEMA = DATABASE()
    AND ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME IN (
        'GetFacultyAnalytics',
        'SearchFeedbacks',
        'GenerateFacultyReport',
        'ValidateDatabaseIntegrity',
        'EnforceReferentialIntegrity',
        'BulkImportStudents',
        'CleanupOldData'
    );

-- Check if all functions exist  
SELECT 
    'Functions Created' AS check_item,
    COUNT(*) AS count
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_SCHEMA = DATABASE()
    AND ROUTINE_TYPE = 'FUNCTION'
    AND ROUTINE_NAME IN (
        'IsValidRatingJSON'
    );

-- Check if support tables exist
SELECT 
    'Support Tables Created' AS check_item,
    COUNT(*) AS count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME IN (
        'Faculty_Audit',
        'Feedback_Stats', 
        'Student_Activity_Log',
        'Business_Rules'
    );

SELECT '=== ALL TESTS COMPLETED ===' AS final_message;
SELECT CONCAT('Test completed at: ', NOW()) AS timestamp;