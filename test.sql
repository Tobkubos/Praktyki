SELECT USERNAME, ACCOUNT_STATUS FROM DBA_USERS WHERE USERNAME = 'MY_TESTING';
GRANT CREATE SESSION TO MY_TESTING;
ALTER USER MY_TESTING IDENTIFIED BY MY_TESTING;
ALTER SESSION SET CONTAINER=XEPDB1;
SHOW CON_NAME;

SELECT USERNAME FROM DBA_USERS;