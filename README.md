# 📦 Supply Chain Lakehouse: Demand Forecasting & Late-Delivery Risk

End-to-end data platform on **Databricks + dbt** covering two supply chain
domains: **demand forecasting** (M5 Walmart) and **delivery-risk prediction**
(Olist marketplace). Built on a **medallion architecture** with tested
transformations, leakage-safe ML, MLflow tracking, and CI/CD.

![CI](https://github.com/<you>/supply-chain-lakehouse/actions/workflows/ci.yml/badge.svg)

## 🎯 Business Problems
1. **Demand:** forecast monthly unit sales per product and store.
2. **Fulfillment:** predict which orders will arrive late at the moment of
   approval, so ops can act early.
Plus: ABC-XYZ inventory segmentation, seller scorecards, logistics cycle times.

## 🏗️ Architecture
![Architecture](docs/architecture.png)

| Layer | Description |
|-------|-------------|
| Bronze | Raw M5 and Olist files as append-only Delta tables |
| Silver | Typed, deduplicated, unpivoted, joined (dbt staging/intermediate) |
| Gold | Star schemas, feature tables, marts, model scores |

> The two datasets come from unrelated businesses, so they share platform
> patterns and `dim_date` but are not joined.

## 🧰 Tech Stack
Databricks (Unity Catalog, Delta Lake, Workflows, AI/BI) · dbt-databricks ·
Python · LightGBM · MLflow · SHAP · GitHub Actions · SQLFluff · pytest

## 📊 Data
- **M5 Forecasting (Walmart):** daily sales, prices, events (CA stores)
- **Olist Brazilian E-Commerce:** orders, logistics timestamps, reviews
- Both from Kaggle (not included in repo, see `ingestion/download_data.sh`)

## ✅ Engineering Practices
- XX dbt tests across XX models, with contracts and documentation
- Incremental models, seeds, reusable macros (unpivot, haversine)
- Point-in-time seller features to prevent leakage
- CI on every PR: lint → dbt build → unit tests

## 🤖 Results
| Demand model | WAPE | RMSSE | Bias |
|---|---|---|---|
| Seasonal naive | _fill in_ | _fill in_ | _fill in_ |
| LightGBM | _fill in_ | _fill in_ | _fill in_ |

| Late-delivery model | PR-AUC | Precision@Top-200 | Recall@fixed precision |
|---|---|---|---|
| Logistic regression | _fill in_ | _fill in_ | _fill in_ |
| LightGBM | _fill in_ | _fill in_ | _fill in_ |
