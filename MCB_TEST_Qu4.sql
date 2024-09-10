CREATE OR REPLACE PROCEDURE GET_ORDER_INVOICE_SUMMARY
IS
BEGIN
  FOR rec IN (
    ------------------------------------------ 
    SELECT 
    TO_NUMBER(SUBSTR(ORDER_REF, 3)) AS order_reference,
    TO_CHAR(order_date, 'MON-YYYY') AS order_period, 
    INITCAP(S.SUPPLIER_NAME) AS supplier_name,
    TO_CHAR(ORDER_TOTAL_AMOUNT, '99,999,990.00') AS order_total_amount,
    ORDER_STATUS AS order_status,
    DISTINCT_INVOICES.invoice_references,
    TO_CHAR(SUM(INVOICE_AMOUNT), '99,999,990.00') AS invoice_total_amount,
    CASE 
        WHEN COUNT(CASE WHEN INVOICE_STATUS = 'Paid' THEN 1 END) = COUNT(*) THEN 'OK'
        WHEN COUNT(CASE WHEN INVOICE_STATUS = 'Pending' THEN 1 END) > 0 THEN 'To follow up'
        ELSE 'To verify'
    END AS action
    FROM PURCHASE_ORDERS P
    LEFT JOIN SUPPLIERS S ON S.SUPPLIER_ID = P.SUPPLIER_ID
    LEFT JOIN INVOICES I ON I.ORDER_ID = P.ORDER_ID
    LEFT JOIN (
        SELECT ORDER_ID, LISTAGG(DISTINCT invoice_reference, '|') WITHIN GROUP (ORDER BY invoice_reference) AS invoice_references
        FROM INVOICES
        GROUP BY ORDER_ID
    ) DISTINCT_INVOICES ON DISTINCT_INVOICES.ORDER_ID = P.ORDER_ID 
    GROUP BY P.ORDER_REF, P.ORDER_DATE, S.SUPPLIER_NAME, P.ORDER_TOTAL_AMOUNT, P.ORDER_STATUS, DISTINCT_INVOICES.invoice_references
    ORDER BY ORDER_DATE DESC
-----------------------------------
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Order Reference: ' || rec.order_reference);
    DBMS_OUTPUT.PUT_LINE('Order Period: ' || rec.order_period);
    DBMS_OUTPUT.PUT_LINE('Supplier Name: ' || rec.supplier_name);
    DBMS_OUTPUT.PUT_LINE('Order Total Amount: ' || rec.order_total_amount);
    DBMS_OUTPUT.PUT_LINE('Order Status: ' || rec.order_status);
    DBMS_OUTPUT.PUT_LINE('Invoice References: ' || rec.invoice_references);
    DBMS_OUTPUT.PUT_LINE('Invoice Total Amount: ' || rec.invoice_total_amount);
    DBMS_OUTPUT.PUT_LINE('Action: ' || rec.action);
    DBMS_OUTPUT.PUT_LINE('-----------------------'); -- Separator between records
  END LOOP;
END;
/