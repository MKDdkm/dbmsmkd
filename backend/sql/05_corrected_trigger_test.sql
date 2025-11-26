-- ================================================================
-- 🚀 CORRECTED TRIGGER TESTING SCRIPT
-- ================================================================

-- First, clean up any previous test data
DELETE FROM Feedback WHERE id LIKE 'demo_test%' OR id LIKE 'trigger_test_%';

-- ================================================================
-- Step 1: Get actual IDs from your database
-- ================================================================

-- Check your actual faculty and student IDs
SELECT 'Your Faculty IDs:' AS info;
SELECT id, name, email FROM Faculty LIMIT 5;

SELECT 'Your Student IDs:' AS info;
SELECT id, name, usn FROM Student LIMIT 5;

-- ================================================================
-- Step 2: Test Auto-Sentiment Trigger (POSITIVE FEEDBACK)
-- ================================================================

-- Replace 'cmhxob8j40004ivi0d7ufoper' with your actual faculty ID
-- Replace 'your_student_id_here' with your actual student ID

INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('trigger_test_positive_1', 
 (SELECT id FROM Student LIMIT 1), 
 'cmhxob8j40004ivi0d7ufoper', 
 'Excellent teaching! Very knowledgeable and helpful professor.',
 '{"teaching": 5, "communication": 5, "punctuality": 5, "knowledge": 5, "helpfulness": 5}', 
 '');

-- Check if sentiment was automatically set to 'Positive'
SELECT 
    id,
    comment,
    sentiment AS auto_assigned_sentiment,
    (JSON_EXTRACT(ratings, '$.teaching') + JSON_EXTRACT(ratings, '$.communication') + 
     JSON_EXTRACT(ratings, '$.punctuality') + JSON_EXTRACT(ratings, '$.knowledge') + 
     JSON_EXTRACT(ratings, '$.helpfulness')) / 5 AS calculated_average,
    createdAt
FROM Feedback 
WHERE id = 'trigger_test_positive_1';

-- ================================================================
-- Step 3: Test Auto-Sentiment Trigger (NEUTRAL FEEDBACK)
-- ================================================================

INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('trigger_test_neutral_1', 
 (SELECT id FROM Student LIMIT 1), 
 'cmhxob8j40004ivi0d7ufoper', 
 'Average teaching, could improve communication skills.',
 '{"teaching": 3, "communication": 3, "punctuality": 3, "knowledge": 3, "helpfulness": 3}', 
 '');

-- Check if sentiment was automatically set to 'Neutral'
SELECT 
    id,
    comment,
    sentiment AS auto_assigned_sentiment,
    (JSON_EXTRACT(ratings, '$.teaching') + JSON_EXTRACT(ratings, '$.communication') + 
     JSON_EXTRACT(ratings, '$.punctuality') + JSON_EXTRACT(ratings, '$.knowledge') + 
     JSON_EXTRACT(ratings, '$.helpfulness')) / 5 AS calculated_average
FROM Feedback 
WHERE id = 'trigger_test_neutral_1';

-- ================================================================
-- Step 4: Test Auto-Sentiment Trigger (NEGATIVE FEEDBACK)
-- ================================================================

INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('trigger_test_negative_1', 
 (SELECT id FROM Student LIMIT 1), 
 'cmhxob8j40004ivi0d7ufoper', 
 'Poor teaching quality, often late to class and unclear explanations.',
 '{"teaching": 2, "communication": 2, "punctuality": 1, "knowledge": 2, "helpfulness": 2}', 
 '');

-- Check if sentiment was automatically set to 'Negative'
SELECT 
    id,
    comment,
    sentiment AS auto_assigned_sentiment,
    (JSON_EXTRACT(ratings, '$.teaching') + JSON_EXTRACT(ratings, '$.communication') + 
     JSON_EXTRACT(ratings, '$.punctuality') + JSON_EXTRACT(ratings, '$.knowledge') + 
     JSON_EXTRACT(ratings, '$.helpfulness')) / 5 AS calculated_average
FROM Feedback 
WHERE id = 'trigger_test_negative_1';

-- ================================================================
-- Step 5: Check if Statistics were Auto-Updated
-- ================================================================

