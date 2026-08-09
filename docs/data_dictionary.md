# Data Dictionary

## 1. Overview

The Gold layer contains the business-ready dimensional model used for **BI reporting, analytical queries, and machine learning**.

```text
                         GOLD MODEL
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
       dim_customers   dim_products    fact_sales
```

The dictionary documents the **business meaning, transformation logic, and analytical usage** of each column.

---

# 2. `dim_customers`

**Purpose:** Customer identity, demographic, and geographic attributes.

| Column            | Type    | Key | Description            | Transformation / Business Rule        | Usage                   |
| ----------------- | ------- | --- | ---------------------- | ------------------------------------- | ----------------------- |
| `customer_key`    | INT     | PK  | Warehouse customer ID  | `ROW_NUMBER()` surrogate key          | Dimension joins         |
| `customer_id`     | INT     | —   | Source customer ID     | From CRM                              | Customer identification |
| `customer_number` | VARCHAR | —   | Source customer number | Standardized source value             | Traceability            |
| `first_name`      | VARCHAR | —   | Customer first name    | Cleansed CRM value                    | Profiling               |
| `last_name`       | VARCHAR | —   | Customer last name     | Cleansed CRM value                    | Profiling               |
| `country`         | VARCHAR | —   | Customer country       | From ERP location                     | Geographic analysis     |
| `marital_status`  | VARCHAR | —   | Marital status         | Standardized source value             | Segmentation            |
| `gender`          | VARCHAR | —   | Customer gender        | CRM preferred; ERP fallback for `n/a` | Demographics            |
| `birthdate`       | DATE    | —   | Date of birth          | Standardized ERP date                 | Age analysis            |
| `create_date`     | DATE    | —   | Customer creation date | Standardized CRM date                 | Lifecycle analysis      |

### Customer Transformation

```text
                    CUSTOMER DATA FLOW

crm_cust_info ───────────────┐
                             │
                             │ Customer attributes
                             │
erp_cust_az12 ───────────────┼──────► dim_customers
                             │
                             │ Birthdate / Gender
                             │
erp_loc_a101 ────────────────┘
                                    Country
```

### Gender Rule

```text
                CRM Gender
                    │
          ┌─────────┴─────────┐
          │                   │
       Valid               'n/a'
          │                   │
          ▼                   ▼
     Use CRM          Use ERP Gender
                              │
                              ▼
                         If unavailable
                              │
                              ▼
                           'n/a'
```

---

# 3. `dim_products`

**Purpose:** Product, category, and commercial attributes.

| Column           | Type    | Key | Description                | Transformation / Business Rule | Usage                  |
| ---------------- | ------- | --- | -------------------------- | ------------------------------ | ---------------------- |
| `product_key`    | INT     | PK  | Warehouse product ID       | `ROW_NUMBER()` surrogate key   | Dimension joins        |
| `product_id`     | INT     | —   | Source product ID          | From CRM                       | Product identification |
| `product_number` | VARCHAR | —   | Source product number      | Business key for sales lookup  | Traceability / joins   |
| `product_name`   | VARCHAR | —   | Product name               | Cleansed CRM value             | Product analysis       |
| `category_id`    | VARCHAR | —   | Category ID                | From CRM product data          | Category reference     |
| `category`       | VARCHAR | —   | Product category           | Enriched from ERP              | Category analysis      |
| `subcategory`    | VARCHAR | —   | Product subcategory        | Enriched from ERP              | Segmentation           |
| `maintenance`    | VARCHAR | —   | Maintenance classification | Enriched from ERP              | Product analysis       |
| `product_cost`   | DECIMAL | —   | Product cost               | Standardized numeric value     | Cost / profitability   |
| `product_line`   | VARCHAR | —   | Product line               | Standardized CRM value         | Product-line analysis  |
| `start_date`     | DATE    | —   | Product start date         | Standardized source date       | Product lifecycle      |

### Product Transformation

```text
                    PRODUCT DATA FLOW

crm_prd_info ─────────────────┐
                              │
                              │ Product attributes
                              │
                              ├──────► dim_products
                              │
erp_px_cat_g1v2 ──────────────┘
                              │
                       Category attributes
```

### Active Product Rule

```text
              crm_prd_info
                    │
                    ▼
             prd_end_dt
                    │
          ┌─────────┴─────────┐
          │                   │
       IS NULL              NOT NULL
          │                   │
          ▼                   ▼
       ACTIVE              Inactive
          │
          ▼
   dim_products
```

---

# 4. `fact_sales`

**Purpose:** Central fact table containing sales transactions and measurable business events.

