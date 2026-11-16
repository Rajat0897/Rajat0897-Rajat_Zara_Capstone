SELECT t.Category, t.pos AS position, t.Product_ID, t.Description_EN, t.Color, t.Sub_Category,
       ROUND(t.Net_Sales_USD)                            AS net_sales_usd,
       ROUND(100 * t.Margin_USD / t.Net_Sales_USD, 1)    AS gross_margin_pct
FROM (
    SELECT p.Category, p.Product_ID, p.Description_EN, p.Color, p.Sub_Category,
           ps.Net_Sales_USD, ps.Margin_USD,
           ROW_NUMBER() OVER (PARTITION BY p.Category ORDER BY ps.Net_Sales_USD DESC) AS pos
    FROM work_product_sales ps
    JOIN work_products p ON p.Product_ID = ps.Product_ID
) t
WHERE t.pos <= 10
ORDER BY t.Category, t.pos;