-- Define a table type for order records
CREATE OR REPLACE TYPE order_record_table AS TABLE OF order_record;
/

CREATE OR REPLACE FUNCTION GET_X_HIGHEST_ORDER(p_rank_num IN NUMBER) RETURN order_record_table IS
  v_order_table order_record_table := order_record_table(); 
BEGIN
  SELECT order_record(
    order_reference,
    order_date,
    supplier_name,
    order_total_amount,
    order_status,
    invoice_references
  )
  BULK COLLECT INTO v_order_table
  FROM (
    SELECT 
      TO_NUMBER(SUBSTR(ORDER_REF, 3)) AS order_reference,
      TO_CHAR(order_date, 'Month DD, YYYY') AS order_date,
      UPPER(SUPPLIER_NAME) AS supplier_name,
      TO_CHAR(ORDER_TOTAL_AMOUNT, '99,999,990.00') AS order_total_amount,
      ORDER_STATUS as order_status,
      DISTINCT_INVOICES.invoice_references,
      DENSE_RANK() OVER (ORDER BY ORDER_TOTAL_AMOUNT DESC) as rank_num
    FROM PURCHASE_ORDERS P
    LEFT JOIN SUPPLIERS S ON S.SUPPLIER_ID = P.SUPPLIER_ID
    LEFT JOIN (
      SELECT ORDER_ID, LISTAGG(DISTINCT invoice_reference, ',') WITHIN GROUP (ORDER BY invoice_reference) AS invoice_references
      FROM INVOICES
      GROUP BY ORDER_ID
    ) DISTINCT_INVOICES ON DISTINCT_INVOICES.ORDER_ID = P.ORDER_ID
    ORDER BY ORDER_TOTAL_AMOUNT DESC 
  )
  WHERE rank_num = p_rank_num;

  RETURN v_order_table;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN v_order_table; -- Return an empty nested table
END;
/