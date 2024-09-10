CREATE OR REPLACE PACKAGE order_management_pkg AS
 
  PROCEDURE populate_suppliers;
  PROCEDURE populate_orders;
  PROCEDURE populate_order_lines;
  PROCEDURE populate_invoices;

END order_management_pkg;
/

CREATE OR REPLACE PACKAGE BODY order_management_pkg AS
-------------------------
  PROCEDURE populate_suppliers 
  IS
      CURSOR supplier_data IS
          SELECT DISTINCT SUPPLIER_NAME, SUPP_CONTACT_NAME, SUPP_ADDRESS, SUPP_CONTACT_NUMBER, SUPP_EMAIL
          FROM XXBCM_ORDER_MGT_STG;
      
      v_supplier_exists NUMBER := 0; 
  BEGIN
      FOR rec IN supplier_data LOOP
          -- Check if the supplier already exists
          SELECT COUNT(*) INTO v_supplier_exists
          FROM SUPPLIERS
          WHERE SUPPLIER_NAME = rec.SUPPLIER_NAME;

          -- Insert the supplier only if it doesn't exist
          IF v_supplier_exists = 0 THEN
              INSERT INTO SUPPLIERS (SUPPLIER_NAME, SUPP_CONTACT_NAME, SUPP_ADDRESS, SUPP_CONTACT_NUMBER, SUPP_EMAIL)
              VALUES (rec.SUPPLIER_NAME, rec.SUPP_CONTACT_NAME, rec.SUPP_ADDRESS, rec.SUPP_CONTACT_NUMBER, rec.SUPP_EMAIL);
          END IF;
      END LOOP;
      
      COMMIT; -- Commit the changes
      
      DBMS_OUTPUT.PUT_LINE('SUPPLIERS table populated successfully.');
  EXCEPTION
      WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error populating SUPPLIERS table: ' || SQLERRM);
          ROLLBACK; -- Rollback changes in case of error
  END populate_suppliers;
 
----------------------------------- 
    PROCEDURE populate_orders
    IS
      CURSOR order_data IS
        SELECT DISTINCT ORDER_REF, ORDER_DATE, SUPPLIER_NAME, ORDER_TOTAL_AMOUNT, ORDER_DESCRIPTION, ORDER_STATUS
        FROM xxbcm_order_mgt_stg
        WHERE INSTR(ORDER_REF, '-') = 0; -- Filter out rows with hyphens in ORDER_REF
    
      v_supplier_id NUMBER;
    BEGIN
      FOR rec IN order_data LOOP
        -- Get the supplier ID based on supplier name
        SELECT SUPPLIER_ID INTO v_supplier_id
        FROM SUPPLIERS
        WHERE SUPPLIER_NAME = rec.SUPPLIER_NAME;
    
        -- Insert order data
        INSERT INTO PURCHASE_ORDERS (ORDER_REF, ORDER_DATE, SUPPLIER_ID, ORDER_TOTAL_AMOUNT, ORDER_DESCRIPTION, ORDER_STATUS)
        VALUES (rec.ORDER_REF, rec.ORDER_DATE, v_supplier_id, rec.ORDER_TOTAL_AMOUNT, rec.ORDER_DESCRIPTION, rec.ORDER_STATUS);
      END LOOP;
    
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('ORDERS table populated successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error populating ORDERS table: ' || SQLERRM);
        ROLLBACK;
    END populate_orders; 
    
--------------------------

    PROCEDURE populate_order_lines
    IS
      CURSOR order_line_data IS
        SELECT ORDER_REF, ORDER_LINE_AMOUNT, ORDER_DESCRIPTION, ORDER_STATUS
        FROM XXBCM_ORDER_MGT_STG
        WHERE INSTR(ORDER_REF, '-') > 0; -- Filter rows with hyphens in ORDER_REF
    
      v_order_id NUMBER;
      v_order_ref_base VARCHAR2(50);
    BEGIN
      FOR rec IN order_line_data LOOP
        -- Extract the base order reference (before the hyphen)
        v_order_ref_base := SUBSTR(rec.ORDER_REF, 1, INSTR(rec.ORDER_REF, '-') - 1);
    
        -- Get the ORDER_ID from PURCHASE_ORDERS based on the base order reference
        SELECT ORDER_ID INTO v_order_id
        FROM PURCHASE_ORDERS
        WHERE ORDER_REF = v_order_ref_base;
    
        -- Insert order line data
        INSERT INTO PURCHASE_ORDER_LINES (ORDER_ID, ORDER_LINE_REF, ORDER_LINE_AMOUNT, ORDER_LINE_DESCRIPTION, ORDER_LINE_STATUS)
        VALUES (v_order_id, rec.ORDER_REF, rec.ORDER_LINE_AMOUNT, rec.ORDER_DESCRIPTION, rec.ORDER_STATUS);
      END LOOP;
    
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('PURCHASE_ORDER_LINES table populated successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error populating PURCHASE_ORDER_LINES table: ' || SQLERRM);
        ROLLBACK;
    END populate_order_lines;
    
--------------------------------
    PROCEDURE populate_invoices
    IS
      CURSOR invoice_data IS
        SELECT DISTINCT INVOICE_REFERENCE, INVOICE_DATE, ORDER_REF, INVOICE_STATUS, INVOICE_HOLD_REASON, INVOICE_AMOUNT, INVOICE_DESCRIPTION
        FROM XXBCM_ORDER_MGT_STG
        WHERE INVOICE_REFERENCE IS NOT NULL; -- Filter rows with non-null invoice references
    
      v_order_id NUMBER;
      v_order_ref_base VARCHAR2(50);
    BEGIN
      FOR rec IN invoice_data LOOP
        -- Extract the base order reference (before the hyphen) from ORDER_REF
        v_order_ref_base := SUBSTR(rec.ORDER_REF, 1, INSTR(rec.ORDER_REF, '-') - 1);
    
        -- Get the ORDER_ID from XXBCM_ORDERS based on the base order reference
        SELECT ORDER_ID INTO v_order_id
        FROM PURCHASE_ORDERS
        WHERE ORDER_REF = v_order_ref_base;
    
        -- Insert invoice data
        INSERT INTO INVOICES (INVOICE_REFERENCE, INVOICE_DATE, ORDER_ID, INVOICE_STATUS, INVOICE_HOLD_REASON, INVOICE_AMOUNT, INVOICE_DESCRIPTION)
        VALUES (rec.INVOICE_REFERENCE, rec.INVOICE_DATE, v_order_id, rec.INVOICE_STATUS, rec.INVOICE_HOLD_REASON, rec.INVOICE_AMOUNT, rec.INVOICE_DESCRIPTION);
      END LOOP;
    
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('INVOICES table populated successfully.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error populating INVOICES table: ' || SQLERRM);
        ROLLBACK;
    END populate_invoices;

END order_management_pkg;
/