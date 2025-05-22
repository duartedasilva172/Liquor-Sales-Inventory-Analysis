Liquor Sales Analytics Case Study – SQL & Tableau Project

📌 Project Objective
This case study explores the operational challenges of retail liquor inventory management through a clean, structured dataset. The goal is to identify high- and low-performing products, analyze reorder patterns, and uncover inventory inefficiencies — such as overstocking underperformers or understocking fast movers — that can cost a business both money and customer satisfaction.

Drawing from my own experience as a bartender, I’ve designed this analysis with practical, business-facing insights in mind. The end result is a Tableau dashboard that decision-makers — from bar managers to warehouse staff — can use to make informed, actionable inventory decisions.

🛠️ Tools & Technologies
SQL Server (Azure SQL Database) – for data cleaning and transformation

Azure Data Studio – query development and execution

Tableau – for dashboard development and business storytelling

GitHub – project versioning and portfolio hosting

🔄 Cleaning & Transformation (T-SQL)
The original liquor sales dataset required significant restructuring to be usable for visual analytics. The data work was completed in SQL using Azure Data Studio.

✅ Key Data Cleaning Steps
Replaced missing values in SUPPLIER with 'Not Recorded'

Conditioned missing ITEM_TYPE values based on ITEM_CODE

Created a new full_date column using DATEFROMPARTS(YEAR, MONTH, 1)

Dropped unnecessary columns, renamed fields for clarity

Added new columns for YEAR and MONTH to simplify Tableau filtering

🧮 Business Metrics Created
total_sales = sum of retail_sales, retail_transfers, and warehouse_sales

net_loss = captures negative sales values (sales anomalies or write-offs)

👇 Negative Sales Logic Example

```
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
```
📊 Framework for Business Insight
This case study is built around a business-driven framework to generate relevant, actionable insights — not just visualizations.

1. Business Context
The dataset captures monthly sales and movement data of liquor products across retail and warehouse channels. Stakeholders include warehouse managers, product managers, general managers, and bar staff.

2. Operational Pain Points
Overstocking underperforming items increases costs and waste

Understocking high-demand products leads to stockouts and lost sales

Reactive ordering practices create instability and inefficiency

3. Project Goals
Identify the best and worst performing SKUs by sales and reorder frequency

Detect inefficiencies in inventory or product lifecycle

Provide visual tools that support decision-making at both strategic and tactical levels

Deliver a clean, aesthetically strong dashboard appropriate for real-world use

4. Core Metrics & Insights
Total sales, quantity sold, and trends over time

Reorder frequency by product or category

Net losses or sales anomalies

Sales-to-inventory ratios

Category and seasonal performance

5. Intended Users
From warehouse staff to general managers, and even bartenders — this tool can guide restocking strategy, spotlight waste, and even help craft menu items around underused inventory or top sellers.

📈 Outcome
A Tableau dashboard was developed from the cleaned dataset, which:

Visualizes trends by product, supplier, and date

Identifies the most and least successful products

Highlights reorder inefficiencies and net losses

Supports business storytelling through KPIs and interactivity

➡️ View the Tableau Dashboard: [Insert Tableau Public Link]
📂 Explore the SQL Source Code: liquor_reordered.sql
📸 See dashboard screenshots: /visuals
📂 The raw liquor sales dataset used in this project is available here:  
🔗 [https://www.kaggle.com/datasets/fatemehmohammadinia/retail-sales-data-set-of-alcohol-and-liquor]
