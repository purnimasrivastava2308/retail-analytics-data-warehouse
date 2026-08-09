# Data Quality

## 1. Overview

Data quality is managed progressively across the **Bronze, Silver, and Gold layers**.

The Bronze layer preserves the source data without transformation. Quality gaps are identified in Bronze, addressed during Silver transformation, and verified after transformation. The same approach is applied when transforming Silver data into the Gold business model.

```text
                         SOURCE
                           │
                           ▼
                    ┌─────────────┐
                    │   BRONZE    │
                    │  Raw Data   │
                    └──────┬──────┘
                           │
                    Identify Quality
                         Gaps
                           │
                           ▼
                    ┌─────────────┐
                    │   SILVER    │
                    │ Cleanse &   │
                    │ Transform   │
                    └──────┬──────┘
                           │
                    Verify Results
                           │
                           ▼
                    ┌─────────────┐
                    │    GOLD     │
                    │ Business    │
                    │ Transform   │
                    └──────┬──────┘
                           │
                    Verify Results
                           │
                           ▼
                    BI / Analytics / ML
```

---

## 2. Bronze Layer — Quality Assessment

Bronze contains **raw source data and is not transformed**.

Quality checks are performed to identify gaps that must be addressed in Silver.

```text
BRONZE
   │
   ├── Inspect NULLs
   ├── Check duplicates
   ├── Validate identifiers
   ├── Check invalid values
   ├── Check data types
   ├── Check date values
   └── Identify source inconsistencies
          │
          ▼
     QUALITY GAPS
```

| Check               | Purpose                                |
| ------------------- | -------------------------------------- |
| NULL analysis       | Identify missing values                |
| Duplicate analysis  | Identify duplicate records             |
| Identifier checks   | Identify invalid or inconsistent keys  |
| Value checks        | Identify unexpected source values      |
| Date checks         | Identify invalid or inconsistent dates |
| Schema checks       | Understand source structure            |
| Cross-source checks | Identify CRM/ERP inconsistencies       |

**Rule:** Bronze data is preserved as received. No cleansing or business transformation is performed in this layer.

---

## 3. Silver Layer — Transformation & Verification

Silver addresses the quality gaps identified during Bronze assessment.

```text
              BRONZE QUALITY GAPS
                       │
                       ▼
                ┌──────────────┐
                │    SILVER    │
                │              │
                │ Clean        │
                │ Standardize  │
                │ Integrate    │
                │ Transform    │
                └──────┬───────┘
                       │
                       ▼
                POST-TRANSFORM
                  VALIDATION
                       │
              ┌────────┴────────┐
              ▼                 ▼
            PASS              FAIL
              │                 │
              ▼                 ▼
          Continue        Investigate /
                           Correct
```

### Silver Transformations

| Quality Gap             | Silver Treatment                  | Verification            |
| ----------------------- | --------------------------------- | ----------------------- |
| Missing values          | Apply defined defaults/fallbacks  | NULL validation         |
| Invalid identifiers     | Standardize or flag values        | Identifier validation   |
| Duplicate records       | Remove/resolve duplicates         | Duplicate check         |
| Inconsistent data types | Cast to expected types            | Data type check         |
| Invalid dates           | Standardize/handle invalid values | Date validation         |
| CRM/ERP inconsistencies | Apply integration rules           | Cross-source validation |
| Inconsistent values     | Standardize values                | Value validation        |

**Rule:** Silver data is considered valid only after the transformations have been verified.

---

## 4. Gold Layer — Business Transformation & Verification

Gold transforms verified Silver data into the final analytical model.

```text
                 SILVER
                    │
                    ▼
             Gold Transformation
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
  dim_customers dim_products fact_sales
        │           │           │
        └───────────┼───────────┘
                    ▼
             GOLD VALIDATION
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
      PASS                     FAIL
        │                       │
        ▼                       ▼
  Analytics / BI / ML      Investigate /
                            Correct
```

### Gold Transformations & Verification

| Area               | Transformation                          | Verification              |
| ------------------ | --------------------------------------- | ------------------------- |
| Customer dimension | Consolidate CRM + ERP attributes        | Attribute validation      |
| Product dimension  | Enrich products with category data      | Join validation           |
| Surrogate keys     | Generate `customer_key` / `product_key` | Uniqueness & NULL checks  |
| Active products    | Keep `prd_end_dt IS NULL`               | Active-product validation |
| Fact keys          | Resolve customer/product surrogate keys | FK validation             |
| Fact grain         | Build sales transaction grain           | Grain validation          |
| Measures           | Standardize sales, quantity, and price  | Measure validation        |
| Relationships      | Build dimension-to-fact relationships   | Referential integrity     |

---

## 5. Gold Quality Gates

```text
                 dim_customers
                       │
                       │ PK
                       ▼
                  fact_sales
                       ▲
                       │ FK
                       │
                 dim_products
```

### Required Checks

```text
dim_customers
   ├── customer_key NOT NULL
   └── customer_key UNIQUE

dim_products
   ├── product_key NOT NULL
   └── product_key UNIQUE

fact_sales
   ├── customer_key → dim_customers
   ├── product_key  → dim_products
   ├── valid dates
   └── valid measures
```

---

## 6. End-to-End Quality Process

```text
┌─────────────────────┐
│       BRONZE        │
│                     │
│ Raw / Untouched     │
│ Data Quality Check  │
└──────────┬──────────┘
           │
           │ Identify gaps
           ▼
┌─────────────────────┐
│       SILVER        │
│                     │
│ Cleanse             │
│ Standardize         │
│ Integrate           │
│ Transform           │
└──────────┬──────────┘
           │
           │ Verify
           ▼
      ┌──────────┐
      │  PASS?   │
      └────┬─────┘
           │
           ▼
┌─────────────────────┐
│        GOLD         │
│                     │
│ Business Transform  │
│ Dimensional Model   │
└──────────┬──────────┘
           │
           │ Verify
           ▼
      ┌──────────┐
      │  PASS?   │
      └────┬─────┘
           │
           ▼
     BI / Analytics / ML
```

### Quality Philosophy

> **Identify → Transform → Verify**

* **Bronze:** Identify data quality gaps without modifying source data.
* **Silver:** Correct, standardize, and integrate the identified issues, then verify the results.
* **Gold:** Apply business transformations and dimensional modeling, then verify the final analytical model.
* **Downstream:** Only verified Gold data is consumed by BI, analytics, and ML workloads.
