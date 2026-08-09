/*
================================================================================
                    BRONZE LAYER - DATA QUALITY CHECKS
================================================================================

Project:
--------
Retail Analytics Data Warehouse


Purpose:
--------
Profiles and investigates raw Bronze-layer data before transformation.

These checks identify data-quality issues in the source data and help
determine the cleansing and transformation rules required for the Silver
layer.


Checks:
-------
- Duplicate records
- Whitespace and formatting issues
- Invalid and missing values
- Unexpected categorical values
- Invalid dates
- Invalid numeric values
- Referential integrity issues
- Hidden characters in source data


Note:
-----
These are diagnostic checks performed before transformation. They are used
to understand the raw data rather than modify it.

================================================================================
*/


-- ============================================================================
-- CRM CUSTOMER DATA
-- ============================================================================

USE RetailAnalyticsDW_bronze;


-- Check for duplicate customer IDs

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check for leading or trailing whitespace in customer names

SELECT
    cst_firstname,
    cst_lastname
FROM crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);


-- Check customer gender values before standardization

SELECT DISTINCT
    cst_gndr
FROM crm_cust_info;


-- Check invalid zero dates

SELECT
    cst_id,
    cst_create_date
FROM crm_cust_info
WHERE cst_create_date = '0000-00-00';


-- ============================================================================
-- CRM PRODUCT DATA
-- ============================================================================

-- Check for duplicate product IDs

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;


-- Check product line values before standardization

SELECT DISTINCT
    prd_line
FROM crm_prd_info;


-- Check invalid product date ranges

SELECT
    prd_id,
    prd_start_dt,
    prd_end_dt
FROM crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- Check invalid product costs

SELECT
    prd_id,
    prd_cost
FROM crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- ============================================================================
-- CRM SALES DATA
-- ============================================================================

-- Check for untrimmed product keys

SELECT
    sls_prd_key
FROM crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key);


-- Check for sales records referencing missing customers

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id
FROM crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM crm_cust_info
);


-- Check for sales records referencing missing products

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id
FROM crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key
    FROM crm_prd_info
);


-- Check sales calculation and numeric validity

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_sales,
    sls_quantity,
    sls_price
FROM crm_sales_details
WHERE sls_price * sls_quantity != sls_sales
   OR sls_price IS NULL
   OR sls_quantity IS NULL
   OR sls_sales IS NULL
   OR sls_price <= 0
   OR sls_quantity <= 0
   OR sls_sales <= 0;


-- Check sales order date formatting

SELECT
    sls_ord_num,
    sls_order_dt
FROM crm_sales_details
WHERE LENGTH(sls_order_dt) != 8;


-- ============================================================================
-- ERP CUSTOMER DATA
-- ============================================================================

-- Check ERP customer IDs against CRM customer keys

SELECT
    cid,
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS normalized_cid
FROM erp_cust_az12
WHERE CASE
          WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
          ELSE cid
      END NOT IN (
          SELECT cst_key
          FROM crm_cust_info
      );


-- Check future birth dates

SELECT
    cid,
    bdate
FROM erp_cust_az12
WHERE bdate > CURRENT_DATE;


-- Check gender values before standardization

SELECT DISTINCT
    gen
FROM erp_cust_az12;


-- Inspect hidden characters in gender values

SELECT DISTINCT
    gen,
    LENGTH(gen) AS value_length,
    HEX(gen) AS hex_value
FROM erp_cust_az12;


-- ============================================================================
-- ERP LOCATION DATA
-- ============================================================================

-- Check country values before standardization

SELECT DISTINCT
    cntry
FROM erp_loc_a101;


-- ============================================================================
-- ERP CATEGORY DATA
-- ============================================================================

-- Check for leading or trailing whitespace

SELECT
    id,
    cat,
    subcat
FROM erp_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat);


-- Check maintenance values before standardization

SELECT DISTINCT
    maintenance
FROM erp_cat_g1v2;
