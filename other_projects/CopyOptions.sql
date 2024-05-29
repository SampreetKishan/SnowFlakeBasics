--1. Create a table called employees with the following columns and data types:
-- customer_id int,
-- first_name varchar(50),
-- last_name varchar(50),
-- email varchar(50),
-- age int,
-- department varchar(50)

CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.employees (
    CUSTOMER_ID INT,
    FIRST_NAME VARCHAR(30),
    LAST_NAME VARCHAR(30),
    EMAIL VARCHAR(50),
    AGE INT,
    DEPARTMENT VARCHAR(30)
); 

-- 2. Create a stage object pointing to 's3://snowflake-assignments-mc/copyoptions/example1'

CREATE OR REPLACE STAGE MANAGE_DB."external_stages"."aws_stage_asgn_section5_CopyOptions"
url=s3://snowflake-assignments-mc/copyoptions/example1;

LIST @MANAGE_DB."external_stages"."aws_stage_asgn_section5_CopyOptions"; 

-- 3. Create a file format object with the specification
-- TYPE = CSV
-- FIELD_DELIMITER=','
-- SKIP_HEADER=1;

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."aws_file_format_asgn_Section5_CopyOptions"; 
ALTER FILE FORMAT manage_db."file_formats"."aws_file_format_asgn_Section5_CopyOptions" 
SET TYPE='CSV', FIELD_DELIMITER=',', SKIP_HEADER=1; 

DESC FILE FORMAT manage_db."file_formats"."aws_file_format_asgn_Section5_CopyOptions" ; 

-- 4. Use the copy option to only validate if there are errors and if yes what errors.

COPY INTO EXERCISE_DB.PUBLIC.employees
FROM @MANAGE_DB."external_stages"."aws_stage_asgn_section5_CopyOptions"
FILE_FORMAT = (FORMAT_NAME= manage_db."file_formats"."aws_file_format_asgn_Section5_CopyOptions")
VALIDATION_MODE = "RETURN_ALL_ERRORS";

--Numeric value '-' is not recognized	copyoptions/example1/employees.csv	10	1	463	conversion	100038	22018	"EMPLOYEES"["CUSTOMER_ID":1]	9	10	-,Sutherland,Deinhard,sdeinhard8@wunderground.com,81,Legal 

-- 5. Load the data anyways regardless of the error using the ON_ERROR option. How many rows have been loaded?

COPY INTO EXERCISE_DB.PUBLIC.employees
FROM @MANAGE_DB."external_stages"."aws_stage_asgn_section5_CopyOptions"
FILE_FORMAT = (FORMAT_NAME= manage_db."file_formats"."aws_file_format_asgn_Section5_CopyOptions")
ON_ERROR = "CONTINUE";

-- Rows parsed = 122, rows loaded = 121





