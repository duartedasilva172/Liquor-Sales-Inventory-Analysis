import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# load the dataset
liquor = pd.read_csv("/kaggle/input/liquor-reordered/liquor_reordered_final_.csv")
liquor.head()

liquor.dtypes # Check column data types and structure
liquor.info()

liquor['full_date'] = pd.to_datetime(liquor['full_date']) # Change full_date data type
liquor.dtypes

liquor.describe() # Use describe() to get a quick breakdown of the columns
liquor.isna().sum() # Calculate the sum of null values in all columns

missing_rows = liquor[liquor['retail_sales'].isna() | liquor['total_sales'].isna()] # Check rows with missing values
missing_rows

liquor_clean = liquor.dropna(subset=['retail_sales', 'total_sales']) # Drop rows with missing values
liquor_clean

liquor['item_type'] = liquor['item_type'].astype('category') # Update item_type to category 
liquor.dtypes
liquor

liquor.duplicated().sum() # Count duplicates
liquor['item_type'].value_counts(dropna= False) # Count rows per item type

don_sample = liquor[liquor['item_description'].str.contains('don julio', case= False)] # Create a sample to simulate
don_sample

# Simulate Inventory For Don Julio Sample

# Parameters
start_inventory = 80 
reorder_point = 40 
reorder_amount = 40

# Sort by date
don_sample = don_sample.sort_values('full_date')

# Reset index for iteration
don_sample = don_sample.reset_index(drop=True)
inventory =[]
current_inventory = start_inventory

for index, row in don_sample.iterrows():
    sales = row['total_sales']
    current_inventory -= sales
    if current_inventory < reorder_point:
        current_inventory += reorder_amount  # Restock
    inventory.append(current_inventory)  # Append every time


don_sample['simulated_inventory'] = inventory
don_sample[['full_date', 'item_description', 'total_sales', 'simulated_inventory']]

# Don Julio Sales Over Time Line Chart

don_sample = don_sample.sort_values('full_date') # Sort data frame by date

plt.figure(figsize=(10,5))
plt.plot(don_sample['full_date'], don_sample['total_sales'], marker='o', linestyle='-', linewidth=2)
plt.title("Don Julio Sales Over Time", fontsize=14)
plt.xlabel("Date", fontsize=10)
plt.ylabel("Sales", fontsize=10)
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig("don_julio_sales.png", dpi=300)  # 🔽 Save image here
plt.show()

# Simulate inventory levels for each category (item_type): 

liquor = liquor.sort_values(['item_code', 'full_date']) # Sort by date 

# Clean and validate item_code
liquor['item_code_clean'] = liquor['item_code'].astype(str).str.strip()

# Filter to only fully numeric item_codes
liquor_clean = liquor[liquor['item_code_clean'].str.isdigit()].copy()

print(liquor_clean['item_code_clean'].unique())

# Step 1: Define Inventory Rules

inventory_rules = {
    'LIQUOR':   {'start_inventory': 100, 'reorder_point': 40, 'reorder_amount': 60},
    'WINE':     {'start_inventory': 80, 'reorder_point': 30, 'reorder_amount': 50},
    'BEER':     {'start_inventory': 120, 'reorder_point': 60, 'reorder_amount':60}
}

# Step 2: Build A Python Function

def simulate_inventory_by_category(group):
    group = group.copy()  # avoid modifying original
    item_type = group['item_type'].iloc[0]

    rules = inventory_rules.get(item_type, {'start_inventory': 80, 'reorder_point': 40, 'reorder_amount': 40})

    current_inventory = rules['start_inventory']
    inventory = []
    reorder_flag = []

    for _, row in group.iterrows():
        sales = row['total_sales']
        current_inventory -= sales
        if current_inventory < rules['reorder_point']:
            current_inventory += rules['reorder_amount']
            reorder_flag.append(1) # Reorder Ocurred
        else:
            reorder_flag.append(0)

        inventory.append(max(current_inventory, 0))

    group['simulated_inventory'] = inventory
    group['reorder_flag'] = reorder_flag
    return group


# Step 3: Apply function while avoiding future warning
liquor_inventory = (
    liquor_clean
    .set_index('item_code')  # temporarily remove group column from the data passed to `apply`
    .groupby(level=0, group_keys=False)
    .apply(simulate_inventory_by_category)
    .reset_index()  # bring 'item_code' back if needed
)


# Export Data Frame

liquor_inventory.to_csv("outputs/liquor_inventory_simulated.csv", index=False)