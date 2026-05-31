 
# Insurance ELT Pipeline — MongoDB · Airbyte · Snowflake · dbt · Power BI

![Pipeline Status](https://img.shields.io/badge/Pipeline-Complete-brightgreen)
![MongoDB](https://img.shields.io/badge/MongoDB-Source%20Database-47A248?logo=mongodb)
![Airbyte](https://img.shields.io/badge/Airbyte-ELT%20Connector-615EFF?logo=airbyte)
![Snowflake](https://img.shields.io/badge/Snowflake-Cloud%20Warehouse-29B5E8?logo=snowflake)
![dbt](https://img.shields.io/badge/dbt-Transformations-FF694B?logo=dbt)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi)


---

## 📌 Project Overview

An **end-to-end ELT (Extract, Load, Transform) data pipeline** that ingests synthetic insurance records from a **MongoDB Atlas** operational database, loads raw data into **Snowflake** via **Airbyte**, applies two-layer SQL transformations using **dbt**, and delivers business-ready insights through a live **Power BI** dashboard.

This project demonstrates a production-style modern data stack, covering the full data engineering lifecycle — from source ingestion to analytics reporting — using industry-standard cloud-native tools.

---

## 🏗️ Architecture

The diagram below shows the full pipeline flow — from Python data generation through MongoDB, Airbyte ingestion, Snowflake warehousing, dbt transformation, and Power BI reporting.


<img width="2540" height="924" alt="image" src="https://github.com/user-attachments/assets/05782727-93ce-4bdb-a9ca-5fe29d7be877" />



```

---

Python (Faker)  →  MongoDB Atlas  →  Airbyte  →  Snowflake  →  dbt  →  Power BI
   (Generate)       (Source DB)     (ELT)       (Warehouse)  (Transform) (Dashboard)
                                                  │
                                         ┌────────┴─────────┐
                                         │  PUBLIC schema   │  ← Raw Airbyte data
                                         │  ANALYTICS schema│  ← dbt mart models
                                         └──────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Data Generation** | Python 3.11 + Faker + PyMongo | Generate synthetic insurance records |
| **Source Database** | MongoDB Atlas (AWS) | Operational NoSQL document store |
| **Ingestion** | Airbyte | No-code ELT connector: MongoDB → Snowflake |
| **Data Warehouse** | Snowflake (AWS ca-central-1) | Cloud-native columnar warehouse |
| **Transformation** | dbt-snowflake 1.11.5 | SQL-based staging and mart models |
| **Business Intelligence** | Power BI Desktop | Live dashboard connected to Snowflake |
| **Version Control** | Git + GitHub | Source code management |

---

## 📂 Repository Structure

```
ETL_Snowflake_DBT_pipeline/
│
├── data-generator/
│   └── simulator.py              # Python script to generate & load data into MongoDB
│
├── ins_dbt/                      # dbt project root
│   ├── dbt_project.yml           # dbt project configuration
│   ├── models/
│   │   ├── sources.yml           # Source definitions (Snowflake raw tables)
│   │   ├── staging/
│   │   │   ├── stg_customers.sql # Staging model: clean raw customer data
│   │   │   └── stg_claims.sql    # Staging model: clean raw claims data
│   │   └── marts/
│   │       └── fct_claims.sql    # Fact model: joined & aggregated claims data
│   ├── tests/                    # dbt data quality tests
│   ├── macros/                   # Custom dbt macros
│   └── target/                   # dbt compiled artifacts (git-ignored)
│
├── dashboard/
│   └── insurance_dashboard.pbix  # Power BI dashboard file
│
├── docs/
│   └── architecture_diagram.png  # Pipeline architecture diagram
│
├── .gitignore
└── README.md
```

---


---

## 🚀 How to Run This Project

### Prerequisites
- Python 3.13+
- MongoDB Atlas account (free tier works)
- Snowflake account (free trial works)
- Airbyte Cloud or local Airbyte (Docker)
- dbt-snowflake installed
- Power BI Desktop (free)

---

### Step 1 — Clone the Repository
```bash
git clone https://github.com/LindaMADU/ETL_Snowflake_DBT_pipeline.git
cd ETL_Snowflake_DBT_pipeline
```

### Step 2 — Install Python Dependencies
```bash
pip install faker pymongo pandas
```

### Step 3 — Generate & Load Data into MongoDB
Update the MongoDB connection string in `data-generator/simulator.py`:
```python
client = pymongo.MongoClient("mongodb+srv://<username>:<password>@<cluster>.mongodb.net/")
```
Then run:
```bash
python data-generator/simulator.py
```
This generates synthetic CUSTOMERS and CLAIMS records and loads them into MongoDB Atlas.

### Step 4 — Set Up Snowflake
Run the following in your Snowflake worksheet:
```sql
CREATE DATABASE INSURANCE;
CREATE SCHEMA INSURANCE.PUBLIC;
CREATE SCHEMA INSURANCE.ANALYTICS;

CREATE WAREHOUSE COMPUTE_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 120
  AUTO_RESUME    = TRUE;
```

### Step 5 — Configure Airbyte Connection
In Airbyte (local or cloud):
- **Source** → MongoDB Atlas → point to your `insurance` database
- **Destination** → Snowflake:

| Field | Value |
|---|---|
| Host | `<account>.snowflakecomputing.com` |
| Database | `INSURANCE` |
| Schema | `PUBLIC` |
| Warehouse | `COMPUTE_WH` |
| Role | `ACCOUNTADMIN` |

- Select streams: `customers`, `claims`
- Run **Sync Now**

### Step 6 — Configure dbt
Create or update `~/.dbt/profiles.yml`:
```yaml
ins_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your-snowflake-account>
      user: <your-username>
      password: <your-password>
      role: ACCOUNTADMIN
      database: INSURANCE
      warehouse: COMPUTE_WH
      schema: ANALYTICS
      threads: 1
      authenticator: snowflake
```

### Step 7 — Run dbt Models
```bash
cd ins_dbt

# Test connection
dbt debug

# Run all models
dbt run

# Run data quality tests
dbt test

# Generate & serve documentation
dbt docs generate
dbt docs serve
```

Expected output:
```
1 of 3 START sql view model ANALYTICS.stg_customers .............. [RUN]
1 of 3 OK created sql view model ANALYTICS.stg_customers ......... [OK]
2 of 3 START sql view model ANALYTICS.stg_claims ................. [RUN]
2 of 3 OK created sql view model ANALYTICS.stg_claims ............ [OK]
3 of 3 START sql table model ANALYTICS.fct_claims ................ [RUN]
3 of 3 OK created sql table model ANALYTICS.fct_claims ........... [OK]
```

### Step 8 — Connect Power BI
1. Open Power BI Desktop
2. **Get Data** → **Snowflake**
3. Server: `<account>.snowflakecomputing.com`
4. Warehouse: `COMPUTE_WH`
5. Database: `INSURANCE` → Schema: `ANALYTICS`
6. Select CLAIMS_SUMMARY → Load
7. Build your dashboard visuals

---

## 📈 Power BI Dashboard

The dashboard connects live to the Snowflake `ANALYTICS` schema and visualises:

| Visual | Fields | Insight |
|---|---|---|
| Line chart | sum of claims_count by Month |
| Bar chart | Sum of Claims_count by claim_type |
| Card KPIs | Sum of Total Amount, Sum of claims_count Avg claim | Sum of Fraud_count |


---
<img width="1357" height="1006" alt="image" src="https://github.com/user-attachments/assets/5bdc1327-4867-4ab4-9e24-4b9ea9c39225" />

---

## 🧪 dbt Tests

The following data quality tests are configured in `models/sources.yml`:

```yaml
- name: stg_customers
  columns:
    - name: customer_id
      tests:
        - unique
        - not_null
    - name: policy_type
      tests:
        - accepted_values:
            values: ['Auto', 'Home', 'Life', 'Health']

- name: stg_claims
  columns:
    - name: claim_id
      tests:
        - unique
        - not_null
    - name: claim_amount
      tests:
        - not_null
```

Run tests:
```bash
dbt test
```

---



---

> **Note:** All data in this project is synthetically generated using the Python Faker library. No real customer or claims data is used. 
