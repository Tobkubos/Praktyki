--############################################################################################
-- AUTHOR: TK
--
-- ATTENTION!: First, execute the script that creates the necessary tables: WARM_UP_STRUCTURE_DDL.sql.​
--
-- Running this entire script will initialize all required objects, including sequences, triggers, functions, and packages.
-- At the very end, for testing purposes, a new user "TEST" will be automatically added to the USERS table.
-- The current user will be set to "1" (the first entry in the USERS table).
--############################################################################################
/*
DROP SEQUENCE USERS_USR_ID_SEQ;
DROP SEQUENCE PROD_PROD_ID_SEQ;
DROP SEQUENCE CATP_CATP_ID_SEQ;
DROP SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ;
DROP SEQUENCE MAH_MAH_ID_SEQ;
TRUNCATE TABLE CATP_PROD;
TRUNCATE TABLE PROD;
TRUNCATE TABLE CATP;
TRUNCATE TABLE MAH;
TRUNCATE TABLE USERS;
*/
--SET SERVEROUTPUT ON;
--SET SERVEROUTPUT OFF;
--############################################################################################
-- PACKAGE
--############################################################################################
CREATE OR REPLACE PACKAGE GLOBAL_USER_PKG AS
  gUSER_ID NUMBER;
  PROCEDURE SET_USER_ID(p_usr_id NUMBER);
  FUNCTION GET_USER_ID RETURN NUMBER;
END GLOBAL_USER_PKG;
/
CREATE OR REPLACE PACKAGE BODY GLOBAL_USER_PKG AS
  PROCEDURE SET_USER_ID(p_usr_id NUMBER) IS
  BEGIN
    gUSER_ID := p_usr_id;
  END SET_USER_ID;
  --
  FUNCTION GET_USER_ID RETURN NUMBER IS
  BEGIN
    RETURN gUSER_ID;
  END GET_USER_ID;
END GLOBAL_USER_PKG;
/
--############################################################################################
-- SEQUENCE
--############################################################################################
CREATE SEQUENCE USERS_USR_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/
CREATE SEQUENCE MAH_MAH_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/
CREATE SEQUENCE PROD_PROD_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/
CREATE SEQUENCE CATP_CATP_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/
CREATE SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/
--############################################################################################
-- FUNCTIONS
--############################################################################################
-- Clears the string from excesive dashes and spaces
CREATE OR REPLACE FUNCTION CLEAR_STRING_F(p_text VARCHAR2) RETURN VARCHAR2 IS
  v_clean_text VARCHAR2(100);
  BEGIN
    v_clean_text := REPLACE(p_text, '-', '');
    v_clean_text := REPLACE(v_clean_text, ' ', '');
  RETURN v_clean_text;
