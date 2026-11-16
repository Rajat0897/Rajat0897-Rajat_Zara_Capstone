CREATE TABLE work_products AS
SELECT p.*, p.Production_Cost AS Cost_EUR_Clean
FROM products p;
ALTER TABLE work_products ADD PRIMARY KEY (Product_ID);

CREATE TABLE work_stores AS
SELECT s.*, m.Country_English
FROM stores s
JOIN work_country_map m ON s.Country = m.Raw_Country;
ALTER TABLE work_stores ADD PRIMARY KEY (Store_ID);