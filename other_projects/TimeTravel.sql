--Setting up table

CREATE OR REPLACE TABLE our_first_db.public."test"(
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string
  );

--'s3://data-snowflake-fundamentals/time-travel/'

-- create a file format
CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."aws_s3_time_travel1"
type=csv
field_delimiter=','
skip_header=1; 

-- CREATE A STAGE 
CREATE OR REPLACE STAGE manage_db."external_stages"."aws_s3_time_travel1"
file_format = manage_db."file_formats"."aws_s3_time_travel1"
url = 's3://data-snowflake-fundamentals/time-travel/';


LIST @manage_db."external_stages"."aws_s3_time_travel1"; 

SELECT $1, $2, $3, $4, $5, $6, $7 from @manage_db."external_stages"."aws_s3_time_travel1" LIMIT 100; 


COPY INTO our_first_db.public."test"
FROM @manage_db."external_stages"."aws_s3_time_travel1"; 

SELECT * from our_first_db.public."test"; 

-- let's "accidentally" change the job to "data scientist"

UPDATE our_first_db.public."test" SET JOB = 'Data Scientist'; 

-- LET'S USE TIME  TRAVEL


-- METHOD 1: OFFSET
SElECT * from our_first_db.public."test" at (OFFSET => -60*0.5); 

DROP TABLE our_first_db.public."test"; 


-- METHOD 2: TIMESTAMP
ALTER SESSION SET TIMEZONE ='UTC'
SELECT DATEADD(DAY, 1, CURRENT_TIMESTAMP);

select current_timestamp();

select * from our_first_db.public."test" before(timestamp=>'2024-04-05 13:54:30.145'::timestamp); 

-- method 3: QueryID 
select * from our_first_db.public."test" before (statement=>'01b37782-3201-0bdf-0007-8a4200057246'); 