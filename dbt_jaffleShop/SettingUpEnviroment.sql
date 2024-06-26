-- Create an xsmall warehouse 
CREATE WAREHOUSE dbt_transforms
 WAREHOUSE_TYPE =  STANDARD
 WAREHOUSE_SIZE =  XSMALL 
 AUTO_SUSPEND = 60
 AUTO_RESUME = TRUE 
INITIALLY_SUSPENDED =  TRUE
COMMENT = 'For dbt transformations';

-- Create two databases and two schemas within one of the database 
-- database:dbt_raw schemas: jaffle_shop and analytics
CREATE DATABASE dbt_raw; 
CREATE SCHEMA dbt_raw.jaffle_shop; 
CREATE SCHEMA dbt_raw.stripe; 

-- create the other database 
CREATE DATABASE dbt_analytics; 

-- In the raw database and jaffle_shop and stripe schemas, create three tables and load relevant data into them:

create table dbt_raw.jaffle_shop.customers 
( id integer,
  first_name varchar,
  last_name varchar
);

-- STAGE the data for the table customers S3 object from s3://dbt-tutorial-public/jaffle_shop_customers.csv
CREATE OR REPLACE STAGE dbt_raw.jaffle_shop.aws_customers_stage
url = 's3://dbt-tutorial-public/jaffle_shop_customers.csv'; 

-- let's review the contents of the table 
select $1, $2, $3, $4, $5, $6 from @dbt_raw.jaffle_shop.aws_customers_stage;

-- there are three columns; ID of type int, first_name of type string, and last_name of type string 

COPY INTO dbt_raw.jaffle_shop.customers
FROM @dbt_raw.jaffle_shop.aws_customers_stage
file_format = (type=csv field_delimiter=',' skip_header=1); 

--let's see if the data is loaded properly
select * from dbt_raw.jaffle_shop.customers;  -- all looks good. 

--let's create the next table for the orders

create table dbt_raw.jaffle_shop.orders
( id integer,
  user_id integer,
  order_date date,
  status varchar,
  _etl_loaded_at timestamp default current_timestamp
);

-- let's create a stage for the orders table on S3 s3://dbt-tutorial-public/jaffle_shop_orders.csv
CREATE OR REPLACE STAGE dbt_raw.jaffle_shop.AWS_ORDERS_STAGE
url = 's3://dbt-tutorial-public/jaffle_shop_orders.csv'; 

-- let's review the contents of the table
SELECT $1, $2, $3, $4, $5, $6  from @dbt_raw.jaffle_shop.AWS_ORDERS_STAGE; 

-- there are four columns; ID of type int for the orders, user_id of type int for the customer id, order_date of type date and status of type string. 

-- let's copy the data into the orders table
COPY INTO dbt_raw.jaffle_shop.orders(id, user_id, order_date, status)
FROM @dbt_raw.jaffle_shop.AWS_ORDERS_STAGE
file_format = (type=csv field_delimiter=',' skip_header=1); 

-- let's review the contents of the table
select * from dbt_raw.jaffle_shop.orders; -- looks good. 


-- let's create the next tabel for payment under the schema stripe

create table dbt_raw.stripe.payment 
( id integer,
  orderid integer,
  paymentmethod varchar,
  status varchar,
  amount integer,
  created date,
  _batched_at timestamp default current_timestamp
);

-- the data for this resides in the s3 object s3://dbt-tutorial-public/stripe_payments.csv

-- let's create stage to review this data
CREATE OR REPLACE STAGE dbt_raw.stripe.AWS_PAYMENTS_STAGE
url = 's3://dbt-tutorial-public/stripe_payments.csv'; 

-- let's review the contents of the S3 object

select $1, $2, $3, $4, $5, $6, $7, $8 ,$9 from @dbt_raw.stripe.AWS_PAYMENTS_STAGE; 
-- there are 6 columns
-- id of type int for the payment 
-- order_id of the type int that corresponds to the order associated with the payment
-- paymentmethod of type string
-- status of type string
-- amount of type int
-- CREATED of type date

COPY into dbt_raw.stripe.payment (id, orderid, paymentmethod, status, amount, created)
FROM @dbt_raw.stripe.AWS_PAYMENTS_STAGE
file_format = (type = csv field_delimiter=',' skip_header=1); 

--let's see if the data is loaded correctly
select * from dbt_raw.stripe.payment; -- all looks good. 


