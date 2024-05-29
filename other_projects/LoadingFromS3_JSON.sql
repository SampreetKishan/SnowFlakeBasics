-- let's make use the the same storage integration object

DESC STORAGE INTEGRATION "s3_int"; 

-- Let's create a new file format 
CREATE OR REPLACE FILE FORMAT manage_db."file_formats"."aws_snowflake_json_ff"
type = json ;

-- let's create a stage 

CREATE OR REPLACE STAGE MANAGE_DB."external_stages"."aws_snowflake_json_stage"
file_format = manage_db."file_formats"."aws_snowflake_json_ff"
STORAGE_INTEGRATION = "s3_int"
url = 's3://snowflakebucketsingapore/json/'; 

LIST @MANAGE_DB."external_stages"."aws_snowflake_json_stage"; 

select * from @MANAGE_DB."external_stages"."aws_snowflake_json_stage"; 


select 
$1:asin,
$1:helpful,
$1:overall,
$1:reviewText,
$1:reviewTime,
$1:reviewerID,
$1:reviewerName,
$1:summary,
$1:unixReviewTime
from @MANAGE_DB."external_stages"."aws_snowflake_json_stage";  


select 
$1:asin::STRING as ASIN,
$1:helpful::STRING as HELPFUL,
$1:overall::INT as OVERALL,
$1:reviewText::STRING as REVIEW_TEXT,
$1:reviewTime::STRING as REVIEW_DATE,
$1:reviewerID::STRING as REVIEWER_ID,
$1:reviewerName::STRING as REVIEWER_NAME,
$1:summary::STRING as SUMMARY,
DATE($1:unixReviewTime::INT) AS DT
from @MANAGE_DB."external_stages"."aws_snowflake_json_stage";  

select 
$1:asin::STRING as ASIN,
$1:helpful::STRING as HELPFUL,
$1:overall::INT as OVERALL,
$1:reviewText::STRING as REVIEW_TEXT,
$1:reviewTime::STRING as REVIEW_DATE,
$1:reviewerID::STRING as REVIEWER_ID,
$1:reviewerName::STRING as REVIEWER_NAME,
$1:summary::STRING as SUMMARY,
DATE($1:unixReviewTime::INT) AS DT
from @MANAGE_DB."external_stages"."aws_snowflake_json_stage";  


-- DATE_FROM_PARTS( <year>, <month>, <day> )

select 
$1:asin::STRING as ASIN,
$1:helpful::STRING as HELPFUL,
$1:overall::INT as OVERALL,
$1:reviewText::STRING as REVIEW_TEXT,
-- $1:reviewTime::STRING as REVIEW_DATE,
DATE_FROM_PARTS( 
    RIGHT($1:reviewTime,4), 
    LEFT($1:reviewTime,2), 
    CASE 
        WHEN SUBSTRING( $1:reviewTime, 5, 1 )=','
            THEN SUBSTRING($1:reviewTime,4,1)
        ELSE 
            SUBSTRING($1:reviewTime,4,2)
    END
) AS REVIEW_DATE,
$1:reviewerID::STRING as REVIEWER_ID,
$1:reviewerName::STRING as REVIEWER_NAME,
$1:summary::STRING as SUMMARY,
DATE($1:unixReviewTime::INT) AS DT
from @MANAGE_DB."external_stages"."aws_snowflake_json_stage"; 



-- Let's create the table

CREATE OR REPLACE TABLE our_first_db.public.review_data (
    ASIN STRING,
    HELPFUL STRING,
    OVERALL INT,
    REVIEW_TEXT STRING,
    REVIEW_DATE DATE,
    REVIEWER_ID STRING,
    REVIEWER_NAME STRING,
    SUMMARY STRING,
    DT DATE   
)


COPY INTO our_first_db.public.review_data
FROM (
    select 
    $1:asin::STRING as ASIN,
    $1:helpful::STRING as HELPFUL,
    $1:overall::INT as OVERALL,
    $1:reviewText::STRING as REVIEW_TEXT,
    -- $1:reviewTime::STRING as REVIEW_DATE,
    DATE_FROM_PARTS( 
        RIGHT($1:reviewTime,4), 
        LEFT($1:reviewTime,2), 
        CASE 
            WHEN SUBSTRING( $1:reviewTime, 5, 1 )=','
                THEN SUBSTRING($1:reviewTime,4,1)
            ELSE 
                SUBSTRING($1:reviewTime,4,2)
        END
    ) AS REVIEW_DATE,
    $1:reviewerID::STRING as REVIEWER_ID,
    $1:reviewerName::STRING as REVIEWER_NAME,
    $1:summary::STRING as SUMMARY,
    DATE($1:unixReviewTime::INT) AS DT
    from @MANAGE_DB."external_stages"."aws_snowflake_json_stage"
); 

SELECT * FROM our_first_db.public.review_data LIMIT 10; 