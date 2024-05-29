-- 1. Sample 5% from the table "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF10TCL"."CUSTOMER_ADDRESS"
-- Use the ROW method and seed(2) to get a reproducible result.
-- Store the result in the our_second_db in a table called CUSTOMER_ADDRESS_SAMPLE_5.

SELECT * from snowflake_sample_data.tpcds_sf10tcl.customer_address limit 10; 
SELECT COUNT(*) from snowflake_sample_data.tpcds_sf10tcl.customer_address;
-- 32,500,000

CREATE OR REPLACE TABLE our_first_db.public.CUSTOMER_ADDRESS_SAMPLE_5
AS
SELECT * from snowflake_sample_data.tpcds_sf10tcl.customer_address
SAMPLE ROW(5) SEED(2); 


SELECT COUNT(*) from our_first_db.public.CUSTOMER_ADDRESS_SAMPLE_5;
--1,625,001


--2. Sample 1% from the table "SNOWFLAKE_SAMPLE_DATA"."TPCDS_SF10TCL"."CUSTOMER"
-- Use the SYSTEM method and seed(2) to get a reproducible result.
-- Store the result in the DEMO_DB in a table called CUSTOMER_SAMPLE_1.

CREATE OR REPLACE TABLE our_first_db.public.CUSTOMER_SAMPLE_1
AS
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER
SAMPLE SYSTEM(1) SEED(2); 

SELECT COUNT(*) FROM  our_first_db.public.CUSTOMER_SAMPLE_1; 

--824,788

