SELECT t.window_label, t.country_group,
       t.fp_2023, t.fp_2024,
       ROUND(100 * (t.fp_2024 / t.fp_2023 - 1), 1)           AS full_price_yoy_pct,
       t.md_2023, t.md_2024,
       t.total_2023, t.total_2024,
       ROUND(100 * (t.total_2024 / t.total_2023 - 1), 1)     AS total_sales_yoy_pct,
       t.margin_2023, t.margin_2024,
       ROUND(100 * (t.margin_2024 / t.margin_2023 - 1), 1)   AS margin_usd_yoy_pct
FROM (
    SELECT w.label AS window_label,
           CASE WHEN d.Country IN ('United States', 'United Kingdom')
                THEN '1 US + UK (BF and early sale)' ELSE '2 Other 5 countries' END AS country_group,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2023 THEN d.Net_Sales_USD - d.Net_Sales_MD_USD END)) AS fp_2023,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2024 THEN d.Net_Sales_USD - d.Net_Sales_MD_USD END)) AS fp_2024,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2023 THEN d.Net_Sales_MD_USD END))                   AS md_2023,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2024 THEN d.Net_Sales_MD_USD END))                   AS md_2024,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2023 THEN d.Net_Sales_USD END))                      AS total_2023,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2024 THEN d.Net_Sales_USD END))                      AS total_2024,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2023 THEN d.Margin_USD END))                         AS margin_2023,
           ROUND(SUM(CASE WHEN YEAR(d.Sale_Date) = 2024 THEN d.Margin_USD END))                         AS margin_2024
    FROM work_daily d
    JOIN (SELECT 'A. 4-24 Dec (3 weeks before Christmas)' AS label, '12-04' AS s, '12-24' AS e
          UNION ALL
          SELECT 'B. 29 Nov-24 Dec (Black Friday to Christmas Eve)', '11-29', '12-24') w
      ON DATE_FORMAT(d.Sale_Date, '%m-%d') BETWEEN w.s AND w.e
    WHERE YEAR(d.Sale_Date) IN (2023, 2024)
    GROUP BY 1, 2
) t
ORDER BY t.window_label, t.country_group;