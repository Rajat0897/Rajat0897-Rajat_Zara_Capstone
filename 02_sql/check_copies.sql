SELECT COUNT(*) AS products_copied FROM work_products;
SELECT COUNT(*) AS stores_copied   FROM work_stores;
SELECT Country_English, COUNT(*) AS stores
FROM work_stores
GROUP BY Country_English
ORDER BY Country_English;