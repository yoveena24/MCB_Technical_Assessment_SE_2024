
CREATE TABLE xxbcm_order_mgt_stg AS SELECT * FROM xxbcm_order_mgt;
    
-- Cleansing the staging table
-- order_total_amount
UPDATE xxbcm_order_mgt_stg t SET order_total_amount = REPLACE(t.order_total_amount, ',','');

-- order_line_amount
UPDATE xxbcm_order_mgt_stg t SET order_line_amount = REPLACE(t.order_line_amount, ',','');
UPDATE xxbcm_order_mgt_stg t SET order_line_amount = REPLACE(t.order_line_amount, 'I','1');
UPDATE xxbcm_order_mgt_stg t SET order_line_amount = REPLACE(t.order_line_amount, 'o','0');
UPDATE xxbcm_order_mgt_stg t SET order_line_amount = REPLACE(t.order_line_amount, 'S','5');

-- invoice_amount
UPDATE xxbcm_order_mgt_stg t SET INVOICE_AMOUNT = REPLACE(t.INVOICE_AMOUNT, ',','');
UPDATE xxbcm_order_mgt_stg t SET INVOICE_AMOUNT = REPLACE(t.INVOICE_AMOUNT, 'I','1');
UPDATE xxbcm_order_mgt_stg t SET INVOICE_AMOUNT = REPLACE(t.INVOICE_AMOUNT, 'o','0');
UPDATE xxbcm_order_mgt_stg t SET INVOICE_AMOUNT = REPLACE(t.INVOICE_AMOUNT, 'S','5');

--SUPP_CONTACT_NUMBER
UPDATE xxbcm_order_mgt_stg t SET SUPP_CONTACT_NUMBER = REPLACE(t.SUPP_CONTACT_NUMBER, '.','');
UPDATE xxbcm_order_mgt_stg t SET SUPP_CONTACT_NUMBER = REPLACE(t.SUPP_CONTACT_NUMBER, 'o','0');
UPDATE xxbcm_order_mgt_stg t SET SUPP_CONTACT_NUMBER = REPLACE(t.SUPP_CONTACT_NUMBER, ' ','');

COMMIT;
