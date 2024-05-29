-- Let's create the GCS Storage Integration object

CREATE OR REPLACE STORAGE INTEGRATION "gcs_int"
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'GCS'
    ENABLED =  TRUE 
    STORAGE_ALLOWED_LOCATIONS = ('gcs://sampreet_cloudstorage_snowflake','gcs://sampreet_cloudstorage_snowflake_json')
    COMMENT = 'Storage integration object for GCP'; 


DESC STORAGE INTEGRATION "gcs_int";

CREATE OR REPLACE STAGE manage_db."external_stages"."gcs_snowflake"
STORAGE_INTEGRATION = "gcs_int"
url = 'gcs://sampreet_cloudstorage_snowflake'
file_format = (type=csv field_delimiter=',' skip_header=1); 


LIST @manage_db."external_stages"."gcs_snowflake"; 

SELECT $1, $2, $3, 
    $4, $5, $6, 
    $7, $8, $9, $10,
    $11, $12, $13, 
    $14, $15, $16, 
    $17, $18, $19, $20
FROM @manage_db."external_stages"."gcs_snowflake"; 

create or replace table OUR_FIRST_DB.PUBLIC.happiness (
    country_name varchar,
    regional_indicator varchar,
    ladder_score number(4,3),
    standard_error number(4,3),
    upperwhisker number(4,3),
    lowerwhisker number(4,3),
    logged_gdp number(5,3),
    social_support number(4,3),
    healthy_life_expectancy number(5,3),
    freedom_to_make_life_choices number(4,3),
    generosity number(4,3),
    perceptions_of_corruption number(4,3),
    ladder_score_in_dystopia number(4,3),
    explained_by_log_gpd_per_capita number(4,3),
    explained_by_social_support number(4,3),
    explained_by_healthy_life_expectancy number(4,3),
    explained_by_freedom_to_make_life_choices number(4,3),
    explained_by_generosity number(4,3),
    explained_by_perceptions_of_corruption number(4,3),
    dystopia_residual number (4,3));

COPY INTO OUR_FIRST_DB.PUBLIC.happiness 
FROM @manage_db."external_stages"."gcs_snowflake"; 

SELECT * FROM OUR_FIRST_DB.PUBLIC.happiness ;
-- DROP STAGE manage_db."external_stages"."gcs_snowflake"

-- because the service role we created on GCP for Snowflake has both read and write privileges 
-- we can write to the stage (GCP)

create or replace stage manage_db."external_stages"."gcp_unload_happinessData"
STORAGE_INTEGRATION = "gcs_int"
url = 'gcs://sampreet_cloudstorage_snowflake/unload_data'
file_format = (type = csv field_delimiter=',' skip_header=1 compression = auto); 

COPY INTO @manage_db."external_stages"."gcp_unload_happinessData"
FROM our_first_db.public.happiness; 

