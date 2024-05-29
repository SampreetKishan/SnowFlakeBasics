-- CREATE THE TABLE
CREATE OR REPLACE TABLE OUR_FIRST_DB.public."test" (
   id int,
   first_name string,
  last_name string,
  email string,
  gender string,
  Job string,
  Phone string);

--show stages; 
LIST @manage_db."external_stages"."aws_s3_time_travel1"; 

select $1, $2, $3, $4, $5, $6, $7 from @manage_db."external_stages"."aws_s3_time_travel1"; 

COPY INTO OUR_FIRST_DB.PUBLIC."test"
FROM @manage_db."external_stages"."aws_s3_time_travel1"
files = ('customers.csv')
file_format=(type=csv field_delimiter=',' skip_header=0)
on_error = CONTINUE; 

--Undropping tables 
DROP TABLE our_first_db.public."test"; 

select * from our_first_db.public."test" limit 10; 
UNDROP TABLE our_first_db.public."test";

-- You can also drop and undrop schemas and databases

-- Undropping tables and time travel
select * from our_first_db.public."test" limit 10; 

-- make mistake #1
UPDATE our_first_db.public."test"
set LAST_NAME = 'TYSON'; 
-- Query: 01b37c23-3201-0c08-0007-8a420005cb3a

-- make mistake #2 
UPDATE our_first_db.public."test"
set JOB = 'DATA ANALYST'; 
-- Query: 01b37c23-3201-0c08-0007-8a420005cb56


CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC."test"
AS
SELECT * FROM our_first_db.public."test" before(statement=>'01b37c23-3201-0c08-0007-8a420005cb56');

ALTER TABLE our_first_db.public."test"
RENAME TO OUR_FIRST_DB.PUBLIC."test_backup_2";

UNDROP TABLE our_first_db.public."test"; 

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC."test"
AS
SELECT * FROM our_first_db.public."test" before(statement=>'01b37c23-3201-0c08-0007-8a420005cb3a');

select * from our_first_db.public."test" limit 10; 