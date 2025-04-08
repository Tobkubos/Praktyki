--#########################################
-- AUTHOR: TK
--
-- ​Executing the entire script will initialize all necessary tables along with their comments.
--#########################################
/*
DROP TABLE CATP_PROD;
DROP TABLE PROD;
DROP TABLE CATP;
DROP TABLE MAH; 
DROP TABLE USERS;
*/
CREATE TABLE USERS(
  USR_ID NUMBER(10),
  NAME VARCHAR2(50) NOT NULL,
  SURNAME VARCHAR2(50) NOT NULL,
  EMAIL VARCHAR2(50) NOT NULL,
  CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
  UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
  CUSR_ID NUMBER(10) NOT NULL,
  UUSR_ID NUMBER(10) NOT NULL,
--
  CONSTRAINT USERS_USR_ID_PK PRIMARY KEY(USR_ID),
  CONSTRAINT USERS_USERS_CUSR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
  CONSTRAINT USERS_USERS_UUSR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
);
/
COMMENT ON TABLE USERS IS             'O: "TK", C: [PL: Tabela użytkowników, EN: Users table]';
/
COMMENT ON COLUMN USERS.USR_ID IS     'O: "TK", C: [PL: Klucz główny, EN: Primary key]';
/
COMMENT ON COLUMN USERS.NAME IS       'O: "TK", C: [PL: Imię, EN: Name]';
/
COMMENT ON COLUMN USERS.SURNAME IS    'O: "TK", C: [PL: Nazwisko, EN: Surname]';
/
COMMENT ON COLUMN USERS.EMAIL IS      'O: "TK", C: [PL: Adres e-mail, EN: E-mail address]';
/
COMMENT ON COLUMN USERS.CREATED_DT IS 'O: "TK", C: [PL: Data stworzenia, EN: Date of creation]';
/
COMMENT ON COLUMN USERS.UPDATED_DT IS 'O: "TK", C: [PL: Data aktualizacji, EN: Update date]';
/
COMMENT ON COLUMN USERS.CUSR_ID IS    'O: "TK", C: [PL: ID użytkownika który stworzył rekord, EN: User ID who created record]';
/
COMMENT ON COLUMN USERS.UUSR_ID IS    'O: "TK", C: [PL: ID użytkownika który zaktualizował rekord, EN: User ID who updated record]';
/
CREATE TABLE MAH(
  MAH_ID NUMBER(10) NOT NULL,
  NAME VARCHAR2(100) NOT NULL,
  COUNTRY VARCHAR2(100) NOT NULL,
  CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
  UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
  CUSR_ID NUMBER(10) NOT NULL,
  UUSR_ID NUMBER(10) NOT NULL,
--
  CONSTRAINT MAH_MAH_ID_PK PRIMARY KEY (MAH_ID),
  CONSTRAINT MAH_USERS_CUSR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
  CONSTRAINT MAH_USERS_UUSR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
);
/
COMMENT ON TABLE MAH IS              'O: "TK", C: [PL: Tabela podmiotów odpowiedzialnych, EN: Marketing authorization holders table]';
/
COMMENT ON COLUMN MAH.MAH_ID is      'O: "TK", C: [PL: Klucz główny, EN: Primary key]';
/
COMMENT ON COLUMN MAH.Name is        'O: "TK", C: [PL: Nazwa podmiotu, EN: Marketing authorization holder name]';
/
COMMENT ON COLUMN MAH.Country is     'O: "TK", C: [PL: Kraj pochodzenia, EN: Country]';
/
COMMENT ON COLUMN MAH.CREATED_DT IS  'O: "TK", C: [PL: Data stworzenia, EN: Date of creation]';
/
COMMENT ON COLUMN MAH.UPDATED_DT IS  'O: "TK", C: [PL: Data aktualizacji, EN: Update date]';
/
COMMENT ON COLUMN MAH.CUSR_ID IS     'O: "TK", C: [PL: ID użytkownika który stworzył rekord, EN: User ID who created record]';
/
COMMENT ON COLUMN MAH.UUSR_ID IS     'O: "TK", C: [PL: ID użytkownika który zaktualizował rekord, EN: User ID who updated record]';
/
CREATE TABLE PROD(
  PROD_ID NUMBER(10),
  STATUS CHAR(1) DEFAULT 'I' NOT NULL,
  PROD_NAME VARCHAR(120) NOT NULL,
  PROD_FORM VARCHAR(40),
  PROD_STRENGTH VARCHAR2(20),
  PROD_PACKAGE VARCHAR2(40),
  MAH_ID NUMBER(10) NOT NULL,
  BLZ7 NUMBER(10),
  GTIN NUMBER(14),
  PROD_STOCK NUMBER(15,3) DEFAULT 0 NOT NULL,
  PROD_PRICE NUMBER(15,3) DEFAULT 0 NOT NULL,
  CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
  UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
  CUSR_ID NUMBER(10) NOT NULL,
  UUSR_ID NUMBER(10) NOT NULL,
--
  CONSTRAINT PROD_PROD_ID_PK PRIMARY KEY (PROD_ID),
  CONSTRAINT PROD_MAH_MAH_ID_FK FOREIGN KEY (MAH_ID) REFERENCES MAH(MAH_ID),
  CONSTRAINT PROD_USERS_CUSR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
  CONSTRAINT PROD_USERS_UUSR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID),
  CONSTRAINT PROD_STATUS_AV_CHK CHECK (STATUS IN ('A', 'I')),
  CONSTRAINT PROD_PROD_STOCK_BETWEEN_CHK CHECK(PROD_STOCK BETWEEN 0 AND 999999999),
  CONSTRAINT PROD_PROD_PRICE_BETWEEN_CHK CHECK(PROD_PRICE BETWEEN 0 AND 999999999)
);
/
COMMENT ON TABLE PROD IS                 'O: "TK", C: [PL: Tabela produktów, EN: Products table]';
/
COMMENT ON COLUMN PROD.PROD_ID IS        'O: "TK", C: [PL: Klucz główny, EN: Primary key]';
/
COMMENT ON COLUMN PROD.STATUS IS         'O: "TK", C: [PL: Status: A-aktywny I-nieaktywny, EN: Status: A-Active I-Inactive]';
/
COMMENT ON COLUMN PROD.PROD_NAME IS      'O: "TK", C: [PL: Nazwa produktu, EN: Product name]';
/
COMMENT ON COLUMN PROD.PROD_FORM IS      'O: "TK", C: [PL: Forma produktu, EN: Product form]';
/
COMMENT ON COLUMN PROD.PROD_STRENGTH IS  'O: "TK", C: [PL: Dawka produktu, EN: Product strength]';
/
COMMENT ON COLUMN PROD.PROD_PACKAGE IS   'O: "TK", C: [PL: Opakowanie, EN: Packaging]';
/
COMMENT ON COLUMN PROD.MAH_ID IS         'O: "TK", C: [PL: ID podmiotu odpowiedzialnego, EN: Marketing authorization holder ID]';
/
COMMENT ON COLUMN PROD.BLZ7 IS           'O: "TK", C: [PL: Kod BLZ7, EN: BLZ7 code]';
/
COMMENT ON COLUMN PROD.GTIN IS           'O: "TK", C: [PL: Globalny numer jednostki handlowej, EN: Global trade item number]';
/
COMMENT ON COLUMN PROD.PROD_STOCK IS     'O: "TK", C: [PL: Stan magazynowy, EN: Stock status]';
/
COMMENT ON COLUMN PROD.PROD_PRICE IS     'O: "TK", C: [PL: Cena produktu, EN: Product price]';
/
COMMENT ON COLUMN PROD.CREATED_DT IS     'O: "TK", C: [PL: Data stworzenia, EN: Date of creation]';
/
COMMENT ON COLUMN PROD.UPDATED_DT IS     'O: "TK", C: [PL: Data aktualizacji, EN: Update date]';
/
COMMENT ON COLUMN PROD.CUSR_ID IS        'O: "TK", C: [PL: ID użytkownika który stworzył rekord, EN: User ID who created record]';
/
COMMENT ON COLUMN PROD.UUSR_ID IS        'O: "TK", C: [PL: ID użytkownika który zaktualizował rekord, EN: User ID who updated record]';
/
CREATE TABLE CATP(
  CATP_ID NUMBER(10) NOT NULL,
  ACTIVE CHAR(1) DEFAULT 'N' NOT NULL,
  NAME VARCHAR2(50) NOT NULL,
  CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
  UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
  CUSR_ID NUMBER(10) NOT NULL,
  UUSR_ID NUMBER(10) NOT NULL,
--
  CONSTRAINT CATP_CATP_ID_PK PRIMARY KEY (CATP_ID),
  CONSTRAINT CATP_NAME_UK UNIQUE (NAME),
  CONSTRAINT CATP_USERS_CUSR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
  CONSTRAINT CATP_USERS_UUSR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID),  
  CONSTRAINT CATP_ACTIVE_AV_CHK CHECK (ACTIVE IN ('Y', 'N'))
);
/
COMMENT ON TABLE CATP IS             'O: "TK", C: [PL: Tabela kategorii produktów, EN: Product categories table]';
/
COMMENT ON COLUMN CATP.CATP_ID IS    'O: "TK", C: [PL: Klucz główny, EN: Primary key]';
/
COMMENT ON COLUMN CATP.ACTIVE IS     'O: "TK", C: [PL: Aktywna: Y-tak N-nie, EN: Active: Y-yes N-no]';
/
COMMENT ON COLUMN CATP.NAME IS       'O: "TK", C: [PL: Nazwa kategorii, EN: Category name]';
/
COMMENT ON COLUMN CATP.CREATED_DT IS 'O: "TK", C: [PL: Data stworzenia, EN: Date of creation]';
/
COMMENT ON COLUMN CATP.UPDATED_DT IS 'O: "TK", C: [PL: Data aktualizacji, EN: Update date]';
/
COMMENT ON COLUMN CATP.CUSR_ID IS    'O: "TK", C: [PL: ID użytkownika który stworzył rekord, EN: User ID who created record]';
/
  COMMENT ON COLUMN CATP.UUSR_ID IS  'O: "TK", C: [PL: ID użytkownika który zaktualizował rekord, EN: User ID who updated record]';
