--system tobiasz
--MY_TESTING MY_TESTING
SET SERVEROUTPUT ON;

DROP TABLE CATP_PROD;
DROP TABLE PROD;
DROP TABLE CATP;
DROP TABLE MAH;
DROP TABLE USERS;
DROP SEQUENCE USERS_USR_ID_SEQ;
DROP SEQUENCE PROD_PROD_ID_SEQ;
DROP SEQUENCE CATP_CATP_ID_SEQ;
DROP SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ;
DROP SEQUENCE MAH_MAH_ID_SEQ;
DROP FUNCTION FUNCTION_3_F;
DROP FUNCTION FUNCTION_4_F;

CREATE TABLE USERS(
    USR_ID      NUMBER(10),
    NAME        VARCHAR2(50)    NOT NULL,
    SURNAME     VARCHAR2(50)    NOT NULL,
    EMAIL       VARCHAR2(50)    NOT NULL,
    
    CONSTRAINT USERS_USR_ID_PK PRIMARY KEY(USR_ID)
);
COMMENT ON TABLE USERS IS '{O: "MY_TESTING", C: "Tabela użytkowników"}';
COMMENT ON COLUMN USERS.USR_ID IS 'Klucz główny';
COMMENT ON COLUMN USERS.NAME IS 'Imię';
COMMENT ON COLUMN USERS.SURNAME IS 'Nazwisko';
COMMENT ON COLUMN USERS.EMAIL IS 'e-mail';


CREATE SEQUENCE USERS_USR_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
    
CREATE OR REPLACE TRIGGER USERS_USR_ID_TRG
    BEFORE INSERT ON USERS
    FOR EACH ROW
    BEGIN
        IF: NEW.USR_ID IS NULL THEN
        SELECT USERS_USR_ID_SEQ.NEXTVAL INTO :NEW.USR_ID FROM DUAL;
        END IF;
    END;
/

INSERT INTO USERS (NAME, SURNAME, EMAIL) VALUES ('MY_TESTING', 'MY_TESTING', 'my_testing@test.com');





CREATE TABLE MAH(
    MAH_ID      NUMBER(10)      NOT NULL,
    NAME        VARCHAR2(100)   NOT NULL,
    COUNTRY     VARCHAR2(100)   NOT NULL,
    
    CONSTRAINT MAH_MAH_ID_PK PRIMARY KEY (MAH_ID)
);

COMMENT ON TABLE MAH IS '{O: "MY_TESTING", C: "podmiot odpowiedzialny"}';
COMMENT ON COLUMN MAH.MAH_ID is 'klucz główny';
COMMENT ON COLUMN MAH.Name is 'Nazwa podmiotu';
COMMENT ON COLUMN MAH.Country is 'Kraj';

CREATE SEQUENCE MAH_MAH_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
    
CREATE OR REPLACE TRIGGER MAH_MAH_ID_TRG
    BEFORE INSERT ON MAH
    FOR EACH ROW
    BEGIN
        IF: NEW.MAH_ID IS NULL THEN
        SELECT MAH_MAH_ID_SEQ.NEXTVAL INTO :NEW.MAH_ID FROM DUAL;
        END IF;
    END;
/   






CREATE TABLE PROD(
    PROD_ID         NUMBER(10),
    STATUS          CHAR(1)         DEFAULT 'I' NOT NULL CHECK(STATUS IN ('A', 'I')),
    PROD_NAME       VARCHAR(120)    NOT NULL,
    PROD_FORM       VARCHAR(40),
    PROD_STRENGTH   VARCHAR2(20),
    PROD_PACKAGE    VARCHAR2(40),
    MAH_ID          NUMBER(10)      NOT NULL,
    BLZ7            NUMBER(10),
    GTIN            NUMBER(14),
    PROD_STOCK      NUMBER(15,3) DEFAULT 0 NOT NULL CHECK(PROD_STOCK BETWEEN 0 AND 999999999),
    PROD_PRICE      NUMBER(15,3) DEFAULT 0 NOT NULL CHECK(PROD_PRICE BETWEEN 0 AND 999999999),
    
    CONSTRAINT PROD_PROD_ID_PK PRIMARY KEY (PROD_ID),
    CONSTRAINT PROD_MAH_MAH_ID_FK FOREIGN KEY (MAH_ID) REFERENCES MAH(MAH_ID),
    CONSTRAINT PROD_BLZ7_GTIN_UK UNIQUE (BLZ7, GTIN)
);

