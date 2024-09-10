CREATE OR REPLACE PROCEDURE GET_SUPPLIER_ORDER_SUMMARY (
    p_start_date IN DATE,
    p_end_date   IN DATE
)
IS
BEGIN
  FOR rec IN (
---------------------------------------
    SELECT
    S.supplier_name AS supplier_name,
    S.supp_contact_name AS supplier_contact_name,
    CN.supplier_contact_no_1,
    CN.supplier_contact_no_2,
    COUNT(*) AS total_orders,
    TO_CHAR(SUM(ORDER_TOTAL_AMOUNT), '99,999,990.00') AS order_total_amount
    FROM 
    SUPPLIERS S
    LEFT JOIN PURCHASE_ORDERS P ON P.SUPPLIER_ID = S.SUPPLIER_ID
    LEFT JOIN (
    SELECT 
    SUPPLIER_ID,
    CASE
        WHEN INSTR(SUPP_CONTACT_NUMBER, ',')> 0  
        THEN CASE
            WHEN LENGTH(SUBSTR(SUPP_CONTACT_NUMBER, 1, INSTR(SUPP_CONTACT_NUMBER, ',') - 1)) = 7 
            THEN SUBSTR(SUBSTR(SUPP_CONTACT_NUMBER, 1, INSTR(SUPP_CONTACT_NUMBER, ',') - 1), 1, 3) || '-' || SUBSTR(SUBSTR(SUPP_CONTACT_NUMBER, 1, INSTR(SUPP_CONTACT_NUMBER, ',') - 1), 4)
            
            WHEN LENGTH(SUBSTR(SUPP_CONTACT_NUMBER, 1, INSTR(SUPP_CONTACT_NUMBER, ',') - 1)) = 8 
            THEN SUBSTR(SUBSTR(SUPP_CONTACT_NUMBER, 1, INSTR(SUPP_CONTACT_NUMBER, ',') - 1), 1, 4) || '-' || SUBSTR(SUBSTR(SUPP_CONTACT_NUMBER, 1, INSTR(SUPP_CONTACT_NUMBER, ',') - 1), 5)
            END
        WHEN INSTR(SUPP_CONTACT_NUMBER, ',')= 0 
        THEN CASE
             WHEN LENGTH(SUPP_CONTACT_NUMBER) = 7 
             THEN SUBSTR(SUPP_CONTACT_NUMBER, 1, 3) || '-' || SUBSTR(SUPP_CONTACT_NUMBER, 4)
             
             WHEN LENGTH(SUPP_CONTACT_NUMBER) = 8 
             THEN SUBSTR(SUPP_CONTACT_NUMBER, 1, 4) || '-' || SUBSTR(SUPP_CONTACT_NUMBER, 5)
             END
    END AS supplier_contact_no_1,  
    CASE 
        WHEN INSTR(SUPP_CONTACT_NUMBER, ',')> 0  
        THEN CASE 
            WHEN LENGTH(TRIM(SUBSTR(SUPP_CONTACT_NUMBER, INSTR(SUPP_CONTACT_NUMBER, ',') + 1))) = 7
            THEN SUBSTR(TRIM(SUBSTR(SUPP_CONTACT_NUMBER, INSTR(SUPP_CONTACT_NUMBER, ',') + 1)), 1, 3) || '-' || SUBSTR(TRIM(SUBSTR(SUPP_CONTACT_NUMBER, INSTR(SUPP_CONTACT_NUMBER, ',') + 1)), 4)
            
            WHEN LENGTH(TRIM(SUBSTR(SUPP_CONTACT_NUMBER, INSTR(SUPP_CONTACT_NUMBER, ',') + 1))) = 8
            THEN SUBSTR(TRIM(SUBSTR(SUPP_CONTACT_NUMBER, INSTR(SUPP_CONTACT_NUMBER, ',') + 1)), 1, 4) || '-' || SUBSTR(TRIM(SUBSTR(SUPP_CONTACT_NUMBER, INSTR(SUPP_CONTACT_NUMBER, ',') + 1)), 5)
            END
        
    END AS supplier_contact_no_2
    FROM SUPPLIERS
    ) CN ON CN.supplier_id = s.supplier_id
    
    WHERE P.ORDER_DATE BETWEEN  p_start_date AND p_end_date
    GROUP BY supplier_name, supp_contact_name, CN.supplier_contact_no_1, CN.supplier_contact_no_2
-----------------------------------------------------------
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Supplier Name: ' || rec.supplier_name);
    DBMS_OUTPUT.PUT_LINE('Supplier Contact Name: ' || rec.supplier_contact_name);
    DBMS_OUTPUT.PUT_LINE('Supplier Contact No 1: ' || rec.supplier_contact_no_1);
    DBMS_OUTPUT.PUT_LINE('Supplier Contact No 2: ' || rec.supplier_contact_no_2);
    DBMS_OUTPUT.PUT_LINE('Total Orders: ' || rec.total_orders);
    DBMS_OUTPUT.PUT_LINE('Order Total Amount: ' || rec.order_total_amount);
    DBMS_OUTPUT.PUT_LINE('-----------------------');
  END LOOP;
END;
/