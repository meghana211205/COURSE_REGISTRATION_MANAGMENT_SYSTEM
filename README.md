# Course Registration Management System (MySQL)

A relational database that manages the core entities of an academic department —
students, phone numbers, courses, faculty, enrollments, and teaching
assignments — with primary/foreign-key integrity, normalized tables (up to 3NF),
analytical SQL (subqueries, aggregates, joins), and reporting views.

This is the runnable implementation of the design in the project report: same six
tables, same relationships, same queries and views. Everything here has been
executed on MySQL/MariaDB and verified to return the results noted below.

## Files

```
sql/course_registration.sql   database + tables + sample data + 7 views (run first)
sql/queries.sql               the analytical queries from the report (run anytime)
README.md                     this file
```

## How to run

**MySQL 8.x**
```bash
mysql -u root -p < sql/course_registration.sql     # create DB, tables, data, views
mysql -u root -p course_registration < sql/queries.sql
```

**MariaDB 10.x** — identical, just use `mariadb` instead of `mysql`.

Loading the schema file prints a row-count summary so you can confirm the load:

```
+---------+-------------+
| tbl     | rows_loaded |
+---------+-------------+
| student |          15 |
| phone   |          15 |
| course  |           5 |
| faculty |          10 |
| enroll  |          15 |
| teaches |          15 |
+---------+-------------+
```

## Schema at a glance

| Table     | Key                              | Notes                                         |
|-----------|----------------------------------|-----------------------------------------------|
| `student` | `student_id` (PK)                | name parts, email, DOB, age, address          |
| `phone`   | (`student_id`,`phone_number`)    | FK→student, `ON DELETE CASCADE`               |
| `course`  | `course_id` (PK)                 | name, credits                                 |
| `faculty` | `faculty_id` (PK)                | FK `course_id`→course (primary assigned course) |
| `enroll`  | (`student_id`,`course_id`)       | FK→student, FK→course; enrollment date        |
| `teaches` | (`faculty_id`,`course_id`,`year`)| FK→faculty, FK→course                         |

Relationships: `student 1—* phone`, `student *—* course` via `enroll`,
`faculty *—* course` via `teaches` (across years).

## What the queries demonstrate (verified output)

| # | Query (concept)                              | Result on the sample data            |
|---|----------------------------------------------|--------------------------------------|
| 1 | Students in the same course as #101 (subquery) | 102, 103, 112, 106, 107, 113         |
| 2 | Student with the maximum age (scalar subquery)  | Vikram Menon (109), age 23           |
| 3 | Enrollments per city (aggregate + `GROUP BY`)   | Guntur 5, then Chennai/Hyderabad/Vijayawada 3, Vizag 1 |
| 4 | Most-enrolled course (nested aggregate)         | Database Systems (4 students)        |
| 5 | Student × course × faculty (3-way join)         | two faculty rows per enrollment      |
| 6 | Students in more than one course (`HAVING`)     | Meghana (101) and Divya (112)        |

## Views

`student_course_view`, `faculty_course_view`, `student_phone_view` (LEFT JOIN so
students with no phone still appear), `course_student_count_view`,
`multi_course_faculty_view` (faculty teaching >1 course — returns 5 on this data),
`city_wise_student_count`, and `faculty_teaching_year_view`.

## Design notes

- **Normalization (3NF).** `phone` is split out because a student may have
  multiple numbers (removes the multivalued attribute). The full faculty↔course
  many-to-many lives in `teaches`, which also carries the `year`; `faculty.course_id`
  is kept as the faculty's primary assigned course (matching the report's ER
  diagram and views). To make `faculty` strictly 3NF you can drop `faculty.course_id`
  and rely solely on `teaches` — the report discusses exactly this trade-off.
- **Referential integrity.** All child rows use `ON DELETE CASCADE`
  (`faculty.course_id` uses `SET NULL`), so deleting a student automatically
  removes their phone and enrollment rows — verified.
- **`multi_course_faculty_view`** uses `COUNT(DISTINCT course_id)` so a faculty
  who teaches the *same* course in two different years isn't miscounted as two
  courses.
- **Portability.** Uses only standard features plus `SUBSTRING_INDEX` (MySQL/
  MariaDB) for the "city from address" reports.

## Résumé / viva talking points

- Designed a normalized (3NF) relational schema of six tables with PK/FK
  constraints and cascading deletes to guarantee referential integrity.
- Modeled two many-to-many relationships through junction tables (`enroll`,
  `teaches`), the latter carrying relationship-level data (`year`).
- Wrote analytical SQL across all three required categories — correlated/nested
  subqueries, aggregate functions with `GROUP BY`/`HAVING`, and multi-table joins.
- Built reusable reporting views, including outer-join and distinct-count views.
- Can explain the 3NF trade-off in the `faculty` table and when denormalization
  is acceptable.

## Possible extensions (if you want to grow it)

- `credits`-based constraints and a trigger that blocks over-enrollment.
- A stored procedure `enroll_student(sid, cid)` with validation.
- Indexes on `enroll(course_id)` / `teaches(course_id)` and `EXPLAIN` before/after.
- A small front-end (Python/Flask or PHP) over these tables and views.
```
