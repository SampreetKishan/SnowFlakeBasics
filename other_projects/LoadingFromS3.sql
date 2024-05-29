-- Let's first create the storage integration object

CREATE OR REPLACE STORAGE INTEGRATION "s3_int"
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::xxxxxxxxxxxx'
STORAGE_ALLOWED_LOCATIONS = ('s3://snowflakebucketsingapore/csv/','s3://snowflakebucketsingapore/json/')
STORAGE_BLOCKED_LOCATIONS = ('s3://snowflakebucketsingapore/differentfiles/'); 

-- Let's describe the storage integration object
DESC STORAGE INTEGRATION "s3_int"; 

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."aws_netflix_data"
TYPE = csv
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
NULL_IF = ('NULL','null')
EMPTY_FIELD_AS_NULL = TRUE; 


CREATE OR REPLACE STAGE manage_db."external_stages"."my_s3_stage"
  STORAGE_INTEGRATION = "s3_int"
  URL = 's3://snowflakebucketsingapore/csv/'
  FILE_FORMAT = manage_db."file_formats"."aws_netflix_data"; 

LIST @manage_db."external_stages"."my_s3_stage"; 

select * from @manage_db."external_stages"."my_s3_stage";

-- CREATE A TABLE

CREATE OR REPLACE TABLE our_first_db.public."netflix_data" (
    show_id STRING,
  type STRING,
  title STRING,
  director STRING,
  cast STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  listed_in STRING,
  description STRING );


-- Load from the stage into the table 

COPY INTO  our_first_db.public."netflix_data"
FROM @manage_db."external_stages"."my_s3_stage"
file_format = manage_db."file_formats"."aws_netflix_data"
files = ('netflix_titles (1).csv')
ON_ERROR = CONTINUE; 

DROP TABLE our_first_db.public."netflix_data"; 

SELECT * FROM our_first_db.public."netflix_data" limit 10; 





// Create table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.movie_titles (
  show_id STRING,
  type STRING,
  title STRING,
  director STRING,
  cast STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  listed_in STRING,
  description STRING )
  
  

// Create file format object
CREATE OR REPLACE file format manage_db."file_formats"."csv_fileformat"
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;
    
    
 // Create stage object with integration object & file format object
CREATE OR REPLACE stage manage_db."external_stages"."csv_folder"
    URL = 's3://snowflakebucketsingapore/csv/'
    STORAGE_INTEGRATION = "s3_int"
    FILE_FORMAT = manage_db."file_formats"."csv_fileformat"



// Use Copy command       
COPY INTO OUR_FIRST_DB.PUBLIC.movie_titles
    FROM @manage_db."external_stages"."csv_folder"
    files = ('netflix_titles (1).csv');
    
    
    
    
    
// Create file format object
CREATE OR REPLACE file format manage_db."file_formats"."csv_fileformat"
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE    
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'    
    
    
SELECT * FROM OUR_FIRST_DB.PUBLIC.movie_titles limit 10; 
    
    
   


