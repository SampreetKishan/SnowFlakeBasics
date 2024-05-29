-- Copy table "SNOWFLAKE_SAMPLE_DATA"."TPCH_SF1"."PART" into a database you control;

CREATE OR REPLACE TABLE our_first_db.public."part" 
AS 
SELECT * FROM snowflake_sample_data.tpch_sf1.part; 

-- Check if the copy worked
select * from our_first_db.public."part" limit 10; 

-- make the "accidental" change
UPDATE our_first_db.public."part" 
SET P_MFGR='Manufacturer#CompanyX'
WHERE P_MFGR='Manufacturer#5';

-- This is the query ID: 01b37bdb-3201-0c08-0007-8a420005c83a

-- TIME TRAVEL METHOD 1: OFFSET
CREATE OR REPLACE TABLE our_first_db.public."time_travel_offset"
AS 
SELECT * FROM OUR_FIRST_DB.PUBLIC."part" at (offset=>-60*3.5); 

-- check if we see entries when P_MFGR='Manufacturer#5';
select * from our_first_db.public."time_travel_offset" where P_MFGR='Manufacturer#5'; 


-- TIME TRAVEL METHOD 2: Query id
CREATE OR REPLACE TABLE our_first_db.public."time_travel_offset"
AS 
SELECT * FROM OUR_FIRST_DB.PUBLIC."part" before (statement=>'01b37bdb-3201-0c08-0007-8a420005c83a');

-- check if we see entries when P_MFGR='Manufacturer#5';
select * from our_first_db.public."time_travel_offset" where P_MFGR='Manufacturer#5'; 

-- drop the tables 
DROP TABLE our_first_db.public."part";
DROP TABLE our_first_db.public."time_travel_offset"; 