-- ============================================================================
--  COURSE REGISTRATION MANAGEMENT SYSTEM
--  Full database: schema + sample data + views
--  Target: MySQL 8.x / MariaDB 10.x
--  Run:    mysql -u root -p < course_registration.sql
-- ============================================================================
--  Six tables : student, phone, course, faculty, enroll, teaches
--  Relationships:
--    student 1--* phone          (a student can have many phone numbers)
--    student *--* course         via enroll   (many-to-many)
--    faculty *--1 course         (faculty's primary assigned course)
--    faculty *--* course         via teaches  (many-to-many, across years)
-- ============================================================================

DROP DATABASE IF EXISTS course_registration;
CREATE DATABASE course_registration;
USE course_registration;

-- ---------------------------------------------------------------------------
-- 1. STUDENT  (primary key: student_id)
-- ---------------------------------------------------------------------------
CREATE TABLE student (
    student_id    INT PRIMARY KEY,
    sfirst_name   VARCHAR(20) NOT NULL,
    smiddle_name  VARCHAR(20),
    slast_name    VARCHAR(20),
    smail         VARCHAR(30),
    sdob          DATE,
    sage          INT,
    saddress      VARCHAR(50)          -- "<area>, <city>"  (city = text after comma)
);

-- ---------------------------------------------------------------------------
-- 2. COURSE  (primary key: course_id)  -- created before faculty (FK target)
-- ---------------------------------------------------------------------------
CREATE TABLE course (
    course_id    INT PRIMARY KEY,
    course_name  VARCHAR(20) NOT NULL,
    credits      INT
);

-- ---------------------------------------------------------------------------
-- 3. FACULTY  (primary key: faculty_id;  course_id -> course)
-- ---------------------------------------------------------------------------
CREATE TABLE faculty (
    faculty_id    INT PRIMARY KEY,
    faculty_name  VARCHAR(30) NOT NULL,
    faculty_mail  VARCHAR(30),
    course_id     INT,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE SET NULL
);

-- ---------------------------------------------------------------------------
-- 4. PHONE  (multivalued attribute of student -> its own table)
--    composite key (student_id, phone_number); cascade on student delete
-- ---------------------------------------------------------------------------
CREATE TABLE phone (
    student_id    INT,
    phone_number  BIGINT,
    PRIMARY KEY (student_id, phone_number),
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 5. ENROLL  (student *--* course;  composite key student_id+course_id)
-- ---------------------------------------------------------------------------
CREATE TABLE enroll (
    student_id     INT,
    course_id      INT,
    date_of_enroll DATE,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES course(course_id)  ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------
-- 6. TEACHES  (faculty *--* course across years; key faculty_id+course_id+year)
-- ---------------------------------------------------------------------------
CREATE TABLE teaches (
    faculty_id INT,
    course_id  INT,
    year       YEAR,
    PRIMARY KEY (faculty_id, course_id, year),
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES course(course_id)  ON DELETE CASCADE
);

-- ===========================================================================
--  SAMPLE DATA
-- ===========================================================================

-- 15 students (ids 101-115), spread across several cities; id 109 is the oldest
INSERT INTO student
    (student_id, sfirst_name, smiddle_name, slast_name, smail, sdob, sage, saddress) VALUES
(101,'Meghana', NULL,     'Sastry', 'meghana101@srmap.edu.in','2004-03-14',21,'12 MG Road, Guntur'),
(102,'Ruhi',    NULL,     'Sheikh', 'ruhi102@srmap.edu.in',   '2005-06-22',20,'8 Benz Circle, Vijayawada'),
(103,'Jahnavi', 'Lakshmi','Marri',  'jahnavi103@srmap.edu.in','2004-01-30',21,'45 Brodipet, Guntur'),
(104,'Arjun',   NULL,     'Reddy',  'arjun104@srmap.edu.in',  '2003-09-10',22,'21 Jubilee Hills, Hyderabad'),
(105,'Priya',   NULL,     'Nair',   'priya105@srmap.edu.in',  '2005-02-17',20,'3 Governorpet, Vijayawada'),
(106,'Karthik', 'Sai',    'Rao',    'karthik106@srmap.edu.in','2004-11-05',21,'77 Lakshmipuram, Guntur'),
(107,'Sneha',   NULL,     'Iyer',   'sneha107@srmap.edu.in',  '2003-12-01',22,'9 T Nagar, Chennai'),
(108,'Rohan',   NULL,     'Das',    'rohan108@srmap.edu.in',  '2005-04-19',20,'14 Banjara Hills, Hyderabad'),
(109,'Vikram',  'Raj',    'Menon',  'vikram109@srmap.edu.in', '2002-08-25',23,'5 Beach Road, Visakhapatnam'),
(110,'Ananya',  NULL,     'Gupta',  'ananya110@srmap.edu.in', '2006-05-30',19,'30 Arundelpet, Guntur'),
(111,'Aditya',  NULL,     'Sharma', 'aditya111@srmap.edu.in', '2004-07-07',21,'62 Patamata, Vijayawada'),
(112,'Divya',   'Anne',   'Pillai', 'divya112@srmap.edu.in',  '2005-10-12',20,'18 Adyar, Chennai'),
(113,'Harsha',  NULL,     'Varma',  'harsha113@srmap.edu.in', '2003-03-03',22,'27 Kukatpally, Hyderabad'),
(114,'Nisha',   NULL,     'Khan',   'nisha114@srmap.edu.in',  '2005-01-09',20,'4 Nallapadu, Guntur'),
(115,'Sanjay',  'Kumar',  'Varma',  'sanjay115@srmap.edu.in', '2004-09-21',21,'11 MVP Colony, Visakhapatnam');

-- one phone per student (table allows many; composite key supports it)
INSERT INTO phone (student_id, phone_number) VALUES
(101,9876500101),(102,9876500102),(103,9876500103),(104,9876500104),(105,9876500105),
(106,9876500106),(107,9876500107),(108,9876500108),(109,9876500109),(110,9876500110),
(111,9876500111),(112,9876500112),(113,9876500113),(114,9876500114),(115,9876500115);

-- 5 courses
INSERT INTO course (course_id, course_name, credits) VALUES
(1,'Database Systems', 4),
(2,'Operating Systems',4),
(3,'Data Structures',  3),
(4,'Computer Networks',3),
(5,'Machine Learning', 4);

-- 10 faculty (2 primarily assigned per course)
INSERT INTO faculty (faculty_id, faculty_name, faculty_mail, course_id) VALUES
(1, 'Dr. Mohammad Abdussami','abdussami@srmap.edu.in',1),
(2, 'Dr. Srinivas Rao',      'srao@srmap.edu.in',     1),
(3, 'Dr. Anita Sharma',      'asharma@srmap.edu.in',  2),
(4, 'Dr. Ramesh Iyer',       'riyer@srmap.edu.in',    2),
(5, 'Dr. Kavita Reddy',      'kreddy@srmap.edu.in',   3),
(6, 'Dr. Suresh Nair',       'snair@srmap.edu.in',    3),
(7, 'Dr. Pooja Gupta',       'pgupta@srmap.edu.in',   4),
(8, 'Dr. Vijay Menon',       'vmenon@srmap.edu.in',   4),
(9, 'Dr. Arun Das',          'adas@srmap.edu.in',     5),
(10,'Dr. Imran Khan',        'ikhan@srmap.edu.in',    5);

-- 15 enrollments; 101 and 112 take two courses each; 114/115 take none (valid)
INSERT INTO enroll (student_id, course_id, date_of_enroll) VALUES
(101,1,'2024-07-15'),
(101,3,'2024-07-16'),
(102,1,'2024-07-15'),
(103,1,'2024-07-17'),
(104,2,'2024-07-18'),
(105,2,'2024-07-18'),
(106,3,'2024-07-19'),
(107,3,'2024-07-20'),
(108,4,'2024-07-21'),
(109,4,'2024-07-22'),
(110,5,'2024-07-23'),
(111,5,'2024-07-24'),
(112,1,'2024-07-25'),
(112,2,'2024-07-26'),
(113,3,'2024-07-27');

-- 15 teaching records; faculty 1,2,3,6,9 each teach more than one course
INSERT INTO teaches (faculty_id, course_id, year) VALUES
(1, 1,2023),
(1, 2,2024),
(2, 1,2024),
(2, 2,2025),
(3, 2,2023),
(3, 3,2024),
(4, 2,2025),
(5, 3,2023),
(6, 3,2024),
(6, 4,2025),
(7, 4,2023),
(8, 4,2024),
(9, 5,2023),
(9, 1,2024),
(10,5,2024);

-- ===========================================================================
--  VIEWS
-- ===========================================================================

-- which student is in which course, with the enrollment date
CREATE OR REPLACE VIEW student_course_view AS
    SELECT s.student_id, s.sfirst_name, s.slast_name, c.course_name, e.date_of_enroll
    FROM student s
    JOIN enroll e ON s.student_id = e.student_id
    JOIN course c ON e.course_id  = c.course_id;

-- faculty mapped to their primary assigned course
CREATE OR REPLACE VIEW faculty_course_view AS
    SELECT f.faculty_id, f.faculty_name, c.course_name
    FROM faculty f
    JOIN course c ON f.course_id = c.course_id;

-- every student with their phone (students without a phone still appear)
CREATE OR REPLACE VIEW student_phone_view AS
    SELECT s.student_id, s.sfirst_name, s.slast_name, p.phone_number
    FROM student s
    LEFT JOIN phone p ON s.student_id = p.student_id;

-- number of students enrolled in each course (0 for courses with none)
CREATE OR REPLACE VIEW course_student_count_view AS
    SELECT c.course_name, COUNT(e.student_id) AS total_students
    FROM course c
    LEFT JOIN enroll e ON c.course_id = e.course_id
    GROUP BY c.course_name;

-- faculty who teach more than one course (per the teaches table)
CREATE OR REPLACE VIEW multi_course_faculty_view AS
    SELECT f.faculty_name, COUNT(DISTINCT t.course_id) AS total_courses
    FROM faculty f
    JOIN teaches t ON f.faculty_id = t.faculty_id
    GROUP BY f.faculty_id, f.faculty_name
    HAVING COUNT(DISTINCT t.course_id) > 1;

-- number of students per city
CREATE OR REPLACE VIEW city_wise_student_count AS
    SELECT TRIM(SUBSTRING_INDEX(saddress, ',', -1)) AS city, COUNT(*) AS student_count
    FROM student
    GROUP BY city;

-- detailed faculty / course / year mapping
CREATE OR REPLACE VIEW faculty_teaching_year_view AS
    SELECT f.faculty_name, c.course_name, t.year
    FROM faculty f
    JOIN teaches t ON f.faculty_id = t.faculty_id
    JOIN course  c ON t.course_id  = c.course_id;

-- Quick confirmation after load
SELECT 'student' AS tbl, COUNT(*) AS rows_loaded FROM student
UNION ALL SELECT 'phone',   COUNT(*) FROM phone
UNION ALL SELECT 'course',  COUNT(*) FROM course
UNION ALL SELECT 'faculty', COUNT(*) FROM faculty
UNION ALL SELECT 'enroll',  COUNT(*) FROM enroll
UNION ALL SELECT 'teaches', COUNT(*) FROM teaches;