END CLEAR_STRING_F;
/
-- Returns string containing full description (args are options for final result)
CREATE OR REPLACE FUNCTION PROD_DESCRIBE_F(
  p_prod_id NUMBER,        
  p_include_prefix NUMBER, -- 1 = adding "(#PROD_ID)", 0 = not
  p_include_suffix NUMBER  -- 1 = adding "MAH: NazwaProducenta", 0 = not
  ) RETURN VARCHAR2 IS
  v_prod_name     VARCHAR2(100);
  v_prod_form     VARCHAR2(50);
  v_prod_strength VARCHAR2(50);
  v_prod_package  VARCHAR2(50);
  v_mah_name      VARCHAR2(100);
  v_result        VARCHAR2(200);
  -- Local function for clearing excesive dashes
  FUNCTION CLEAN_DASHES_F(p_text VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      RETURN REGEXP_REPLACE(NVL(TRIM(p_text), ''), '-{2,}', '-'); 
  END CLEAN_DASHES_F;
  --
  BEGIN
    SELECT PROD.PROD_NAME, PROD.PROD_FORM, PROD.PROD_STRENGTH, PROD.PROD_PACKAGE, MAH.NAME 
    INTO v_prod_name, v_prod_form, v_prod_strength, v_prod_package, v_mah_name
    FROM PROD
    LEFT JOIN MAH ON PROD.MAH_ID = MAH.MAH_ID
    WHERE PROD.PROD_ID = p_prod_id;
    --
    v_prod_name     := CLEAN_DASHES_F(v_prod_name);
    v_prod_form     := CLEAN_DASHES_F(v_prod_form);
    v_prod_strength := CLEAN_DASHES_F(v_prod_strength);
    v_prod_package  := CLEAN_DASHES_F(v_prod_package);
    -- Creating product name
    v_result := v_prod_name || ' ' || v_prod_form || ' ' || v_prod_strength || ' ' || v_prod_package;
    -- Prefix "(#PROD_ID)"
    IF p_include_prefix = 1 THEN
      v_result := '(#' || p_prod_id || ') ' || v_result;
    END IF;
    -- Sufix "MAH: NazwaProducenta"
    IF p_include_suffix = 1 THEN
      v_result := v_result || ' MAH: ' || NVL(v_mah_name, 'NIEOKREŚLONE');
    END IF;
    -- Clearing string from excesive spaces
    v_result := REGEXP_REPLACE(v_result, '\s+', ' ');
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'ERROR: NO DATA FOR PROD_ID: ' || p_prod_id;
    WHEN OTHERS THEN
      RETURN 'ERROR: ' || SQLERRM;
END PROD_DESCRIBE_F;
/
CREATE OR REPLACE FUNCTION CAT_PROD_COUNTER_F(
  p_catp_id NUMBER
  ) RETURN VARCHAR2 IS
  v_category_name VARCHAR(100);
  v_product_count NUMBER;
  v_result VARCHAR2(200);
  BEGIN
    SELECT CATP.NAME, COUNT(CATP_PROD_ID)
    INTO v_category_name, v_product_count
    FROM CATP
    LEFT JOIN CATP_PROD ON CATP.CATP_ID = CATP_PROD.CATP_ID
    WHERE CATP.CATP_ID = p_catp_id
    GROUP BY CATP.NAME;
    v_result := 'POSTAC: ' || v_category_name || ' (' || v_product_count || ' )';
    RETURN v_result;
  --
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'NO DATA FOR CATP_ID: ' || p_catp_id;
    WHEN OTHERS THEN
      RETURN 'ERROR: ' || SQLERRM;
END CAT_PROD_COUNTER_F;
/
--############################################################################################    
-- Main procedure - imports data from model to appropriate tables
--############################################################################################    
CREATE OR REPLACE PROCEDURE IMPORT_FROM_MODEL_P(p_usr_id NUMBER) AS
  CURSOR cur_source IS
    SELECT PRID, BLZ7_ID, KEAN, NAZW, POST, DAWK, OPAK, STOCK, PRICE, NPRD, PNZW, PKRJ
    FROM EXAMPLE_PRODUCT_MODEL
    ORDER BY PRID;
  v_post_clean VARCHAR2(100);
  v_dawk_clean VARCHAR2(100);
  v_category_name VARCHAR2(100);
  v_prod_id NUMBER;
  v_mah_id NUMBER;
  v_catp_id NUMBER;
  v_catp_prod_id NUMBER;
  -- Local function that creates FORM phrase from first word
  FUNCTION GET_FORM_CAT_F(p_post VARCHAR2) RETURN VARCHAR2 IS
    v_category VARCHAR2(100);
  BEGIN
    v_category := REGEXP_SUBSTR(TRIM(p_post), '^\S+|^[^.]+');
    IF v_category IS NOT NULL THEN
      RETURN 'POSTAC: ' || v_category;
    ELSE
      RETURN 'INNE';
    END IF;
  END GET_FORM_CAT_F;
  --
  BEGIN
    GLOBAL_USER_PKG.SET_USER_ID(p_usr_id);
    FOR rec IN cur_source LOOP   
      DBMS_OUTPUT.PUT_LINE('--------------------');
      DBMS_OUTPUT.PUT_LINE('BLZ7_ID: ' || rec.BLZ7_ID);
      DBMS_OUTPUT.PUT_LINE('KEAN: ' || rec.KEAN);
      DBMS_OUTPUT.PUT_LINE('NAZW: ' || rec.NAZW);
      DBMS_OUTPUT.PUT_LINE('POST: ' || rec.POST);
      DBMS_OUTPUT.PUT_LINE('DAWK: ' || rec.DAWK);
      DBMS_OUTPUT.PUT_LINE('OPAK: ' || rec.OPAK);
      DBMS_OUTPUT.PUT_LINE('STOCK: ' || rec.STOCK);
      DBMS_OUTPUT.PUT_LINE('PRICE: ' || rec.PRICE);
      DBMS_OUTPUT.PUT_LINE('NPRD: ' || rec.NPRD);
      DBMS_OUTPUT.PUT_LINE('PNZW: ' || rec.PNZW);
      DBMS_OUTPUT.PUT_LINE('PKRJ: ' || rec.PKRJ);
      DBMS_OUTPUT.PUT_LINE('--------------------');
      -- String cleaning
      v_post_clean := CLEAR_STRING_F(rec.POST);
      v_dawk_clean := CLEAR_STRING_F(rec.DAWK);
      -- Building category string from first word
      v_category_name := GET_FORM_CAT_F(v_post_clean);
      --INSERTING TO MAH
      DECLARE
        v_exists NUMBER;
      BEGIN
        SELECT COUNT(*) INTO v_exists FROM MAH WHERE NAME = rec.PNZW;
        IF v_exists = 0 THEN
          INSERT INTO MAH (NAME, COUNTRY)
          VALUES (rec.PNZW, NVL(rec.PKRJ, 'BRAK WPISU'));
        END IF;
        SELECT MAH_ID INTO v_mah_id FROM MAH WHERE NAME = rec.PNZW;
        EXCEPTION WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error while handling MAH for PNZW: ' || rec.PNZW);
          DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
      END;
      --INSERTING TO PROD
      DECLARE
        v_exists NUMBER;
      BEGIN
        SELECT COUNT(*) INTO v_exists
        FROM PROD 
        WHERE PROD_ID = rec.PRID;
        IF v_exists = 0 THEN
          INSERT INTO PROD(PROD_NAME, PROD_FORM, PROD_STRENGTH, PROD_PACKAGE, MAH_ID, BLZ7, GTIN, PROD_STOCK, PROD_PRICE) 
          VALUES (rec.NAZW, v_post_clean, v_dawk_clean, rec.OPAK, v_mah_id, rec.BLZ7_ID, rec.KEAN, rec.STOCK, rec.PRICE)
          RETURNING PROD_ID INTO v_prod_id;
        END IF;
        EXCEPTION WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error while handling PROD for PRID: ' || rec.PRID);
          DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
      END;
      --INSERTING TO CATP
      DECLARE
        v_exists NUMBER;
      BEGIN
        SELECT COUNT(*) INTO v_exists
        FROM CATP
        WHERE NAME = v_category_name;
        IF v_exists = 0 THEN
          INSERT INTO CATP(NAME)
          VALUES(v_category_name)
          RETURNING CATP_ID INTO v_catp_id;
        ELSE
          SELECT CATP_ID INTO v_catp_id 
          FROM CATP 
          WHERE NAME = v_category_name;
        END IF;
        EXCEPTION WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error while handling CATP for v_category_name: ' || v_category_name);
          DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
      END;  
      --INSERTING TO CATP_PTOD
      DECLARE
        v_exists NUMBER;
      BEGIN
        SELECT COUNT(*) INTO v_exists
        FROM CATP_PROD
        WHERE CATP_ID = v_catp_id AND PROD_ID = v_prod_id;
        IF v_exists = 0 THEN
          INSERT INTO CATP_PROD (CATP_ID, PROD_ID)
          VALUES (v_catp_id, v_prod_id);
        END IF;
        EXCEPTION WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error while handling CATP_PROD for v_catp_id | v_prod_id: ' || v_catp_id ||' | '|| v_prod_id);
          DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
      END;  
    END LOOP;
  END;
/
--############################################################################################    
-- TRIGGER 1 - trigger for insert operation
--############################################################################################    
CREATE OR REPLACE TRIGGER PROD_INSERT_TRG
  BEFORE INSERT ON PROD
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    IF :NEW.PROD_ID IS NULL THEN
      :NEW.PROD_ID := PROD_PROD_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER MAH_INSERT_TRG
  BEFORE INSERT ON MAH
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    IF :NEW.MAH_ID IS NULL THEN
      :NEW.MAH_ID := MAH_MAH_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER USERS_INSERT_TRG
  BEFORE INSERT ON USERS
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    IF :NEW.USR_ID IS NULL THEN
        :NEW.USR_ID := USERS_USR_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER CATP_INSERT_TRG
  BEFORE INSERT ON CATP
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    IF :NEW.CATP_ID IS NULL THEN
        :NEW.CATP_ID := CATP_CATP_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER CATP_PROD_INSERT_TRG
  BEFORE INSERT ON CATP_PROD
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
    IF :NEW.CATP_PROD_ID IS NULL THEN
      :NEW.CATP_PROD_ID := CATP_PROD_CATP_PROD_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
--############################################################################################    
-- TRIGGER 2 - trigger for update operation
--############################################################################################    
CREATE OR REPLACE TRIGGER PROD_UPDATE_TRG
  BEFORE UPDATE ON PROD
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
  END;
/
CREATE OR REPLACE TRIGGER MAH_UPDATE_TRG
  BEFORE UPDATE ON MAH
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
  END;
/
CREATE OR REPLACE TRIGGER USERS_UPDATE_TRG
  BEFORE UPDATE ON USERS
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
  END;
/
CREATE OR REPLACE TRIGGER CATP_UPDATE_TRG
  BEFORE UPDATE ON CATP
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
  END;
/
CREATE OR REPLACE TRIGGER CATP_PROD_UPDATE_TRG
  BEFORE UPDATE ON CATP_PROD
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.GET_USER_ID;
  END;
/
CREATE OR REPLACE VIEW CATP_PROD_COUNT_V AS
  SELECT 
    CATP.CATP_ID, 
    CATP.NAME || ' (' || 
    (SELECT COUNT(*) FROM CATP_PROD WHERE CATP_PROD.CATP_ID = CATP.CATP_ID) 
    || ')' AS NAME
  FROM CATP
  WITH READ ONLY;
--
CREATE OR REPLACE VIEW FULL_PROD_INFO_V AS 
  SELECT 
    PROD_ID, 
    PROD.PROD_STOCK, 
    PROD.PROD_PRICE, 
    PROD_DESCRIBE_F(PROD_ID, 0, 0) AS "PRODUCT NAME", 
    MAH.NAME AS "MAH_NAME"
  FROM PROD
  JOIN MAH ON PROD.MAH_ID = MAH.MAH_ID
  WITH READ ONLY;
--############################################################################################
-- TEST AREA
--############################################################################################
-- Setting user to 1
BEGIN
  GLOBAL_USER_PKG.SET_USER_ID(1);
END;
/
-- Inserting first user
INSERT INTO USERS (NAME, SURNAME, EMAIL) VALUES ('TEST2', 'TEST2', 'my_testing@test.com');
-- Executing main procedure
EXEC IMPORT_FROM_MODEL_P(GLOBAL_USER_PKG.get_user_id);
-- Inserting test product to check if the next product has ID number 1001
INSERT INTO PROD(PROD_NAME, PROD_FORM, PROD_STRENGTH, PROD_PACKAGE, MAH_ID, BLZ7, GTIN, PROD_STOCK, PROD_PRICE)
VALUES ('TEST NAZWA', 'TEST FORM', 'TEST DAWKA', 'TEST OPAK', 100, 12345, 123456, 999, 69);
-- Show view
--SELECT * from CATP_PROD_COUNT_V;
--SELECT * from FULL_PROD_INFO_V;
-- check if every object is VALID
--SELECT OBJECT_TYPE, OBJECT_NAME, STATUS FROM USER_OBJECTS WHERE STATUS = 'VALID' ORDER BY OBJECT_TYPE, OBJECT_NAME;
SELECT OBJECT_TYPE, OBJECT_NAME, STATUS FROM USER_OBJECTS WHERE STATUS != 'VALID' ORDER BY OBJECT_TYPE, OBJECT_NAME;
--COMMIT;