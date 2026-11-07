-- ============================================================================
--  COURSE REGISTRATION MANAGEMENT SYSTEM - analytical queries
--  Run after loading the database:
--      mysql -u root -p course_registration < queries.sql
--  (or paste individual queries into the MySQL client)
-- ============================================================================
USE course_registration;

-- ----------------------------------------------------------------------------
-- SUBQUERIES
-- ----------------------------------------------------------------------------

-- Q1. Students enrolled in the same course(s) as student 101.
--     Expected with sample data: 102, 103, 112 (share course 1),
--     and 106, 107, 113 (share course 3).
SELECT DISTINCT s.student_id, s.sfirst_name, s.slast_name
FROM student s
WHERE s.student_id IN (
    SELECT e2.student_id
    FROM enroll e1
    JOIN enroll e2 ON e1.course_id = e2.course_id
    WHERE e1.student_id = 101 AND e2.student_id <> 101
);

-- Q2. Student(s) with the maximum age.
--     Expected: Vikram Menon (109), age 23.
SELECT student_id, sfirst_name, slast_name, sage
FROM student
WHERE sage = (SELECT MAX(sage) FROM student);

-- ----------------------------------------------------------------------------
-- AGGREGATE FUNCTIONS
-- ----------------------------------------------------------------------------

-- Q3. Total number of enrollments per city.
SELECT TRIM(SUBSTRING_INDEX(saddress, ',', -1)) AS city,
       COUNT(e.student_id) AS total_enrollments
FROM student s
JOIN enroll e ON s.student_id = e.student_id
GROUP BY city
ORDER BY total_enrollments DESC;

-- Q4. Course with the highest number of students enrolled.
--     Expected: Database Systems (course 1 has 4 enrollments).
SELECT course_name
FROM course
WHERE course_id = (
    SELECT course_id
    FROM enroll
    GROUP BY course_id
    ORDER BY COUNT(student_id) DESC
    LIMIT 1
);

-- ----------------------------------------------------------------------------
-- JOINS
-- ----------------------------------------------------------------------------

-- Q5. Each student with the courses they take and the faculty for that course.
--     (Each course has two assigned faculty, so an enrollment yields two rows.)
SELECT s.sfirst_name, s.slast_name, c.course_name, f.faculty_name
FROM student s
JOIN enroll  e ON s.student_id = e.student_id
JOIN course  c ON e.course_id  = c.course_id
JOIN faculty f ON c.course_id  = f.course_id
ORDER BY s.student_id, c.course_name;

-- Q6. Students enrolled in more than one course.
--     Expected: Meghana (101) and Divya (112), course_count = 2 each.
SELECT s.student_id, s.sfirst_name, s.slast_name,
       COUNT(e.course_id) AS course_count
FROM student s
JOIN enroll e ON s.student_id = e.student_id
GROUP BY s.student_id, s.sfirst_name, s.slast_name
HAVING COUNT(e.course_id) > 1;

-- ----------------------------------------------------------------------------
-- VIEWS - quick demonstration (defined in course_registration.sql)
-- ----------------------------------------------------------------------------
SELECT * FROM student_course_view          ORDER BY student_id;
SELECT * FROM faculty_course_view          ORDER BY faculty_id;
SELECT * FROM student_phone_view           ORDER BY student_id;
SELECT * FROM course_student_count_view    ORDER BY total_students DESC;
SELECT * FROM multi_course_faculty_view    ORDER BY total_courses DESC;
SELECT * FROM city_wise_student_count      ORDER BY student_count DESC;
SELECT * FROM faculty_teaching_year_view   ORDER BY faculty_name, year;
