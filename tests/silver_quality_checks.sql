/*
================================================================================
                    SILVER LAYER - DATA QUALITY CHECKS
================================================================================

Project:
--------
Retail Analytics Data Warehouse


Purpose:
--------
Validates the Silver-layer data after transformation from the Bronze layer.

These checks verify that the cleansing, standardization, and transformation
rules have been applied correctly and that the resulting data meets the
expected quality requirements.


Checks:
-------
- Duplicate records
- Standardized categorical values
- Valid dates
- Valid numeric values
- Referential integrity
- Sales calculation consistency
- Data formatting


Expected Result:
----------------
Validation queries designed to identify invalid records should return no rows.

DISTINCT-value checks should contain only the expected standardized values.

================================================================================
*/


-- ============================================================================
-- CRM CUSTOMER DATA
-- ============================================================================

USE RetailAnalyticsDW_silver;


-- Check for duplicate customer IDs

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check standardized marital status values

SELECT DISTINCT
    cst_marital_status
FROM crm_cust_info;


-- Check standardized gender values

SELECT DISTINCT
    cst_gndr
FROM crm_cust_info;


-- Check for untrimmed customer names

SELECT
    cst_firstname,
    cst_lastname
FROM crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);


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


-- Check standardized product line values

SELECT DISTINCT
    prd_line
FROM crm_prd_info;


-- Check for invalid product date ranges

SELECT
    prd_id,
    prd_start_dt,
    prd_end_dt
FROM crm_prd_info
WHERE prd_end_dt IS NOT NULL
  AND prd_start_dt > prd_end_dt;


-- Check for invalid product costs

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


-- Check customer referential integrity

SELECT
    sls_ord_num,
    sls_cust_id
FROM crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM crm_cust_info
);


-- Check product referential integrity

SELECT
    sls_ord_num,
    sls_prd_key
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


-- ============================================================================
-- ERP CUSTOMER DATA
-- ============================================================================

-- Check ERP customer IDs against CRM customer keys

SELECT
    cid
FROM erp_cust_az12
WHERE cid NOT IN (
    SELECT cst_key
    FROM crm_cust_info
);


-- Check for future birth dates after transformation

SELECT
    cid,
    bdate
FROM erp_cust_az12
WHERE bdate > CURRENT_DATE;


-- Check standardized gender values

SELECT DISTINCT
    gen
FROM erp_cust_az12;


-- ============================================================================
-- ERP LOCATION DATA
-- ============================================================================

-- Check standardized country values

SELECT DISTINCT
    cntry
FROM erp_loc_a101;


-- Check for missing country values

SELECT
    cid,
    cntry
FROM erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';


-- ============================================================================
-- ERP CATEGORY DATA
-- ============================================================================

-- Check for untrimmed category values

SELECT
    id,
    cat,
    subcat
FROM erp_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat);


-- Check standardized maintenance values

SELECT DISTINCT
    maintenance
FROM erp_cat_g1v2;
