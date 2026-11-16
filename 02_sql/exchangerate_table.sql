CREATE TABLE work_exchange_rates (
    Currency    VARCHAR(5) PRIMARY KEY,
    Rate_to_USD DECIMAL(6,4) NOT NULL
);
 
INSERT INTO work_exchange_rates (Currency, Rate_to_USD) VALUES
    ('USD', 1.0000),
    ('EUR', 1.0800),
    ('GBP', 1.2700),
    ('CNY', 0.1400);
 
-- Check: should show 4 rows
SELECT * FROM work_exchange_rates;