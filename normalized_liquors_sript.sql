-- OBJECTIVE: Create a normalized liquor type reference within the existing table

SELECT * FROM [liquor_inventory_simulated] 
WHERE item_type = 'LIQUOR' 
-- Preview all data where item_type is 'LIQUOR'

ALTER TABLE [liquor_inventory_simulated] 
ADD liquor_type VARCHAR(64);
-- Add new column to classify liquors by type

-- Test logic before making updates to the table
WITH logic_test AS (
  SELECT *,  
    CASE 
      WHEN item_description LIKE '%TEQUILA%' THEN 'TEQUILA'
      ELSE 'OTHER'
    END AS liquor_type_test
  FROM [liquor_inventory_simulated]
)

SELECT * FROM logic_test
WHERE liquor_type_test = 'TEQUILA'; 
-- View test results for tequila classification

-- Apply initial liquor type classification using pattern matching
UPDATE [liquor_inventory_simulated]
SET liquor_type = 
  CASE 
    WHEN item_description LIKE '%TEQUILA%' THEN 'TEQUILA'
    WHEN item_description LIKE '%VODKA%' THEN 'VODKA'
    WHEN item_description LIKE '%RUM%' THEN 'RUM'
    WHEN item_description LIKE '%BRANDY%' THEN 'BRANDY'
    WHEN item_description LIKE '%MEZCAL%' THEN 'MEZCAL'
    WHEN item_description LIKE '%BOURBON%' THEN 'WHISKY'
    WHEN item_description LIKE '%WHISKEY%' THEN 'WHISKY'
    WHEN item_description LIKE '%WHISKY%' THEN 'WHISKY'
    WHEN item_description LIKE '%RYE%' THEN 'WHISKY'
    WHEN item_description LIKE '%GIN%' THEN 'GIN'
    WHEN item_type = 'WINE' THEN 'N/A'
    WHEN item_type = 'BEER' THEN 'N/A'
    ELSE 'OTHER' 
  END;

-- Identify liquors still classified as 'OTHER'
SELECT * FROM [liquor_inventory_simulated]
WHERE item_type = 'LIQUOR' AND liquor_type = 'OTHER';

-- Count distinct item codes still labeled as 'OTHER'
SELECT COUNT(DISTINCT item_code) AS others 
FROM [liquor_inventory_simulated]
WHERE item_type = 'LIQUOR' AND liquor_type = 'OTHER';

-- Retrieve detailed view of 'OTHER' liquors for manual review
SELECT DISTINCT item_code, item_description, total_sales 
FROM [liquor_inventory_simulated]
WHERE item_type = 'LIQUOR' AND liquor_type = 'OTHER';

-- Manually correct remaining 'OTHER' rows based on detailed review
UPDATE [liquor_inventory_simulated]
SET liquor_type = 
  CASE 
    WHEN item_description LIKE '%COGNAC%' THEN 'COGNAC'
    WHEN item_description LIKE 'NOTEWORTHY SMALL BATCH%' THEN 'WHISKY'
    WHEN item_description LIKE '%TEQ%' THEN 'TEQUILA'
    WHEN item_description LIKE '%JAMESON%' THEN 'WHISKY'
    WHEN item_description LIKE 'MAKER''S MARK' THEN 'WHISKY'
    WHEN item_description LIKE '%ESPOLON%' THEN 'TEQUILA'
    WHEN item_description LIKE 'MONKEY 47' THEN 'GIN'
    WHEN item_description LIKE '%WILD TURKEY%' THEN 'WHISKY'
    WHEN item_description LIKE '%JIM BEAM%' THEN 'WHISKY'
    WHEN item_description LIKE 'KENTUCKY%' THEN 'WHISKY'
    WHEN item_description LIKE 'CHIVAS EXTRA%' THEN 'WHISKY'
    ELSE liquor_type 
  END
WHERE liquor_type = 'OTHER';

-- The manual update above successfully corrected 221 distinct item codes

-- Drop and recreate the normalized liquor table for analysis or export
DROP TABLE IF EXISTS liquors_normalized;

-- Create a new table with only liquor items and updated liquor_type
SELECT 
  item_code,
  item_description,
  item_type,
  total_sales,
  liquor_type
INTO liquors_normalized
FROM [liquor_inventory_simulated]
WHERE item_type = 'LIQUOR';

-- Check if any items in the new table still show as 'OTHER'
SELECT * FROM liquors_normalized
WHERE liquor_type = 'OTHER';

-- Normalize naming by fixing known typos (e.g., WHISKEY → WHISKY)
UPDATE liquors_normalized
SET liquor_type = 
  CASE 
    WHEN liquor_type = 'WHISKEY' THEN 'WHISKY' 
    ELSE liquor_type 
  END
WHERE liquor_type = 'WHISKEY';
