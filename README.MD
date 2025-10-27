# 🧠 Oracle-ebsR12-Governed-AI

**AI-Enhanced Oracle E-Business Suite R12.x with Governed RAG Architecture**  
Built on **Oracle APEX 23ai + Oracle Database 23ai+** with **On-Prem LLM Integration**

<p align="center">
  <img src="Oracle-EBS-AI.png" alt="Oracle-ebsR12-Governed-AI Banner" width="100%">
</p>

<h1 align="center">Oracle-ebsR12-Governed-AI</h1>
<p align="center"><em>AI-Enhanced Oracle E-Business Suite R12.x with On-Prem RAG & Governance</em></p>

---

## 📘 Overview

**Oracle-ebsR12-Governed-AI** delivers a secure, on-premise **Retrieval-Augmented Generation (RAG)** framework for extending Oracle E-Business Suite R12.x with enterprise-grade AI capabilities.  
It integrates Oracle APEX (23ai), Oracle Database 23ai’s vector and text features, and a private LLM gateway — all within existing EBS security and governance boundaries.

**Key Idea →**

> *Bring AI to your data — without moving your data.*

---

## 🧩 Key Features

| Domain                 | Capability                         | Description                                                                  |
| ---------------------- | ---------------------------------- | ---------------------------------------------------------------------------- |
| **Integration**        | EBS ↔ APEX ↔ LLM                   | Seamless launch from EBS menus or toolbar; shared ICX session                |
| **RAG Pipeline**       | Extract → Chunk → Embed → Retrieve | Implemented fully inside Oracle DB 23ai                                      |
| **Governance**         | Redaction + Audit                  | AI policies (`CFG_AI_POLICY`), redaction rules, audit trail (`AI_USAGE_LOG`) |
| **Multilingual**       | Arabic + English                   | ONNX E5 Multilingual embedding model                                         |
| **On-Prem LLM**        | REST / PLSQL Gateway               | Secure local LLM or OCI Private Endpoint                                     |
| **Scalable**           | Modular Engine                     | Supports HRMS, FIN, SCM, CRM via shared framework                            |
| **Zero Data Movement** | Native Vector DB                   | All processing inside Oracle stack                                           |

---

## 🏗️ Architecture Snapshot

`EBS R12.x  →  Oracle APEX (23ai)  →  Oracle DB 23ai  →  On-Prem LLM`

- Shared ICX session (`ebs_session_util`)

- Text extraction (`UTL_TO_TEXT`), chunking (`UTL_TO_CHUNKS`), embedding (ONNX)

- Policy & redaction inside DB

- Audit dashboard in APEX

> 📂 See `/architecture/AI_EBS_RAG_DIAGRAM.drawio` for the full logical + governance view.

---

## 🧱 Repository Structure

`Oracle-ebsR12-Governed-AI/ │ 

 ├── README.md 

 ├── /architecture/ │  

 ├── AI_EBS_ENTERPRISE_RAG_BLUEPRINT.md │ 

 ├── AI_EBS_RAG_DIAGRAM.drawio │  

 ├── EXEC_SUMMARY_AI_EBS.pptx │

 ├── /governance/ │  

 ├── CFG_AI_GOVERNANCE.sql │  

 ├── AI_POLICY_UTIL_PKG.sql │ 

 ├── /engine/ │ 

 ├── RAG_ENGINE_PKG.sql │  

 ├── SAMPLE_USE_CASES.md │

 ├── /apex/ │ 

 ├── APEX_RAG_APP_SPEC.md │  

 ├── ebs_session_util_pkg.sql │

 ├── /business/ │  

 ├── BUSINESS_CASE_AI_EBS_RAG.md │  

 ├── EXEC_SUMMARY_ONEPAGE.md │ 

 └── LICENSE / .gitignore`

---

## ⚙️ Quick Start Guide

### 1️⃣ Prerequisites

- Oracle Database 23ai or higher

- Oracle E-Business Suite R12.x (12.1+ tested)

- Oracle APEX 23.x + ORDS configured

- On-prem or OCI Private LLM Endpoint

- PL/SQL permissions for UTL_HTTP and DBMS_VECTOR

### 2️⃣ Installation Steps

`-- Run governance schema @governance/CFG_AI_GOVERNANCE.sql  -- Deploy RAG engine @engine/RAG_ENGINE_PKG.sql  -- Install AI policy utility @governance/AI_POLICY_UTIL_PKG.sql  -- Import APEX app and configure LLM endpoint URL -- (e.g., http://llm-gateway.local/v1/chat/completions)`

### 3️⃣ Launch from EBS

Add APEX menu function:

`http://<apex-host>/ords/f?p=100:10:::::P10_ICX_TOKEN:&ICX_TOKEN`

---

## 🔐 Governance Model

- **Authentication:** EBS ICX session validation

- **Authorization:** Responsibility ↔ AI policy mapping

- **Data Classification:** `CONFIDENTIAL`, `RESTRICTED`, etc.

- **Redaction:** Regex-based rules (`CFG_REDACTION_RULE`)

- **Audit:** `AI_USAGE_LOG` + APEX dashboard

---

## 🧮 Example Use Cases

| Module | Example Query                                          | Benefit                     |
| ------ | ------------------------------------------------------ | --------------------------- |
| HRMS   | “Summarize pending vacation requests for employee Ali” | Faster HR approvals         |
| FIN    | “List overdue vendor payments > 90 days”               | Real-time finance insights  |
| SCM    | “Show top suppliers by delay rate”                     | Proactive supply management |
| CRM    | “Summarize customer feedback this month”               | Enhanced service awareness  |

---

## 📈 Benefits & ROI

| Metric                           | Target      |
| -------------------------------- | ----------- |
| Document search time reduction   | 60 – 70 %   |
| User adoption (pilot)            | ≥ 75 %      |
| Avg response latency (local LLM) | < 4 seconds |
| ROI break-even                   | ≤ 36 months |

---

## 🧭 Roadmap

1. **Pilot Phase:** HR + Finance modules

2. **Enterprise Rollout:** SCM + CRM

3. **Model Lifecycle Governance:** LLM versioning, accuracy scoring

4. **Explainability Dashboards:** Show prompt context + policy log

5. **Predictive Extensions:** Attrition + Forecast analytics

---

## 🤝 Contributing

This repository is designed for collaborative improvement within Oracle enterprise projects.  
To propose enhancements:

1. Fork the repo.

2. Create a feature branch (`feature/your-update`).

3. Submit a pull request with change summary and testing notes.

---

## 📄 License

All content © 2025 Alaaeldin Abdelmonem.  
Available for enterprise reference and demonstration under the Oracle Internal Use License (or MIT if open-sourced).
