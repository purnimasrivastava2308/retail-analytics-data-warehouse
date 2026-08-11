/*
================================================================================
                            GROWTH ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Analyzes revenue and profit growth over time across major business dimensions.

Analysis:
---------
- Revenue YoY growth
- Profit YoY growth
- Category YoY revenue growth
- Subcategory YoY revenue growth
- Country YoY revenue growth
- Product YoY revenue growth

================================================================================
*/

USE RetailAnalyticsDW_gold;


-- Overall revenue YoY growth

SELECT
    year,
    ROUND(
        (
            revenue
            - LAG(revenue) OVER (ORDER BY year)
        )
        / NULLIF(
            LAG(revenue) OVER (ORDER BY year),
            0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM (
    SELECT
        YEAR(order_date) AS year,
        SUM(sales_amount) AS revenue
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY
        YEAR(order_date)
) t;


-- Overall profit YoY growth

SELECT
    year,
    ROUND(
        (
            profit
            - LAG(profit) OVER (ORDER BY year)
        )
        / NULLIF(
            LAG(profit) OVER (ORDER BY year),
            0
        ) * 100,
        2
    ) AS profit_growth_pct
FROM (
    SELECT
        YEAR(fc.order_date) AS year,
        SUM((fc.price - dp.cost) * fc.quantity) AS profit
    FROM fact_sales fc
    LEFT JOIN dim_products dp
        ON fc.product_key = dp.product_key
    WHERE fc.order_date IS NOT NULL
    GROUP BY
        YEAR(fc.order_date)
) t;


-- Category YoY revenue growth

SELECT
    year,
    category,
    total_revenue,
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
    ) AS yoy_category_revenue_growth_pct
FROM (
    SELECT
        YEAR(order_date) AS year,
        dp.category,
        SUM(sales_amount) AS total_revenue
    FROM fact_sales fc
    LEFT JOIN dim_products dp
        ON fc.product_key = dp.product_key
    WHERE order_date IS NOT NULL
    GROUP BY
        YEAR(order_date),
        dp.category
) t;


-- Subcategory YoY revenue growth

SELECT
    year,
    subcategory,
    total_revenue,
    ROUND(
        (
            total_revenue
            - LAG(total_revenue) OVER (
                PARTITION BY subcategory
                ORDER BY year
            )
        )
        / NULLIF(
            LAG(total_revenue) OVER (
                PARTITION BY subcategory
                ORDER BY year
            ),
            0
        ) * 100,
        2
    ) AS yoy_subcategory_revenue_growth_pct
FROM (
    SELECT
        YEAR(order_date) AS year,
        dp.subcategory,
        SUM(sales_amount) AS total_revenue
    FROM fact_sales fc
    LEFT JOIN dim_products dp
        ON fc.product_key = dp.product_key
    WHERE order_date IS NOT NULL
    GROUP BY
        YEAR(order_date),
        dp.subcategory
) t;


-- Country YoY revenue growth

SELECT
    year,
    country,
    total_revenue,
    ROUND(
        (
            total_revenue
            - LAG(total_revenue) OVER (
                PARTITION BY country
                ORDER BY year
            )
        )
        / NULLIF(
            LAG(total_revenue) OVER (
                PARTITION BY country
                ORDER BY year
            ),
            0
        ) * 100,
        2
    ) AS yoy_country_revenue_growth_pct
FROM (
    SELECT
        YEAR(order_date) AS year,
        dc.country,
        SUM(sales_amount) AS total_revenue
    FROM fact_sales fc
    LEFT JOIN dim_customers dc
        ON fc.customer_key = dc.customer_key
    WHERE order_date IS NOT NULL
    GROUP BY
        YEAR(order_date),
        dc.country
) t;


-- Product YoY revenue growth

SELECT
    year,
    product_name,
    total_revenue,
    ROUND(
        (
            total_revenue
            - LAG(total_revenue) OVER (
                PARTITION BY product_name
                ORDER BY year
            )
        )
        / NULLIF(
            LAG(total_revenue) OVER (
                PARTITION BY product_name
                ORDER BY year
            ),
            0
        ) * 100,
        2
    ) AS yoy_product_revenue_growth_pct
FROM (
    SELECT
        YEAR(order_date) AS year,
        dp.product_name,
        SUM(sales_amount) AS total_revenue
    FROM fact_sales fc
    LEFT JOIN dim_products dp
        ON fc.product_key = dp.product_key
    WHERE order_date IS NOT NULL
    GROUP BY
        YEAR(order_date),
        dp.product_name
) t;
