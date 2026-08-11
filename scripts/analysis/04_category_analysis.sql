/*
================================================================================
                         CATEGORY ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Analyzes revenue, profit, margin, and growth across product categories
and subcategories.

Analysis:
---------
- Category revenue
- Category profit
- Category profit margin
- Category YoY revenue growth
- Subcategory revenue
- Category revenue contribution

================================================================================
*/

USE RetailAnalyticsDW_gold;


-- Revenue by category

SELECT
    dp.category,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.category
ORDER BY
    total_revenue DESC;


-- Profit by category

SELECT
    dp.category,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity),
        2
    ) AS total_profit
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.category
ORDER BY
    total_profit DESC;


-- Profit margin by category

SELECT
    dp.category,
    ROUND(
        SUM((fc.price - dp.cost) * fc.quantity)
        / NULLIF(SUM(fc.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.category
ORDER BY
    profit_margin_pct DESC;


-- Category YoY revenue growth

SELECT
    year,
    category,
    ROUND(
        (
            total_revenue
            - LAG(total_revenue) OVER (
                PARTITION BY category
                ORDER BY year
            )
        )
        / NULLIF(
            LAG(total_revenue) OVER (
                PARTITION BY category
                ORDER BY year
            ),
            0
        ) * 100,
        2
    ) AS yoy_revenue_growth
FROM (
    SELECT
        YEAR(fc.order_date) AS year,
        dp.category,
        SUM(fc.sales_amount) AS total_revenue
    FROM fact_sales fc
    LEFT JOIN dim_products dp
        ON fc.product_key = dp.product_key
    WHERE fc.order_date IS NOT NULL
    GROUP BY
        YEAR(fc.order_date),
        dp.category
) t;


-- Revenue by subcategory

SELECT
    dp.subcategory,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.subcategory
ORDER BY
    total_revenue DESC;


-- Lowest revenue subcategories

SELECT
    dp.subcategory,
    SUM(fc.sales_amount) AS total_revenue
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.subcategory
ORDER BY
    total_revenue;


-- Category revenue contribution

SELECT
    dp.category,
    ROUND(
        SUM(fc.sales_amount)
        / NULLIF(
            (SELECT SUM(sales_amount) FROM fact_sales),
            0
        ) * 100,
        2
    ) AS category_revenue_pct
FROM fact_sales fc
LEFT JOIN dim_products dp
    ON fc.product_key = dp.product_key
GROUP BY
    dp.category
ORDER BY
    category_revenue_pct DESC;
