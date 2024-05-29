-- let's create the file format
CREATE OR REPLACE FILE FORMAT MANAGE_DB."file_formats"."parquet"
type='parquet'; 

DESC file format MANAGE_DB."file_formats"."parquet"; 

-- 's3://snowflakeparquetdemo' 
CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_parquet"
url='s3://snowflakeparquetdemo' 
file_format=MANAGE_DB."file_formats"."parquet"; 

LIST @manage_db."external_stages"."aws_stage_parquet"; 

select * from @manage_db."external_stages"."aws_stage_parquet" limit 10; 



{
  "__index_level_0__": 7,
  "cat_id": "HOBBIES",
  "d": 489,
  "date": 1338422400000000,
  "dept_id": "HOBBIES_1",
  "id": "HOBBIES_1_008_CA_1_evaluation",
  "item_id": "HOBBIES_1_008",
  "state_id": "CA",
  "store_id": "CA_1",
  "value": 12
}

select 
    $1:"__index_level_0__"::INT as index_level,
    $1:"cat_id"::STRING as cat_id,
    $1:"d"::INT as d,
    DATE($1:"date"::INT) as dt,
    $1:"dept_id"::STRING as dept_id,
    $1:"id"::STRING as id,
    $1:"item_id"::string as item_id,
    $1:"state_id"::string as state_id,
    $1:"store_id"::STRING as store_id,
    $1:"value"::INT as value,
    METADATA$FILENAME::STRING as filename,
    METADATA$FILE_ROW_NUMBER::INT as row_number,
    to_timestamp_ntz(current_timestamp) as load_date
    from  @manage_db."external_stages"."aws_stage_parquet" limit 10; 

-- now let's try to load the data into a table 

CREATE OR REPLACE table our_first_db.public."daily_sales_parquet"(
    index_level INT,
    cat_id STRING,
    d INT,
    dt DATE,
    dept_id STRING,
    id STRING,
    item_id STRING,
    tate_id STRING,
    store_id STRING,
    value INT,
    filename STRING,
    row_number STRING,
    load_date timestamp default to_timestamp_ntz(current_timestamp)
); 

select * from our_first_db.public."daily_sales_parquet"; 

COPY into our_first_db.public."daily_sales_parquet"
FROM (
    select 
    $1:"__index_level_0__"::INT as index_level,
    $1:"cat_id"::STRING as cat_id,
    $1:"d"::INT as d,
    DATE($1:"date"::INT) as dt,
    $1:"dept_id"::STRING as dept_id,
    $1:"id"::STRING as id,
    $1:"item_id"::string as item_id,
    $1:"state_id"::string as state_id,
    $1:"store_id"::STRING as store_id,
    $1:"value"::INT as value,
    METADATA$FILENAME::STRING as filename,
    METADATA$FILE_ROW_NUMBER::INT as row_number,
    to_timestamp_ntz(current_timestamp) as load_date
    from  @manage_db."external_stages"."aws_stage_parquet" 
)
files=('daily_sales_items.parquet')
file_format=(type='parquet'); 

select * from our_first_db.public."daily_sales_parquet" limit 10; 

DROP TABLE  our_first_db.public."daily_sales_parquet"; 

DROP STAGE manage_db."external_stages"."aws_stage_parquet" ;