COMMENT ON TABLE PROD IS '{O: "MY_TESTING", C: "Produkty"}';
COMMENT ON COLUMN PROD.PROD_ID IS 'Klucz główny';
COMMENT ON COLUMN PROD.STATUS IS 'Status';
COMMENT ON COLUMN PROD.PROD_NAME IS 'Nazwa Produktu';
COMMENT ON COLUMN PROD.PROD_FORM IS 'Forma Produktu';
COMMENT ON COLUMN PROD.PROD_STRENGTH IS 'Moc Produktu';
COMMENT ON COLUMN PROD.PROD_PACKAGE IS 'Opakowanie';
COMMENT ON COLUMN PROD.MAH_ID IS 'ID podmiotu odpowiedzialnego';
COMMENT ON COLUMN PROD.BLZ7 IS 'Kod BLZ7';
COMMENT ON COLUMN PROD.GTIN IS 'Globalny numer jednostki handlowej';
COMMENT ON COLUMN PROD.PROD_STOCK IS 'Stan magazynowy';
COMMENT ON COLUMN PROD.PROD_PRICE IS 'Cena produktu';

CREATE SEQUENCE PROD_PROD_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER PROD_PROD_ID_TRG
    BEFORE INSERT ON PROD
    FOR EACH ROW
    BEGIN
        IF: NEW.PROD_ID IS NULL THEN
        SELECT PROD_PROD_ID_SEQ.NEXTVAL INTO :NEW.PROD_ID FROM DUAL;
        END IF;
    END;
/












CREATE TABLE CATP(
    CATP_ID     NUMBER(10)      NOT NULL,
    ACTIVE      CHAR(1)         DEFAULT 'N' NOT NULL CHECK(ACTIVE IN('Y','N')),
    NAME        VARCHAR2(50)    NOT NULL,
    
    CONSTRAINT CATP_CATP_OD_PK PRIMARY KEY (CATP_ID),
    CONSTRAINT CATP_NAME_UK UNIQUE (NAME) 
);

COMMENT ON TABLE CATP IS '{O: "MY_TESTING", C: "Kategorie produktów"}';
COMMENT ON COLUMN CATP.CATP_ID IS 'klucz główny';
COMMENT ON COLUMN CATP.ACTIVE IS 'Status';
COMMENT ON COLUMN CATP.NAME IS 'Nazwa Kategorii';


CREATE SEQUENCE CATP_CATP_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER CATP_CATP_ID_TRG
    BEFORE INSERT ON CATP
    FOR EACH ROW
    BEGIN
        IF: NEW.CATP_ID IS NULL THEN
        SELECT CATP_CATP_ID_SEQ.NEXTVAL INTO :NEW.CATP_ID FROM DUAL;
        END IF;
    END;
/    












--CATP_PROD + SEQUENCE + TRIGGER + PK (FK UK 1.1, FK UK 1.2)
CREATE TABLE CATP_PROD(
    CATP_PROD_ID NUMBER(10) NOT NULL,
    CATP_ID NUMBER(10) NOT NULL,
    PROD_ID NUMBER(10) NOT NULL,
    
    CONSTRAINT CATP_PROD_CATP_PROD_ID_PK PRIMARY KEY (CATP_PROD_ID),
    CONSTRAINT CATP_PROD_CATP_ID_PROD_ID UNIQUE (CATP_ID, PROD_ID),
    CONSTRAINT CATP_PROD_CAPT_CATP_ID_FK FOREIGN KEY (CATP_ID) REFERENCES CATP(CATP_ID),
    CONSTRAINT CATP_PROD_PROD_PROD_ID_FK FOREIGN KEY (PROD_ID) REFERENCES PROD(PROD_ID)
);
    
COMMENT ON TABLE CATP_PROD IS '{O: "MY_TESTING", C: "tabela asocjacji dla CATP i PROD"}';
COMMENT ON COLUMN CATP_PROD.CATP_PROD_ID IS 'klucz główny';
COMMENT ON COLUMN CATP_PROD.CATP_ID IS 'klucz kategorii';
COMMENT ON COLUMN CATP_PROD.PROD_ID IS 'klucz produktu';
    
CREATE SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
    
CREATE OR REPLACE TRIGGER CATP_PROD_CATP_PROD_ID_TRG
    BEFORE INSERT ON CATP_PROD
    FOR EACH ROW
    BEGIN
        IF: NEW.CATP_PROD_ID IS NULL THEN
        SELECT CATP_PROD_CATP_PROD_ID_SEQ.NEXTVAL INTO :NEW.CATP_PROD_ID FROM DUAL;
        END IF;
    END;
/    
    
    
    


