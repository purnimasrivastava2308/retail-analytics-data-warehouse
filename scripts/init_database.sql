```sql
/*
================================================================================
                    RETAIL ANALYTICS DATA PLATFORM
                    DATABASE INITIALIZATION SCRIPT
================================================================================

Purpose
-------
This script creates the three databases used by the Retail Analytics Data
Platform.

The project follows a layered data warehouse architecture:

    Source Data
        ↓
    Bronze Layer
        ↓
    Silver Layer
        ↓
    Gold Layer
        ↓
    Tableau / Machine Learning


Database Architecture
---------------------

1. RetailAnalyticsDW_bronze
   ------------------------
   Stores raw data as received from source systems.

   Purpose:
   - Raw data ingestion
   - Source data preservation
   - Data traceability
   - Reprocessing when required


2. RetailAnalyticsDW_silver
   ------------------------
   Stores cleaned, validated, and transformed data.

   Purpose:
   - Data cleaning
   - Data standardization
   - Duplicate handling
   - Data validation
   - Business-rule transformations


3. RetailAnalyticsDW_gold
   -----------------------
   Stores business-ready analytical data.

   Purpose:
   - Dimensional modeling
   - Analytical datasets
   - KPI development
   - Tableau reporting
   - Machine learning datasets


Data Flow
---------

    Raw Source Data
           │
           ▼
    ┌─────────────────────────┐
    │ RetailAnalyticsDW_bronze│
    │       Raw Data          │
    └────────────┬────────────┘
                 │
                 ▼
    ┌─────────────────────────┐
    │ RetailAnalyticsDW_silver│
    │    Cleaned Data         │
    └────────────┬────────────┘
                 │
                 ▼
    ┌─────────────────────────┐
    │  RetailAnalyticsDW_gold │
    │   Analytics Data        │
    └────────────┬────────────┘
                 │
            ┌────┴────┐
            ▼         ▼
        Tableau    Python / ML


Notes
-----
- This script only creates the databases.
- Table creation will be handled in separate SQL scripts.
- The database names use lowercase layer names consistently.
- The script can be executed from MySQL Workbench.
- Database/table design will be defined after analyzing the source datasets.

================================================================================
*/


-- =============================================================================
-- 1. CREATE BRONZE DATABASE
-- =============================================================================

CREATE DATABASE RetailAnalyticsDW_bronze;


-- =============================================================================
-- 2. CREATE SILVER DATABASE
-- =============================================================================

CREATE DATABASE RetailAnalyticsDW_silver;


-- =============================================================================
-- 3. CREATE GOLD DATABASE
-- =============================================================================

CREATE DATABASE RetailAnalyticsDW_gold;


-- =============================================================================
-- 4. VERIFY DATABASE CREATION
-- =============================================================================

SELECT
    SCHEMA_NAME
FROM
    INFORMATION_SCHEMA.SCHEMATA
WHERE
    SCHEMA_NAME IN (
        'RetailAnalyticsDW_bronze',
        'RetailAnalyticsDW_silver',
        'RetailAnalyticsDW_gold'
    )
ORDER BY
    SCHEMA_NAME;


/*

================================================================================
INITIALIZATION COMPLETE
================================================================================

Next steps:

1. Analyze the source datasets.
2. Design the Bronze layer tables.
3. Load raw data into the Bronze layer.
4. Clean and transform data into the Silver layer.
5. Design the Gold dimensional model.
6. Build analytics-ready datasets.
7. Connect the Gold layer to Tableau.
8. Develop Tableau dashboards and business KPIs.
9. Use Gold-layer data for future Python/ML workflows.

================================================================================
*/
```
