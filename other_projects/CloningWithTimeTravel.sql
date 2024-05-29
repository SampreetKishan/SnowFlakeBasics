-- s3://data-snowflake-fundamentals/time-travel/

CREATE OR REPLACE STAGE manage_db."external_stages"."aws_stage_cloning"
url = 's3://data-snowflake-fundamentals/time-travel/'; 

LIST @manage_db."external_stages"."aws_stage_cloning"; 

select $1, $2, $3, $4, $5, $6, $7, $8 FROM @manage_db."external_stages"."aws_stage_cloning"; 

CREATE OR REPLACE TABLE our_first_db.public."customers"
(
    id int,
    first_name string,
    last_name string,
    email string,
    gender varchar(1),
    job string,
    phone string
); 

create or replace file format manage_db."file_formats"."aws_ff_cloning"
type = csv
field_delimiter = ','
skip_header=1; 

COPY INTO our_first_db.public."customers"
FROM  @manage_db."external_stages"."aws_stage_cloning"
file_format = manage_db."file_formats"."aws_ff_cloning"
files = ('customers.csv'); 

select * from our_first_db.public."customers"; 

select count(id) as count_id, id 
from our_first_db.public."customers" 
group by id 
order by  count_id desc; 

UPDATE our_first_db.public."customers"
set first_name = 'Randomios'
where id = 1; 

CREATE OR REPLACE TABLE our_first_db.public."customers_clone1"
clone our_first_db.public."customers" at (offset=> -60*5.5); 

select * from our_first_db.public."customers_clone1"; 

-- drop table our_first_db.public."customers_clone1"; 


-- swapping tables (this swaps meta data too)


ALTER table our_first_db.public."customers_clone1"
swap with our_first_db.public."customers"; 


select * from our_first_db.public."customers"; 

