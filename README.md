# Retail Analytics Intelligence Platform

An end-to-end **retail analytics platform** that transforms CRM and ERP source data into a trusted analytical foundation for **business intelligence, advanced analytics, and machine learning**.

The platform follows a **Medallion Architecture** with progressive data quality validation, targeted performance optimization, and a sales-centered **Gold star schema**.

---

## Architecture

```text
                         CRM + ERP
                            │
                            ▼
                    ┌───────────────┐
                    │    BRONZE     │
                    │   Raw Data    │
                    │               │
                    │ No Transform  │
                    └───────┬───────┘
                            │
                     Identify Gaps
                            │
                            ▼
                    ┌───────────────┐
                    │    SILVER     │
                    │               │
                    │ Cleanse       │
                    │ Standardize   │
                    │ Integrate     │
                    │ Transform     │
                    │               │
                    │ Targeted      │
                    │ Indexing      │
                    └───────┬───────┘
                            │
                         Verify
                            │
                            ▼
                    ┌───────────────┐
                    │     GOLD      │
                    │               │
                    │ Dimensional   │
                    │ Model         │
                    │               │
                    │ Indexed       │
                    │ Partitioned   │
                    └───────┬───────┘
                            │
                         Verify
                            │
                   ┌────────┴────────┐
                   ▼                 ▼
                Tableau              ML
                   │                 │
                   └────────┬────────┘
                            ▼
                     Business Insights
```

### Medallion Layers

| Layer      | Responsibility                                                                           |
| ---------- | ---------------------------------------------------------------------------------------- |
| **Bronze** | Preserve raw CRM and ERP source data                                                     |
| **Silver** | Cleanse, standardize, integrate, transform, and optimize data for downstream processing  |
| **Gold**   | Provide the validated, business-ready analytical model optimized for BI and ML workloads |

---

## Data Sources

### CRM

```text
cust_info.csv
prd_info.csv
sales_details.csv
```

### ERP

```text
cust_az12.csv
loc_a101.csv
px_cat_g1v2.csv
```

---

## Gold Data Model

The Gold layer follows a **sales-centered star schema**.

```text
                    ┌───────────────────┐
                    │  dim_customers    │
                    ├───────────────────┤
                    │ PK customer_key   │
                    │ customer_id       │
                    │ customer_number   │
                    │ demographic data  │
                    │ geographic data   │
                    └─────────┬─────────┘
                              │
                            1 : N
                              │
                              ▼
                    ┌───────────────────┐
                    │    fact_sales     │
                    ├───────────────────┤
                    │ FK customer_key   │
                    │ FK product_key    │
                    │ order_number      │
                    │ order_date        │
                    │ sales_amount      │
                    │ quantity          │
                    │ price             │
                    └─────────┬─────────┘
                              │
                            N : 1
                              │
                              ▼
                    ┌───────────────────┐
                    │   dim_products    │
                    ├───────────────────┤
                    │ PK product_key    │
                    │ product_id        │
                    │ product_number    │
                    │ product_name      │
                    │ category          │
                    │ subcategory       │
                    │ product_cost      │
                    └───────────────────┘
```

### Gold Tables

| Table           | Purpose                                                   |
| --------------- | --------------------------------------------------------- |
| `dim_customers` | Customer identity, demographic, and geographic attributes |
| `dim_products`  | Product, category, and commercial attributes              |
| `fact_sales`    | Sales transactions and measurable business events         |

---

## Data Quality

Quality follows an **Identify → Transform → Verify** approach.

```text
Bronze
  │
  ├── Identify quality gaps
  ▼
Silver
  │
  ├── Cleanse
  ├── Standardize
  ├── Integrate
  └── Verify
  ▼
Gold
  │
  ├── Business transformation
  ├── Dimensional modeling
  └── Verify
  ▼
Analytics / BI / ML
```

Validation includes:

* Completeness and NULL checks
* Duplicate detection
* Identifier validation
* Date validation
* Primary and foreign key validation
* Referential integrity
* Measure validation
* Business-rule validation
* Source-to-target reconciliation

---

## Key Transformations

### Customer

* Integrates CRM customer information with ERP demographic and location data.
* Uses CRM gender as the primary value with ERP fallback where required.
* Generates a warehouse surrogate `customer_key`.

### Product

* Integrates CRM product information with ERP category data.
* Includes only active products where `prd_end_dt IS NULL`.
* Generates a warehouse surrogate `product_key`.

### Sales

* Resolves customer and product surrogate keys.
* Links transactions to the Gold dimensions.
* Preserves the defined sales transaction grain.
* Provides standardized measures for analytical workloads.

---

## Performance Optimization

The platform uses **targeted indexing and partitioning** to improve data processing and analytical query performance.

### Silver Layer Indexing

The Silver layer is table-based and uses indexes on columns frequently involved in **Silver-to-Gold joins and date filtering**.

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

