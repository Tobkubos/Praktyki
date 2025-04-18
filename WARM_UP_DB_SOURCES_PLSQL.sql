--======================================================================================
-- AUTHOR: TK
--
-- ATTENTION!: First, execute the script that creates the necessary tables: WARM_UP_STRUCTURE_DDL.sql.​
--
-- Running this entire script will initialize all required objects, including sequences, triggers, functions, and packages.
-- At the very end, for testing purposes, a new user "TEST" will be automatically added to the USERS table.
-- The current user will be set to "1" (the first entry in the USERS table).
--======================================================================================
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
/*
SET SERVEROUTPUT ON;
SET SERVEROUTPUT OFF;
*/
CREATE OR REPLACE PACKAGE GLOBAL_USER_PKG AS
  --############################################################################################
  -- Package consisting of global variable storing actual user_id also providing getter and setter
  --############################################################################################
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
--======================================================================================
-- SEQUENCES
--======================================================================================
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
--======================================================================================
-- FUNCTIONS
--======================================================================================
CREATE OR REPLACE FUNCTION CLEAN_SPACES_F(v_result VARCHAR2) RETURN VARCHAR2 IS  
  --############################################################################################
  -- Function for clearing spaces dashes
  --############################################################################################
  BEGIN
    RETURN REGEXP_REPLACE(TRIM(v_result), '\s+', ' ');
  END CLEAN_SPACES_F;
/
CREATE OR REPLACE FUNCTION FIRST_WORD_CUT_F(p_post VARCHAR2) RETURN VARCHAR2 IS
  --############################################################################################
  -- Returns first word to space or "."
  --############################################################################################
  BEGIN
    RETURN REGEXP_SUBSTR(TRIM(p_post), '^\S+|^[^.]+');
  END FIRST_WORD_CUT_F;
/
CREATE OR REPLACE FUNCTION CLEAN_DASHES_F(p_text VARCHAR2) RETURN VARCHAR2 IS
  --############################################################################################
  -- Function for clearing excesive dashes
  --############################################################################################
  BEGIN
    RETURN REGEXP_REPLACE(NVL(TRIM(p_text), ''), '-{2,}', '-'); 
END CLEAN_DASHES_F;
/
CREATE OR REPLACE FUNCTION CLEAR_STRING_F(p_text VARCHAR2) RETURN VARCHAR2 IS
  --############################################################################################
  -- Clears the string from excesive dashes and spaces
  --############################################################################################
  v_clean_text VARCHAR2(100);
  BEGIN
    v_clean_text := REPLACE(p_text, '-', '');
    v_clean_text := REPLACE(v_clean_text, ' ', '');
  RETURN v_clean_text;
