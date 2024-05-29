--If you have not created the database EXERCISE_DB then you can do so - otherwise use this database for this exercise.

--1. Query from the previously created JSON_RAW  table.

-- Note: This table was created in the previous assignment (assignment 7) where you had to create a stage object that is pointing to 's3://snowflake-assignments-mc/unstructureddata/'. We have called the table JSON_RAW.

LIST @manage_db."external_stages"."aws_stage_assignment7"; 

CREATE or REPLACE file format manage_db."file_formats"."assignment_8"
type = json;

CREATE OR REPLACE TABLE exercise_db.public."assignment_8"
(
    RAW_DATA VARIANT
); 

COPY INTO exercise_db.public."assignment_8"
FROM @manage_db."external_stages"."aws_stage_assignment7"
files =('Jobskills.json')
FILE_FORMAT = (FORMAT_NAME=manage_db."file_formats"."assignment_8"); 

select * from exercise_db.public."assignment_8" limit 10; 


-- 2. Select the attributes
-- first_name
-- last_name
-- skills
--and query these columns.

SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:last_name::STRING as last_name,
    RAW_DATA:Skills as skills
FROM exercise_db.public."assignment_8";

-- 2. The skills column contains an array. Query the first two values in the skills attribute for every record in a separate column:
-- first_name
-- last_name
-- skills_1
-- skills_2

SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:last_name::STRING as last_name,
    RAW_DATA:Skills[0]::STRING as skills_1,
    RAW_DATA:Skills[1]::STRING as skills_2
FROM exercise_db.public."assignment_8";

-- 3. Create a table and insert the data for these 4 columns in that table.

CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC."final_result_assignment_8" 
    AS
        (
            SELECT 
                RAW_DATA:first_name::STRING as first_name,
                RAW_DATA:last_name::STRING as last_name,
                RAW_DATA:Skills[0]::STRING as skills_1,
                RAW_DATA:Skills[1]::STRING as skills_2
            FROM exercise_db.public."assignment_8"
        );

-- Questions for this assignment
-- What is the first skill of the person with first_name 'Florina'?

-- select * from EXERCISE_DB.PUBLIC."final_result_assignment_8" ;

select skills_1 
from EXERCISE_DB.PUBLIC."final_result_assignment_8" 
where first_name='Florina'; 



--