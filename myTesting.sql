--system tobiasz
--MY_TESTING MY_TESTING

/*
DROP TABLE USERS;
DROP TABLE PROD;
DROP TABLE CATP;
DROP TABLE CATP_PROD;
DROP TABLE MAH;
DROP SEQUENCE USERS_USR_ID_SEQ;
DROP SEQUENCE PROD_PROD_ID_SEQ;
DROP SEQUENCE CATP_CATP_ID_SEQ;
DROP SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ;
DROP SEQUENCE MAH_MAH_ID_SEQ;
*/

CREATE TABLE USERS(
    USR_ID NUMBER(10),
    NAME VARCHAR2(50) NOT NULL,
    SURNAME VARCHAR2(50) NOT NULL,
    EMAIL VARCHAR2(50) NOT NULL,
    
    CONSTRAINT USERS_USR_ID_PK PRIMARY KEY(USR_ID)
);
COMMENT ON TABLE USERS IS '{O: "MY_TESTING", C: "Tabela użytkowników"}';
COMMENT ON COLUMN USERS.USR_ID IS 'Klucz główny';
COMMENT ON COLUMN USERS.NAME IS 'Imię';
COMMENT ON COLUMN USERS.SURNAME IS 'Nazwisko';
COMMENT ON COLUMN USERS.EMAIL IS 'e-mail';

CREATE SEQUENCE USERS_USR_ID_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
    
CREATE OR REPLACE TRIGGER USERS_USR_ID_TRG
    BEFORE INSERT ON USERS
    FOR EACH ROW
    BEGIN
        IF: NEW.USR_ID IS NULL THEN
        SELECT USERS_USR_ID_SEQ.NEXTVAL INTO :NEW.USR_ID FROM DUAL;
        END IF;
    END;
/









CREATE TABLE PROD(
    PROD_ID NUMBER(10),
    STATUS CHAR(1) DEFAULT 'I' NOT NULL CHECK(STATUS IN ('A', 'I')),
    PROD_NAME VARCHAR(80) NOT NULL,
    PROD_FORM VARCHAR(20),
    PROD_STRENGTH VARCHAR2(20),
    PROD_PACKAGE VARCHAR2(20),
    MAH_ID NUMBER(10) NOT NULL,
    BLZ7 NUMBER(10),
    GTIN NUMBER(13),
    PROD_STOCK NUMBER(15,3) DEFAULT 0 NOT NULL CHECK(PROD_STOCK BETWEEN 0 AND 999999999),
    PROD_PRICE NUMBER(15,3) DEFAULT 0 NOT NULL CHECK(PROD_PRICE BETWEEN 0 AND 999999999),

    CONSTRAINT PROD_PROD_ID_PK PRIMARY KEY (PROD_ID)
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

CREATE SEQUENCE PROD_PROD_ID_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

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
    CATP_ID NUMBER(10) NOT NULL,
    ACTIVE CHAR(1) DEFAULT 'N' NOT NULL CHECK(ACTIVE IN('Y','N')),
    NAME VARCHAR2(50) NOT NULL,
    
    CONSTRAINT CATP_CATP_OD_PK PRIMARY KEY (CATP_ID),
    CONSTRAINT CATP_NAME_UK UNIQUE (NAME) 
);

COMMENT ON TABLE CATP IS '{O: "MY_TESTING", C: "Kategorie produktów"}';
COMMENT ON COLUMN CATP.CATP_ID IS 'klucz główny';
COMMENT ON COLUMN CATP.ACTIVE IS 'Status';
COMMENT ON COLUMN CATP.NAME IS 'Nazwa Kategorii';


CREATE SEQUENCE CATP_CATP_ID_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

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
    
CREATE SEQUENCE CATP_PROD_CATP_PROD_ID_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
    
CREATE OR REPLACE TRIGGER CATP_PROD_CATP_PROD_ID_TRG
    BEFORE INSERT ON CATP_PROD
    FOR EACH ROW
    BEGIN
        IF: NEW.CATP_PROD_ID IS NULL THEN
        SELECT CATP_PROD_CATP_PROD_ID_SEQ.NEXTVAL INTO :NEW.CATP_PROD_ID FROM DUAL;
        END IF;
    END;
/    
    
    
    
    
    
    
    
    
    
CREATE TABLE MAH(
    MAH_ID NUMBER(10) NOT NULL,
    NAME VARCHAR2(100) NOT NULL,
    COUNTRY VARCHAR2(100) NOT NULL,
    
    CONSTRAINT MAH_MAH_ID_PK PRIMARY KEY (MAH_ID)
);

COMMENT ON TABLE MAH IS '{O: "MY_TESTING", C: "podmiot odpowiedzialny"}';
COMMENT ON COLUMN MAH.MAH_ID is 'klucz główny';
COMMENT ON COLUMN MAH.Name is 'Nazwa podmiotu';
COMMENT ON COLUMN MAH.Country is 'Kraj';

CREATE SEQUENCE MAH_MAH_ID_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
    
