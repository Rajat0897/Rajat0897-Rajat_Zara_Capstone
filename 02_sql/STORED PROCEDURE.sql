DROP PROCEDURE IF EXISTS promo_report;
DELIMITER $$
CREATE PROCEDURE promo_report (IN p_start DATE, IN p_end DATE, IN p_country VARCHAR(30))
BEGIN
    DECLARE v_days       INT;
    DECLARE v_prev_start DATE;
    DECLARE v_prev_end   DATE;
 
    SET v_days       = DATEDIFF(p_end, p_start) + 1;
    SET v_prev_end   = DATE_SUB(p_start, INTERVAL 1 DAY);
    SET v_prev_start = DATE_SUB(p_start, INTERVAL v_days DAY);
 
    -- cur = the selected dates, prv = the same number of days right before.
    -- (Two small CTEs instead of a temporary table: MySQL does not allow a
    --  temporary table to be read twice in one query.)
    WITH cur AS (
        SELECT SUM(Units_Sold - Units_Returned) AS u,
               SUM(Net_Sales_USD)               AS s,
               SUM(Margin_USD)                  AS m
        FROM work_daily
        WHERE Sale_Date BETWEEN p_start AND p_end
          AND (p_country = 'All' OR Country = p_country)
    ),
    prv AS (
        SELECT SUM(Units_Sold - Units_Returned) AS u,
               SUM(Net_Sales_USD)               AS s,
               SUM(Margin_USD)                  AS m
        FROM work_daily
        WHERE Sale_Date BETWEEN v_prev_start AND v_prev_end
          AND (p_country = 'All' OR Country = p_country)
    )
    SELECT 'Selected period' AS report_row, p_start AS from_date, p_end AS to_date,
           cur.u AS units, ROUND(cur.s, 0) AS net_sales_usd, ROUND(cur.m, 0) AS margin_usd,
           ROUND(100 * cur.m / cur.s, 1) AS margin_pct
    FROM cur
    UNION ALL
    SELECT 'Period before', v_prev_start, v_prev_end,
           prv.u, ROUND(prv.s, 0), ROUND(prv.m, 0), ROUND(100 * prv.m / prv.s, 1)
    FROM prv
    UNION ALL
    SELECT 'Change (%; margin_pct = points)', NULL, NULL,
           ROUND(100 * (cur.u / prv.u - 1), 1),
           ROUND(100 * (cur.s / prv.s - 1), 1),
           ROUND(100 * (cur.m / prv.m - 1), 1),
           ROUND(100 * cur.m / cur.s - 100 * prv.m / prv.s, 1)
    FROM cur, prv;
END$$
DELIMITER ;
 
CALL promo_report('2024-11-29', '2024-12-02', 'United States');    
CALL promo_report('2024-12-20', '2025-01-02', 'United Kingdom');  
CALL promo_report('2024-06-27', '2024-07-10', 'All');             