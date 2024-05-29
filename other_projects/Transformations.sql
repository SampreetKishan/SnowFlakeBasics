select * from orders limit 10; 
-- order_id
-- amount 
-- profit 
-- quantity 
-- category 
-- subcategory 

-- Exercise 1 (just create a table with a couple of columns order_id, amount)
CREATE OR REPLACE TABLE ORDERS_EX (
ORDER_ID VARCHAR(25),
AMOUNT INT
); 

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
FROM (select s.$1, s.$2 from @manage_db."external_stages"."aws_stage_instructor" s)
file_format = (type = csv field_delimiter = ',' skip_header=1)
files = ('OrderDetails.csv'); 


-- exercise 2; if the profit < 0, say profit = unprofitable, else profit = profitable 
select * from our_first_db.public.orders_ex limit 10; 

CREATE OR REPLACE TABLE our_first_db.public."ORDERS_EX" (
ORDER_ID VARCHAR(25),
AMOUNT INT,
PROFIT INT,
PROFITABLE VARCHAR(50)
); 

COPY INTO  our_first_db.public."ORDERS_EX"
FROM (
        select s.$1, s.$2, s.$3,
            CASE 
                WHEN s.$3 <0 THEN 'unprofitable'
                ELSE 'profitable'
            END
        FROM
        @manage_db."external_stages"."aws_stage_instructor" s
    )
files = ('OrderDetails.csv')
file_format = (type = csv field_delimiter=',' skip_header=1); 
select * from our_first_db.public.orders_ex limit 10; 


-- Exercise: substring (5) category

create or replace table our_first_db.public.orders_ex (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    CATEGORY VARCHAR(10)   
); 

COPY INTO our_first_db.public.orders_ex 
FROM (
    select s.$1, s.$2, s.$3, LEFT(s.$5,5)
    FROM @manage_db."external_stages"."aws_stage_instructor" s
)
files = ('OrderDetails.csv')
file_format = (type = csv field_delimiter=',' skip_header=1); 

select * from our_first_db.public.orders_ex limit 10; 



