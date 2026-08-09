# Retail Analytics Intelligence Platform

An end-to-end **retail analytics platform** that transforms CRM and ERP source data into a trusted analytical foundation for **business intelligence, advanced analytics, and machine learning**.

The platform follows a **Medallion Architecture** with progressive data quality validation and a sales-centered **Gold star schema**.

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

| Layer      | Responsibility                                        |
| ---------- | ----------------------------------------------------- |
| **Bronze** | Preserve raw CRM and ERP source data                  |
| **Silver** | Cleanse, standardize, integrate, and transform data   |
| **Gold**   | Provide the validated business-ready analytical model |

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

* Sales and revenue trends
* Customer segmentation
* Product and category performance
* Geographic analysis
* Pricing analysis
* Profitability analysis
* Fulfillment analysis

### Machine Learning

The Gold model provides structured features for downstream ML workflows such as:

* Customer segmentation
* Customer behavior analysis
* Sales forecasting
* Predictive analytics

---

## Technology Stack

| Area                | Technology            |
| ------------------- | --------------------- |
| Data Warehouse      | MySQL                 |
| Data Transformation | SQL                   |
| Data Quality        | SQL validation checks |
| BI & Visualization  | Tableau               |
| Machine Learning    | Python                |
| Version Control     | Git / GitHub          |

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
│   ├── gold/
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

| Document                                            | Description                                    |
| --------------------------------------------------- | ---------------------------------------------- |
| [`ARCHITECTURE.md`](docs/ARCHITECTURE.md)           | Overall architecture and data flow             |
| [`DATA_MODEL.md`](docs/DATA_MODEL.md)               | Gold star schema and relationships             |
| [`DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md)     | Column definitions, transformations, and usage |
| [`DATA_QUALITY.md`](docs/DATA_QUALITY.md)           | Layer-wise quality checks and validation       |
| [`NAMING_CONVENTION.md`](docs/NAMING_CONVENTION.md) | Database and SQL naming standards              |

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
       │ Transformation + Verification
       ▼
      Gold
       │
       ├───────────────┐
       ▼               ▼
   Tableau             ML
       │               │
       └───────┬───────┘
               ▼
       Business Insights
```

## Project Objective

The platform demonstrates a complete, production-oriented analytics workflow:

**Raw Data → Quality Assessment → Transformation → Validation → Dimensional Modeling  → Machine Learning ****→ BI**

The resulting Gold layer provides a **trusted, reusable, and scalable analytical foundation** for downstream reporting, analytics, and predictive workloads.