END CLEAR_STRING_F;
/
CREATE OR REPLACE FUNCTION PROD_DESCRIBE_F(
  --############################################################################################
  -- Returns string containing full description (args are options for final result)
  --############################################################################################
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
    v_result := CLEAN_SPACES_F(v_result);
    RETURN v_result;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'ERROR: NO DATA FOR PROD_ID: ' || p_prod_id;
    WHEN OTHERS THEN
      RETURN 'ERROR: ' || SQLERRM;
END PROD_DESCRIBE_F;
/
CREATE OR REPLACE FUNCTION CAT_PROD_COUNTER_F(
  --############################################################################################
  -- Returns how much products are in the category
  --############################################################################################
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
--======================================================================================
-- PROCEDURES
--======================================================================================
CREATE OR REPLACE PROCEDURE IMPORT_FROM_MODEL_P(p_usr_id NUMBER) AS
  --############################################################################################    
  -- Main procedure - imports data from model to appropriate tables
  --############################################################################################  
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
  v_exists NUMBER;
  -- Local function that creates FORM phrase from first word
  FUNCTION GET_FORM_CAT_F(p_post VARCHAR2) RETURN VARCHAR2 IS
    v_category VARCHAR2(100);
  BEGIN
      v_category := FIRST_WORD_CUT_F(p_post);
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
      v_dawk_clean := NVL(CLEAR_STRING_F(rec.DAWK), 'nieokreślone');
      -- Building category string from first word
      v_category_name := GET_FORM_CAT_F(v_post_clean);
      --INSERTING TO MAH
      v_exists := 0;
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
      v_exists := 0;
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
      v_exists := 0;
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
      v_exists := 0;
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
    COMMIT;
  END;
/
--
CREATE OR REPLACE PROCEDURE UPDATE_FROM_MODEL_P(p_usr_id NUMBER) AS
  --############################################################################################    
  -- Procedure that updates product data from model
  --############################################################################################
  CURSOR cur_source IS
    SELECT 
      m.PRID, m.BLZ7_ID, m.KEAN, m.NAZW, m.POST, m.DAWK, m.OPAK, m.STOCK, m.PRICE, m.NPRD, m.PNZW, m.PKRJ,
      p.PROD_NAME, p.PROD_FORM, p.PROD_STRENGTH, p.PROD_PACKAGE, p.BLZ7, p.GTIN, p.PROD_STOCK, p.PROD_PRICE
    FROM EXAMPLE_PRODUCT_MODEL m
    JOIN PROD p ON p.PROD_ID = m.PRID
    WHERE 
      p.PROD_NAME != m.NAZW
      OR p.PROD_FORM != CLEAR_STRING_F(m.POST)
      OR p.PROD_STRENGTH != NVL(CLEAR_STRING_F(m.DAWK), 'nieokreślone')
      OR p.PROD_PACKAGE != m.OPAK
      OR p.BLZ7 != m.BLZ7_ID
      OR p.GTIN != m.KEAN
      OR p.PROD_STOCK != m.STOCK
      OR p.PROD_PRICE != m.PRICE
    ORDER BY p.PROD_ID;
  BEGIN
    FOR rec IN cur_source LOOP
      DBMS_OUTPUT.PUT_LINE('Differences for PRID=' || rec.PRID);
      IF rec.PROD_NAME != rec.NAZW THEN
        DBMS_OUTPUT.PUT_LINE('  PROD_NAME: ' || rec.PROD_NAME || ' != ' || rec.NAZW);
        UPDATE PROD
          SET PROD_NAME = rec.NAZW
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.PROD_FORM != CLEAR_STRING_F(rec.POST) THEN
        DBMS_OUTPUT.PUT_LINE('  PROD_FORM: ' || rec.PROD_FORM || ' != ' || CLEAR_STRING_F(rec.POST));
        UPDATE PROD
          SET PROD_FORM = CLEAR_STRING_F(rec.POST)
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.PROD_STRENGTH != NVL(CLEAR_STRING_F(rec.DAWK), 'nieokreślone') THEN
        DBMS_OUTPUT.PUT_LINE('  PROD_STRENGTH: ' || rec.PROD_STRENGTH || ' != ' || NVL(CLEAR_STRING_F(rec.DAWK), 'nieokreślone'));
        UPDATE PROD
          SET PROD_STRENGTH = NVL(CLEAR_STRING_F(rec.DAWK), 'nieokreślone')
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.PROD_PACKAGE != rec.OPAK THEN
        DBMS_OUTPUT.PUT_LINE('  PROD_PACKAGE: ' || rec.PROD_PACKAGE || ' != ' || rec.OPAK);
         UPDATE PROD
          SET PROD_PACKAGE = rec.OPAK
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.BLZ7 != rec.BLZ7_ID THEN
        DBMS_OUTPUT.PUT_LINE('  PROD_BLZ7: ' || rec.BLZ7 || ' != ' || rec.BLZ7_ID);
         UPDATE PROD
          SET BLZ7 = rec.BLZ7_ID
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.GTIN != rec.KEAN THEN
        DBMS_OUTPUT.PUT_LINE('  GTIN: ' || rec.GTIN || ' != ' || rec.KEAN);
        UPDATE PROD
          SET GTIN = rec.KEAN
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.PROD_STOCK != rec.STOCK THEN
        DBMS_OUTPUT.PUT_LINE('  STOCK: ' || rec.PROD_STOCK || ' != ' || rec.STOCK);
        UPDATE PROD
          SET PROD_STOCK = rec.STOCK
          WHERE PROD_ID = rec.PRID;
      END IF;
      IF rec.PROD_PRICE != rec.PRICE THEN
        DBMS_OUTPUT.PUT_LINE('  PRICE: ' || rec.PROD_PRICE || ' != ' || rec.PRICE);
        UPDATE PROD
          SET PROD_PRICE = rec.PRICE
          WHERE PROD_ID = rec.PRID;
      END IF;
      COMMIT;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('EVEYTHING CHECKED');
  END;
/
--======================================================================================  
-- TRIGGER 1 - trigger for insert operation
--======================================================================================
CREATE OR REPLACE TRIGGER PROD_INSERT_TRG
  --###############################
  -- Trigger for inserting in PROD
  --###############################
  BEFORE INSERT ON PROD
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    IF :NEW.PROD_ID IS NULL THEN
      :NEW.PROD_ID := PROD_PROD_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER MAH_INSERT_TRG
  --###############################
  -- Trigger for inserting in MAH
  --###############################
  BEFORE INSERT ON MAH
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    IF :NEW.MAH_ID IS NULL THEN
      :NEW.MAH_ID := MAH_MAH_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER USERS_INSERT_TRG
  --###############################
  -- Trigger for inserting in USERS
  --###############################
  BEFORE INSERT ON USERS
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    IF :NEW.USR_ID IS NULL THEN
        :NEW.USR_ID := USERS_USR_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER CATP_INSERT_TRG
  --###############################
  -- Trigger for inserting in CATP
  --###############################
  BEFORE INSERT ON CATP
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    IF :NEW.CATP_ID IS NULL THEN
        :NEW.CATP_ID := CATP_CATP_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
CREATE OR REPLACE TRIGGER CATP_PROD_INSERT_TRG
  --###############################
  -- Trigger for inserting in CATP_PROD
  --###############################
  BEFORE INSERT ON CATP_PROD
  FOR EACH ROW
  BEGIN
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.CUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
    IF :NEW.CATP_PROD_ID IS NULL THEN
      :NEW.CATP_PROD_ID := CATP_PROD_CATP_PROD_ID_SEQ.NEXTVAL;
    END IF;
  END;
/
--======================================================================================  
-- TRIGGER 2 - trigger for update operation
--======================================================================================
CREATE OR REPLACE TRIGGER PROD_UPDATE_TRG
  --###############################
  -- Trigger for updating in PROD
  --###############################
  BEFORE UPDATE ON PROD
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
  END;
/
CREATE OR REPLACE TRIGGER MAH_UPDATE_TRG
  --###############################
  -- Trigger for updating in MAH
  --###############################
  BEFORE UPDATE ON MAH
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
  END;
/
CREATE OR REPLACE TRIGGER USERS_UPDATE_TRG
  --###############################
  -- Trigger for updating in USERS
  --###############################
  BEFORE UPDATE ON USERS
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
  END;
/
CREATE OR REPLACE TRIGGER CATP_UPDATE_TRG
  --###############################
  -- Trigger for updating in CATP
  --###############################
  BEFORE UPDATE ON CATP
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
  END;
/
CREATE OR REPLACE TRIGGER CATP_PROD_UPDATE_TRG
  --###############################
  -- Trigger for updating in CATP_PROD
  --###############################
  BEFORE UPDATE ON CATP_PROD
  FOR EACH ROW
  BEGIN
    :NEW.UPDATED_DT := SYSDATE;
    :NEW.UUSR_ID := GLOBAL_USER_PKG.gUSER_ID;
  END;
/
CREATE OR REPLACE VIEW CATP_PROD_COUNT_V AS
  SELECT 
    CATP.CATP_ID, 
    CATP.NAME || ' (' || COUNT(CATP_PROD.CATP_ID) || ')' AS NAME
  FROM CATP
    LEFT JOIN CATP_PROD ON (CATP_PROD.CATP_ID = CATP.CATP_ID)
  GROUP BY CATP.CATP_ID, CATP.NAME
  ORDER BY CATP.CATP_ID
  WITH READ ONLY;
--
CREATE OR REPLACE VIEW FULL_PROD_INFO_V AS 
  SELECT 
    PROD.PROD_ID, 
    PROD.PROD_STOCK, 
    PROD.PROD_PRICE,
    -- Product name
    CLEAN_SPACES_F(
      CLEAN_DASHES_F(PROD.PROD_NAME) || ' ' ||
      CLEAN_DASHES_F(PROD.PROD_FORM) || ' ' ||
      CLEAN_DASHES_F(PROD.PROD_STRENGTH) || ' ' ||
      CLEAN_DASHES_F(PROD.PROD_PACKAGE)
    ) AS "PRODUCT NAME",
    MAH.NAME AS "MAH_NAME"
  FROM PROD
  JOIN MAH ON PROD.MAH_ID = MAH.MAH_ID
  ORDER BY PROD.PROD_ID
  WITH READ ONLY;
--======================================================================================
-- TEST AREA
--======================================================================================
-- Check if every object is VALID
--SELECT OBJECT_TYPE, OBJECT_NAME, STATUS FROM DBA_OBJECTS WHERE STATUS != 'VALID' ORDER BY OBJECT_TYPE, OBJECT_NAME;
--SELECT OBJECT_TYPE, OBJECT_NAME, STATUS FROM DBA_OBJECTS WHERE STATUS = 'VALID' ORDER BY OBJECT_TYPE, OBJECT_NAME;
-- Setting user to 1
BEGIN
  GLOBAL_USER_PKG.SET_USER_ID(1);
END;
/
-- Inserting first user
INSERT INTO USERS (NAME, SURNAME, EMAIL) VALUES ('TEST2', 'TEST2', 'my_testing@test.com');
-- Executing main procedure
EXEC IMPORT_FROM_MODEL_P(GLOBAL_USER_PKG.get_user_id);
-- Updating data if something changed in model
--EXEC UPDATE_FROM_MODEL_P(GLOBAL_USER_PKG.get_user_id);
-- Inserting test product to check if the next product has ID number 1001
INSERT INTO PROD(PROD_NAME, PROD_FORM, PROD_STRENGTH, PROD_PACKAGE, MAH_ID, BLZ7, GTIN, PROD_STOCK, PROD_PRICE) VALUES ('TEST NAZWA', 'TEST FORM', 'TEST DAWKA', 'TEST OPAK', 100, 12345, 123456, 999, 69);
-- Show view
--SELECT * from CATP_PROD_COUNT_V;
--SELECT * from FULL_PROD_INFO_V;

