-- Snowpipe demo

-- let's first create a table

CREATE OR REPLACE TABLE our_first_db.public."employees"(
    id INT,
    first_name STRING,
    last_name STRING,
    email STRING,
    location STRING ,
    department STRING

); 

-- let's describe the existing storage integration object 
DESC STORAGE INTEGRATION "s3_int"; 

-- let's create a file format 

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."aws_snowpipe_employees"
type = csv
field_delimiter = ','
skip_header = 1
null_if = ('NULL','null')
empty_field_as_null = TRUE; 

DESC FILE FORMAT manage_db."file_formats"."aws_snowpipe_employees"; 


-- Let's create the stage 
CREATE OR REPLACE STAGE manage_db."external_stages"."aws_snowpipe_employees"
storage_integration = "s3_int"
url = 's3://snowflakebucketsingapore/csv/snowpipe/'
file_format = manage_db."file_formats"."aws_snowpipe_employees"; 

LIST @manage_db."external_stages"."aws_snowpipe_employees"; 

DESC STAGE manage_db."external_stages"."aws_snowpipe_employees";


-- Create the pipe 
CREATE OR REPLACE schema MANAGE_DB."pipes"; -- ."s3_employees_pipe"; 

CREATE OR REPLACE PIPE manage_db."pipes"."s3_employees_pipe"
auto_ingest = TRUE
AS 
COPY INTO our_first_db.public."employees"
FROM @manage_db."external_stages"."aws_snowpipe_employees"; 

DESC PIPE manage_db."pipes"."s3_employees_pipe"; 

-- SQS notification channel: arn:aws:sqs:ap-southeast-1:631592820011:sf-snowpipe-AIDAZGDO5TUVQYCUKYRJY-zuEu5T-KeMLp-b73vny42Q

select count(*) from our_first_db.public."employees"; 


-- error handling 
-- Let's intentionally change the file format 
CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."aws_snowpipe_employees"
type = csv
field_delimiter = ','
skip_header = 1
null_if = ('NULL','null')
empty_field_as_null = TRUE; 

-- let's see if the pipe is working
SELECT SYSTEM$PIPE_STATUS(MANAGE_DB."pipes"."s3_employees_pipe");

SELECT SYSTEM$PIPE_STATUS("MANAGE_DB.pipes.Pipes.s3_employees_pipe");

// Snowpipe error message
SELECT * FROM TABLE(VALIDATE_PIPE_LOAD(
    PIPE_NAME => manage_db."pipes"."s3_employees_pipe",
    START_TIME => DATEADD(HOUR,-2,CURRENT_TIMESTAMP())));


SHOW PIPES;

-- managing pipes

SHOW pipes; 
SHOW PIPES like '%employees%'; 
show pipes in database manage_db;

-- changing pipes 
-- let's say we want the employees pipe to feed into another table employees2 

CREATE OR REPLACE TABLE our_first_db.public."employees2"(
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
  );

-- Pause pipe
ALTER PIPE MANAGE_DB."pipes"."s3_employees_pipe" SET PIPE_EXECUTION_PAUSED = TRUE



// Verify pipe is paused and has pendingFileCount 0 
SELECT SYSTEM$PIPE_STATUS('MANAGE_DB.pipes.s3_employees_pipe') ;

// RECREATE THE PIPE
CREATE OR REPLACE PIPE MANAGE_DB."pipes"."s3_employees_pipe"
auto_ingest = TRUE
AS 
COPY INTO our_first_db.public."employees2"
FROM @manage_db."external_stages"."aws_snowpipe_employees"; 

DESC PIPE MANAGE_DB."pipes"."s3_employees_pipe"; 

ALTER PIPE manage_db."pipes"."s3_employees_pipe" SET pipe_execution_paused = FALSE; 

LIST @manage_db."external_stages"."aws_snowpipe_employees"; 
DESC STAGE manage_db."external_stages"."aws_snowpipe_employees";

SELECT count(*) FROM our_first_db.public."employees2"; 

COPY INTO OUR_FIRST_DB.PUBLIC."employees2"
FROM @manage_db."external_stages"."aws_snowpipe_employees"; 

SHOW PIPES; 

