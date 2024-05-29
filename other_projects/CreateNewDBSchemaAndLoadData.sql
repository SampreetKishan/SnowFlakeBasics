-- Create a new db
CREATE OR REPLACE DATABASE "OUR_FIRST_DB"; 

-- Using the default "public" schema, create a new table 

CREATE TABLE "OUR_FIRST_DB"."PUBLIC"."LOAN_PAYMENT" (
  "Loan_ID" STRING,
  "loan_status" STRING,
  "Principal" STRING,
  "terms" STRING,
  "effective_date" STRING,
  "due_date" STRING,
  "paid_off_time" STRING,
  "past_due_days" STRING,
  "age" STRING,
  "education" STRING,
  "Gender" STRING);

  -- Use the "OUR_FIRST_DB"."PUBLIC" schema

  USE DATABASE "OUR_FIRST_DB";
  USE SCHEMA "PUBLIC"; 

  -- There is no data in the "LOAN_PAYMENT" table

  SELECT * FROM LOAN_PAYMENT;

  -- Let's copy data from a public S3 bucket into the table

   COPY INTO LOAN_PAYMENT
    FROM s3://bucketsnowflakes3/Loan_payments_data.csv
    file_format = (type = csv 
                   field_delimiter = ',' 
                   skip_header=1);

    -- let's glance through the data 
    select * from loan_payment limit 10; 