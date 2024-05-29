show shares; 

DESC SHARE orders_share; 

CREATE MANAGED ACCOUNT TEST_CLIENT
ADMIN_NAME = 'test_client',
ADMIN_PASSWORD ='Test_client_password_115'
TYPE = READER; 

--{"accountName":"TEST_CLIENT","accountLocator":"RA66238","url":"https://lysndrb-test_client.snowflakecomputing.com","accountLocatorUrl":"https://ra66238.ap-southeast-1.snowflakecomputing.com"}

ALTER SHARE orders_share
ADD ACCOUNT ="RA66238"; 

DROP MANAGED ACCOUNT TEST_CLIENT; 



