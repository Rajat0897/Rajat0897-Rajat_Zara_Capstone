SELECT band,
       ROUND(100 * sale_lines / SUM(sale_lines) OVER (), 2) AS lines_share_pct,
       ROUND(net_sales_usd, 0)                              AS net_sales_usd,
       ROUND(100 * margin_usd / net_sales_usd, 1)           AS gross_margin_pct
FROM (
    SELECT CASE WHEN Discount = 0     THEN '1 Full price'
                WHEN Discount <= 0.35 THEN '2 30% off'
                WHEN Discount <= 0.55 THEN '3 40-50% off'
                ELSE                       '4 60-70% off' END AS band,
           SUM(CASE WHEN Transaction_Type = 'Sale' THEN 1 ELSE 0 END) AS sale_lines,
           SUM(Net_Sales_USD) AS net_sales_usd,
           SUM(Margin_USD)    AS margin_usd
    FROM work_fact
    GROUP BY 1
) b
ORDER BY band;

SELECT Discount,
       COUNT(*)                                             AS total_lines,
       ROUND(SUM(Net_Sales_USD), 0)                         AS net_sales_usd,
       ROUND(100 * SUM(Margin_USD) / SUM(Net_Sales_USD), 1) AS gross_margin_pct
FROM work_fact
GROUP BY Discount
ORDER BY Discount;