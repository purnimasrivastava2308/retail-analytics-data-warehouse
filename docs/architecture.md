# Architecture

## 1. Architecture Overview

The Retail Analytics Data Warehouse follows a **Medallion Architecture** consisting of Bronze, Silver, and Gold layers.

Source data originates from two systems:

* **CRM** — customer, product, and sales data
* **ERP** — customer attributes, location, and product category data

The data flows through progressive transformation layers:

```text
                     SOURCE SYSTEMS
              ┌────────────┴────────────┐
              │                         │
           CRM Sources               ERP Sources
              │                         │
              └────────────┬────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    BRONZE   │
                    │  Raw Data   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    SILVER   │
                    │ Cleaned &   │
                    │ Standardized│
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │     GOLD    │
                    │  Business   │
                    │    Model    │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    ▼             ▼
                 Tableau          ML
                                Pipeline
```

---

## 2. Source Data

### CRM

```text
source_crm/
├── cust_info.csv
├── prd_info.csv
└── sales_details.csv
```

| Source | File                | Description          |
| ------ | ------------------- | -------------------- |
| CRM    | `cust_info.csv`     | Customer information |
| CRM    | `prd_info.csv`      | Product information  |
| CRM    | `sales_details.csv` | Sales transactions   |

### ERP

```text
source_erp/
├── cust_az12.csv
├── loc_a101.csv
└── px_cat_g1v2.csv
```

| Source | File              | Description                     |
| ------ | ----------------- | ------------------------------- |
| ERP    | `cust_az12.csv`   | Customer demographic attributes |
| ERP    | `loc_a101.csv`    | Customer location information   |
| ERP    | `px_cat_g1v2.csv` | Product category information    |

---

## 3. Medallion Architecture

### Bronze Layer — Raw

The Bronze layer stores the source data with minimal transformation.

```text
CRM Sources ──┐
              ├──► Bronze
ERP Sources ──┘
```

**Purpose:**

* Preserve source data.
* Maintain source-level structure.
* Provide a reproducible raw-data layer.
* Support downstream transformation and validation.

---

### Silver Layer — Cleansed

The Silver layer integrates and transforms the Bronze data into standardized datasets.

```text
Bronze
  │
  ├── CRM customer
  ├── CRM product
  ├── CRM sales
  ├── ERP customer
  ├── ERP location
  └── ERP category
        │
        ▼
     Silver
```

**Key transformations:**

* Data cleansing
* Data type standardization
* Duplicate handling
* Invalid-value handling
* Identifier validation
* CRM–ERP integration
* Business rule application
* Standardization of business keys used by downstream layers

The Silver layer is **table-based**, allowing targeted indexing to improve the performance of Silver-to-Gold transformations.

---

## 4. Silver Layer Performance Optimization

Targeted indexes are created on Silver tables for columns that are frequently used in **joins and date-based filtering** during Gold-layer processing.

Indexes are intentionally limited to relevant access paths to avoid unnecessary indexing and additional write/storage overhead.

| Silver Table        | Indexed Column | Purpose                       |
| ------------------- | -------------- | ----------------------------- |
| `crm_cust_info`     | `customer_key` | Customer joins                |
| `crm_prd_info`      | `product_key`  | Product joins                 |
| `crm_prd_info`      | `category_id`  | Category joins                |
| `crm_sales_details` | `product_key`  | Product joins                 |
| `crm_sales_details` | `customer_id`  | Customer joins                |
| `crm_sales_details` | `order_date`   | Date filtering / Gold loading |
| `erp_cat_g1v2`      | `category_id`  | Category joins                |
| `erp_cust_az12`     | `customer_id`  | Customer joins                |
| `erp_loc_a101`      | `customer_id`  | Customer/location joins       |

The corresponding implementation is maintained in:

```text
scripts/
└── silver/
    └── 03_indexes.sql
```

---

## 5. Gold Layer — Business

The Gold layer contains the final analytical model.

```text
Silver
   │
   ▼
Gold
   ├── dim_customers
   ├── dim_products
   └── fact_sales
```

The Gold layer follows a **sales-centered star schema**.

The Gold layer is designed as the primary consumption layer for:

* Business Intelligence
* Tableau dashboards
* Analytical SQL queries
* Machine Learning feature preparation

---

## 6. Gold Layer Data Model

```text
                    ┌─────────────────────┐
                    │    dim_customers    │
                    ├─────────────────────┤
                    │ PK customer_key     │
                    │    customer_id      │
                    │    customer_number  │
                    │    first_name       │
                    │    last_name        │
                    │    country          │
                    │    marital_status   │
                    │    gender           │
                    │    birthdate        │
                    │    create_date      │
                    └──────────┬──────────┘
                               │
                               │ 1 : N
                               ▼
                    ┌─────────────────────┐
                    │      fact_sales     │
                    ├─────────────────────┤
                    │    order_number     │
                    │ FK customer_key     │
                    │ FK product_key      │
                    │    order_date       │
                    │    shipping_date    │
                    │    due_date         │
                    │    sales_amount     │
                    │    quantity         │
                    │    price            │
                    └──────────┬──────────┘
                               │
                               │ N : 1
                               ▼
                    ┌─────────────────────┐
                    │     dim_products    │
                    ├─────────────────────┤
                    │ PK product_key      │
                    │    product_id       │
                    │    product_number   │
                    │    product_name     │
                    │    category_id      │
                    │    category         │
                    │    subcategory      │
                    │    maintenance      │
                    │    product_cost     │
                    │    product_line     │
                    │    start_date       │
                    └─────────────────────┘
```

