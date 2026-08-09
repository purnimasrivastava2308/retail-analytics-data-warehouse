/*
===============================================================================
Gold Layer - Data Quality Checks
===============================================================================
Purpose:
    Validate the integrity, completeness, consistency, and business validity
    of the Gold dimensional model.

Tables:
    - dim_customers
    - dim_products
    - fact_sales

Important:
    This script is read-only. It identifies quality issues but does not
    modify Gold data.

Expected Result:
    Each check should return 0 invalid records unless otherwise specified.
===============================================================================
*/

USE retailanalyticsdw_gold;


/*=============================================================================
1. DIM_CUSTOMERS
=============================================================================*/

-- 1.1 Primary key: NULL check
SELECT COUNT(*) AS null_customer_keys
FROM dim_customers
WHERE customer_key IS NULL;


-- 1.2 Primary key: duplicate check
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- 1.3 Customer ID: NULL check
SELECT COUNT(*) AS null_customer_ids
FROM dim_customers
WHERE customer_id IS NULL;


/*=============================================================================
2. DIM_PRODUCTS
=============================================================================*/

-- 2.1 Primary key: NULL check
SELECT COUNT(*) AS null_product_keys
FROM dim_products
WHERE product_key IS NULL;


-- 2.2 Primary key: duplicate check
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- 2.3 Product number: NULL check
SELECT COUNT(*) AS null_product_numbers
FROM dim_products
WHERE product_number IS NULL;


-- 2.4 Product number: duplicate check
SELECT
    product_number,
    COUNT(*) AS duplicate_count
FROM dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


/*=============================================================================
3. FACT_SALES - NULL & KEY CHECKS
=============================================================================*/

-- 3.1 Foreign key NULL check
SELECT
    SUM(customer_key IS NULL) AS null_customer_keys,
    SUM(product_key IS NULL) AS null_product_keys
FROM fact_sales;


-- 3.2 Customer foreign key validation
SELECT COUNT(*) AS invalid_customer_keys
FROM fact_sales f
LEFT JOIN dim_customers c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


-- 3.3 Product foreign key validation
SELECT COUNT(*) AS invalid_product_keys
FROM fact_sales f
LEFT JOIN dim_products p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


/*=============================================================================
4. FACT_SALES - MEASURE VALIDATION
=============================================================================*/

-- 4.1 Invalid quantity
SELECT COUNT(*) AS invalid_quantity
FROM fact_sales
WHERE quantity IS NULL
   OR quantity <= 0;


-- 4.2 Invalid price
SELECT COUNT(*) AS invalid_price
FROM fact_sales
WHERE price IS NULL
   OR price < 0;


-- 4.3 Invalid sales amount
SELECT COUNT(*) AS invalid_sales_amount
FROM fact_sales
WHERE sales_amount IS NULL
   OR sales_amount < 0;


/*=============================================================================
5. FACT_SALES - DATE VALIDATION
=============================================================================*/

-- 5.1 Missing order date
SELECT COUNT(*) AS null_order_dates
FROM fact_sales
WHERE order_date IS NULL;


-- 5.2 Invalid date sequence
SELECT COUNT(*) AS invalid_date_sequence
FROM fact_sales
WHERE shipping_date < order_date
   OR due_date < order_date;


/*=============================================================================
6. PRODUCT BUSINESS RULE
=============================================================================*/

-- 6.1 Gold should contain only active products
--     Source rule: prd_end_dt IS NULL
--     This check validates the resulting Gold dataset indirectly by ensuring
--     the expected active-product population is used during transformation.

SELECT COUNT(*) AS product_count
FROM dim_products;


/*=============================================================================
7. FACT GRAIN CHECK
=============================================================================*/

-- 7.1 Identify potentially duplicated sales records.
--     Review results according to the defined source transaction grain.

SELECT
    order_number,
    customer_key,
    product_key,
    COUNT(*) AS record_count
FROM fact_sales
GROUP BY
    order_number,
    customer_key,
    product_key
HAVING COUNT(*) > 1;
