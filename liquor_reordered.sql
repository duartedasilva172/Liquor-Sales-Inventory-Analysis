SELECT * 
[dbo].[liquor]

SELECT DISTINCT month 
FROM liquor_reordered

SELECT * 
INTO db_liquor
FROM [dbo].[liquor]

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'db_liquor'

SELECT * 
FROM [dbo].[db_liquor] 
WHERE SUPPLIER IS NULL

UPDATE [dbo].[db_liquor]
SET SUPPLIER = 'Not Recorded'
WHERE SUPPLIER IS NULL

SELECT * 
FROM [dbo].[db_liquor] 
WHERE ITEM_TYPE IS NULL

UPDATE db_liquor
SET ITEM_TYPE = 'WINE'
WHERE ITEM_TYPE IS NULL AND ITEM_CODE = 347939

-- DATE FORMATING

ALTER TABLE db_liquor
ADD full_date DATE; 

UPDATE db_liquor
SET full_date = DATEFROMPARTS(YEAR, MONTH, 1);

-- CREATE A NEW CLEANLY FORMATTED TABLE

SELECT 
    DATEFROMPARTS(YEAR, MONTH, 1) AS full_date,
    SUPPLIER AS supplier,
    ITEM_CODE AS item_code,
    ITEM_DESCRIPTION AS item_description,
    ITEM_TYPE AS item_type,
    [RETAIL SALES] AS retail_sales,
    [RETAIL TRANSFERS] AS retail_transfers,
    [WAREHOUSE SALES] warehouse_sales
INTO liquor_reordered
FROM db_liquor;

-- CREATE TOTAL SALES COLUMN

SELECT *,
(retail_sales + retail_transfers + warehouse_sales) AS total_sales
FROM liquor_reordered

ALTER TABLE liquor_reordered
ADD total_sales FLOAT;

UPDATE liquor_reordered
SET total_sales = ISNULL(retail_sales, 0)
                + ISNULL(retail_transfers, 0)
                + ISNULL(warehouse_sales, 0)

-- NULL CHECK

SELECT 
  SUM(CASE WHEN full_date IS NULL THEN 1 ELSE 0 END) AS null_full_date,
  SUM(CASE WHEN supplier IS NULL THEN 1 ELSE 0 END) AS null_supplier,
  SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) AS null_total_sales
FROM liquor_reordered;

-- VERIFY full_date IS A DATE TYPE 

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'liquor_reordered'

-- Add month and year columns for filtering

ALTER TABLE liquor_reordered ADD year INT, month INT; 

UPDATE liquor_reordered
SET year = YEAR(full_date),
    month = MONTH(full_date);

/* I found some values in warehouse sales are negative, I decided to create
a new column that would store the negative values, as they may represent lost
product, which is key to analyze as well */

ALTER TABLE liquor_reordered
ADD net_loss FLOAT;

UPDATE liquor_reordered
SET 
    total_sales = CASE
                  WHEN retail_sales + retail_transfers + warehouse_sales < 0 THEN 0 
                  ELSE retail_sales + retail_transfers + warehouse_sales
                END,
    net_loss = CASE
               WHEN retail_sales + retail_transfers + warehouse_sales < 0
               THEN retail_sales + retail_transfers + warehouse_sales
               END;

