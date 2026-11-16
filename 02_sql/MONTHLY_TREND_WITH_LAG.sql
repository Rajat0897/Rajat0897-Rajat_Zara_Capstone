WITH m AS (
    SELECT YEAR(Sale_Date) AS yr, MONTH(Sale_Date) AS mth,
           SUM(Net_Sales_USD)    AS net_sales,
           SUM(Margin_USD)       AS margin,
           SUM(Net_Sales_MD_USD) AS md_sales
    FROM work_daily
    GROUP BY YEAR(Sale_Date), MONTH(Sale_Date)
)
SELECT yr, mth,
       ROUND(net_sales)                                                  AS net_sales_usd,
       ROUND(100 * margin / net_sales, 1)                                AS margin_pct,
       ROUND(100 * md_sales / net_sales, 1)                              AS pct_sales_from_markdown,
       ROUND(100 * (net_sales / LAG(net_sales, 1)  OVER (ORDER BY yr, mth) - 1), 1) AS mom_pct,
       ROUND(100 * (net_sales / LAG(net_sales, 12) OVER (ORDER BY yr, mth) - 1), 1) AS yoy_pct,
       CASE WHEN yr = 2025 AND mth = 3 THEN 'partial month (1-18 Mar): ignore % changes' ELSE '' END AS note
FROM m
ORDER BY yr, mth;