# Liquor Sales Data Cleaning & Transformation – SQL Project

## 📊 Project Overview

This project involved cleaning, transforming, and restructuring a raw liquor sales dataset using T-SQL in Azure Data Studio to prepare it for dashboarding in Tableau. 

The primary goals were to:
- Normalize the raw dataset into a clean, analysis-ready format
- Handle missing values and inconsistent data
- Derive new business metrics such as total sales and net loss
- Prepare the dataset for effective filtering and visualization (e.g., by date, supplier, item type)

---

## 🛠️ Tools & Technologies
- **SQL Server** (Azure SQL Database)
- **Azure Data Studio**
- **Tableau** (for dashboard visualization)
- **GitHub** (for version control and portfolio sharing)

---

## 🔍 Key Steps & Logic

### 1. Data Cleanup
- Replaced missing `SUPPLIER` values with `'Not Recorded'`
- Replaced missing `ITEM_TYPE` values (with conditional logic on `ITEM_CODE`)
- Added a `full_date` column using `DATEFROMPARTS(YEAR, MONTH, 1)`
- Removed unnecessary columns and formatted the structure

### 2. New Table Creation
Created a new table `liquor_reordered` to store the cleaned and restructured data with:
- Formatted date
- Cleaned and renamed fields
- Extracted `YEAR` and `MONTH` fields for filtering in Tableau

### 3. Business Metrics
Calculated two important metrics:
- `total_sales` = sum of retail sales, retail transfers, and warehouse sales
- `net_loss` = total negative sales values (when total_sales was negative)

To preserve integrity:
- If `total_sales` was negative, it was set to `0`
- The negative value was moved to `net_loss` to maintain insight into potential losses or anomalies

```sql
-- Handling negative total sales
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
