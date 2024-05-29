--  url='s3://bucketsnowflake-jsondemo';

CREATE OR REPLACE STAGE MANAGE_DB."external_stages"."aws_stage_jsondata_1"
url='s3://bucketsnowflake-jsondemo'
file_format = manage_db."file_formats"."HR_DATA_JSON"; 

LIST @MANAGE_DB."external_stages"."aws_stage_jsondata_1"; 
select * from @MANAGE_DB."external_stages"."aws_stage_jsondata_1"; 

-- CREATE A TABLE FOR JSON DATA

CREATE OR REPLACE TABLE our_first_db.public.HR_DATA(
    RAW_DATA VARIANT
); 

CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."HR_DATA_JSON"
TYPE = JSON; 

DESC file format  manage_db."file_formats"."HR_DATA_JSON"; 

-- LOAD the data from the stage into the table

COPY INTO our_first_db.public.HR_DATA
FROM @MANAGE_DB."external_stages"."aws_stage_jsondata_1"
files = ('HR_data.json')
file_format = (FORMAT_NAME=manage_db."file_formats"."HR_DATA_JSON"); 


select * from our_first_db.public.HR_DATA limit 10; 
select COUNT(*) from our_first_db.public.HR_DATA; -- limit 10; 
-- We now have to flatten the table 

select 
    RAW_DATA:city::string as city, 
    RAW_DATA:first_name::string as first_name, 
    RAW_DATA:gender::string as gender, 
    RAW_DATA:id::int as id,
    RAW_DATA:job.salary as job_salary,
    RAW_DATA:job.title as job_title,
    -- RAW_DATA:spoken_languages
    from our_first_db.public.HR_DATA limit 10;


-- handling nested data
select RAW_DATA:prev_company[0]::STRING as prev_company from our_first_db.public.HR_DATA limit 10;

-- or I can aggregate it
SELECT 
    ARRAY_SIZE(RAW_DATA:prev_company)::INT as num_prev_companies
    from our_first_db.public.HR_DATA limit 10;

-- or if we want to flatten such that we can see at least 2 of the previous companies we can do this
SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:id::INT as id,
    RAW_DATA:job.salary::INT as salary,
    RAW_DATA:job:title::STRING as title,
    RAW_DATA:prev_company[0]::STRING as previous_company
    FROM our_first_db.public.HR_DATA   

    UNION ALL
SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:id::INT as id,
    RAW_DATA:job.salary::INT as salary,
    RAW_DATA:job:title::STRING as title,
    RAW_DATA:prev_company[1]::STRING as previous_company
    FROM our_first_db.public.HR_DATA
    order by id; 

-- Let's try to flatten the spoken_languages column

SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:id::INT as id,
    RAW_DATA:job.salary::INT as salary,
    RAW_DATA:job.title::STRING as title,
    RAW_DATA:spoken_languages[0].language::STRING as language,
    RAW_DATA:spoken_languages[0].level::STRING as level
FROM our_first_db.public.HR_DATA
    UNION ALL  
SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:id::INT as id,
    RAW_DATA:job.salary::INT as salary,
    RAW_DATA:job.title::STRING as title,
    RAW_DATA:spoken_languages[1].language::STRING as language,
    RAW_DATA:spoken_languages[1].level::STRING as level
FROM our_first_db.public.HR_DATA
    UNION ALL 
SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:id::INT as id,
    RAW_DATA:job.salary::INT as salary,
    RAW_DATA:job.title::STRING as title,
    RAW_DATA:spoken_languages[0].language::STRING as language,
    RAW_DATA:spoken_languages[0].level::STRING as level
FROM our_first_db.public.HR_DATA
ORDER BY id;   
    
-- ^for the above SQL command, you need to know the maximum number of languages any one person in your dataset can speak.

SELECT 
    RAW_DATA:first_name::STRING as first_name,
    RAW_DATA:id::INT as id,
    f.value:language::STRING as language,
    f.value:level::STRING as level,
    FROM our_first_db.public.HR_DATA, table(flatten(RAW_DATA:spoken_languages)) as f; 

-- lets add the result into a new table

CREATE OR REPLACE TABLE our_first_db.public.hr_data_languages 
AS 
    select 
        RAW_DATA:first_name::STRING as first_name,
        RAW_DATA:id::INT as id,
        f.value:language::STRING as language,
        f.value:level::STRING as level
        FROM our_first_db.public.HR_DATA, table(flatten(RAW_DATA:spoken_languages)) as f;

select * from our_first_db.public.hr_data_languages limit 10; 

