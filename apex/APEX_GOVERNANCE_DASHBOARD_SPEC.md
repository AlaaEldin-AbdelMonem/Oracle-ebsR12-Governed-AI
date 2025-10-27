# 🛡️ APEX Governance & Audit Dashboard Specification

**Repository:** Oracle-ebsR12-Governed-AI  
**Author:** Alaaeldin Abdelmonem  
**Version:** 1.0 | Date: 2025-10-27  

---

## 🎯 Purpose

Provide a single APEX page where administrators can:

- Monitor **AI activity logs** (`AI_USAGE_LOG`)
- Track **policy violations** and **redacted outputs**
- Visualize **usage metrics** by module, user, and model
- Demonstrate **compliance → governance → audit loop**

This dashboard supports ISO / NCA / internal audit standards and aligns with enterprise security mandates.

---

## 🧱 Page Design

| Page ID | Page Title                      | Role                          |
| ------- | ------------------------------- | ----------------------------- |
| **20**  | AI Governance & Audit Dashboard | AI Admin / Compliance Officer |

---

### 🧩 Page Layout

| Region Type            | Region Name                | Purpose                                                        |
| ---------------------- | -------------------------- | -------------------------------------------------------------- |
| **KPI Tiles**          | “Usage Overview”           | Show Total Queries / Redacted / Violations / Avg Response Time |
| **Interactive Report** | “AI Usage Log”             | Detailed record from `AI_REALTIME_USAGE_V`                     |
| **Bar Chart**          | “Usage by Module”          | Aggregated counts from `AI_USAGE_LOG.MODULE_NAME`              |
| **Pie Chart**          | “Output Type Distribution” | Redacted vs Normal                                             |
| **Line Chart**         | “Trends Over Time”         | Daily volume from `AI_USAGE_LOG.EXECUTED_AT`                   |
| **Detail Dialog**      | “Prompt & Response Trace”  | Display original prompt, context, and policy ID                |

---

## ⚙️ KPI Tile Queries

| Metric              | SQL                                                                          |
|:------------------- |:---------------------------------------------------------------------------- |
| Total Queries       | `SELECT COUNT(*) FROM AI_USAGE_LOG;`                                         |
| Redacted Responses  | `SELECT COUNT(*) FROM AI_USAGE_LOG WHERE REDACTED_FLAG='Y';`                 |
| Avg Response Length | `SELECT AVG(LENGTH(RESPONSE_SUMMARY)) FROM AI_USAGE_LOG;`                    |
| Policy Violations   | `SELECT COUNT(*) FROM AI_USAGE_LOG WHERE CLASSIFICATION_LEVEL='RESTRICTED';` |

---

## 📊 Charts

### 1️⃣ Usage by Module

```sql
SELECT MODULE_NAME, COUNT(*) AS TOTAL_CALLS
FROM AI_USAGE_LOG
GROUP BY MODULE_NAME;
2️⃣ Redaction vs Normal Output
sql
Copy code
SELECT CASE WHEN REDACTED_FLAG='Y' THEN 'Redacted' ELSE 'Normal' END AS TYPE,
       COUNT(*) AS CNT
FROM AI_USAGE_LOG
GROUP BY CASE WHEN REDACTED_FLAG='Y' THEN 'Redacted' ELSE 'Normal' END;
3️⃣ Daily Query Trend
sql
Copy code
SELECT TRUNC(EXECUTED_AT) AS QUERY_DATE, COUNT(*) AS TOTAL
FROM AI_USAGE_LOG
GROUP BY TRUNC(EXECUTED_AT)
ORDER BY QUERY_DATE;
🔍 Interactive Report – AI Usage Log
Source View: AI_REALTIME_USAGE_V

Column    Description
USERNAME    EBS user who triggered query
MODULE_NAME    EBS module (HRMS / FIN / SCM / CRM)
MODEL_NAME    Embedding / LLM model used
EXECUTED_AT    Timestamp of execution
OUTPUT_TYPE    Normal / Redacted
PROMPT_LEN    Input size indicator
RESPONSE_LEN    Output size indicator

Row Highlighting

Red background → RESTRICTED data classification

Yellow text → REDACTED output

🧮 Policy Violation Monitor
SQL Source

sql
Copy code
SELECT U.USERNAME, U.MODULE_NAME, U.CLASSIFICATION_LEVEL,
       U.SENSITIVITY_LABEL, P.POLICY_NAME, U.EXECUTED_AT
FROM AI_USAGE_LOG U
JOIN CFG_AI_POLICY P ON U.POLICY_ID = P.POLICY_ID
WHERE U.CLASSIFICATION_LEVEL = 'RESTRICTED';
KPI: No violations > 0 per day under normal operation.

🔐 Access Control
Role    Access Level
AIADMIN    Full view (all regions)
AIAUDITOR    Read-only interactive report
AIDEV    View own module records only

🧾 Drill-Down Dialog: Prompt & Response Trace
Field    Data Source
Prompt Text    AI_USAGE_LOG.PROMPT_TEXT
Retrieved Context    AI_USAGE_LOG.RETRIEVED_CONTEXT
Response Summary    AI_USAGE_LOG.RESPONSE_SUMMARY
Applied Policy    CFG_AI_POLICY.POLICY_NAME

Buttons: Export as JSON, Re-run Policy Test, Copy Context.

🧭 Navigation & Integration
From APEX Home: Page 10 (Chat) → Menu → “Governance Dashboard” (Page 20).

Breadcrumb: 🏠 → AI Assistant → Governance Dashboard.

Context: ICX token passed through EBS_SESSION_UTIL_PKG.

🎨 Design Guidelines
Element    Style
Theme    APEX Universal Theme 42 (Light Mode)
Primary Color    #C74634 (Oracle Red)
Accent Color    #9FA6AD (Silver Gray)
Fonts    Inter / Open Sans
Icons    Lucide – “shield”, “activity”, “database”, “bot”

📈 Performance Targets
Metric    Target
Dashboard load time    < 3 seconds
Report rows limit    1000 (default)
Chart refresh interval    60 seconds
Drill-down query time    < 1 second

🧾 Sample KPI Region SQL (Full Example)
sql
Copy code
SELECT
  (SELECT COUNT(*) FROM AI_USAGE_LOG) AS TOTAL_QUERIES,
  (SELECT COUNT(*) FROM AI_USAGE_LOG WHERE REDACTED_FLAG='Y') AS REDACTED,
  (SELECT COUNT(*) FROM AI_USAGE_LOG WHERE CLASSIFICATION_LEVEL='RESTRICTED') AS POLICY_VIOLATIONS,
  (SELECT ROUND(AVG(EXTRACT(SECOND FROM SYSTIMESTAMP - EXECUTED_AT)),2)
     FROM AI_USAGE_LOG) AS AVG_LATENCY_SEC
FROM DUAL;
End of File

 
```
