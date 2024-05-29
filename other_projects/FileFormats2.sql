--If you have not created the database EXERCISE_DB then you can do so. The same goes for the customer table with the following columns:
-- ID INT,
-- first_name varchar,
-- last_name varchar,
-- email varchar,
-- age int,
-- city varchar

-- All of this is done. The table exists with 2600 rows


-- 1. Create a stage & file format object
-- The data is available under: s3://snowflake-assignments-mc/fileformat/
-- Data type: CSV - delimited by '|' (pipe)
-- Header is in the first line.

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_assignment_4"
url=s3://snowflake-assignments-mc/fileformat/
file_format = (field_delimiter="|" skip_header=1); 

-- 2. List the files in the table
LIST @manage_db."external_stages"."aws_stage_assignment_4"; 

-- s3://snowflake-assignments-mc/fileformat/customers4.csv

-- 3. Load the data in the existing customers table using the COPY command your stage and the created file format object.

-- let's in fact create another file format

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."assignment_4"; 

DESC FILE FORMAT manage_db."file_formats"."assignment_4";

DESC STAGE manage_db."external_stages"."aws_stage_assignment_4"; 

-- we can either use the file format attributes from the stage object OR the file format object. 
-- I have already edited the attributes for the stage object so we should be good to go.

select * from exercise_db.public.customers limit 10; 

--3. Load the data in the existing customers table using the COPY command your stage and the created file format object.

COPY INTO exercise_db.public.customers
FROM @manage_db."external_stages"."aws_stage_assignment_4"
files = ('customers4.csv')
on_error = "ABORT_STATEMENT"; 


-- 4. How many rows have been loaded in this assignment?

select count(*) from exercise_db.public.customers; 

-- Answer : 250 






