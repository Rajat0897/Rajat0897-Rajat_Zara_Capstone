CREATE INDEX ix_ws_date     ON work_sales (Sale_Date);
CREATE INDEX ix_ws_product  ON work_sales (Product_ID);
CREATE INDEX ix_ws_store    ON work_sales (Store_ID);
CREATE INDEX ix_ws_country  ON work_sales (Country);
CREATE INDEX ix_ws_invoice  ON work_sales (Invoice_ID);
CREATE INDEX ix_ws_customer ON work_sales (Customer_ID);