CREATE OR REPLACE TRIGGER MAH_MAH_ID_TRG
    BEFORE INSERT ON MAH
    FOR EACH ROW
    BEGIN
        IF: NEW.MAH_ID IS NULL THEN
        SELECT MAH_MAH_ID_SEQ.NEXTVAL INTO :NEW.MAH_ID FROM DUAL;
        END IF;
    END;
/   




--CONSTRAINT DO PROD - MAH
ALTER TABLE PROD ADD(
    CONSTRAINT PROD_MAH_MAH_ID_FK FOREIGN KEY (MAH_ID) REFERENCES MAH(MAH_ID)
)

--CONST COLUMNS FOR ALL
ALTER TABLE USERS ADD(
    CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
    UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
    CUSR_ID NUMBER(10) NOT NULL,
    UUSR_ID NUMBER(10) NOT NULL,
    
    CONSTRAINT USERS_CUSR_ID_USR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
    CONSTRAINT USERS_UUSR_ID_USR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
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













CREATE OR REPLACE PROCEDURE PROCEDURE_1_P(P_USR_ID NUMBER) AS
    CURSOR cur_source IS
        SELECT BLZ7_ID, KEAN, NAZW, POST, DAWK, OPAK, STOCK, PRICE, NPRD, PNZW, PKRJ
        FROM EXAMPLE_PRODUCT_MODEL;
    
    v_post_clean VARCHAR2(100);
    v_dawk_clean VARCHAR2(100);
    v_category_name VARCHAR2(100);
    
    v_prod_id NUMBER;
    v_mah_id NUMBER;
    v_capt_id NUMBER;
    
        
        FUNCTION FUNCTION_2_F(p_post VARCHAR2) RETURN VARCHAR2 IS
            v_category VARCHAR2(100);
        BEGIN
            v_category := REGEXP_SUBSTR(TRIM(p_post), '^\S+|^[^.]+');
            
            IF v_category IS NOT NULL THEN
                RETURN 'POSTAC: ' || v_category;
            ELSE
                RETURN NULL;
            END IF;
        END FUNCTION_2_F;


    BEGIN
    FOR rec IN cur_source LOOP
        -- 1. myslniki i spacje
        v_post_clean := FUNCTION_1_F(rec.POST);
        v_dawk_clean := FUNCTION_1_F(rec.DAWK);

        -- 2. nazwa kat
        v_category_name := FUNCTION_2_F(v_post_clean);


        -- Na poczatku sprawdzamy MAH, poniewaz PROD wymaga podania MAH_ID
        BEGIN
            SELECT MAH_ID INTO v_mah_id 
            FROM MAH 
            WHERE NAME = rec.PNZW 
            FOR UPDATE NOWAIT;
            
            UPDATE MAH 
                SET COUNTRY = rec.PKRJ,
                    UUSR_ID = P_USR_ID,
                    UPDATED_DT = SYSDATE
                WHERE MAH_ID = v_mah_id;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                SELECT MAH_MAH_ID_SEQ.NEXTVAL INTO v_mah_id FROM DUAL;
                
                INSERT INTO MAH (MAH_ID, NAME, COUNTRY, CREATED_DT, UPDATED_DT, CUSR_ID, UUSR_ID)
                VALUES (v_mah_id, rec.PNZW, rec.PKRJ, SYSDATE, SYSDATE, P_USR_ID, P_USR_ID);
        END;
        
        
        -- Sprawdzenie czy produkt juz istnieje po numerze GTIN
        BEGIN
            SELECT PROD_ID INTO v_prod_id
                FROM PROD
                WHERE GTIN = rec.KEAN
                FOR UPDATE NOWAIT;
            
            UPDATE PROD
                SET 
                    PROD_NAME = rec.nazw,
                    PROD_FORM = v_post_clean,
                    PROD_STRENGTH = v_dawk_clean,
                    PROD_PACKAGE = rec.OPAK,
                    PROD_STOCK = rec.STOCK,
                    PROD_PRICE = rec.PRICE,
                    UUSR_ID = P_USR_ID_ID,
                    UPDATED_DT = SYSDATE
                WHERE PROD_ID = v_prod_id;
                
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    SELECT PROD_PROD_ID_SEQ.NEXTVAL INTO v_prod_id FROM DUAL;
                    
                    INSERT INTO PROD(PROD_ID, PROD_NAME, PROD_FORM, PROD_STRENGTH, PROD_PACKAGE, MAH_ID, BLZ7, GTIN, PROD_STOCK, PROD_PRICE, CREATED_DT, UPDATED_DT, CUSR_ID, UUSR_ID)
                    VALUES (v_prod_id, rec.NAZW, rec.POST, rec.DAWK, rec.OPAK, v_mah_id, rec.BLZ7_ID, rec.KEAN, rec.STOCK, rec.PRICE, SYSDATE, SYSDATE, P_USR_ID, P_USR_ID);
        END;
        
    END LOOP;
END;
/

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
    SELECT CATP.NAME, COUNT(CAPT_PROD_ID)
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
        RETURN 'BŁĄD || SQLERRM';
END FUNCTION_4_F;
/




EXEC PROCEDURE_1_P(12345);
DELETE FROM PROD;