### Grain

**One row represents one source sales transaction for a customer and product.**

| Column          | Type    | Key     | Description             | Transformation / Business Rule | Usage             |
| --------------- | ------- | ------- | ----------------------- | ------------------------------ | ----------------- |
| `order_number`  | VARCHAR | —       | Sales order ID          | From source sales data         | Order analysis    |
| `product_key`   | INT     | FK      | Warehouse product ID    | Lookup from `dim_products`     | Product analysis  |
| `customer_key`  | INT     | FK      | Warehouse customer ID   | Lookup from `dim_customers`    | Customer analysis |
| `order_date`    | DATE    | —       | Order date              | Standardized source date       | Time-series       |
| `shipping_date` | DATE    | —       | Shipping date           | Standardized source date       | Fulfillment       |
| `due_date`      | DATE    | —       | Expected due date       | Standardized source date       | Delivery          |
| `sales_amount`  | DECIMAL | Measure | Sales transaction value | Standardized source amount     | Revenue           |
| `quantity`      | INT     | Measure | Units sold              | Standardized source quantity   | Sales volume      |
| `price`         | DECIMAL | Measure | Selling price           | Standardized source price      | Pricing           |

---

# 5. Fact Table Key Resolution

The fact table uses **Gold-layer surrogate keys** instead of repeating customer and product attributes.

```text
                     SILVER SALES
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        customer_id              product_number
              │                         │
              ▼                         ▼
       dim_customers              dim_products
              │                         │
              ▼                         ▼
        customer_key               product_key
              │                         │
              └────────────┬────────────┘
                           ▼
                      fact_sales
```

### Relationship

```text
dim_customers.customer_key ──┐
                             │
                             ▼
                        fact_sales
                             ▲
                             │
dim_products.product_key ────┘
```

This maintains the **star-schema structure** and avoids storing repeated descriptive attributes in the fact table.

---

# 6. Source-to-Gold Column Flow

```text
                         SOURCE
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
           CRM/ERP       CRM/ERP        CRM
          Customer       Product       Sales
              │             │             │
              ▼             ▼             ▼
       dim_customers  dim_products   fact_sales
              │             │             │
              └─────────────┼─────────────┘
                            ▼
                     GOLD STAR SCHEMA
```

### Transformation Pattern

```text
RAW
 │
 ▼
Clean
 │
 ▼
Standardize
 │
 ▼
Integrate
 │
 ▼
Generate Surrogate Keys
 │
 ▼
Gold Dimensions
 │
 ▼
Resolve Dimension Keys
 │
 ▼
Gold Fact
```

---

# 7. Column Usage by Analytical Area

```text
                         GOLD MODEL
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
      CUSTOMER            PRODUCT             SALES
      ANALYSIS            ANALYSIS           ANALYSIS
          │                  │                  │
          ▼                  ▼                  ▼
       country            category         sales_amount
       gender             subcategory      quantity
       birthdate          product_line     price
       marital_status     product_cost     order_date
          │                  │                  │
          └──────────────────┼──────────────────┘
                             ▼
                       BUSINESS INSIGHTS
```

| Analytical Area | Primary Columns                                    |
| --------------- | -------------------------------------------------- |
| Revenue         | `sales_amount`, `order_date`                       |
| Sales Volume    | `quantity`, `order_date`                           |
| Customer        | `country`, `gender`, `marital_status`, `birthdate` |
| Product         | `category`, `subcategory`, `product_line`          |
| Profitability   | `sales_amount`, `product_cost`, `quantity`         |
| Pricing         | `price`, `quantity`, `sales_amount`                |
| Fulfillment     | `order_date`, `shipping_date`, `due_date`          |

---

# 8. Data Model Conventions

```text
                    DIMENSIONS
                         │
                         │ Descriptive
                         │ Attributes
                         ▼
                    fact_sales
                         │
                         │ Business Events
                         ▼
                      MEASURES
```

| Convention   | Meaning                                            |
| ------------ | -------------------------------------------------- |
| `PK`         | Primary key                                        |
| `FK`         | Foreign key                                        |
| `Measure`    | Numeric analytical value                           |
| `*_key`      | Warehouse surrogate key                            |
| Business Key | Source-system identifier retained for traceability |

### Design Principles

* Dimensions provide **descriptive business context**.
* `fact_sales` stores **transactional business events and measures**.
* Surrogate keys establish relationships between dimensions and facts.
* Source identifiers are retained for **traceability**.
* Gold data is standardized for **Tableau, SQL analytics, and ML workloads**.
