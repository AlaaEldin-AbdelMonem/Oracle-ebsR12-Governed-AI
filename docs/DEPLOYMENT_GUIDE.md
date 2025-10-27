# 🚀 Deployment Guide – Oracle EBS Governed AI (RAG Integration)
**Repository:** Oracle-ebsR12-Governed-AI  
**Author:** Alaaeldin Abdelmonem  
**Version:** 1.0 | Date: 2025-10-27  

---

## 🏗️ 1️⃣ Overview
This guide describes the end-to-end steps to deploy the **Governed RAG framework** on-premises or within a private OCI environment, integrating:

- Oracle E-Business Suite R12.x (HRMS / FIN / SCM / CRM)
- Oracle APEX 23ai + ORDS
- Oracle Database 23ai (Vector + AI features)
- On-Prem / Private LLM Gateway  

> **Goal:** Deliver AI capabilities inside EBS with complete governance and no external data movement.

---

## ⚙️ 2️⃣ System Requirements

| Layer | Component | Recommended Version | Notes |
|:--|:--|:--|:--|
| **Database** | Oracle DB 23ai (Enterprise Edition) | 23.4 + | Vector Search, DBMS_VECTOR_CHAIN enabled |
| **APEX + ORDS** | Oracle APEX 23.2 + ORDS 24.x | — | Hosted on same or separate node |
| **EBS** | R12.1 / R12.2 | — | HRMS, FIN, SCM, CRM modules |
| **OS** | Linux x86-64 | — | OL 8 / RHEL 8 recommended |
| **LLM Layer** | Local or OCI Private Model | — | OpenAI-compatible REST endpoint |

Hardware baseline: 8 vCPU, 64 GB RAM, 1 TB storage (typical medium enterprise).

---

## 🧩 3️⃣ Deployment Phases
### Phase 1 – Governance Schema Setup
```sql
@governance/CFG_AI_GOVERNANCE.sql
@governance/SEED_LKP_DATA.sql
Validate with:

sql
Copy code
SELECT COUNT(*) FROM LKP_CLASSIFICATION_LEVEL;
Phase 2 – RAG Engine Deployment
sql
Copy code
@engine/RAG_ENGINE_PKG.sql
Verify install:

sql
Copy code
SELECT object_name FROM user_objects WHERE object_name LIKE 'RAG_ENGINE_PKG';
Phase 3 – Session Bridge (APEX ↔ EBS)
sql
Copy code
@apex/ebs_session_util_pkg.sql
Create helper table (if desired):

sql
Copy code
CREATE GLOBAL TEMPORARY TABLE app_session_context (
  apex_session_id NUMBER,
  user_id NUMBER,
  user_name VARCHAR2(100),
  resp_id NUMBER,
  language_code VARCHAR2(10),
  created_at DATE
) ON COMMIT DELETE ROWS;
Phase 4 – APEX App Import
Launch APEX Builder → Import f100.sql.

Set Authentication Scheme = ICX Session Adapter.

Create Application Items:

P10_ICX_TOKEN

APP_USER

DEFAULT_POLICY_ID = 1

Add menu function in EBS:

perl
Copy code
http://<apex-host>/ords/f?p=100:10:::::P10_ICX_TOKEN:&ICX_TOKEN
Phase 5 – LLM Gateway Configuration
Edit RAG_ENGINE_PKG.GENERATE_ANSWER and set:

plsql
Copy code
V_API_URL := 'http://llm-gateway.local/v1/chat/completions';
Example gateway options:

Local : Ollama / Mistral / Llama3 hosted on intranet

OCI Private Endpoint : OpenAI-compatible OCI AI Service

Test endpoint:

bash
Copy code
curl -X POST http://llm-gateway.local/v1/chat/completions -d '{"model":"e5","messages":[{"role":"user","content":"ping"}]}'
Phase 6 – Audit & Governance Dashboard
Import /apex/APEX_GOVERNANCE_DASHBOARD_SPEC.md elements:

Page 20 → Interactive Report + Charts

Source views → AI_REALTIME_USAGE_V

Security → Role AIADMIN / AIAUDITOR

Phase 7 – Testing & Validation
Test	Expected Result
ICX Session Validation	APEX accepts EBS token only (valid context)
RAG Retrieval	Top 5 chunks fetched < 1 s
Redaction Check	All emails/IDs masked
Audit Logging	New record in AI_USAGE_LOG per prompt
Dashboard KPIs	Counts refresh automatically

🧾 4️⃣ Security Checklist
Area	Control
Authentication	EBS ICX Session Token (SSO)
Authorization	EBS Responsibility → APEX Role mapping
Data Classification	LKP_CLASSIFICATION_LEVEL
Redaction	CFG_REDACTION_RULE
Audit	AI_USAGE_LOG / AI_REALTIME_USAGE_V
LLM Boundary	On-Prem / Private Network Only

📈 5️⃣ Performance Tuning
Parameter	Recommendation
Vector Index	HNSW for < 100K chunks, IVF_FLAT for > 1M
DB Memory Target	≥ 16 GB SGA for vector operations
Response Caching	Use AI_RESPONSE_CACHE table
Network Latency	Deploy LLM gateway on same LAN

🧮 6️⃣ Troubleshooting
Issue	Resolution
Invalid ICX token	Verify EBS session not expired (ICX_SESSIONS)
Redaction not applied	Check CFG_REDACTION_RULE and policy mapping
No records in Audit	Ensure RAG_ENGINE_PKG.GENERATE_ANSWER commits
REST call fails	Verify LLM endpoint URL and UTL_HTTP ACL
Vector error	Confirm DBMS_VECTOR is enabled and user has privileges

🧭 7️⃣ Rollback / Uninstall
sql
Copy code
DROP VIEW AI_REALTIME_USAGE_V;
DROP TABLE AI_USAGE_LOG;
DROP TABLE CFG_AI_POLICY;
DROP TABLE CFG_REDACTION_RULE;
DROP TABLE AI_EMBEDDINGS;
DROP PACKAGE AI_POLICY_UTIL;
DROP PACKAGE RAG_ENGINE_PKG;
DROP PACKAGE ebs_session_util_pkg;
APEX App → Application Utilities → Delete Application.

🧱 8️⃣ Deliverables Checklist
Category	Artifact	Path
Governance	CFG_AI_GOVERNANCE.sql	/governance
RAG Engine	RAG_ENGINE_PKG.sql	/engine
Session Bridge	ebs_session_util_pkg.sql	/apex
APEX Spec	APEX_RAG_APP_SPEC.md	/apex
Dashboard Spec	APEX_GOVERNANCE_DASHBOARD_SPEC.md	/apex
Business Case	BUSINESS_CASE_AI_EBS_RAG.md	/business
One Pager	EXEC_SUMMARY_ONEPAGE.md	/business

✅ 9️⃣ Post-Deployment KPIs
KPI	Target Value
Avg RAG response latency	< 4 seconds
Redaction accuracy	100 %
Policy violation rate	0 %
Adoption rate (pilot)	≥ 75 % of target users
System availability	> 99.5 %

📎 10️⃣ References
Oracle Database 23ai Documentation: Vector & AI Packages

Oracle APEX 23ai Developer Guide

EBS R12 Integration Framework (Oracle Support Note IDs 730064.1 / 1905593.1)

OpenAI-Compatible API Schema (v1/chat/completions)