-- This should show updated statistics for the faculty
SELECT 
    faculty_id,
    total_feedbacks,
    overall_average,
    positive_count,
    neutral_count, 
    negative_count,
    last_updated
FROM Feedback_Stats 
WHERE faculty_id = 'cmhxob8j40004ivi0d7ufoper';

-- ================================================================
-- Step 6: Test Faculty Audit Trigger
-- ================================================================

-- Update faculty name to trigger audit
UPDATE Faculty 
SET name = 'Vidya VV (Updated)' 
WHERE id = 'cmhxob8j40004ivi0d7ufoper';

-- Check audit trail
SELECT 
    faculty_id,
    action_type,
    old_name,
    new_name,
    changed_by,
    change_timestamp
FROM Faculty_Audit 
WHERE faculty_id = 'cmhxob8j40004ivi0d7ufoper'
ORDER BY change_timestamp DESC 
LIMIT 1;

-- Reset faculty name back
UPDATE Faculty 
SET name = 'Vidya VV' 
WHERE id = 'cmhxob8j40004ivi0d7ufoper';

-- ================================================================
-- Step 7: Test Constraint Validation (These should FAIL)
-- ================================================================

-- Test 1: Try invalid rating (should fail)
-- Uncomment the line below to test (it will fail)
/*
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('should_fail_1', 
 (SELECT id FROM Student LIMIT 1), 
 'cmhxob8j40004ivi0d7ufoper', 
 'This should fail due to invalid rating',
 '{"teaching": 6, "communication": 4, "punctuality": 4, "knowledge": 4, "helpfulness": 4}', 
 'Positive');
*/

-- Test 2: Try short comment (should fail)
-- Uncomment the line below to test (it will fail)
/*
INSERT INTO Feedback (id, studentId, facultyId, comment, ratings, sentiment) VALUES
('should_fail_2', 
 (SELECT id FROM Student LIMIT 1), 
 'cmhxob8j40004ivi0d7ufoper', 
 'Hi',
 '{"teaching": 4, "communication": 4, "punctuality": 4, "knowledge": 4, "helpfulness": 4}', 
 'Neutral');
*/

-- ================================================================
-- Step 8: Test Stored Procedures
-- ================================================================

-- Test faculty analytics procedure
CALL GetFacultyAnalytics('cmhxob8j40004ivi0d7ufoper');

-- ================================================================
-- Step 9: Summary of All Tests
-- ================================================================

SELECT 'TRIGGER TEST RESULTS SUMMARY' AS test_summary;

SELECT 
    'Sentiment Assignment Tests' AS test_type,
    COUNT(*) AS tests_run,
    COUNT(DISTINCT sentiment) AS different_sentiments_assigned
FROM Feedback 
WHERE id LIKE 'trigger_test_%';

SELECT 
    'Individual Test Results' AS breakdown,
    id,
    sentiment,
    (JSON_EXTRACT(ratings, '$.teaching') + JSON_EXTRACT(ratings, '$.communication') + 
     JSON_EXTRACT(ratings, '$.punctuality') + JSON_EXTRACT(ratings, '$.knowledge') + 
     JSON_EXTRACT(ratings, '$.helpfulness')) / 5 AS avg_rating
FROM Feedback 
WHERE id LIKE 'trigger_test_%'
ORDER BY id;

-- Check if all triggers are installed
SELECT 
    'Installed Triggers' AS info,
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    ACTION_TIMING
FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = DATABASE()
ORDER BY TRIGGER_NAME;

-- ================================================================
-- 🎉 EXPECTED RESULTS:
-- ================================================================
/*
1. trigger_test_positive_1 should have sentiment = 'Positive' (avg = 5.0)
2. trigger_test_neutral_1 should have sentiment = 'Neutral' (avg = 3.0)  
3. trigger_test_negative_1 should have sentiment = 'Negative' (avg = 1.8)
4. Feedback_Stats should show updated counts for the faculty
5. Faculty_Audit should have an entry for the name change
6. Invalid rating and short comment inserts should fail with error messages
7. GetFacultyAnalytics should return comprehensive data
*/

SELECT 'ALL TRIGGER TESTS COMPLETED! ✅' AS final_message;