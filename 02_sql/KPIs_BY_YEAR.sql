SELECT YEAR(Sale_Date)                                                  AS yr,
       ROUND(SUM(CASE WHEN Transaction_Type = 'Sale'   THEN Net_Sales_USD END), 0) AS gross_sales_usd,
       ROUND(SUM(CASE WHEN Transaction_Type = 'Return' THEN Net_Sales_USD END), 0) AS returns_usd,
       ROUND(SUM(Net_Sales_USD), 0)                                     AS net_sales_usd,
       ROUND(SUM(Margin_USD), 0)                                        AS gross_margin_usd,
       ROUND(100 * SUM(Margin_USD) / SUM(Net_Sales_USD), 1)             AS gross_margin_pct
FROM work_v_sales
GROUP BY YEAR(Sale_Date)
ORDER BY yr;
 
SELECT YEAR(Sale_Date)                                      AS yr,
       ROUND(SUM(Net_Sales_USD), 0)                         AS net_sales_usd_1jan_18mar,
       ROUND(100 * SUM(Margin_USD) / SUM(Net_Sales_USD), 1) AS gross_margin_pct
FROM work_v_sales
WHERE DATE_FORMAT(Sale_Date, '%m-%d') <= '03-18'
GROUP BY YEAR(Sale_Date)
ORDER BY yr;