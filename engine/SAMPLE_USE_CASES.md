# 🧩 Sample Use Cases – Oracle EBS Governed AI (RAG Engine)

**Repository:** Oracle-ebsR12-Governed-AI  
**Author:** Alaaeldin Abdelmonem  
**Version:** 1.0 | Date: 2025-10-27  

---

## 🧠 Purpose

Demonstrate how the `RAG_ENGINE_PKG` integrates with Oracle EBS R12.x modules (HRMS, FIN, SCM, CRM) to deliver **secure, explainable AI results** governed by database policies.

Each use case below represents a *realistic EBS query*, with example flow:
EBS User → APEX Chat → RAG_ENGINE_PKG → AI_POLICY_UTIL → LLM → Redacted Response + Audit Log

yaml
Copy code

---

## 👥 HRMS Module

### 🎯 Use Case 1: Vacation Request Summary

**User Query:**  

> “Summarize pending vacation requests for employee Ali.”

**System Flow:**

1. Retrieve HR_EMP_VACATION records where STATUS='PENDING'.  
2. Generate embeddings for relevant HR notes or comments.  
3. RAG retrieves top chunks and composes summary.  
4. Redaction masks sensitive IDs or salary references.  
5. Response logged in `AI_USAGE_LOG`.

**Expected AI Output:**  

> “Ali Mohamed has 2 pending vacation requests: 5 days from 12–16 Nov, and 10 days from 5–15 Dec. Both await HR approval.”

---

### 🎯 Use Case 2: Benefits Clarification

**User Query:**  

> “Explain my current benefits and dependents.”

**System Flow:**  

- Context from HR_BENEFITS and HR_DEPENDENTS tables.  
- Redaction masks national IDs or dependent ages.  
- AI returns simplified summary.

**Expected AI Output:**  

> “You are enrolled in the Platinum Medical Plan with 3 dependents covered. Dental and vision plans are active.”

---

## 💰 FIN Module

### 🎯 Use Case 3: Overdue Invoices

**User Query:**  

> “List overdue vendor invoices greater than 90 days.”

**Flow:**  

- Vectorized context from AP_INVOICES_ALL.  
- AI ranks top suppliers by due date and amount.  
- Response summarized with totals.

**Expected AI Output:**  

> “There are 8 invoices > 90 days overdue, totaling 240K SAR. Key vendors: GulfTech (120K), Al-Tamimi Supplies (60K).”

---

### 🎯 Use Case 4: Journal Entry Review

**User Query:**  

> “Summarize journal entries for Q3 related to cost center 5100.”

**Expected AI Output:**  

> “Cost Center 5100 logged 32 entries in Q3 totaling 1.2M SAR. Major categories: Payroll Accruals (45%), Equipment Lease (30%).”

---

## 🚚 SCM Module

### 🎯 Use Case 5: Supplier Delay Analysis

**User Query:**  

> “Which suppliers have delayed deliveries this month?”

**Flow:**  

- Pull data from PO_HEADERS_ALL, PO_LINES_ALL, and RECEIPT_DATE_DIFF.  
- AI computes delays and trends.

**Expected Output:**  

> “3 suppliers reported delays >5 days: Al-Hassan Industrial (7d), GulfLogix (6d), ElectroME (5d).”

---

### 🎯 Use Case 6: Inventory Optimization

**User Query:**  

> “What items show low stock across warehouses?”

**Expected Output:**  

> “10 SKUs are below reorder level. Critical: Bearings Type-X, Motors 5HP. Warehouse JED1 < 5 units stock.”

---

## 🤝 CRM Module

### 🎯 Use Case 7: Customer Sentiment Review

**User Query:**  

> “Summarize customer feedback from October.”

**Flow:**  

- Extract unstructured text from EBS Service Requests / Notes.  
- Chunk + embed + summarize sentiment trends.

**Expected AI Output:**  

> “Customer sentiment is 82% positive. Most requests praise delivery speed, while negative feedback focuses on invoice clarity.”

---

### 🎯 Use Case 8: Lead Conversion Insight

**User Query:**  

> “Show lead-to-opportunity conversion rate for last quarter.”

**Expected AI Output:**  

> “Conversion rate for Q3 = 34%. 220 leads → 75 opportunities. Top source: Trade Expo Jeddah.”

---

## 🧾 Governance Trace (Applies to All)

| Policy             | Enforced Object       | Description                                   |
| ------------------ | --------------------- | --------------------------------------------- |
| **Access Control** | `CFG_AI_POLICY`       | Defines classification/label scope per module |
| **Redaction**      | `CFG_REDACTION_RULE`  | Masks PII (email, ID, phone)                  |
| **Audit**          | `AI_USAGE_LOG`        | Records user, prompt, model, and response     |
| **Explainability** | `AI_REALTIME_USAGE_V` | Provides transparent trace of AI outputs      |

---

## 🧮 Testing Metrics

| Area                   | Expected Target |
| ---------------------- | --------------- |
| Context retrieval time | ≤ 1 second      |
| Avg LLM response time  | < 4 seconds     |
| Redaction accuracy     | 100%            |
| Query success rate     | ≥ 95%           |

---

## 🧱 Extension Ideas

- Predictive “Next Action” suggestions (based on RAG + ML)  
- Email summarization from `FND_DOCUMENTS` table  
- Arabic–English translation summaries via bilingual model  
- APEX component for “Explain this screen” (contextual help)  

---

**End of File**
