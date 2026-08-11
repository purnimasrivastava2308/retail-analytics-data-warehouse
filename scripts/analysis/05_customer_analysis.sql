/*
================================================================================
                          CUSTOMER ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Analyzes customer revenue, orders, customer distribution, and average
order value across customer demographics and geography.

Analysis:
---------
- Revenue by gender
- Orders by country
- Profit by country
- Customers by country
- Revenue by country
- Revenue by age
- Orders by gender
- Average order value by country
- Average order value by gender
- Revenue by age group

================================================================================
*/

USE RetailAnalyticsDW_gold;


-- Revenue by gender

SELECT
    dc.gender,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.gender;


-- Orders by country

SELECT
    dc.country,
    COUNT(DISTINCT fc.order_number) AS total_orders
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.country
ORDER BY
    total_orders DESC;


-- Profit by country

SELECT
    dc.country,
    SUM((fc.price - dp.cost) * fc.quantity) AS total_profit
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dc.country
ORDER BY
    total_profit DESC;


-- Customers by country

SELECT
    dc.country,
    COUNT(DISTINCT dc.customer_id) AS total_customers
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.country
ORDER BY
    total_customers DESC;


-- Revenue by country

SELECT
    dc.country,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.country;


-- Revenue by customer age

SELECT
    TIMESTAMPDIFF(
        YEAR,
        dc.birthdate,
        CURRENT_DATE
    ) AS age,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
WHERE dc.birthdate IS NOT NULL
GROUP BY
    age
ORDER BY
    age;


-- Orders by gender

SELECT
    dc.gender,
    COUNT(DISTINCT fc.order_number) AS total_orders
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.gender
ORDER BY
    total_orders DESC;


-- Average order value by country

SELECT
    dc.country,
    ROUND(
        SUM(fc.sales_amount)
        / NULLIF(COUNT(DISTINCT fc.order_number), 0),
        2
    ) AS aov_country
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.country;


-- Average order value by gender

SELECT
    dc.gender,
    ROUND(
        SUM(fc.sales_amount)
        / NULLIF(COUNT(DISTINCT fc.order_number), 0),
        2
    ) AS aov_gender
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
GROUP BY
    dc.gender;


-- Revenue by customer age group

SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, dc.birthdate, '2014-01-28') < 25
            THEN 'Under 25'
        WHEN TIMESTAMPDIFF(YEAR, dc.birthdate, '2014-01-28')
            BETWEEN 25 AND 34
            THEN '25-34'
        WHEN TIMESTAMPDIFF(YEAR, dc.birthdate, '2014-01-28')
            BETWEEN 35 AND 44
            THEN '35-44'
        WHEN TIMESTAMPDIFF(YEAR, dc.birthdate, '2014-01-28')
            BETWEEN 45 AND 54
            THEN '45-54'
        ELSE '55+'
    END AS age_group,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_customers dc
    ON fc.customer_key = dc.customer_key
WHERE dc.birthdate IS NOT NULL
GROUP BY
    age_group
ORDER BY
    age_group;
