# Data Model

## 1. Gold Layer Star Schema

The Gold layer follows a **sales-centered star schema** with one fact table and two dimension tables.

```text
                         ┌─────────────────────────┐
                         │      dim_customers      │
                         ├─────────────────────────┤
                         │ PK customer_key         │
                         │    customer_id          │
                         │    customer_number      │
                         │    first_name            │
                         │    last_name             │
                         │    country               │
                         │    marital_status        │
                         │    gender                │
                         │    birthdate             │
                         │    create_date           │
                         └────────────┬────────────┘
                                      │
                                      │ 1
                                      │
                                      │ N
                                      ▼
                         ┌─────────────────────────┐
                         │       fact_sales        │
                         ├─────────────────────────┤
                         │    order_number         │
                         │ FK customer_key         │
                         │ FK product_key          │
                         │    order_date           │
                         │    shipping_date        │
                         │    due_date             │
                         │    sales_amount         │
                         │    quantity              │
                         │    price                 │
                         └────────────┬────────────┘
                                      │
                                      │ N
                                      │
                                      │ 1
                                      ▼
                         ┌─────────────────────────┐
                         │      dim_products       │
                         ├─────────────────────────┤
                         │ PK product_key          │
                         │    product_id           │
                         │    product_number       │
                         │    product_name         │
                         │    category_id           │
                         │    category              │
                         │    subcategory           │
                         │    maintenance           │
                         │    product_cost          │
                         │    product_line         │
                         │    start_date            │
                         └─────────────────────────┘
```

---

## 2. Source-to-Gold Data Flow

The data progresses through the Medallion layers from source systems to the final Gold data model.

```text
┌───────────────────────────┐
│          SOURCES          │
├───────────────────────────┤
│ CRM                       │
│ ERP                       │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│     BRONZE — RAW          │
├───────────────────────────┤
│ crm_sales_details         │
│ crm_cust_info             │
│ crm_prd_info              │
│ erp_cust_az12             │
│ erp_loc_a101              │
│ erp_px_cat_g1v2           │
└─────────────┬─────────────┘
              │
              │ Cleanse
              │ Standardize
              │ Validate
              ▼
┌───────────────────────────┐
│   SILVER — CLEANSED       │
├───────────────────────────┤
│ crm_sales_details         │
│ crm_cust_info             │
│ crm_prd_info              │
│ erp_cust_az12             │
│ erp_loc_a101              │
│ erp_px_cat_g1v2           │
└─────────────┬─────────────┘
              │
              │ Integrate
              │ Transform
              │ Model
              ▼
┌───────────────────────────┐
│     GOLD — BUSINESS       │
├───────────────────────────┤
│ fact_sales                │
│ dim_customers             │
│ dim_products              │
└───────────────────────────┘
```

### Gold Transformation Flow

```text
crm_sales_details ───────────────► fact_sales


crm_cust_info ───────┐
erp_cust_az12 ───────┼───────────► dim_customers
erp_loc_a101 ────────┘


crm_prd_info ────────┐
erp_px_cat_g1v2 ─────┴───────────► dim_products
```

The Gold layer consolidates and transforms the cleansed Silver datasets into a **sales-centered star schema**.

---

## 3. Relationships

```text
dim_customers
      │
      │ customer_key
      │
      │ 1 : N
      ▼
 fact_sales
      ▲
      │
      │ product_key
      │
      │ N : 1
      │
dim_products
```

### Foreign Keys

```text
fact_sales.customer_key
        │
        └──► dim_customers.customer_key


fact_sales.product_key
        │
        └──► dim_products.product_key
```

---

## 4. Table Roles

```text
┌──────────────────┐
│  dim_customers   │
│                  │
│ Who bought?      │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│    fact_sales    │
│                  │
│ What was sold?   │
│ When? How much?  │
└────────┬─────────┘
         ▲
         │
┌──────────────────┐
│  dim_products    │
│                  │
│ What product?    │
└──────────────────┘
```

| Table           | Role                            |
| --------------- | ------------------------------- |
| `dim_customers` | Customer descriptive attributes |
| `dim_products`  | Product descriptive attributes  |
| `fact_sales`    | Sales transactions and measures |

---

## 5. Key Design

```text
dim_customers
      │
      └── PK: customer_key
              ▲
              │ FK
              │
         fact_sales


dim_products
      │
      └── PK: product_key
              ▲
              │ FK
              │
         fact_sales
```

Both dimension primary keys are **surrogate keys** generated during the Gold-layer transformation.

The fact table uses these surrogate keys to establish relationships with the dimensions.

---

## 6. Model Summary

```text
                 STAR SCHEMA

             dim_customers
                    │
                    │
                    ▼
              ┌───────────┐
              │ fact_sales│
              └─────┬─────┘
                    ▲
                    │
                    │
              dim_products
```

**Dimensions provide context.
The fact table stores measurable business events.**
