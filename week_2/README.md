Week 2: The Incremental Fact & Snapshots
This week you build the heart of the warehouse — the line-level fact table — make it incremental so re-runs are fast, and take your first snapshot to track how data changes over time. Budget: ~2 hours.

📖 Lesson Overview
The Fact Table: join staged orders, items, and products into fct_order_items — one row per line item, with revenue, cost, and margin.
Incremental Materialization: the difference between rebuilding a whole table every run and only appending new rows.
Snapshots: dbt can take an automatic "picture" of a table every time it runs, so you can look back and see how a value (like a product's price) changed.
Recap of the target schema (dimensions were built in Week 1):


📝 Assignment Tasks
Task 2.1 — Build the Line-Level Fact (40 pts)
Create models/dev/fct_order_items.sql. Grain: one row per order_item_id.

Join stg_order_items → stg_orders (for customer_id, store_id, order_date, order_status) and stg_order_items → stg_products (for cost_price).

💡 Measures to calculate:

gross_amount = quantity * unit_price
discount_amount = quantity * unit_price * discount_pct / 100
net_amount = quantity * unit_price * (1 - discount_pct / 100)
total_cost = quantity * cost_price
margin = net_amount - total_cost
Deliverable: fct_order_items.sql that runs and produces the expected number of rows.

Task 2.2 — Make the Fact Incremental (30 pts)
Convert fct_order_items to an incremental model.

💡 What you need:

{{ config(
    materialized='incremental',
    unique_key='order_item_id'
) }}
Then add a filter so re-runs only pick up new rows:

{% if is_incremental() %}
    where order_item_id > (select coalesce(max(order_item_id), 0) from {{ this }})
{% endif %}
Test it:

dbt run --select fct_order_items --profiles-dir .                # first build
dbt run --select fct_order_items --profiles-dir .                # second run adds 0 rows
dbt run --select fct_order_items --full-refresh --profiles-dir . # rebuild from scratch
Deliverable: the incremental fct_order_items.sql.

Task 2.3 — Snapshot Product Prices (30 pts)
Create snapshots/snap_products.sql to track changes to list_price and is_active in raw_products over time.

💡 Starter:

{% snapshot snap_products %}
{{
    config(
        target_schema='RAW',
        unique_key='product_id',
        strategy='check',
        check_cols=['list_price', 'is_active']
    )
}}
select * from {{ ref('raw_products') }}
{% endsnapshot %}
Run it:

dbt snapshot --profiles-dir .
Deliverable: a working snap_products.sql. After running, the snapshot table has dbt_valid_from / dbt_valid_to columns. (Try changing a price in the seed, re-seeding, and snapshotting again to see a new version appear.)

🤖 Auto-Grade Your Work
python scripts/grade_assignment.py --week 2
Fix any ❌ items and re-run. 🚀