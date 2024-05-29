-- Data sharing allows us to create a data share that can be used by other Snowflake accounts as well as non-snowflake accounts.
-- Any changes made to the original data source(also called producer) will be reflected immediately in all the data shares(consumers). Note: consumers CAN'T make changes to the data in the data share.


-- s3://bucketsnowflakes3

-- let's create a separate database for data share
CREATE OR REPLACE DATABASE data_share;

create or replace stage manage_db."external_stages"."aws_s3_datasharing_stage"
url ='s3://bucketsnowflakes3'; 

LIST @manage_db."external_stages"."aws_s3_datasharing_stage"; 

-- There are 3 files. Use the s3://bucketsnowflakes3/OrderDetails.csv file. 

SELECT $1, $2, $3, $4, $5, $6, $7 , $8 from @manage_db."external_stages"."aws_s3_datasharing_stage" (PATTERN => 'OrderDetails.csv');

CREATE OR REPLACE table DATA_SHARE.PUBLIC.ORDERS(
order_id STRING,
AMOUNT INT,
PROFIT INT,
QUANTITY INT, 
CATEGORY STRING,
SUB_CATEGORY STRING
);

COPY INTO DATA_SHARE.PUBLIC.ORDERS
FROM @manage_db."external_stages"."aws_s3_datasharing_stage"
files = ('OrderDetails.csv')
file_format = (type = csv field_delimiter=',' skip_header=1);

CREATE OR REPLACE TABLE DATA_SHARE.PUBLIC.CUSTOMERS(
    ID STRING,
    FIRST_NAME STRING,
    LAST_NAME STRING,
    EMAIL STRING,
    GENDER STRING,
    JOB STRING,
    PHONE STRING
); 

INSERT INTO DATA_SHARE.PUBLIC.CUSTOMERS 
SELECT * FROM OUR_FIRST_DB.PUBLIC."customers"; 

select * from DATA_SHARE.PUBLIC.ORDERS limit 10; 



-- create data share object 

SHOW SHARES; --  where kind = 'OUTBOUND';
-- you can see inbound and outbound shares 


-- CREATE THE DATA SHARE OBJECT
CREATE OR REPLACE SHARE ORDERS_SHARE;


-- GRANT USAGE ON THE DATABASE AND SCHEMA TO THE DATA SHARE
GRANT USAGE ON DATABASE DATA_SHARE TO SHARE ORDERS_SHARE; 
GRANT USAGE ON SCHEMA DATA_SHARE.PUBLIC TO SHARE ORDERS_SHARE; 

--ALLOW THE DATASHARE TO DO SELECT ON THE TABLE DATA_SHARE.PUBLIC.ORDERS 
GRANT SELECT ON TABLE DATA_SHARE.PUBLIC.ORDERS TO SHARE ORDERS_SHARE; 
GRANT SELECT ON ALL TABLES IN DATABASE DATA_SHARE to share orders_share; 

SHOW SHARES;
SHOW GRANTS TO SHARE ORDERS_SHARE; 


-- Add a consumer account to the data share
ALTER SHARE ORDERS_SHARE ADD ACCOUNT="LJMEWNH.DO40197"
SHARE_RESTRICTIONS=false;

-- Looks like shares are not possible from a business critical account to a lower edition account unless share_restrictions are disabled. 

-- let's make a change to the dataset

select * from data_share.public.orders limit 10;

INSERT INTO data_share.public.orders(order_id, amount, profit, quantity, category, sub_category) values ('Test',100, 100, 100,'Test_category','Test_sub_category'); 

select * from data_share.public.orders where order_id='Test';

-- SHOW SHARES; 
-- drop share orders_share; 