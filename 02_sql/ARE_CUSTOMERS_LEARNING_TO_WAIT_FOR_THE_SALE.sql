SELECT YEAR(Sale_Date)                                              AS yr,
       ROUND(100 * SUM(Units_Sold_MD) / SUM(Units_Sold), 1)         AS pct_units_on_markdown,
       ROUND(100 * SUM(Net_Sales_MD_USD) / SUM(Net_Sales_USD), 1)   AS pct_net_sales_on_markdown
FROM work_daily
GROUP BY YEAR(Sale_Date)
ORDER BY yr;
 
SELECT YEAR(Sale_Date)                                              AS yr,
       ROUND(100 * SUM(Units_Sold_MD) / SUM(Units_Sold), 1)         AS pct_units_on_markdown,
       ROUND(100 * SUM(Net_Sales_MD_USD) / SUM(Net_Sales_USD), 1)   AS pct_net_sales_on_markdown
FROM work_daily
WHERE DATE_FORMAT(Sale_Date, '%m-%d') <= '03-18'
GROUP BY YEAR(Sale_Date)
ORDER BY yr;