Indexes are intentionally limited to relevant access paths rather than indexing every column.

### Gold Layer Indexing

The Gold layer uses primary keys and targeted indexes for analytical workloads.

```text
dim_customers
└── PRIMARY KEY (customer_key)

dim_products
└── PRIMARY KEY (product_key)

fact_sales
├── INDEX (customer_key)
├── INDEX (product_key)
├── INDEX (order_date)
└── INDEX (order_number)
```

These indexes support:

* Dimension-to-fact joins
* Customer analysis
* Product analysis
* Date-based filtering
* Order-level analysis

### Fact Table Partitioning

The `fact_sales` table is partitioned by **year of `order_date`** using MySQL `RANGE` partitioning.

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

The partitioning expression is:

```sql
YEAR(order_date)
```

Year-based partitioning supports the project's time-oriented analytical workload, including:

* Yearly revenue analysis
* Monthly sales trends
* Year-over-year growth
* Category growth analysis
* Product growth analysis
* Country growth analysis

For appropriate date-filtered queries, MySQL can use **partition pruning** to reduce the amount of data scanned.

Indexes and partitioning are implemented separately from the analytical SQL to keep performance-related database changes organized and maintainable.

---

## Analytics & ML

The Gold model provides a reusable foundation for:

```text
                    GOLD DATA
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
       Tableau        SQL         Machine
       Dashboards    Analysis     Learning
          │             │             │
          └─────────────┼─────────────┘
                        ▼
                Business Insights
```

### Analytics

* Executive KPI analysis
* Sales and revenue trends
* Customer segmentation
* Customer concentration
* Product performance
* Category and subcategory analysis
* Geographic analysis
* Pricing analysis
* Profitability analysis
* Year-over-year growth analysis

### Machine Learning

The Gold model provides structured features for downstream ML workflows such as:

* Customer segmentation
* Customer behavior analysis
* Sales forecasting
* Predictive analytics

---

## Technology Stack

| Area                     | Technology                   |
| ------------------------ | ---------------------------- |
| Data Warehouse           | MySQL                        |
| Data Transformation      | SQL                          |
| Data Quality             | SQL validation checks        |
| Performance Optimization | MySQL indexes & partitioning |
| BI & Visualization       | Tableau                      |
| Machine Learning         | Python                       |
| Version Control          | Git / GitHub                 |

---

## Repository Structure

```text
retail-analytics-intelligence-platform/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   │   ├── 01_create_tables.sql
│   │   ├── 02_load_data.sql
│   │   └── 03_indexes.sql
│   │
│   ├── gold/
│   │   ├── 01_create_tables.sql
│   │   ├── 02_load_data.sql
│   │   ├── 03_indexes.sql
│   │   └── 04_partition_fact_sales.sql
│   │
│   └── quality_checks/
│
├── docs/
│   ├── ARCHITECTURE.md
│   ├── DATA_MODEL.md
│   ├── DATA_DICTIONARY.md
│   ├── DATA_QUALITY.md
│   └── NAMING_CONVENTION.md
│
├── tableau/
│   └── executive_dashboard.twbx
│
├── ml/
│
└── README.md
```

---

## Documentation

| Document                                            | Description                                                          |
| --------------------------------------------------- | -------------------------------------------------------------------- |
| [`ARCHITECTURE.md`](docs/ARCHITECTURE.md)           | Overall architecture, data flow, indexing, and partitioning strategy |
| [`DATA_MODEL.md`](docs/DATA_MODEL.md)               | Gold star schema and relationships                                   |
| [`DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md)     | Column definitions, transformations, and usage                       |
| [`DATA_QUALITY.md`](docs/DATA_QUALITY.md)           | Layer-wise quality checks and validation                             |
| [`NAMING_CONVENTION.md`](docs/NAMING_CONVENTION.md) | Database and SQL naming standards                                    |

---

## End-to-End Workflow

```text
CRM / ERP Sources
       │
       ▼
     Bronze
       │
       │ Quality Assessment
       ▼
     Silver
       │
       │ Transformation
       │ + Targeted Indexing
       │ + Verification
       ▼
      Gold
       │
       │ Indexing
       │ + Year-Based Partitioning
       │ + Verification
       │
       ├───────────────┐
       ▼               ▼
   Tableau             ML
       │               │
       └───────┬───────┘
               ▼
       Business Insights
```

---

## Project Objective

The platform demonstrates a complete, production-oriented analytics workflow:

**Raw Data → Quality Assessment → Transformation → Validation → Dimensional Modeling → Performance Optimization → Machine Learning → BI**

The resulting Gold layer provides a **trusted, reusable, and scalable analytical foundation** for downstream reporting, analytics, and predictive workloads.

The architecture separates data transformation from downstream consumption while applying targeted database optimization to support both analytical processing and BI workloads.