/
CREATE TABLE CATP_PROD(
  CATP_PROD_ID NUMBER(10) NOT NULL,
  CATP_ID NUMBER(10) NOT NULL,
  PROD_ID NUMBER(10) NOT NULL,
  CREATED_DT DATE DEFAULT SYSDATE NOT NULL,
  UPDATED_DT DATE DEFAULT SYSDATE NOT NULL,
  CUSR_ID NUMBER(10) NOT NULL,
  UUSR_ID NUMBER(10) NOT NULL,
--
  CONSTRAINT CATP_PROD_CATP_PROD_ID_PK PRIMARY KEY (CATP_PROD_ID),
  CONSTRAINT CATP_PROD_CATP_ID_PROD_ID_UK UNIQUE (CATP_ID, PROD_ID),
  CONSTRAINT CATP_PROD_CAPT_CATP_ID_FK FOREIGN KEY (CATP_ID) REFERENCES CATP(CATP_ID),
  CONSTRAINT CATP_PROD_PROD_PROD_ID_FK FOREIGN KEY (PROD_ID) REFERENCES PROD(PROD_ID),
  CONSTRAINT CATP_PROD_USERS_CUSR_ID_FK FOREIGN KEY (CUSR_ID) REFERENCES USERS(USR_ID),
  CONSTRAINT CATP_PROD_USERS_UUSR_ID_FK FOREIGN KEY (UUSR_ID) REFERENCES USERS(USR_ID)
);
/
COMMENT ON TABLE CATP_PROD IS               'O: "TK", C: [PL: Tabela asocjacji dla CATP i PROD, EN: Association table for CATP and PROD]';
/
COMMENT ON COLUMN CATP_PROD.CATP_PROD_ID IS 'O: "TK", C: [PL: Klucz główny, EN: Primary key]';
/
COMMENT ON COLUMN CATP_PROD.CATP_ID IS      'O: "TK", C: [PL: Klucz kategorii, EN: Category key]';
/
COMMENT ON COLUMN CATP_PROD.PROD_ID IS      'O: "TK", C: [PL: Klucz produktu, EN: Product key]';
/
COMMENT ON COLUMN CATP_PROD.CREATED_DT IS   'O: "TK", C: [PL: Data stworzenia, EN: Date of creation]';
/
COMMENT ON COLUMN CATP_PROD.UPDATED_DT IS   'O: "TK", C: [PL: Data aktualizacji, EN: Update date]';
/
COMMENT ON COLUMN CATP_PROD.CUSR_ID IS      'O: "TK", C: [PL: ID użytkownika który stworzył rekord, EN: User ID who created record]';
/
COMMENT ON COLUMN CATP_PROD.UUSR_ID IS      'O: "TK", C: [PL: ID użytkownika który zaktualizował rekord, EN: User ID who updated record]';
/