### Relationships

```text
dim_customers.customer_key
        │
        └──────────► fact_sales.customer_key

dim_products.product_key
        │
        └──────────► fact_sales.product_key
```

Both dimensions have generated surrogate keys that are referenced by `fact_sales`.

---

## 7. Gold Layer Performance Optimization

The Gold layer uses **primary keys and targeted indexes** to support analytical queries, dimensional joins, and BI workloads.

### Dimension Table Keys

```text
dim_customers
└── PRIMARY KEY (customer_key)

dim_products
└── PRIMARY KEY (product_key)
```

### Fact Table Indexes

```text
fact_sales
├── INDEX (customer_key)
├── INDEX (product_key)
├── INDEX (order_date)
└── INDEX (order_number)
```

These indexes support common analytical access patterns including:

* Customer-based analysis
* Product-based analysis
* Date-based filtering
* Order-level analysis
* Joins between the fact table and dimensions

The corresponding implementation is maintained in:

```text
scripts/
└── gold/
    └── 03_indexes.sql
```

Indexes are kept targeted to avoid unnecessary or duplicate indexes.

---

## 8. Fact Table Partitioning

The `fact_sales` table is partitioned by **order year** using MySQL `RANGE` partitioning.

```text
fact_sales
│
├── p_2010
├── p_2011
├── p_2012
├── p_2013
├── p_2014
└── p_future
```

The partitioning strategy is based on:

```sql
YEAR(order_date)
```

Current partitions are defined as:

| Partition  | Data         |
| ---------- | ------------ |
| `p_2010`   | 2010         |
| `p_2011`   | 2011         |
| `p_2012`   | 2012         |
| `p_2013`   | 2013         |
| `p_2014`   | 2014         |
| `p_future` | Future years |

Year-based partitioning is appropriate for this workload because a significant portion of the analytical workload is time-oriented, including:

* Yearly revenue analysis
* Monthly sales trends
* Year-over-year growth
* Category growth analysis
* Product growth analysis
* Country growth analysis

For queries that filter directly on the partitioning expression, MySQL can use **partition pruning**, reducing the amount of data that needs to be scanned.

The partitioning implementation is maintained in:

```text
scripts/
└── gold/
    └── 04_partition_fact_sales.sql
```

---

## 9. Analytics and Machine Learning

The Gold layer serves as the trusted source for both **Business Intelligence** and **Machine Learning** workloads.

```text
                         GOLD
                          │
             ┌────────────┴────────────┐
             │                         │
             ▼                         ▼
         TABLEAU                  ML PIPELINE
             │                         │
             ▼                         ▼
       BI Dashboards             Data Preparation
                                       │
                                       ▼
                                Feature Engineering
                                       │
                                       ▼
                                  Model Training
                                       │
                                       ▼
                                  Model Evaluation
                                       │
                                       ▼
                                   Predictions
```

### Machine Learning Implementation

The ML pipeline uses curated Gold-layer data rather than raw source data.

```text
Gold Tables
    │
    ├── dim_customers
    ├── dim_products
    └── fact_sales
          │
          ▼
    Feature Engineering
          │
          ├── Customer Features
          ├── Product Features
          └── Sales Features
          │
          ▼
      Training Dataset
          │
          ▼
     Model Training
          │
          ▼
      Model Evaluation
          │
          ▼
       Predictions
```

The ML layer is separated from the warehouse transformation layer so that analytical models can be developed and evaluated independently while using a consistent, validated data foundation.

---

## 10. End-to-End Data Flow

```text
SOURCE
│
├── CRM
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
│
└── ERP
    ├── cust_az12.csv
    ├── loc_a101.csv
    └── px_cat_g1v2.csv
          │
          ▼
      ┌─────────┐
      │ BRONZE  │
      │   RAW   │
      └────┬────┘
           │
           ▼
      ┌─────────┐
      │ SILVER  │
      │ CLEANED │
      └────┬────┘
           │
           │ Indexed join paths
           ▼
      ┌─────────┐
      │  GOLD   │
      │ BUSINESS│
      └────┬────┘
           │
           │ Indexed + Partitioned
           │
      ┌────┴──────────┐
      ▼               ▼
  dim/fact         Analytical
     Model            Layer
      │               │
      │          ┌────┴─────┐
      │          ▼          ▼
      │       Tableau       ML
      │          │          │
      │          ▼          ▼
      │     BI Insights  Predictions
      │
      └─────────────────────────────
```

The architecture provides a clear separation between **raw ingestion, data transformation, business-ready analytics, and machine learning**.

Targeted indexing in the Silver layer improves transformation performance, while Gold-layer indexing and `fact_sales` partitioning optimize downstream analytical workloads.

The Gold layer serves as the trusted source for Tableau dashboards, analytical SQL queries, and machine learning workflows.