--CONST COLUMNS FOR ALL
ALTER TABLE USERS ADD(
    CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
    UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
    CUSR_ID NUMBER(10),
    UUSR_ID NUMBER(10)
    
    --CONSTRAINT USERS_CUSR_ID_USR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
    --CONSTRAINT USERS_UUSR_ID_USR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
);
COMMENT ON COLUMN USERS.CREATED_DT IS 'Data stworzenia';
COMMENT ON COLUMN USERS.UPDATED_DT IS 'Data aktualizacji';
COMMENT ON COLUMN USERS.CUSR_ID IS 'ID użytkownika który stworzył rekord';
COMMENT ON COLUMN USERS.UUSR_ID IS 'ID użytkownika który zaktualizował rekord';

    
ALTER TABLE PROD ADD(
    CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
    UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
    CUSR_ID NUMBER(10) NOT NULL,
    UUSR_ID NUMBER(10) NOT NULL,
    
    CONSTRAINT PROD_CUSR_ID_USR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
    CONSTRAINT PROD_UUSR_ID_USR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
);
COMMENT ON COLUMN PROD.CREATED_DT IS 'Data stworzenia';
COMMENT ON COLUMN PROD.UPDATED_DT IS 'Data aktualizacji';
COMMENT ON COLUMN PROD.CUSR_ID IS 'ID użytkownika który stworzył rekord';
COMMENT ON COLUMN PROD.UUSR_ID IS 'ID użytkownika który zaktualizował rekord';

ALTER TABLE CATP ADD(
    CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
    UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
    CUSR_ID NUMBER(10) NOT NULL,
    UUSR_ID NUMBER(10) NOT NULL,
    
    CONSTRAINT CATP_CUSR_ID_USR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
    CONSTRAINT CATP_UUSR_ID_USR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
); 
COMMENT ON COLUMN CATP.CREATED_DT IS 'Data stworzenia';
COMMENT ON COLUMN CATP.UPDATED_DT IS 'Data aktualizacji';
COMMENT ON COLUMN CATP.CUSR_ID IS 'ID użytkownika który stworzył rekord';
COMMENT ON COLUMN CATP.UUSR_ID IS 'ID użytkownika który zaktualizował rekord';

ALTER TABLE CATP_PROD ADD(
    CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
    UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
    CUSR_ID NUMBER(10) NOT NULL,
    UUSR_ID NUMBER(10) NOT NULL,
    
    CONSTRAINT CATP_PROD_CUSR_ID_USR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
    CONSTRAINT CATP_PROD_UUSR_ID_USR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
);
COMMENT ON COLUMN CATP_PROD.CREATED_DT IS 'Data stworzenia';
COMMENT ON COLUMN CATP_PROD.UPDATED_DT IS 'Data aktualizacji';
COMMENT ON COLUMN CATP_PROD.CUSR_ID IS 'ID użytkownika który stworzył rekord';
COMMENT ON COLUMN CATP_PROD.UUSR_ID IS 'ID użytkownika który zaktualizował rekord';

ALTER TABLE MAH ADD(
    CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
    UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
    CUSR_ID NUMBER(10) NOT NULL,
    UUSR_ID NUMBER(10) NOT NULL,
    
    CONSTRAINT MAH_CUSR_ID_USR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
    CONSTRAINT MAH_UUSR_ID_USR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
); 
COMMENT ON COLUMN MAH.CREATED_DT IS 'Data stworzenia';
COMMENT ON COLUMN MAH.UPDATED_DT IS 'Data aktualizacji';
COMMENT ON COLUMN MAH.CUSR_ID IS 'ID użytkownika który stworzył rekord';
COMMENT ON COLUMN MAH.UUSR_ID IS 'ID użytkownika który zaktualizował rekord';











CREATE OR REPLACE FUNCTION FUNCTION_1_F(p_text VARCHAR2) RETURN VARCHAR2 IS
    v_clean_text VARCHAR2(100);
BEGIN
    v_clean_text := REPLACE(p_text, '-', '');
    v_clean_text := REPLACE(v_clean_text, ' ', '');
    
    RETURN v_clean_text;
END FUNCTION_1_F;
/


