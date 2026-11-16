DROP TABLE IF EXISTS work_md_depth;
CREATE TABLE work_md_depth (
    Category       VARCHAR(10),
    Sub_Category   VARCHAR(40),
    Discount       DECIMAL(5,2),
    Units_Sold     INT,
    Net_Sales_USD  DOUBLE,
    Margin_USD     DOUBLE,
    PRIMARY KEY (Category, Sub_Category, Discount)
);
 
INSERT INTO work_md_depth
SELECT p.Category, p.Sub_Category, x.Discount,
       SUM(x.units), SUM(x.sales), SUM(x.margin)
FROM (
    SELECT Product_ID, Discount,
           SUM(CASE WHEN Transaction_Type = 'Sale' THEN Qty_Raw ELSE 0 END) AS units,
           SUM(Net_Sales_USD) AS sales,
           SUM(Margin_USD)    AS margin
    FROM work_fact
    GROUP BY Product_ID, Discount
) x
JOIN work_products p ON p.Product_ID = x.Product_ID
GROUP BY p.Category, p.Sub_Category, x.Discount;
 

SELECT Category, Discount,
       SUM(Units_Sold)                                       AS units_sold,
       ROUND(SUM(Net_Sales_USD))                             AS net_sales_usd,
       ROUND(100 * SUM(Margin_USD) / SUM(Net_Sales_USD), 1)  AS gross_margin_pct
FROM work_md_depth
GROUP BY Category, Discount
ORDER BY Category, Discount;
 

SELECT d70.Category, d70.Sub_Category,
       ROUND(d70.Net_Sales_USD)                                   AS net_sales_at_70,
       ROUND(100 * d70.Net_Sales_USD / t.total_sales, 1)          AS pct_of_subcat_sales_at_70,
       ROUND(100 * d70.Margin_USD / d70.Net_Sales_USD, 1)         AS margin_pct_at_70,
       ROUND(100 * f0.Margin_USD  / f0.Net_Sales_USD, 1)          AS margin_pct_full_price,
       ROUND(d70.Margin_USD)                                      AS margin_usd_at_70
FROM work_md_depth d70
JOIN work_md_depth f0 ON f0.Category = d70.Category AND f0.Sub_Category = d70.Sub_Category
                     AND f0.Discount = 0
JOIN (SELECT Category, Sub_Category, SUM(Net_Sales_USD) AS total_sales
      FROM work_md_depth GROUP BY Category, Sub_Category) t
  ON t.Category = d70.Category AND t.Sub_Category = d70.Sub_Category
WHERE d70.Discount = 0.70
ORDER BY margin_usd_at_70;