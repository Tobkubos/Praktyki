--======================================================================================
-- AUTHOR: TK​
--
-- Running this entire script will test all REGULAR EXPRESSIONS.
-- You can use those functions to test yourself giving string as an argument:
-- CLEAN_SPACES_F(text)
-- CLEAN_DASHES_F(text)
-- FIRST_WORD_CUT_F(text)
--======================================================================================
SET SERVEROUTPUT ON;
--
CREATE OR REPLACE FUNCTION TEST_CLEAN_SPACES_F RETURN BOOLEAN IS
  --############################################################################################
  -- Function for testing regular expression from clearing excesive spaces
  --############################################################################################
  v_result VARCHAR2(50);
  v_expected_result VARCHAR2(50);
  v_test_passed BOOLEAN := TRUE;
  BEGIN
    -- Test 1
    v_result := CLEAN_SPACES_F('Hello    World');
    v_expected_result := 'Hello World';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 1 failed:' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 2
    v_result := CLEAN_SPACES_F('   Hello World   ');
    v_expected_result := 'Hello World';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 2 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 3
    v_result := CLEAN_SPACES_F('Hello World');
    v_expected_result := 'Hello World';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 3 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 4
    v_result := CLEAN_SPACES_F('   ');
    v_expected_result := '';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 4 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 5
    v_result := CLEAN_SPACES_F('HelloWorld');
    v_expected_result := 'HelloWorld';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 5 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 6
    v_result := CLEAN_SPACES_F('Hello   World   How   Are   You');
    v_expected_result := 'Hello World How Are You';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 6 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 7
    v_result := CLEAN_SPACES_F('Hello   World!   123   ');
    v_expected_result := 'Hello World! 123';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 7 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- END RESULT
    IF v_test_passed THEN
      DBMS_OUTPUT.PUT_LINE('All tests passed for CLEAN_SPACES!');
      RETURN TRUE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Some tests failed for CLEAN_SPACES.');
      RETURN FALSE;
    END IF;
  END TEST_CLEAN_SPACES_F;
/
CREATE OR REPLACE FUNCTION TEST_CLEAN_DASHES_F RETURN BOOLEAN IS
  --############################################################################################
  -- Function for testing regular expression from clearing excesive dashes
  --############################################################################################
  v_result VARCHAR2(50);
  v_expected_result VARCHAR2(50);
  v_test_passed BOOLEAN := TRUE;
  BEGIN
    -- Test 1
    v_result := CLEAN_DASHES_F('---Hello---World--');
    v_expected_result := '-Hello-World-';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 1 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 2
    v_result := CLEAN_DASHES_F('---Hello World---');
    v_expected_result := '-Hello World-';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 2 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 3
    v_result := CLEAN_DASHES_F('Hello World');
    v_expected_result := 'Hello World';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 3 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 4
    v_result := CLEAN_DASHES_F('------');
    v_expected_result := '';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 4 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 5
    v_result := CLEAN_DASHES_F('-Hello World');
    v_expected_result := '-Hello World';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 5 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 6
    v_result := CLEAN_DASHES_F('Hello World-');
    v_expected_result := 'Hello World-';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 6 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 7
    v_result := CLEAN_DASHES_F('Hello---World');
    v_expected_result := 'Hello-World';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 7 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 8
    v_result := CLEAN_DASHES_F('');
    v_expected_result := '';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 8 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 9
    v_result := CLEAN_DASHES_F('-');
    v_expected_result := '';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 9 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- END RESULT
    IF v_test_passed THEN
      DBMS_OUTPUT.PUT_LINE('All tests passed for CLEAN_DASHES!');
      RETURN TRUE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Some tests failed for CLEAN_DASHES.');
      RETURN FALSE;
    END IF;
  END TEST_CLEAN_DASHES_F;
/
CREATE OR REPLACE FUNCTION TEST_FIRST_WORD_CUT_F RETURN BOOLEAN IS
  --############################################################################################
  -- Function for testing regular expression from clearing excesive dashes
  --############################################################################################
  v_result VARCHAR2(50);
  v_expected_result VARCHAR2(50);
  v_test_passed BOOLEAN := TRUE;
  BEGIN
    -- Test 1
    v_result := FIRST_WORD_CUT_F('  Hello World ');
    v_expected_result := 'Hello';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 1 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 2
    v_result := FIRST_WORD_CUT_F('.Hello World');
    v_expected_result := '.Hello';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 2 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;  
    -- Test 3
    v_result := FIRST_WORD_CUT_F('.');
    v_expected_result := '';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 3 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 4
    v_result := FIRST_WORD_CUT_F('Hello');
    v_expected_result := 'Hello';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 4 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- Test 5
    v_result := FIRST_WORD_CUT_F('     .Hello');
    v_expected_result := '.Hello';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 5 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
     -- Test 6
    v_result := FIRST_WORD_CUT_F('World. Hello');
    v_expected_result := 'World.';
    IF v_result != v_expected_result THEN
      DBMS_OUTPUT.PUT_LINE('Test 6 failed: ' || v_result);
      v_test_passed := FALSE;
    END IF;
    -- END RESULT
    IF v_test_passed THEN
      DBMS_OUTPUT.PUT_LINE('All tests passed for FIRST_WORD_CUT!');
      RETURN TRUE;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Some tests failed for FIRST_WORD_CUT.');
      RETURN FALSE;
    END IF;
  END TEST_FIRST_WORD_CUT_F;
/
--======================================================================================
-- TESTING ALL REGULAR EXPRESSIONS
--======================================================================================
BEGIN
  IF TEST_CLEAN_DASHES_F THEN
    DBMS_OUTPUT.PUT_LINE('CLEAN_DASHES_F TEST SUCCESS');
  ELSE
    DBMS_OUTPUT.PUT_LINE('CLEAN_DASHES_F TEST FAILED');
  END IF;
  IF TEST_CLEAN_SPACES_F THEN
    DBMS_OUTPUT.PUT_LINE('CLEAN_SPACES_F TEST SUCCESS');
  ELSE
    DBMS_OUTPUT.PUT_LINE('CLEAN_SPACES_F TEST FAILED');
  END IF;
  IF TEST_FIRST_WORD_CUT_F THEN
    DBMS_OUTPUT.PUT_LINE('FIRST_WORD_CUT_F TEST SUCCESS');
  ELSE
    DBMS_OUTPUT.PUT_LINE('FIRST_WORD_CUT_F TEST FAILED');
  END IF;
END;
/
--SELECT CLEAN_DASHES_F('ALA MA----KOTA') AS CLEARED FROM DUAL;
--SELECT CLEAN_SPACES_F('ALA       MA-   -       -KOTA') AS CLEARED FROM DUAL; 
--SELECT FIRST_WORD_CUT_F('ALA MA KOTA') AS FIRST FROM DUAL;
SET SERVEROUTPUT OFF;