
--#########################################
-- Skrypt stworzony przez: Tobiasz Kubiak
--#########################################

/*
DROP SEQUENCE USERS_USR_ID_SEQ;
DROP SEQUENCE PROD_PROD_ID_SEQ;
DROP SEQUENCE CATP_CATP_ID_SEQ;
DROP SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ;
DROP SEQUENCE MAH_MAH_ID_SEQ;
*/

/*

trzeba zrobic package, pozwala to tworzyc zmienne globalne, stworzenie pakietu z jednej procedury i jedney funkcji, zadaniem procedury bedize wpisanie do package usera a funckja odczytuje odentyfikator

*/



CREATE SEQUENCE USERS_USR_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE MAH_MAH_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE PROD_PROD_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE CATP_CATP_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

    
CREATE OR REPLACE FUNCTION FUNCTION_1_F(p_text VARCHAR2) RETURN VARCHAR2 IS
    v_clean_text VARCHAR2(100);
BEGIN
    v_clean_text := REPLACE(p_text, '-', '');
    v_clean_text := REPLACE(v_clean_text, ' ', '');
    
    RETURN v_clean_text;
END FUNCTION_1_F;
/

CREATE OR REPLACE FUNCTION FUNCTION_3_F(
    p_prod_id NUMBER,        
    p_include_prefix NUMBER, -- 1 = dodajemy "(#PROD_ID)", 0 = nie
    p_include_suffix NUMBER  -- 1 = dodajemy "MAH: NazwaProducenta", 0 = nie
) RETURN VARCHAR2 IS
    v_prod_name     VARCHAR2(100);
    v_prod_form     VARCHAR2(50);
    v_prod_strength VARCHAR2(50);
    v_prod_package  VARCHAR2(50);
    v_mah_name      VARCHAR2(100);
    v_result        VARCHAR2(500);

    -- Usuwanie nadmiarowych myślników i obsługa NULL
    FUNCTION CLEAN_DASHES(p_text VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN REGEXP_REPLACE(NVL(TRIM(p_text), ''), '-{2,}', '-'); 
    END CLEAN_DASHES;

BEGIN
    -- Pobranie danych
    SELECT PROD.PROD_NAME, PROD.PROD_FORM, PROD.PROD_STRENGTH, PROD.PROD_PACKAGE, MAH.NAME 
    INTO v_prod_name, v_prod_form, v_prod_strength, v_prod_package, v_mah_name
    FROM PROD
    LEFT JOIN MAH ON PROD.MAH_ID = MAH.MAH_ID
    WHERE PROD.PROD_ID = p_prod_id;

    -- Usunięcie nadmiarowych myślników
    v_prod_name     := CLEAN_DASHES(v_prod_name);
    v_prod_form     := CLEAN_DASHES(v_prod_form);
    v_prod_strength := CLEAN_DASHES(v_prod_strength);
    v_prod_package  := CLEAN_DASHES(v_prod_package);

    -- Tworzenie głównej nazwy produktu
    v_result := v_prod_name || ' ' || v_prod_form || ' ' || v_prod_strength || ' ' || v_prod_package;

    -- Prefiks "(#PROD_ID)"
    IF p_include_prefix = 1 THEN
        v_result := '(#' || p_prod_id || ') ' || v_result;
    END IF;

    -- Sufiks "MAH: NazwaProducenta"
    IF p_include_suffix = 1 THEN
        v_result := v_result || ' MAH: ' || NVL(v_mah_name, 'BRAK PRODUCENTA');
    END IF;

    -- Usunięcie nadmiarowych spacji
    v_result := REGEXP_REPLACE(v_result, '\s+', ' ');

    RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'BRAK DANYCH DLA PROD_ID: ' || p_prod_id;
    WHEN OTHERS THEN
        RETURN 'BŁĄD: ' || SQLERRM;
END FUNCTION_3_F;
/

CREATE OR REPLACE FUNCTION FUNCTION_4_F(
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
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'BRAK DANYCH DLA CATP_ID' || p_catp_id;
        WHEN OTHERS THEN
            RETURN 'BŁĄD ' || SQLERRM;
END FUNCTION_4_F;
/

--#####################################################################################################################
--
--              GŁÓWNA PROCEDURA
--
--#####################################################################################################################
CREATE OR REPLACE PROCEDURE PROCEDURE_1_P(p_usr_id NUMBER) AS
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
    
       
       
        FUNCTION FUNCTION_2_F(p_post VARCHAR2) RETURN VARCHAR2 IS
            v_category VARCHAR2(100);
        BEGIN
            v_category := REGEXP_SUBSTR(TRIM(p_post), '^\S+|^[^.]+');
            
            IF v_category IS NOT NULL THEN
                RETURN 'POSTAC: ' || v_category;
            ELSE
                RETURN 'POSTAC: NIEZNANA';
            END IF;
        END FUNCTION_2_F;
        
        
    BEGIN
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
        
        
        -- 1. myslniki i spacje
        v_post_clean := FUNCTION_1_F(rec.POST);
        v_dawk_clean := FUNCTION_1_F(rec.DAWK);
        -- 2. nazwa kat
        v_category_name := FUNCTION_2_F(v_post_clean);
 
        -- Na poczatku sprawdzamy MAH, poniewaz PROD wymaga podania MAH_ID, sprawdzamy na podstawie nazwy
         BEGIN
            SELECT MAH_ID INTO v_mah_id 
            FROM MAH 
            WHERE NAME = rec.PNZW;
         
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                --wstawiamy nowy rekord i pobieramy ID
                INSERT INTO MAH (NAME, COUNTRY)
                VALUES (rec.PNZW, NVL(rec.PKRJ, 'BRAK WPISU'))
                RETURNING MAH_ID INTO v_mah_id;
        END;
        
        BEGIN
            -- Sprawdź czy istnieje produkt
            SELECT PROD_ID INTO v_prod_id
            FROM PROD
            WHERE PROD_ID = rec.PRID
            FOR UPDATE NOWAIT;
            
            UPDATE PROD
                SET 
                    PROD_NAME = rec.nazw,
                    PROD_FORM = v_post_clean,
                    PROD_STRENGTH = v_dawk_clean,
                    PROD_PACKAGE = rec.OPAK,
                    PROD_STOCK = rec.STOCK,
                    PROD_PRICE = rec.PRICE
                WHERE PROD_ID = v_prod_id;
                
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO PROD(PROD_NAME, PROD_FORM, PROD_STRENGTH, PROD_PACKAGE, MAH_ID, BLZ7, GTIN, PROD_STOCK, PROD_PRICE)
                    VALUES (rec.NAZW, rec.POST, rec.DAWK, rec.OPAK, v_mah_id, rec.BLZ7_ID, rec.KEAN, rec.STOCK, rec.PRICE)
                    RETURNING PROD_ID INTO v_prod_id;
        END;
        
        -- sprawdzenie czy CATP juz istnieje
        BEGIN
            SELECT CATP_ID into v_catp_id 
                FROM CATP
                WHERE NAME = v_category_name
                FOR UPDATE NOWAIT;
                
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    INSERT INTO CATP(NAME)
                    VALUES(v_category_name)
                    RETURNING CATP_ID INTO v_catp_id;
        END;
        --/*
        -- sprawdzenie czy CATP_PROD juz istnieje
        BEGIN
            INSERT INTO CATP_PROD (CATP_ID, PROD_ID)
            SELECT v_catp_id, v_prod_id FROM DUAL
            WHERE NOT EXISTS(
            SELECT 1 FROM CATP_PROD WHERE CATP_ID = v_catp_id AND PROD_ID = v_prod_id);
        END;
       -- */     
    END LOOP;
END;
/

--#####################################################################################################################
--
--          TRIGGER 1 - trigger podczas wstawiania nowego rekordu
--
--#####################################################################################################################
CREATE OR REPLACE TRIGGER TRIGGER_1_PROD_TRG
BEFORE INSERT ON PROD
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;

    -- Automatyczne przypisanie ID użytkownika
    :NEW.CUSR_ID := v_user_id;
    :NEW.UUSR_ID := v_user_id;

    -- Ustawienie nowej wartości klucza głównego, jeśli jest NULL
    IF :NEW.PROD_ID IS NULL THEN
        :NEW.PROD_ID := PROD_PROD_ID_SEQ.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRIGGER_1_MAH_TRG
BEFORE INSERT ON MAH
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;

    -- Automatyczne przypisanie ID użytkownika
    :NEW.CUSR_ID := v_user_id;
    :NEW.UUSR_ID := v_user_id;

    -- Ustawienie nowej wartości klucza głównego, jeśli jest NULL
    IF :NEW.MAH_ID IS NULL THEN
        :NEW.MAH_ID := MAH_MAH_ID_SEQ.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRIGGER_1_USERS_TRG
    BEFORE INSERT ON USERS
    FOR EACH ROW
    BEGIN
        IF: NEW.USR_ID IS NULL THEN
        SELECT USERS_USR_ID_SEQ.NEXTVAL INTO :NEW.USR_ID FROM DUAL;
        END IF;
    END;
/

CREATE OR REPLACE TRIGGER TRIGGER_1_CATP_TRG
BEFORE INSERT ON CATP
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;

    -- Automatyczne przypisanie ID użytkownika
    :NEW.CUSR_ID := v_user_id;
    :NEW.UUSR_ID := v_user_id;

    -- Ustawienie nowej wartości klucza głównego, jeśli jest NULL
    IF :NEW.CATP_ID IS NULL THEN
        :NEW.CATP_ID := CATP_CATP_ID_SEQ.NEXTVAL;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRIGGER_1_CATP_PROD_TRG
BEFORE INSERT ON CATP_PROD
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.CREATED_DT := SYSDATE;
    :NEW.UPDATED_DT := SYSDATE;

    -- Automatyczne przypisanie ID użytkownika
    :NEW.CUSR_ID := v_user_id;
    :NEW.UUSR_ID := v_user_id;

    -- Ustawienie nowej wartości klucza głównego, jeśli jest NULL
    IF :NEW.CATP_PROD_ID IS NULL THEN
        :NEW.CATP_PROD_ID := CATP_PROD_CATP_PROD_ID_SEQ.NEXTVAL;
    END IF;
END;
/
--#####################################################################################################################
--
--          TRIGGER 2 - trigger podczas aktualizacji rekordu
--
--#####################################################################################################################
CREATE OR REPLACE TRIGGER TRIGGER_2_PROD_TRG
BEFORE UPDATE ON PROD
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.UPDATED_DT := SYSDATE;
    -- Automatyczne przypisanie ID użytkownika
    :NEW.UUSR_ID := v_user_id;
END;
/

CREATE OR REPLACE TRIGGER TRIGGER_2_USERS_TRG
BEFORE UPDATE ON USERS
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.UPDATED_DT := SYSDATE;
    -- Automatyczne przypisanie ID użytkownika
    :NEW.UUSR_ID := v_user_id;
END;
/

CREATE OR REPLACE TRIGGER TRIGGER_2_CATP_TRG
BEFORE UPDATE ON CATP
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.UPDATED_DT := SYSDATE;
    -- Automatyczne przypisanie ID użytkownika
    :NEW.UUSR_ID := v_user_id;
END;
/

CREATE OR REPLACE TRIGGER TRIGGER_2_CATP_PROD_TRG
BEFORE UPDATE ON CATP_PROD
FOR EACH ROW
DECLARE
    v_user_id NUMBER;
BEGIN
    -- Pobranie ID użytkownika na podstawie aktualnego użytkownika bazy danych
    SELECT USR_ID INTO v_user_id
    FROM USERS
    WHERE NAME = USER
    FETCH FIRST 1 ROW ONLY;  -- Dla bezpieczeństwa, jeśli zwróci wiele wierszy

    -- Ustawienie wartości timestamp
    :NEW.UPDATED_DT := SYSDATE;
    -- Automatyczne przypisanie ID użytkownika
    :NEW.UUSR_ID := v_user_id;
END;
/


CREATE OR REPLACE VIEW VIEW_2_V AS
    SELECT 
        CATP.CATP_ID, 
        CATP.NAME || ' (' || 
        (SELECT COUNT(*) FROM CATP_PROD WHERE CATP_PROD.CATP_ID = CATP.CATP_ID) 
        || ')' AS NAME
    FROM CATP
    WITH READ ONLY;
    
    
CREATE OR REPLACE VIEW VIEW_1_V AS 
SELECT 
    PROD_ID, 
    PROD.PROD_STOCK, 
    PROD.PROD_PRICE, 
    FUNCTION_3_F(PROD_ID, 0, 0) AS "PRODUCT NAME", 
    MAH.NAME AS "MAH_NAME"
FROM PROD
JOIN MAH ON PROD.MAH_ID = MAH.MAH_ID
WITH READ ONLY;
--#####################################################################################################################
--
-- PACKAGE DO USTAWIANIA ZMIENNEJ GLOBALNEJ gUSER_ID
--
--#####################################################################################################################

CREATE OR REPLACE PACKAGE PACKAGE_1_PKG AS
    -- Zmienna globalna
    gUSER_ID NUMBER;

    -- Procedura ustawiająca wartość zmiennej globalnej
    PROCEDURE SET_USER_ID(p_usr_id NUMBER);

    -- Funkcja do odczytu wartości zmiennej globalnej
    FUNCTION GET_USER_ID RETURN NUMBER;

    -- Procedura do uzupełniania CUSR_ID i UUSR_ID
    PROCEDURE UPDATE_USER_IDS(p_usr_id NUMBER);
    
END PACKAGE_1_PKG;
/

CREATE OR REPLACE PACKAGE BODY PACKAGE_1_PKG AS

    -- Procedura ustawiająca wartość zmiennej globalnej
    PROCEDURE SET_USER_ID(p_usr_id NUMBER) IS
    BEGIN
        gUSER_ID := p_usr_id;
    END SET_USER_ID;

    -- Funkcja do odczytu wartości zmiennej globalnej
    FUNCTION GET_USER_ID RETURN NUMBER IS
    BEGIN
        RETURN gUSER_ID;
    END GET_USER_ID;

    -- Procedura do uzupełniania CUSR_ID i UUSR_ID
    PROCEDURE UPDATE_USER_IDS(p_usr_id NUMBER) IS
    BEGIN
        UPDATE USERS
        SET CUSR_ID = p_usr_id, 
            UUSR_ID = p_usr_id
        WHERE USR_ID = p_usr_id;
    END UPDATE_USER_IDS;

END PACKAGE_1_PKG;
/


--#####################################################################################################################
INSERT INTO USERS (NAME, SURNAME, EMAIL) VALUES ('MY_TESTING', 'MY_TESTING', 'my_testing@test.com');
EXEC PROCEDURE_1_P(1);
--SELECT * from VIEW_2_V;
--SELECT * from VIEW_1_V;
select count(*) from PROD;



