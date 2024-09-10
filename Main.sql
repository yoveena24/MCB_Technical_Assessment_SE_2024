/* 
Question 1 
Run the script DB_Prequisite.sql
*/

/*
Question 2
Run the script MCB_TEST_Qu2.sql
*/

/*
Question 3
Run the DataCleansing_Script.sql before creating the procedures
Run the file MCB_TEST_Qu3.sql before running the below procedures
*/

EXECUTE order_management_pkg.populate_suppliers;

EXECUTE order_management_pkg.populate_orders;

EXECUTE order_management_pkg.populate_order_lines;

EXECUTE order_management_pkg.populate_invoices;

/*
Question 4
Run the file MCB_TEST_Qu4.sql before running the below procedure
Enable DBMS_OUTPUT
*/
EXECUTE GET_ORDER_INVOICE_SUMMARY;

/*
Question 5
Run the file MCB_TEST_Qu5.sql before running the below procedure
*/
SELECT *
FROM TABLE(GET_X_HIGHEST_ORDER(3));

/*
Question 6
Run the file MCB_TEST_Qu6.sql before running the below procedure
Enable DBMS_OUTPUT
*/
EXECUTE GET_SUPPLIER_ORDER_SUMMARY(DATE '2017-01-01', DATE '2017-08-31');


