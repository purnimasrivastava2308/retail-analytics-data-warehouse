/*
================================================================================
                       CUSTOMER SEGMENTATION ANALYSIS
================================================================================

Project:
--------
Retail Analytics Data Warehouse

Purpose:
--------
Segments customers using Recency, Frequency, and Monetary-style scoring.

Scoring:
--------
- Recency
- Frequency
- Total revenue

Segments:
---------
- VIP
- High Value
- Regular
- Low Value
- At Risk
- Lost
- Cannot Conclude

================================================================================
*/

USE RetailAnalyticsDW_gold;


WITH cte_recency_score AS (

    WITH cte_recency AS (

        SELECT
            dc.customer_id,
            CONCAT(dc.first_name, ' ', dc.last_name) AS full_name,
            TIMESTAMPDIFF(
                DAY,
                MAX(fc.order_date),
                '2014-01-28'
            ) AS recency
        FROM fact_sales fc
        LEFT JOIN dim_customers dc
            ON fc.customer_key = dc.customer_key
        WHERE fc.order_date IS NOT NULL
        GROUP BY
            dc.customer_id,
            full_name
    )

    SELECT
        *,
        CASE
            WHEN PERCENT_RANK() OVER (ORDER BY recency) <= 0.2
                THEN 5
            WHEN PERCENT_RANK() OVER (ORDER BY recency) <= 0.4
                THEN 4
            WHEN PERCENT_RANK() OVER (ORDER BY recency) <= 0.6
                THEN 3
            WHEN PERCENT_RANK() OVER (ORDER BY recency) <= 0.8
                THEN 2
            ELSE 1
        END AS recency_score
    FROM cte_recency
),

cte_frequency_score AS (

    WITH cte_frequency AS (

        SELECT
            dc.customer_id,
            CONCAT(dc.first_name, ' ', dc.last_name) AS full_name,
            COUNT(DISTINCT fc.order_number) AS frequency
        FROM fact_sales fc
        LEFT JOIN dim_customers dc
            ON fc.customer_key = dc.customer_key
        GROUP BY
            dc.customer_id,
            full_name
    )

    SELECT
        customer_id,
        full_name,
        frequency,
        CASE
            WHEN PERCENT_RANK() OVER (ORDER BY frequency DESC) <= 0.2
                THEN 5
            WHEN PERCENT_RANK() OVER (ORDER BY frequency DESC) <= 0.4
                THEN 4
            WHEN PERCENT_RANK() OVER (ORDER BY frequency DESC) <= 0.6
                THEN 3
            WHEN PERCENT_RANK() OVER (ORDER BY frequency DESC) <= 0.8
                THEN 2
            ELSE 1
        END AS frequency_score
    FROM cte_frequency
),

cte_total_revenue_score AS (

    WITH cte_total_revenue AS (

        SELECT
            dc.customer_id,
            CONCAT(dc.first_name, ' ', dc.last_name) AS full_name,
            SUM(fc.sales_amount) AS total_revenue
        FROM fact_sales fc
        LEFT JOIN dim_customers dc
            ON fc.customer_key = dc.customer_key
        GROUP BY
            dc.customer_id,
            full_name
    )

    SELECT
        *,
        CASE
            WHEN PERCENT_RANK() OVER (ORDER BY total_revenue DESC) <= 0.2
                THEN 5
            WHEN PERCENT_RANK() OVER (ORDER BY total_revenue DESC) <= 0.4
                THEN 4
            WHEN PERCENT_RANK() OVER (ORDER BY total_revenue DESC) <= 0.6
                THEN 3
            WHEN PERCENT_RANK() OVER (ORDER BY total_revenue DESC) <= 0.8
                THEN 2
            ELSE 1
        END AS total_revenue_score
    FROM cte_total_revenue
)

SELECT
    rs.customer_id,
    rs.full_name,
    CASE
        WHEN recency_score >= 4
            AND frequency_score >= 4
            AND total_revenue_score >= 4
            THEN 'VIP'

        WHEN recency_score >= 4
            AND (
                frequency_score >= 4
                OR total_revenue_score >= 4
            )
            THEN 'High Value'

        WHEN recency_score >= 3
            AND frequency_score >= 3
            THEN 'Regular'

        WHEN (
            recency_score
            + frequency_score
            + total_revenue_score
        ) BETWEEN 4 AND 7
            THEN 'Low Value'

        WHEN recency_score <= 2
            AND (
                frequency_score >= 3
                OR total_revenue_score >= 3
            )
            THEN 'At Risk'

        WHEN recency_score <= 2
            AND frequency_score <= 2
            AND total_revenue_score <= 2
            THEN 'Lost'

        ELSE 'Cannot Conclude'
    END AS customer_segmentation
FROM cte_recency_score rs
INNER JOIN cte_frequency_score fs
    ON rs.customer_id = fs.customer_id
INNER JOIN cte_total_revenue_score trs
    ON rs.customer_id = trs.customer_id;
