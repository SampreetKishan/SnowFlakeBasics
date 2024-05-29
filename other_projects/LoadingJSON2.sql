-- If you have not created the database EXERCISE_DB then you can do so - otherwise use this database for this exercise.

-- 1. Create a stage object that is pointing to 's3://snowflake-assignments-mc/unstructureddata/'

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_assignment7"
url='s3://snowflake-assignments-mc/unstructureddata/'; 

LIST @manage_db."external_stages"."aws_stage_assignment7"; 

-- 2. Create a file format object that is using TYPE = JSON

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."assignment_7"
type = json; 

-- 3. Create a table called JSON_RAW with one column
-- Column name: Raw
-- Column type: Variant

CREATE OR REPLACE TABLE exercise_db.public."JSON_RAW"(
    RAW VARIANT
);

-- 4. Copy the raw data in the JSON_RAW table using the file format object and stage object

COPY INTO exercise_db.public."JSON_RAW"
FROM @manage_db."external_stages"."aws_stage_assignment7"
files = ('Jobskills.json')
file_format = (FORMAT_NAME=manage_db."file_formats"."assignment_7"); 

--Questions for this assignment
-- What is the last name of the person in the first row (id=1)?

select * from exercise_db.public."JSON_RAW" limit 10; 