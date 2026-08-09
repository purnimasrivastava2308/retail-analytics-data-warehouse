# Naming Conventions

## 1. Overview

The data warehouse follows consistent naming standards to improve **readability, maintainability, and scalability**.

---

## 2. Database Objects

| Object   | Convention             | Example                                 |
| -------- | ---------------------- | --------------------------------------- |
| Database | `lowercase_snake_case` | `retailanalyticsdw_gold`                |
| Table    | `lowercase_snake_case` | `dim_customers`                         |
| View     | `lowercase_snake_case` | `retailanalyticsdw_gold_customer_sales` |
| Column   | `lowercase_snake_case` | `customer_key`                          |

---

## 3. Layer Naming

Database layers use a consistent suffix:

```text
retailanalyticsdw_bronze
retailanalyticsdw_silver
retailanalyticsdw_gold
```

| Layer    | Purpose                         |
| -------- | ------------------------------- |
| `bronze` | Raw source data                 |
| `silver` | Cleansed and standardized data  |
| `gold`   | Business-ready analytical model |

---

## 4. Table Naming

Gold tables follow dimensional modeling conventions:

```text
dim_<entity>
fact_<business_process>
```

Examples:

```text
dim_customers
dim_products
fact_sales
```

Silver tables retain source-system prefixes for lineage:

```text
crm_<entity>
erp_<entity>
```

Examples:

```text
crm_cust_info
crm_prd_info
crm_sales_details

erp_cust_az12
erp_loc_a101
erp_cat_g1v2
```

---

## 5. Column Naming

All column names use **lowercase `snake_case`**.

```text
customer_key
customer_id
customer_number
product_key
order_date
sales_amount
```

### Key Naming

```text
<entity>_key      → Warehouse surrogate key
<entity>_id       → Source/system identifier
<entity>_number   → Business/reference identifier
```

Example:

```text
customer_key
customer_id
customer_number
```

### Silver Transformation Columns

Columns introduced during Silver-layer transformation use a `dwh_` prefix to distinguish **warehouse-generated or standardized attributes** from source-system fields.

```text
dwh_<attribute>
```

Examples:

```text
dwh_create_date
dwh_update_date
dwh_load_date
dwh_source_system
```

Use this convention only for attributes **introduced by the warehouse process**, not for renamed source columns.

---

## 6. Date & Measure Naming

Use descriptive names that clearly identify the business meaning.

```text
order_date
shipping_date
due_date
start_date

sales_amount
quantity
price
product_cost
```

Avoid ambiguous names such as:

```text
date
value
amount
num
cost1
```

---

## 7. SQL Naming

Use **uppercase SQL keywords** and **lowercase `snake_case` identifiers**.

```sql
SELECT
    customer_key,
    sales_amount
FROM fact_sales
WHERE sales_amount > 0;
```

Use short, meaningful table aliases:

```sql
FROM fact_sales fs
LEFT JOIN dim_customers dc
    ON fs.customer_key = dc.customer_key;
```

---

## 8. Naming Principles

```text
Consistent
    ↓
Descriptive
    ↓
Predictable
    ↓
Maintainable
```

* Use `snake_case` consistently.
* Prefer descriptive names over unnecessary abbreviations.
* Use `*_key` for warehouse surrogate keys.
* Use `*_id` for source identifiers.
* Use `dim_` and `fact_` consistently in the Gold layer.
* Preserve `crm_` and `erp_` prefixes where source lineage is important.
* Use `dwh_` for warehouse-generated or standardized Silver attributes.
* Avoid spaces, special characters, and inconsistent capitalization.
* Names should communicate **business meaning clearly**.
