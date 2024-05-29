-- If we are dealing with large amounts of data, it is a good idea to do development work on a sample of the dataset.
-- There are two types of sampling. Row and System(or Block)
-- In row type sampling, there is a probability percentage associated with each row of being included in the sample. For example, each row has a probability of 10% of being included in the sampled dataset.
-- Row type of sampling is ideal for small-medium sized datasets.
-- In System type sampling, there is a probability percentage associated with each partition(or block) of being included in the dataset.
-- System type of sampling is useful for very large datasets.



SELECT COUNT(*) FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS; 
-- Total rows = 32,500,000

SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS LIMIT 10; 


-- no sampling
SELECT CA_LOCATION_TYPE, COUNT(*) as no_loc_type, (count(*) * 100 )/32500000 as perc_loc_type
from SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
group by CA_LOCATION_TYPE; 

-- Row type of sampling
-- Row(n) ; n indicates the probability percentage. If there are 1000 rows, and n=10, then the sample will have ~100 rows.
-- Seed(m); m indicates the number of times you'll receive the same result in the sample.. 
create or replace view our_first_db.public.sf_customer_address_view
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE ROW(10) SEED(23); 

select count(*) from our_first_db.public.sf_customer_address_view; 
-- Total rows = 3249565

-- Number of rows in the sampled dataset: 3,249,565

-- Let's see the percentage of entries with the "single family" location_type. With the no-sampling dataset, it was 32.33%.

SELECT CA_LOCATION_TYPE, COUNT(*) as no_loc_type, (count(*) * 100 )/ 3249565 as perc_loc_type
from our_first_db.public.sf_customer_address_view
group by CA_LOCATION_TYPE; 

-- With the row type of sampling, single family is 32.31% of the data. Very similar to the dataset with no sampling. 

-- Let's try system(block sampling)

CREATE OR REPLACE VIEW our_first_db.public.sf_customer_address_view_block
AS 
SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.CUSTOMER_ADDRESS
SAMPLE SYSTEM(10) SEED(23); 

select count(*) from our_first_db.public.sf_customer_address_view_block; 
-- Total rows = 2,743,416; This won't be exactly 10% of the number of rows of the original dataset. 

-- let's see the percentage of single_family location types. 
SELECT CA_LOCATION_TYPE, COUNT(*) as no_loc_type, (count(*) * 100 )/ 3249565 as perc_loc_type
from our_first_db.public.sf_customer_address_view_block
group by CA_LOCATION_TYPE; 
-- It is 27.25% which is not as accurate as the row type of sampling.. That's probably because this isn't a large dataset and row type of sampling is the preferred method of sampling? 
