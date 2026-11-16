CREATE TABLE work_sales AS
SELECT
    t.Invoice_ID,
    t.Line,
    t.Customer_ID,
    t.Product_ID,
    t.Size,
    t.Color,
    t.Date,
    DATE(t.Date)                                   AS Sale_Date,
    t.Discount,
    CASE WHEN t.Discount > 0 THEN 1 ELSE 0 END     AS Is_Markdown,
    t.Transaction_Type,
    t.Store_ID,
    t.Employee_ID,
    t.Payment_Method,
    t.Quantity                                     AS Qty_Raw,
    CASE WHEN t.Transaction_Type = 'Return'
         THEN -t.Quantity ELSE t.Quantity END      AS Qty_Signed,
    t.Line_Total                                   AS Line_Total_Local,
    t.Line_Total * r.Rate_to_USD                   AS Net_Sales_USD,
    t.Currency,
    p.Category,
    p.Sub_Category,
    s.Country_English                              AS Country
FROM transactions t
JOIN work_exchange_rates r ON t.Currency   = r.Currency
JOIN work_products p       ON t.Product_ID = p.Product_ID
JOIN work_stores s         ON t.Store_ID   = s.Store_ID;
