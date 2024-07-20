--here we are trying to check how many rows in data is empty
SELECT 
    COUNT(*) AS total_rows,
    COUNT(brokered_by) AS brokered_by_not_null,
    COUNT(status) AS status_not_null,
    COUNT(price) AS price_not_null,
    COUNT(bed) AS bed_not_null,
    COUNT(bath) AS bath_not_null,
    COUNT(acre_lot) AS acre_lot_not_null,
    COUNT(street) AS street_not_null,
    COUNT(city) AS city_not_null,
    COUNT(state) AS state_not_null,
    COUNT(zip_code) AS zip_code_not_null,
    COUNT(house_size) AS house_size_not_null,
    COUNT(prev_sold_date) AS prev_sold_date_not_null
FROM property_data;

-- we are trying to see how many unique states & zipcodes are present in data
SELECT DISTINCT state FROM property_data;
SELECT DISTINCT zip_code FROM property_data;

-- Now we Try to delete the data where price,state,zipcode,housesize col are null since these are major factors in analyzing anything in housing market we try to remove emply values to have a reliable data
DELETE FROM property_data
WHERE price IS NULL
   OR state IS NULL
   OR zip_code IS NULL
   OR house_size IS NULL;
   
 --count number of rows after removing missing values
   SELECT COUNT(*) AS total_rows
FROM property_data;

--Replacing brokeredby col where id are null since broker doesnt have any significant impact
-- Replace missing brokered_by values with a placeholder
UPDATE property_data
SET brokered_by = '0'
WHERE brokered_by IS NULL;

-- Remove rows with missing values in bed, bath, acre_lot, or prev_sold_date
DELETE FROM property_data
WHERE bed IS NULL
   OR bath IS NULL
   OR acre_lot IS NULL
   OR prev_sold_date IS NULL;

Select * From property_data ;
COPY property_data TO 'C:\Users\91770\Desktop\Portfolio\Housing\cleaned_property_data.csv' DELIMITER ',' CSV HEADER;

--trying to see if there are any duplicates im strying to see count of all the data first and then grouped them and set count >1 so if there are duplicates it would display that with count
SELECT 
    brokered_by, status, price, bed, bath, acre_lot, street, city, state, zip_code, house_size, prev_sold_date,
    COUNT(*) as cnt
FROM property_data
GROUP BY brokered_by, status, price, bed, bath, acre_lot, street, city, state, zip_code, house_size, prev_sold_date
HAVING COUNT(*) > 1;


--Fixing any structural errors 
UPDATE property_data
SET state = UPPER(state);

--Trying to remove any spaces in street and city cols
UPDATE property_data
SET street = TRIM(street),
    city = TRIM(city);

SELECT 
    AVG(price) AS mean_price,
    STDDEV(price) AS stddev_price
FROM property_data;

SELECT *
FROM property_data
WHERE ABS(price - 569409) > 3 * 1191272;

WITH stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) AS Q3
    FROM property_data
)
SELECT
    Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
    Q3 + 1.5 * (Q3 - Q1) AS upper_bound
FROM stats;


-- Review the distribution of 'price' values among outliers
SELECT price, COUNT(*)
FROM property_data
WHERE price < -300000 OR price > 1140000
GROUP BY price
ORDER BY price;


SELECT 
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) AS Q3
FROM property_data
WHERE price < -300000 OR price > 1140000;

-- Check the distribution of other columns among outliers
SELECT city, COUNT(*)
FROM property_data
WHERE price < -300000 OR price > 1140000
GROUP BY city;
