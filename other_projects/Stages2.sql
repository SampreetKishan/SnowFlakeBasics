-- If you have not created the database EXERCISE_DB then you can do so. The same goes for the customer table with the following columns:
-- ID INT,
-- first_name varchar,
-- last_name varchar,
-- email varchar,
-- age int,
-- city varchar
SELECT * from EXERCISE_DB.PUBLIC.CUSTOMERS LIMIT 10; 


--1. Create a database called EXERCISE_DB (if you have created that in one of the previous lectures you can skip this step)

-- DESCRIBE EXERCISE_DB; 


--2. Create a stage object
-- The data is available under: s3://snowflake-assignments-mc/loadingdata/
-- Data type: CSV - delimited by ';' (semicolon)
-- Header is in the first line.

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_exercise"
url = s3://snowflake-assignments-mc/loadingdata/

DESC stage manage_db."external_stages"."aws_stage_exercise";

-- 3. List the files in the table
LIST @manage_db."external_stages"."aws_stage_exercise"; 

-- 4. Load the data in the existing customers table using the COPY command
select * from exercise_db.public.customers limit 10; 
-- initial count
select count(*) from exercise_db.public.customers limit 10; 
-- initial count = 1000

COPY INTO exercise_db.public.customers 
FROM @manage_db."external_stages"."aws_stage_exercise"
file_format = (type = csv field_delimiter=';' skip_header=1)
files = ('customers2.csv', 'customers3.csv'); 

-- 4. How many rows have been loaded in this assignment?
select count(*) from exercise_db.public.customers ; 

-- final count : 2600. So, the answer is 2600 - 1000 = 1600.

