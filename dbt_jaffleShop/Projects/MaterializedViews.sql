-- If you are working with large databases/tables, querying can take a while. This is bad especially in production enviormnents.
-- One way to speed up queries, if the same type of queries are used repeatedly, is using materialized views. 
-- A materialized view is a query turned table (obtained by a larger table) that can be used by other queries for faster processing. 

-- materialized view vs regular view (from google bard)
-- Views: Virtual tables, query a view means the database will execute the query defined for the view. Can be slow since the query definition is executed.
-- materualized views: Data actually stored, query will work with the precomputed results in the materialized view. So, it is much faster. 

--Let's first disable global caching
ALTER SESSION SET USE_CACHED_RESULT=FALSE; -- disable global caching
SELECT count(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000.ORDERS; 

CREATE OR REPLACE TABLE our_first_db.public.sf100_ORDERS
as 
select *
from SNOWFLAKE_SAMPLE_DATA.TPCH_SF100.ORDERS; 

DROP TABLE our_first_db.public.sf1000_ORDERS; 
-- This took about 22 seconds.

-- let's assume this query is executed often. Let's create a materialized view for this commonly executed query.

CREATE OR REPLACE MATERIALIZED VIEW sf_max_tpch_sf100_orders
AS 
select 
max(O_ORDERKEY) as max_order_key,
max(O_CUSTKEY) as max_cust_key,
max(O_TOTALPRICE) as max_total_price,
max(O_ORDERDATE) as max_order_date,
max(O_CLERK) as max_ocleck 
from  our_first_db.public.sf100_ORDERS; 

SHOW MATERIALIZED VIEWS;

select * from sf_max_tpch_sf100_orders; 
 

-- let's make an update to the the original table in our_first_db
update our_first_db.public.sf100_ORDERS
SET O_TOTALPRICE=100000000
where O_TOTALPRICE = 10000000; 

-- let's look at the refresh history of the materialized view

select * from table(information_schema.materialized_view_refresh_history());

ALTER SESSION SET USE_CACHED_RESULT=TRUE; 