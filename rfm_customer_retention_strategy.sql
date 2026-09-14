============================================================
-- Online Retail — RFM Customer Retention Strategy
-- Database: online_retail (PostgreSQL)
-- Tables: customers, transactions
-- Period: Dec 2010 - Dec 2011
============================================================


-- Q1: Which segments drive the most revenue?
SELECT
    segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND((SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER ())::numeric, 1) AS revenue_share_pct,
    ROUND(AVG(monetary)::numeric, 2) AS avg_revenue_per_customer
FROM customers
GROUP BY segment
ORDER BY total_revenue DESC;   


-- Q2: Customer distribution across segments
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 1) AS pct_of_total
FROM customers
GROUP BY segment
ORDER BY customers DESC;


-- Q3: Churn rate and revenue at risk by segment
SELECT
    segment,
    COUNT(*) AS total_customers,
    SUM(churned) AS churned_customers,
    ROUND(SUM(churned) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(SUM(monetary)::numeric, 2) AS total_revenue,
    ROUND(SUM(CASE WHEN churned = 1 THEN monetary ELSE 0 END)::numeric, 2) AS revenue_at_risk
FROM customers
GROUP BY segment
ORDER BY revenue_at_risk DESC;


-- Q4: Top 10 high-value at-risk customers
SELECT
	customer_id, 
	segment, 
	recency, 
	frequency, 
	ROUND(monetary::numeric, 2) AS monetary
FROM customers
WHERE churned = 1
  AND monetary >= (
      SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY monetary)
      FROM customers
  )
ORDER BY monetary DESC
LIMIT 10;


-- Q5: Top 3 products by revenue in each segment
WITH product_revenue AS (
    SELECT
        c.segment,
        t.product_name,
        SUM(t.revenue) AS product_revenue,
        ROW_NUMBER() OVER (PARTITION BY c.segment ORDER BY SUM(t.revenue) DESC) AS rank
    FROM customers c
    JOIN transactions t ON c.customer_id = t.customer_id
    GROUP BY c.segment, t.product_name
)
SELECT segment, product_name, ROUND(product_revenue::numeric, 2) AS product_revenue, rank
FROM product_revenue
WHERE rank <= 3
ORDER BY segment, rank;


-- Q6: Average days between purchases per segment
SELECT
    c.segment,
    ROUND(AVG(t.gap_days)::numeric, 1) AS avg_days_between_purchases
FROM customers c
JOIN (
    SELECT
        customer_id,
        invoice_date::date - LAG(invoice_date::date) OVER (
            PARTITION BY customer_id ORDER BY invoice_date
        ) AS gap_days
    FROM transactions
) t ON c.customer_id = t.customer_id
WHERE t.gap_days IS NOT NULL
GROUP BY c.segment
ORDER BY avg_days_between_purchases ASC;      


-- Q7: Monthly revenue trend over Dec 2010 – Dec 2011
SELECT
    DATE_TRUNC('month', invoice_date) AS month,
    COUNT(DISTINCT customer_id) AS active_customers,
    ROUND(SUM(revenue)::numeric, 2) AS monthly_revenue
FROM transactions
WHERE invoice_date >= '2010-12-01'
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month;   