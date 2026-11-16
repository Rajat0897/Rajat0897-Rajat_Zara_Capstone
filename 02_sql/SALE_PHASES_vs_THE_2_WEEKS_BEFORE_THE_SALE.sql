WITH cal AS (
    SELECT Season, Phase_No, Start_Date, End_Date, Country, Category, Sub_Category,
           MIN(Start_Date) OVER (PARTITION BY Season, Country, Category, Sub_Category) AS Season_Start
    FROM work_discount_cal
),
ph AS (                                   -- sales DURING each phase
    SELECT c.Season, c.Phase_No, c.Start_Date, c.End_Date,
           COUNT(DISTINCT c.Country)                AS n_countries,
           SUM(d.Units_Sold - d.Units_Returned)     AS units,
           SUM(d.Net_Sales_USD)                     AS sales,
           SUM(d.Margin_USD)                        AS margin,
           SUM(d.Net_Sales_MD_USD)                  AS sales_md
    FROM cal c
    JOIN work_daily d
      ON d.Country = c.Country AND d.Category = c.Category AND d.Sub_Category = c.Sub_Category
     AND d.Sale_Date BETWEEN c.Start_Date AND c.End_Date
    GROUP BY c.Season, c.Phase_No, c.Start_Date, c.End_Date
),
bl AS (                                   -- sales in the 14 days BEFORE the season
    SELECT c.Season, c.Phase_No, c.Start_Date, c.End_Date,
           SUM(d.Units_Sold - d.Units_Returned)     AS units,
           SUM(d.Net_Sales_USD)                     AS sales,
           SUM(d.Margin_USD)                        AS margin
    FROM cal c
    JOIN work_daily d
      ON d.Country = c.Country AND d.Category = c.Category AND d.Sub_Category = c.Sub_Category
     AND d.Sale_Date BETWEEN DATE_SUB(c.Season_Start, INTERVAL 14 DAY)
                         AND DATE_SUB(c.Season_Start, INTERVAL 1 DAY)
    WHERE DATE_SUB(c.Season_Start, INTERVAL 14 DAY) >= '2023-01-01'
    GROUP BY c.Season, c.Phase_No, c.Start_Date, c.End_Date
)
SELECT p.Season,
       p.Phase_No                                                       AS phase,
       p.n_countries,
       p.Start_Date, p.End_Date,
       DATEDIFF(p.End_Date, p.Start_Date) + 1                           AS phase_days,
       ROUND(b.units  / 14)                                             AS units_day_before,
       ROUND(p.units  / (DATEDIFF(p.End_Date, p.Start_Date) + 1))       AS units_day_phase,
       ROUND(100 * ((p.units / (DATEDIFF(p.End_Date, p.Start_Date) + 1)) / (b.units / 14) - 1), 1)
                                                                        AS units_change_pct,
       ROUND(b.sales  / 14)                                             AS sales_day_before,
       ROUND(p.sales  / (DATEDIFF(p.End_Date, p.Start_Date) + 1))       AS sales_day_phase,
       ROUND(100 * ((p.sales / (DATEDIFF(p.End_Date, p.Start_Date) + 1)) / (b.sales / 14) - 1), 1)
                                                                        AS sales_change_pct,
       ROUND(100 * b.margin / b.sales, 1)                               AS margin_pct_before,
       ROUND(100 * p.margin / p.sales, 1)                               AS margin_pct_phase,
       ROUND(b.margin / 14)                                             AS margin_day_before,
       ROUND(p.margin / (DATEDIFF(p.End_Date, p.Start_Date) + 1))       AS margin_day_phase,
       ROUND(100 * ((p.margin / (DATEDIFF(p.End_Date, p.Start_Date) + 1)) / (b.margin / 14) - 1), 1)
                                                                        AS margin_change_pct,
       ROUND(100 * p.sales_md / p.sales, 1)                             AS pct_sales_on_markdown
FROM ph p
JOIN bl b ON b.Season = p.Season AND b.Phase_No = p.Phase_No
         AND b.Start_Date = p.Start_Date AND b.End_Date = p.End_Date
ORDER BY p.Start_Date, p.n_countries DESC;