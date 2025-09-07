# Sales Data Analysis with SQL

This project showcases **advanced SQL queries** performed on a sales database to answer real business questions. The queries span across sales, regions, accounts, sales reps, and web activity. Each question is documented with its SQL query, results (in JSON/tabular form), and key insights.

---

## 1. Total Sales by Region

**Business Question:** What is the total sales amount (total\_amt\_usd) for each region?

**SQL Query:**

```sql
SELECT
    r.id AS region_id,
    r.name AS region_name,
    SUM(o.total_amt_usd) AS total_sales
FROM region AS r
FULL OUTER JOIN sales_reps AS sr ON r.id = sr.region_id
FULL OUTER JOIN accounts a ON sr.id = a.sales_rep_id
FULL OUTER JOIN orders o ON a.id = o.account_id
GROUP BY r.id, r.name
ORDER BY total_sales DESC;
```

**Results:**

| Region ID | Region Name | Total Sales (USD) |
| --------- | ----------- | ----------------- |
| 1         | Northeast   | 7,744,405.36      |
| 3         | Southeast   | 6,458,497.00      |
| 4         | West        | 5,925,122.96      |
| 2         | Midwest     | 3,013,486.51      |

**Insight:** The **Northeast** region drives the highest revenue, contributing over **\$7.7M** in sales.

---

## 2. Top 5 Customers by Total Sales

**Business Question:** Which 5 accounts have spent the most in total sales?

**SQL Query:**

```sql
SELECT
    a.name,
    COALESCE(SUM(o.total_amt_usd), 0) AS total_sales
FROM accounts AS a
LEFT JOIN orders AS o ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_sales DESC;
```

**Top 5 Results:**

| Account Name        | Total Sales (USD) |
| ------------------- | ----------------- |
| Johnson Controls    | 9,304,986.28      |
| International Paper | 9,299,464.27      |
| Chevron             | 9,275,803.41      |
| Valero Energy       | 9,213,092.11      |
| Northrop Grumman    | 9,198,512.46      |

**Insight:** **Johnson Controls** and **International Paper** lead as the top spenders, each generating over **\$9.2M** in revenue.

---

## 3. Sales Rep Performance

**Business Question:** Which sales reps generated the highest revenue, and how many accounts do they manage?

**SQL Query:**

```sql
SELECT
    sr.name,
    SUM(o.total_amt_usd) AS total_amount,
    COUNT(DISTINCT a.id) AS num_accounts
FROM sales_reps AS sr
LEFT JOIN accounts AS a ON sr.id = a.sales_rep_id
LEFT JOIN orders AS o ON a.id = o.account_id
GROUP BY sr.name
ORDER BY total_amount DESC;
```

**Top Performers:**

| Sales Rep           | Total Sales (USD) | Number of Accounts |
| ------------------- | ----------------- | ------------------ |
| Earlie Schleusner   | 1,098,137.72      | 11                 |
| Tia Amato           | 1,010,690.60      | 8                  |
| Vernita Plump       | 934,212.93        | 11                 |
| Georgianna Chisholm | 886,244.12        | 15                 |
| Arica Stoltzfus     | 810,353.34        | 10                 |

**Insight:** **Earlie Schleusner** tops the list with over **\$1.09M** in sales, while **Georgianna Chisholm** manages the most accounts (15).

---

## 4. Average Sales by Region

**Business Question:** What is the average sales amount per order across regions?

**SQL Query:**

```sql
SELECT
    r.id AS region_id,
    r.name AS region_name,
    ROUND(AVG(o.total_amt_usd), 2) AS avg_sales
FROM region AS r
FULL OUTER JOIN sales_reps AS sr ON r.id = sr.region_id
FULL OUTER JOIN accounts a ON sr.id = a.sales_rep_id
FULL OUTER JOIN orders o ON a.id = o.account_id
GROUP BY r.id, r.name
ORDER BY avg_sales DESC;
```

**Results:**

| Region ID | Region Name | Average Sales (USD) |
| --------- | ----------- | ------------------- |
| 4         | West        | 3,626.15            |
| 2         | Midwest     | 3,359.52            |
| 1         | Northeast   | 3,285.70            |
| 3         | Southeast   | 3,190.96            |

**Insight:** The **West** region has the highest average sales per order at **\$3,626.15**, suggesting fewer but larger deals.

---

## 5. Customer Web Activity

**Business Question:** How many web events does each account have? Rank them by activity.

**SQL Query:**

```sql
SELECT
    a.name AS account_name,
    COUNT(web.id) AS num_events
FROM web_events AS web
LEFT JOIN accounts AS a ON web.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC;
```

**Top Accounts by Web Events:**

| Account Name                | Number of Events |
| --------------------------- | ---------------- |
| Ecolab                      | 101              |
| Charter Communications      | 96               |
| AutoNation                  | 94               |
| Colgate-Palmolive           | 93               |
| FirstEnergy                 | 91               |
| Marathon Petroleum          | 90               |
| TJX                         | 89               |
| Core-Mark Holding           | 89               |
| EOG Resources               | 89               |
| Philip Morris International | 86               |

**Insight:** **Ecolab** leads with **101 web events**, showing the highest online engagement. High digital activity may indicate strong interest or customer loyalty.

---

# 📌 Summary

This project demonstrates how SQL can be applied to extract meaningful insights from sales data. From identifying top-performing regions and customers to analyzing sales reps and web activity, these queries provide a comprehensive view of business performance.

✅ **Key Highlights:**

* Northeast region is the revenue leader.
* Johnson Controls is the biggest customer.
* Earlie Schleusner leads sales reps in revenue.
* West region has the highest order value on average.
* Ecolab is the most digitally active customer.

---

### 🔗 Usage

* Clone this repository.
* Review queries in `Advanced SQL for Data Analysis.sql`.
* Explore insights summarized in this README.

---

### 📂 Files in Repo

* `Advanced SQL for Data Analysis.sql` → All SQL scripts.
* `README.md` → Documentation and insights (this file).
