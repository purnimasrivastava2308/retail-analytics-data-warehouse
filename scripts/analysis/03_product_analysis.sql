/*
================================================================================
                          PRODUCT PERFORMANCE ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Analyzes product-level revenue, quantity, profit, and profitability.

Analysis:
---------
- Top revenue-generating products
- Lowest revenue-generating products
- Top products by quantity
- Top products by profit
- Revenue versus profit performance
- Product profit margin
- Top 10 product revenue contribution

================================================================================
*/

USE RetailAnalyticsDW_gold;


-- Top 10 products by revenue

SELECT
    dp.product_name,
    ROUND(SUM(fc.sales_amount), 2) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.product_name
ORDER BY
    total_revenue DESC
LIMIT 10;


-- Bottom 10 products by revenue

SELECT
    dp.product_name,
    ROUND(SUM(fc.sales_amount), 2) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.product_name
ORDER BY
    total_revenue
LIMIT 10;


-- Top 10 products by quantity sold

SELECT
    dp.product_name,
    SUM(fc.quantity) AS total_quantity
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.product_name
ORDER BY
    total_quantity DESC
LIMIT 10;


-- Top 10 products by profit

SELECT
    dp.product_name,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity),
        2
    ) AS total_profit
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.product_name
ORDER BY
    total_profit DESC
LIMIT 10;


-- Product revenue and profit performance

SELECT
    dp.product_name AS high_sales_low_profit_product_name,
    ROUND(SUM(fc.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity),
        2
    ) AS total_profit,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity)
        / NULLIF(SUM(fc.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.product_name
ORDER BY
    total_revenue DESC,
    total_profit ASC;


-- Products with lowest profit margin

SELECT
    dp.product_name,
    ROUND(SUM(fc.sales_amount), 2) AS total_revenue,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity),
        2
    ) AS total_profit,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity)
        / NULLIF(SUM(fc.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.product_name
ORDER BY
    profit_margin_pct ASC;


-- Top 10 product revenue contribution

SELECT
    ROUND(
        SUM(total_revenue)
        / NULLIF(
            (SELECT SUM(sales_amount) FROM fact_sales),
            0
        ) * 100,
        2
    ) AS top_10_product_revenue_pct
FROM (
    SELECT
        dp.product_name,
        SUM(fc.sales_amount) AS total_revenue
    FROM fact_sales fc
    LEFT JOIN dim_products dp
        ON fc.product_key = dp.product_key
    GROUP BY
        dp.product_name
    ORDER BY
        total_revenue DESC
    LIMIT 10
) t;
