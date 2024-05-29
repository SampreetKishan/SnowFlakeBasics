--url='s3://bucketsnowflakes3';

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_clustering"
url = s3://bucketsnowflakes3; 

LIST @manage_db."external_stages"."aws_stage_clustering"; 


SELECT COUNT(*) FROM OUR_SECOND_DB.PUBLIC.ORDERS; 

COPY INTO OUR_SECOND_DB.PUBLIC.ORDERS
FROM @manage_db."external_stages"."aws_stage_clustering"
file_format = (type=csv field_delimiter=',' skip_header=1)
files = ('OrderDetails.csv'); 


// Create table

CREATE OR REPLACE TABLE our_second_db.public."ORDERS_CACHING" (
ORDER_ID	VARCHAR(30)
,AMOUNT	NUMBER(38,0)
,PROFIT	NUMBER(38,0)
,QUANTITY	NUMBER(38,0)
,CATEGORY	VARCHAR(30)
,SUBCATEGORY	VARCHAR(30)
,DATE DATE)   ; 



INSERT INTO our_second_db.public."ORDERS_CACHING" 
SELECT
t1.ORDER_ID
,t1.AMOUNT	
,t1.PROFIT	
,t1.QUANTITY	
,t1.CATEGORY	
,t1.SUBCATEGORY	
,DATE(UNIFORM(1500000000,1700000000,(RANDOM())))
FROM our_second_db.public.orders t1
CROSS JOIN (SELECT * FROM our_second_db.public.orders) t2;
--CROSS JOIN (SELECT TOP 100 * FROM our_second_db.public.orders) t3;

-- SYSTEM$CANCEL_QUERY(01b35b49-3201-0aa6-0007-8a4200045076); 

select * from our_second_db.public.orders_caching limit 10; 


// Query Performance before Cluster Key
select * from our_second_db.public.orders_caching where date = '2020-06-09'; 
// 01b35b64-3201-0aa6-0007-8a4200045126 took about 1.2s


// Adding Cluster Key & Compare the result
ALTER TABLE our_second_db.public.orders_caching CLUSTER BY (DATE); 


select * from our_second_db.public.orders_caching where date = '2020-06-07'; 


-- The cluster key is not ideal

ALTER TABLE our_second_db.public.orders_caching CLUSTER BY ( MONTH(DATE) );

DROP TABLE our_second_db.public.orders_caching; 

