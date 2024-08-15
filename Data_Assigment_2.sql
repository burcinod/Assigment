
-- a. Compute the Z-Score of SALE_PRICE for each sale/row as normalized against the entirety of the dataset
WITH sales_data AS (
    SELECT 
        *,
        CAST("SALE PRICE" AS FLOAT) AS sale_price,
        CAST("TOTAL UNITS" AS FLOAT) AS total_units,
        CAST("GROSS SQUARE FEET" AS FLOAT) AS gross_square_feet
    FROM sales
    WHERE "SALE PRICE" > 0 AND "TOTAL UNITS" > 0 AND "GROSS SQUARE FEET" > 0
),
zscore_data AS (
    SELECT
        *,
        AVG(sale_price) OVER () AS avg_sale_price,
        STDDEV(sale_price) OVER () AS stddev_sale_price
    FROM sales_data
),

-- b. Compute the Z-Score of SALE_PRICE for each sale/row based on the NEIGHBORHOOD and BUILDING_CLASS segment
zscore_neighborhood_data AS (
    SELECT
        *,
        AVG(sale_price) OVER (PARTITION BY "NEIGHBORHOOD", "BUILDING CLASS AT PRESENT") AS avg_sale_price_neighborhood,
        STDDEV(sale_price) OVER (PARTITION BY "NEIGHBORHOOD", "BUILDING CLASS AT PRESENT") AS stddev_sale_price_neighborhood
    FROM zscore_data
)

-- c. Compute square_ft_per_unit and price_per_unit
SELECT 
    *,
    (sale_price - avg_sale_price) / stddev_sale_price AS sale_price_zscore, -- part a
    (sale_price - avg_sale_price_neighborhood) / stddev_sale_price_neighborhood AS sale_price_zscore_neighborhood, -- part b
    (gross_square_feet / total_units) AS square_ft_per_unit, -- part c
    (sale_price / total_units) AS price_per_unit -- part c
FROM zscore_neighborhood_data;
