-- CREATE THE TABLE
CREATE OR REPLACE TABLE OUR_FIRST_DB.public."test" (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);

  show stages; 
LIST @manage_db."external_stages"."aws_s3_time_travel1"; 

select $1, $2, $3, $4, $5, $6, $7 from @manage_db."external_stages"."aws_s3_time_travel1"; 

COPY INTO OUR_FIRST_DB.PUBLIC."test"
FROM @manage_db."external_stages"."aws_s3_time_travel1"
files = ('customers.csv')
file_format=(type=csv field_delimiter=',' skip_header=0)
on_error = CONTINUE; 

select * from our_first_db.public."test" LIMIT 10; 


-- MAKE MISTAKE ONE
UPDATE our_first_db.public."test"
SET LAST_NAME = 'TYSON'; 

-- Query:01b37c02-3201-0c30-0007-8a420005b742

-- Make mistake #2
UPDATE our_first_db.public."test"
SET JOB = 'Data Analyst'; 

-- Query:  01b37c02-3201-0bf8-0007-8a420005a8ee

CREATE OR REPLACE TABLE our_first_db.public."test_backup"
AS 
SELECT * FROM our_first_db.public."test" before(statement=>'01b37c02-3201-0bf8-0007-8a420005a8ee'); 

select * from our_first_db.public."test_backup" limit 10; 

TRUNCATE table our_first_db.public."test"; 

CREATE OR REPLACE TABLE our_first_db.public."test_backup"
AS 
SELECT * FROM our_first_db.public."test" before(statement=>'01b37c02-3201-0c30-0007-8a420005b742');

INSERT INTO our_first_db.public."test"
SELECT * FROM OUR_FIRST_DB.PUBLIC."test_backup"; 


SELECT * FROM OUR_FIRST_DB.PUBLIC."test"; 

DROP TABLE our_first_db.public."test"; 

--DROP TABLE OUR_FIRST_DB.PUBLIC.test; 
    