# Week 5 — Index Performance Measurement

## Required Join Query

```sql
explain analyze
select *
from "DEV".fct_order_items f
join "DEV".fct_orders o
    on f.order_id = o.order_id;
```

## Join Results

| Test | Execution Time | Join Type | Scan Type |
|---|---:|---|---|
| Before index | 0.318 ms | Hash Join | Sequential Scan |
| After index | 0.484 ms | Hash Join | Sequential Scan |

## Interpretation

There was no meaningful performance improvement for the full join after creating the index. PostgreSQL continued to use a sequential scan because `fct_order_items` contains only 313 rows and the query reads all rows from both tables. For such a small dataset, scanning the entire table is cheaper than using the index.

The difference between 0.318 ms and 0.484 ms is normal execution-time variation on a very small dataset. The result does not indicate that the index is broken; it indicates that the index is unnecessary for this specific full-table join at the current data volume.

## Additional Selective Query Test

The following query was tested to verify that the index works when searching for a specific `order_id`:

```sql
explain analyze
select *
from "DEV".fct_order_items
where order_id = 1204;
```

## Selective Query Results

| Test | Execution Time | Scan Type |
|---|---:|---|
| Before index | 0.111 ms | Sequential Scan |
| After index | 0.091 ms | Index Scan |

Without the index, PostgreSQL scanned all 313 rows and removed 312 rows using the filter. After creating the index, PostgreSQL used `idx_fct_order_items_order_id` to locate the required row directly.

This additional test confirms that the index works correctly and can improve selective queries, even though PostgreSQL does not use it for the required full-table join.