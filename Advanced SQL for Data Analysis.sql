
-- =========================================================
-- 1. TOTAL SALES BY REGION
-- Business Question: What is the total sales amount (total_amt_usd) for each region?
-- =========================================================

-- Write SQL code here
SELECT 
	r.id AS region_id,
	r.name AS region_name,
	SUM(o.total_amt_usd) AS total_sales
FROM region AS r
FULL OUTER JOIN sales_reps AS sr 
ON r.id = sr.region_id
FULL OUTER JOIN accounts a
ON sr.id = a.sales_rep_id
FULL OUTER JOIN orders o
ON a.id = o.account_id
GROUP BY r.id, r.name
ORDER BY total_sales DESC;

-- =========================================================
-- 2. TOP 5 CUSTOMERS BY TOTAL SALES
-- Business Question: Which 5 accounts have spent the most in total_amt_usd?
-- =========================================================

-- Write SQL code here
SELECT 
	a.name,
	COALESCE(SUM(o.total_amt_usd), 0) AS total_sales
FROM accounts AS a
LEFT JOIN orders AS o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_sales DESC;

-- =========================================================
-- 3. SALES REP PERFORMANCE
-- Business Question: For each sales rep, what is the total sales amount across all their accounts?
-- =========================================================

-- Write SQL code here
SELECT 
	sr.name,
	SUM(o.total_amt_usd) AS total_amount,
	COUNT(DISTINCT a.id) AS num_accounts
FROM sales_reps AS sr
LEFT JOIN accounts AS a
ON sr.id = a.sales_rep_id
LEFT JOIN orders AS o
ON a.id = o.account_id
GROUP BY sr.name
ORDER BY total_amount DESC;

-- =========================================================
-- 4. AVERAGE ORDER VALUE BY REGION
-- Business Question: What is the average order amount per region? 
-- =========================================================

-- Write SQL code here
SELECT 
	r.id AS region_id,
	r.name AS region_name,
	ROUND(AVG(o.total_amt_usd), 2) AS avg_sales
FROM region AS r
FULL OUTER JOIN sales_reps AS sr 
ON r.id = sr.region_id
FULL OUTER JOIN accounts a
ON sr.id = a.sales_rep_id
FULL OUTER JOIN orders o
ON a.id = o.account_id
GROUP BY r.id, r.name
ORDER BY avg_sales DESC;

-- =========================================================
-- 5. CUSTOMER WEB ACTIVITY
-- Business Question: How many web events does each account have? Rank them by activity.
-- =========================================================

-- Write SQL code here
SELECT 
	a.name AS account_name,
	COUNT(web.id) AS num_events
FROM web_events AS web
LEFT JOIN accounts AS a
ON web.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC;

-- =========================================================
-- 6. TIME-BASED ANALYSIS
-- Business Question: What is the monthly trend of total sales (total_amt_usd) over time?
-- =========================================================

-- Write SQL code here
SELECT 
	DATE_TRUNC('month', occurred_at)::DATE as month,
	SUM(total_amt_usd) AS total_amt 
FROM orders
GROUP BY 1
ORDER BY 1;

SELECT 
	DATE_TRUNC('month', occurred_at)::DATE AS year
FROM orders;

SELECT 
	EXTRACT(DAY FROM occurred_at)
FROM orders;

-- =========================================================
-- 7. TOP CHANNELS FOR WEB EVENTS
-- Business Question: Which web_event channels bring the most engagement (number of events)?
-- =========================================================

-- Write SQL code here
SELECT 
	channel,
	COUNT(*) AS event_count 
FROM web_events 
GROUP BY channel
ORDER BY event_count DESC;

-- =========================================================
-- 8. HIGH-VALUE ORDERS
-- Business Question: Which orders have a total_amt_usd greater than the average order value?
-- =========================================================

-- Write SQL code here
SELECT 
	ROUND(AVG(total_amt_usd), 2)
FROM orders;

SELECT *
FROM orders
WHERE 
	total_amt_usd > 3348.02;

SELECT *
FROM orders
WHERE 
	total_amt_usd > (
					SELECT 
						ROUND(AVG(total_amt_usd), 2)
					FROM orders);

WITH avg_order AS (
	SELECT AVG(total_amt_usd) AS avg_amt
	FROM orders
)

