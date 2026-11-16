-- How many, and in which categories?
SELECT 
    p.Category,
    COUNT(*) AS products,
    SUM(CASE
        WHEN s.Product_ID IS NULL THEN 1
        ELSE 0
    END) AS never_sold
FROM
    work_products p
        LEFT JOIN
    (SELECT DISTINCT
        Product_ID
    FROM
        work_sales) s ON s.Product_ID = p.Product_ID
GROUP BY p.Category;

-- Show 10 examples with their launch dates

SELECT 
    p.Product_ID,
    p.Category,
    p.Sub_Category,
    p.Description_EN,
    p.Launch_Date
FROM
    work_products p
        LEFT JOIN
    (SELECT DISTINCT
        Product_ID
    FROM
        work_sales) s ON s.Product_ID = p.Product_ID
WHERE
    s.Product_ID IS NULL
ORDER BY p.Launch_Date DESC
LIMIT 10;