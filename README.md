# RFM Customer Retention Strategy

## Business Problem

A UK-based online retailer sells household and office products. Between Dec 2010 and Dec 2011, management observed declining repeat purchase rates and wanted to shift from a one-size-fits-all marketing approach to segmented, data-driven retention.

This project answers two questions:

1. Which customer segments drive the most revenue?
2. Which segments carry the highest churn risk (90+ days without a purchase)?

## Deliverables

| # | Deliverable | File |
|---|---|---|
| 1 | Data preparation & modelling (Python) | `rfm_customer_retention_strategy.ipynb` |
| 2 | Data analysis (SQL) | `rfm_customer_retention_strategy.sql` |
| 3 | Visualization & insights (Power BI) | `RFM Customer Retention Strategy.pbix` |
| 4 | Project report | `RFM Customer Retention Strategy Report.pdf` |
| 5 | Presentation | `RFM Customer Retention Strategy.pptx` |
| 6 | GitHub repository | `rfm_customer_retention_strategy` |

## Dataset

- **Source:** [UK Online Retail (UCI Repository)](https://archive.ics.uci.edu/dataset/352/online+retail)
- **Size:** 541,909 transactions → 397,884 after cleaning
- **Period:** Dec 2010 – Dec 2011
- **Customers:** 4,338 (after removing null CustomerIDs)

## Methodology

- **Data Cleaning (Python):** Removed cancellations, invalid prices/quantities, null customers. Parsed dates, created revenue column.
- **RFM Scoring:** Computed Recency, Frequency, Monetary per customer. Applied `pd.qcut()` with 5 bins (quintiles) after `rank(method='first')` to handle ties.
- **Segmentation:** Priority-ordered decision tree (Recency → Frequency → Monetary). First match wins. 7 segments, default = Low Priority.
- **Churn Definition:** `churned = 1` if recency ≥ 90 days.
- **SQL Analysis (PostgreSQL):** 7 business queries answering revenue, churn, product, and trend questions.
- **Dashboard (Power BI):** Two-page interactive dashboard (Overview + Churn & Risk).

## Segments

| Segment | Customers | Criteria |
|---|---|---|
| Champions | 947 | R≥4, F≥4, M≥4 |
| Loyal Customers | 454 | R≥3, F≥4, M≥3 |
| Potential Loyalists | 190 | R≥4, F=3, M≥3 |
| Can't Lose Them | 173 | R≤2, F≥4, M≥4 |
| At Risk | 207 | R=2, F≥3, M≥3 |
| Hibernating | 106 | R≤2, M≥4 |
| Low Priority | 2,261 | All remaining |

## Key Findings

- 32.3% of customers (Champions + Loyal) drive 74.9% of revenue (£6.67M of £8.91M)
- £1,035,269 in revenue at risk across all segments (customers inactive 90+ days)
- Can't Lose Them: 173 customers, 93% churned, £398K lost
- At Risk: 207 customers, 68% churned, £241K at risk
- 52.1% of customers are Low Priority → focus spend on top 48%
- Oct–Nov seasonal spike may misclassify seasonal buyers as churned

## Recommendations

| # | Segment | Action | Priority |
|---|---|---|---|
| 1 | Champions | Loyalty tier / early access | P2 – Protect |
| 2 | Loyal Customers | Cross-sell complementary categories | P2 – Protect |
| 3 | Potential Loyalists | Bundle offer to increase frequency | P3 – Nurture |
| 4 | Can't Lose Them | Personalised win-back with exclusive offer | **P1 – Act now** |
| 5 | At Risk | Automated day-60 "we miss you" nudge | **P1 – Act now** |
| 6 | Hibernating | Low-cost email with high-value product recommendation | P3 – Nurture |
| 7 | Low Priority | Suppress from campaigns | P4 – Exclude |

- **P1 – Act now:** High revenue at risk.
- **P2 – Protect:** High revenue, stable.
- **P3 – Nurture:** Moderate potential.
- **P4 – Exclude:** Not worth the spend.

## Tech Stack

- **Python:** Pandas, Matplotlib
- **Database:** PostgreSQL
- **Visualization:** Power BI

## How to Run

1. Clone repo: `git clone https://github.com/keertigurung/rfm-customer-retention-strategy.git`
2. Download dataset: [UCI Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail)
3. Install dependencies: `pip install pandas matplotlib psycopg2-binary sqlalchemy`
4. Run notebook: `jupyter notebook rfm_customer_retention_strategy.ipynb`
5. Run SQL: Open `rfm_customer_retention_strategy.sql` in `psql` or DBeaver (requires PostgreSQL with `customers` and `transactions` tables)
6. Open dashboard: `RFM Customer Retention Strategy.pbix` in Power BI Desktop

## Limitations

- 90-day churn threshold is a business assumption, not data-driven
- Data covers only 12-month period; Oct–Nov spike may misclassify seasonal buyers as churned
- No external factors (marketing spend, economic conditions) considered
- Segment boundaries are rule-based; adjacent quintiles may produce similar profiles   
