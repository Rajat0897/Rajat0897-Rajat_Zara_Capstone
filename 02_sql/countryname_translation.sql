CREATE TABLE work_country_map (
    Raw_Country     VARCHAR(60) PRIMARY KEY,
    Country_English VARCHAR(60) NOT NULL
);
 
INSERT INTO work_country_map (Raw_Country, Country_English) VALUES
    ('United States', 'United States'),
    ('中国',           'China'),
    ('Deutschland',   'Germany'),
    ('France',        'France'),
    ('España',        'Spain'),
    ('Portugal',      'Portugal'),
    ('United Kingdom','United Kingdom');
 
-- Check: should show 7 rows
SELECT * FROM work_country_map;