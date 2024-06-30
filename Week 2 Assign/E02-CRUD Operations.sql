use Assignment1;
GO

--*****************************
DROP TABLE courses;
GO
--*****************************


--EXERCISE 1

-- Create courses table
CREATE TABLE courses(
	course_id int IDENTITY NOT NULL,
	course_name VARCHAR(60) NOT NULL,
	course_author VARCHAR(40) NOT NULL,
	course_status VARCHAR(10) NOT NULL,
	course_published_dt DATE,
);
GO

ALTER TABLE courses
ADD CONSTRAINT pk_course_id PRIMARY KEY (course_id);
GO

ALTER TABLE courses
ADD CONSTRAINT chk_course_status CHECK (course_status IN ('published', 'draft', 'inactive'));
GO



-- EXCERCISE 2

-- Insert data into courses using the data provided. Make sure id is system generated.
INSERT INTO courses(course_name, course_author, course_status, course_published_dt)
VALUES
	('Programming using Python', 'Bob Dillon', 'published', '2020-09-30'),
	('Data Engineering using Python', 'Bob Dillon', 'published', '2020-07-15'),
	('Data Engineering using Scala', 'Elvis Presley', 'draft', NULL),
	('Programming using Scala', 'Elvis Presley', 'published', '2020-05-12'),
	('Programming using Java', 'Mike Jack', 'inactive', '2020-08-10'),
	('Web Applications - Python Flask', 'Bob Dillon', 'inactive', '2020-07-20'),
	('Web Applications - Java Spring', 'Mike Jack', 'draft', NULL),
	('Pipeline Orchestration - Python', 'Bob Dillon', 'draft', NULL),
	('Streaming Pipelines - Python', 'Bob Dillon', 'published', '2020-10-05'),
	('Web Applications - Scala Play', 'Elvis Presley', 'inactive', '2020-09-30'),
	('Web Applications - Python Django', 'Bob Dillon', 'published', '2020-06-23'),
	('Server Automation - Ansible', 'Uncle Sam', 'published', '2020-07-05');
GO



SELECT * FROM courses;
GO



-- EXCERCISE 3

-- Update the status of all the **draft courses** related to Python and Scala to **published** along with the **course_published_dt using system date**. 
UPDATE courses
SET course_status = 'published',
	course_published_dt = GETDATE()
WHERE course_status = 'draft'
AND (course_name LIKE '%Python%' OR course_name LIKE '%Scala%');
GO


SELECT * FROM courses;
GO



-- EXCERCISE 4

-- Delete all the courses which are neither in draft mode nor published.
DELETE FROM courses
WHERE course_status NOT IN ('draft', 'published');
go


-- Validation: Get count of all published courses by author
SELECT course_author, count(1) AS course_count
FROM courses
WHERE course_status = 'published'
GROUP BY course_author
ORDER BY course_count DESC;
GO



--*****************************

SELECT * FROM courses;
GO


DROP TABLE courses;
GO

--*****************************