SELECT * 
FROM orders AS o
INNER JOIN accounts AS a
ON o.account_id = a.id, avg_order
WHERE o.total_amt_usd > avg_order.avg_amt;


-- =========================================================
-- 9. SALES REP WITH HIGHEST AVERAGE ORDER VALUE
-- Business Question: Which sales rep has the highest average total order amount?
-- =========================================================

-- Write SQL code here
SELECT 
	sr.name,
	AVG(o.total_amt_usd) AS avg_amount
FROM sales_reps AS sr
LEFT JOIN accounts AS a
ON sr.id = a.sales_rep_id
LEFT JOIN orders AS o
ON a.id = o.account_id
GROUP BY sr.name
ORDER BY avg_amount DESC
LIMIT 1;

-- =========================================================
-- 10. REGION WITH MOST HIGH-VALUE CUSTOMERS
-- Business Question: Which region has the highest number of accounts spending above 50k total_amt_usd?
-- =========================================================

-- Write SQL code here
WITH account_totals AS (	
	SELECT
		a.name,
		a.sales_rep_id,
		SUM(COALESCE(o.total_amt_usd, 0)) AS total_sales
	FROM accounts AS a
	LEFT JOIN orders AS o ON a.id = o.account_id
	GROUP BY a.name, a.sales_rep_id
)
SELECT 
	r.name AS region_name,
	COUNT(*) FILTER (WHERE at.total_sales > 50000) AS high_value_accounts,
	COUNT(*) AS total_accounts
FROM region AS r 
INNER JOIN sales_reps AS sr ON r.id = sr.region_id
INNER JOIN account_totals AS at ON sr.id = at.sales_rep_id
GROUP BY r.name
ORDER BY high_value_accounts DESC;

-- =========================================================
-- 11. CTE EXAMPLE: TOP CUSTOMERS IN EACH REGION
-- Business Question: Use a CTE to find the top 3 customers by total sales in each region.
-- =========================================================

-- Write SQL code here
WITH account_totals AS (
SELECT
	a.name,
	sr.region_id,
	SUM(COALESCE(o.total_amt_usd, 0)) AS total_sales
FROM accounts a
INNER JOIN sales_reps sr ON sr.id = a.sales_rep_id
LEFT JOIN orders o ON o.account_id = a.id
GROUP BY a.name, sr.region_id
), ranked AS (
SELECT at.*,
	RANK() OVER(PARTITION BY at.region_id ORDER BY total_sales DESC) AS sales_rank
FROM account_totals AS at
)
SELECT 
	r.name AS region_name,
	ranked.name AS account_name,
	ranked.total_sales,
	ranked.sales_rank
FROM ranked
INNER JOIN region AS r ON ranked.region_id = r.id
WHERE ranked.sales_rank <= 3;
	

-- =========================================================
-- 12. WINDOW FUNCTION: RUNNING TOTAL
-- Business Question: Show a running total of sales over time for each account.
-- =========================================================

-- Write SQL code here
SELECT 
	a.name,
	o.occurred_at::DATE AS order_date,
	o.total_amt_usd, 
	SUM(o.total_amt_usd) OVER (PARTITION BY a.name ORDER BY o.occurred_at) AS running_total
FROM accounts a
INNER JOIN orders o
ON a.id = o.account_id;

-- =========================================================
-- 13. RANKING ORDERS
-- Business Question: Rank all orders by total_amt_usd from highest to lowest.
-- =========================================================

-- Write SQL code here
SELECT 
	o.id AS order_id,
	name, 
	total_amt_usd,
	RANK() OVER (ORDER BY total_amt_usd DESC) AS order_rank
FROM orders AS o
INNER JOIN accounts a ON a.id = o.account_id;

-- =========================================================
-- 14. SUBQUERY EXAMPLE
-- Business Question: Find accounts whose total sales are above the overall average sales.
-- =========================================================

-- Write SQL code here
SELECT 
	a.name,
	SUM(o.total_amt_usd) AS total_amt
FROM accounts a 
INNER JOIN orders o
ON a.id = o.account_id 
WHERE o.total_amt_usd > 
	(
	SELECT AVG(total_amt_usd)
	FROM orders
	)
GROUP BY a.name;

-- =========================================================
-- END OF ADVANCED ANALYSIS SCRIPT
-- =========================================================
