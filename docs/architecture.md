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

---

### Gold Layer — Business

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

---

## 4. Gold Layer Data Model

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

## 5. Analytics and Machine Learning

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

## 6. End-to-End Data Flow

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
           ▼
      ┌─────────┐
      │  GOLD   │
      │ BUSINESS│
      └────┬────┘
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

The architecture provides a clear separation between **raw ingestion, data transformation, business-ready analytics, and machine learning**, while the Gold layer serves as the trusted source for downstream BI and predictive analytics.