CREATE OR REPLACE FUNCTION FUNCTION_3_F(
    p_prod_id NUMBER,         -- PROD_ID, na podstawie którego pobieramy dane
    p_include_prefix BOOLEAN, -- TRUE = dodajemy "(#PROD_ID)"
    p_include_suffix BOOLEAN  -- TRUE = dodajemy "MAH: NazwaProducenta"
    
) RETURN VARCHAR2 IS
    v_prod_name     VARCHAR2(100);
    v_prod_form     VARCHAR2(50);
    v_prod_strength VARCHAR2(50);
    v_prod_package  VARCHAR2(50);
    v_mah_name      VARCHAR2(100);
    v_result        VARCHAR2(500);
    
    -- Pomocnicza funkcja do usunięcia nadmiarowych myślników
    FUNCTION CLEAN_DASHES(p_text VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN REGEXP_REPLACE(TRIM(p_text), '-{2,}', '-'); -- Zamiana "--" na "-"
    END CLEAN_DASHES;
    
BEGIN
    -- Pobranie danych z tabeli PROD i MAH
    SELECT PROD.PROD_NAME, PROD.PROD_FORM, PROD.PROD_STRENGTH, PROD.PROD_PACKAGE, MAH.NAME 
    INTO v_prod_name, v_prod_form, v_prod_strength, v_prod_package, v_mah_name
    FROM PROD
    LEFT JOIN MAH ON PROD.MAH_ID = MAH.MAH_ID
    WHERE PROD.PROD_ID = p_prod_id;

    -- Usunięcie nadmiarowych myślników z każdego pola
    v_prod_name     := CLEAN_DASHES(v_prod_name);
    v_prod_form     := CLEAN_DASHES(v_prod_form);
    v_prod_strength := CLEAN_DASHES(v_prod_strength);
    v_prod_package  := CLEAN_DASHES(v_prod_package);

    -- Tworzenie głównej nazwy produktu
    v_result := v_prod_name || ' ' || v_prod_form || ' ' || v_prod_strength || ' ' || v_prod_package;

    -- Dodanie prefixu "(#PROD_ID) " jeśli wymagane
    IF p_include_prefix THEN
        v_result := '(#' || p_prod_id || ') ' || v_result;
    END IF;

    -- Dodanie suffixu "MAH: NazwaProducenta" jeśli wymagane i jeśli producent istnieje
    IF p_include_suffix AND v_mah_name IS NOT NULL THEN
        v_result := v_result || ' MAH: ' || v_mah_name;
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
        SELECT BLZ7_ID, KEAN, NAZW, POST, DAWK, OPAK, STOCK, PRICE, NPRD, PNZW, PKRJ
        FROM EXAMPLE_PRODUCT_MODEL;
    
    
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
    DBMS_OUTPUT.PUT_LINE('WTF');
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
        DBMS_OUTPUT.PUT_LINE('rec.POST: ' || NVL(rec.POST, 'NULL'));
        v_post_clean := FUNCTION_1_F(rec.POST);
        v_dawk_clean := FUNCTION_1_F(rec.DAWK);
        DBMS_OUTPUT.PUT_LINE('v_post: ' || NVL(v_post_clean, 'NULL'));
        -- 2. nazwa kat
        v_category_name := FUNCTION_2_F(v_post_clean);
 
        DBMS_OUTPUT.PUT_LINE('v_category: ' || NVL(v_category_name, 'NULL'));
        -- Na poczatku sprawdzamy MAH, poniewaz PROD wymaga podania MAH_ID
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
            -- Sprawdź czy istnieje produkt z takim samym BLZ7 i GTIN
            SELECT PROD_ID INTO v_prod_id
            FROM PROD
            WHERE BLZ7 = rec.BLZ7_ID AND 
                  (GTIN = rec.KEAN OR (GTIN IS NULL AND rec.KEAN IS NULL))
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
                    VALUES (rec.NAZW, rec.POST, rec.DAWK, rec.OPAK, v_mah_id, rec.BLZ7_ID, rec.KEAN, rec.STOCK, rec.PRICE);
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
        /*
        -- sprawdzenie czy CATP_PROD juz istnieje
        BEGIN
            INSERT INTO CATP_PROD (CATP_ID, PROD_ID)
            SELECT v_catp_id, v_prod_id FROM DUAL
            WHERE NOT EXISTS(
            SELECT 1 FROM CATP_PROD WHERE CATP_ID = v_catp_id AND PROD_ID = v_prod_id);
        END;
        */     
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
    IF :NEW.USR_ID IS NULL THEN
        :NEW.USR_ID := USERS_USR_ID_SEQ.NEXTVAL;
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
--#####################################################################################################################


-- SELECT USER FROM DUAL;
-- SELECT MAH_MAH_ID_SEQ.NEXTVAL FROM DUAL;
-- INSERT INTO MAH(NAME, COUNTRY) VALUES ('TEST INC.', 'PL');

EXEC PROCEDURE_1_P(1);

SELECT BLZ7_ID, KEAN, NAZW, POST, DAWK, OPAK, STOCK, PRICE, NPRD, PNZW, PKRJ
FROM EXAMPLE_PRODUCT_MODEL
FETCH FIRST 10 ROW ONLY;

select count(*) from PROD;
