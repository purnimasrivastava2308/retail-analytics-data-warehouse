/*
================================================================================
                    RETAIL ANALYTICS DATA PLATFORM
                    DATABASE INITIALIZATION SCRIPT
================================================================================

Purpose
-------
Initializes the databases required for the Retail Analytics Data Platform.

The project follows a layered architecture:

    Source Data
        ↓
    Bronze Layer
        ↓
    Silver Layer
        ↓
    Gold Layer
        ↓
    Tableau / Machine Learning


Database Layers
---------------

Bronze:
    RetailAnalyticsDW_bronze
    Stores raw source data with minimal transformation.

Silver:
    RetailAnalyticsDW_silver
    Stores cleaned, validated, and transformed data.

Gold:
    RetailAnalyticsDW_gold
    Stores business-ready analytical data used for Tableau reporting
    and future machine learning workflows.


Important
---------
This script intentionally drops and recreates the databases.

Running this script will permanently delete all existing tables and data
inside these three databases.

Use this script during development when a clean database initialization
is required.

================================================================================
*/


-- =============================================================================
-- 1. BRONZE DATABASE
-- =============================================================================

DROP DATABASE IF EXISTS RetailAnalyticsDW_bronze;

CREATE DATABASE RetailAnalyticsDW_bronze;


-- =============================================================================
-- 2. SILVER DATABASE
-- =============================================================================

DROP DATABASE IF EXISTS RetailAnalyticsDW_silver;

CREATE DATABASE RetailAnalyticsDW_silver;


-- =============================================================================
-- 3. GOLD DATABASE
-- =============================================================================

DROP DATABASE IF EXISTS RetailAnalyticsDW_gold;

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
