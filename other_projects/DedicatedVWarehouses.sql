-- Let's create two warehouses. One for the Data scientists and one for database admins

-- Warehouse for data scientists "DS_WH"

CREATE OR REPLACE WAREHOUSE "DS_WH"
WAREHOUSE_TYPE = 'STANDARD'
WAREHOUSE_SIZE = 'SMALL'
MAX_CLUSTER_COUNT = 1
MIN_CLUSTER_COUNT = 1
AUTO_SUSPEND = 120
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
COMMENT = 'Dedicated virtual warehouse for data scientists'; 

-- Warehouse for database admins "DBA_WH"

CREATE OR REPLACE WAREHOUSE "DBA_WH"
WAREHOUSE_TYPE = 'STANDARD'
WAREHOUSE_SIZE = 'XSMALL'
MAX_CLUSTER_COUNT = 1
MIN_CLUSTER_COUNT = 1
AUTO_SUSPEND = 120
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = TRUE
COMMENT = 'Dedicated virtual warehouse for data scientists'; 

-- Role for data scientists
CREATE OR REPLACE ROLE "data_scientists" ;

GRANT USAGE ON WAREHOUSE "DS_WH" TO ROLE "data_scientists" ; 

-- Role for database admins 
CREATE OR REPLACE ROLE "database_admins" ;
GRANT USAGE ON WAREHOUSE "DS_WH" TO ROLE "data_scientists" ;

-- Create user DS1 with the role "data_scientists"

CREATE USER "DS1" 
LOGIN_NAME = "DS1"
PASSWORD = "DS1_password"
DEFAULT_ROLE = "data_scientists"
DEFAULT_WAREHOUSE = "DS_WH"; 

GRANT ROLE "data_scientists"  to USER "DS1"; 

DESC USER "DS1"; 