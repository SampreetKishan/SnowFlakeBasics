select * from our_first_db.public.orders limit 10; 

-- Exercise 1: Let's create a table that contains  order_id, amount, profit, category but we only load order_id, amount 

CREATE OR REPLACE TABLE our_first_db.public.orders_ex (
    ORDER_ID VARCHAR(10),
    AMOUNT INT,
    PROFIT INT, 
    CATEGORY VARCHAR(20)
); 

COPY INTO our_first_db.public.orders_ex(ORDER_ID, AMOUNT) 
FROM (
    SELECT s.$1, s.$2
    FROM @manage_db."external_stages"."aws_stage_instructor" s
)
files = ('OrderDetails.csv')
file_format = (type = csv field_delimiter=',' skip_header=1); 

select * from OUR_FIRST_DB.PUBLIC.ORDERS_EX limit 10; 


-- Exercise: instead of using pre existing order_id use auto_increment starting from 1

CREATE OR REPLACE TABLE our_first_db.public.orders_ex (
    ORDER_ID number autoincrement start 1 increment 1,
    amount INT, 
    CATEGORY VARCHAR(20)
); 

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX(AMOUNT, CATEGORY)
FROM (
    SELECT s.$2, s.$5
    FROM @manage_db."external_stages"."aws_stage_instructor" s
)
files = ('OrderDetails.csv')
file_format = (type = csv field_delimiter=',' skip_header=1); 

select * from our_first_db.public.orders_ex where order_id <80 and order_id > 70; 


