-- 1. Create a table called employees with the following columns and data types:
-- customer_id int,
-- first_name varchar(50),
-- last_name varchar(50),
-- email varchar(50),
-- age int,
-- department varchar(50)


select * from exercise_db.public.employees limit 10; 

CREATE OR REPLACE TABLE exercise_db.public.employees (
    CUSTOMER_ID INT,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    EMAIL VARCHAR(50),
    AGE INT,
    DEPARTMENT VARCHAR(50)

);

-- 2. Create a stage object pointing to's3://snowflake-assignments-mc/copyoptions/example2'

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_assignment5"
url= s3://snowflake-assignments-mc/copyoptions/example2;

LIST @manage_db."external_stages"."aws_stage_assignment5";

-- 3. Create a file format object with the specification
-- TYPE = CSV
-- FIELD_DELIMITER=','
-- SKIP_HEADER=1;

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."assignment_5"; 

DESC FILE FORMAT manage_db."file_formats"."assignment_5"; 
ALTER FILE FORMAT manage_db."file_formats"."assignment_5" 
SET SKIP_HEADER=1; 
DESC FILE FORMAT manage_db."file_formats"."assignment_5"; 

-- 4. Use the copy option to only validate if there are errors and if yes what errors.

COPY INTO exercise_db.public.employees
FROM @manage_db."external_stages"."aws_stage_assignment5"
FILE_FORMAT = (FORMAT_NAME=manage_db."file_formats"."assignment_5")
VALIDATION_MODE = "RETURN_ERRORS";

-- 5. One value in the first_name column has more than 50 characters. We assume the table column properties could not be changed.
-- What option could you use to load that record anyways and just truncate the value after 50 characters?
-- Load the data in the table using that option.

COPY INTO exercise_db.public.employees
FROM @manage_db."external_stages"."aws_stage_assignment5"
FILE_FORMAT = (FORMAT_NAME=manage_db."file_formats"."assignment_5")
TRUNCATECOLUMNS = TRUE; 
--VALIDATION_MODE = "RETURN_ERRORS";

select count(*) from exercise_db.public.employees; 

