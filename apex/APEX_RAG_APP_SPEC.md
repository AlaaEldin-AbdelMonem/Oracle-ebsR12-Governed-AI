# 🧠 APEX RAG Application Specification
### Repository: Oracle-ebsR12-Governed-AI  
**Path:** `/apex/APEX_RAG_APP_SPEC.md`  
**Author:** Alaaeldin Abdelmonem  
**Version:** 1.0 (2025-10-27)

---

## 🏗️ 1. Application Overview
The **APEX RAG App** provides an AI-assistant interface for Oracle E-Business Suite R12.x users.  
It is launched directly from EBS menus or toolbar buttons and authenticates using the **ICX session token**, ensuring single sign-on and consistent governance.

**Key Capabilities**
| Category | Description |
|-----------|--------------|
| **User Access** | Inherits authentication & roles from EBS ICX context |
| **Chat Interface** | Conversational AI powered by `RAG_ENGINE_PKG.GENERATE_ANSWER` |
| **Governance** | Enforced redaction & audit through `AI_POLICY_UTIL` and `AI_USAGE_LOG` |
| **Document Search** | Embedded RAG retrieval for HRMS, FIN, SCM, CRM |
| **Multilingual Support** | Arabic + English (ONNX E5 Multilingual) |

---

## 🔐 2. Session Context Integration

### 2.1 Custom Package `EBS_SESSION_UTIL`
Located in `/apex/ebs_session_util_pkg.sql`  
```plsql
FUNCTION get_user_context (p_icx_token IN VARCHAR2)
  RETURN t_user_context;
Returns: USER_ID, USER_NAME, RESP_ID, RESP_NAME, LANGUAGE_CODE

2.2 Launch from EBS
Menu Function URL

perl
Copy code
http://<apex-host>/ords/f?p=100:10:::::P10_ICX_TOKEN:&ICX_TOKEN
2.3 Login Process
EBS user clicks “AI Assistant”

EBS passes ICX token → APEX

EBS_SESSION_UTIL validates token against FND_SESSION_MANAGEMENT

Context stored in APP_SESSION_CONTEXT table (session-scoped)

🧩 3. Page Structure
Page	Title	Purpose
10	AI Assistant (Chat Console)	Main RAG interface
20	Audit Dashboard	View AI usage logs & policy violations
30	Document Manager	Manual ingestion / re-chunking
40	Policy Monitor	Admin page to toggle AI policies

📄 Page 10 – AI Assistant
Regions

Region	Type	Description
Chat Window	Interactive Report	Real-time conversation history
Input Box	Text Field (P10_PROMPT)	User query or document summary request
Context Preview	Collapsible Region	Shows top RAG chunks used
Response Area	HTML Region	Displays LLM response (after redaction)

Dynamic Action

plsql
Copy code
DECLARE
  v_result CLOB;
BEGIN
  v_result := RAG_ENGINE_PKG.GENERATE_ANSWER(
                 P_USER       => :APP_USER,
                 P_MODULE     => 'HRMS',
                 P_QUERY      => :P10_PROMPT);
  :P10_RESPONSE := v_result;
END;
📊 Page 20 – Audit Dashboard
Displays records from AI_REALTIME_USAGE_V.

KPI Tiles

Total Queries Today

Redacted vs Normal

Top Modules

Average Response Time

Report Columns

Column	Source	Description
Username	AI_USAGE_LOG.USERNAME	EBS user
Module	AI_USAGE_LOG.MODULE_NAME	HRMS/FIN/SCM/CRM
Policy	CFG_AI_POLICY.POLICY_NAME	Enforced policy
Output Type	derived	Normal / Redacted

📂 Page 30 – Document Manager
Allows authorized users to upload EBS attachments to RAG.

Upload PDF/DOCX → table AI_DOCUMENTS_STAGE

Calls RAG_ENGINE_PKG.EXTRACT_TEXT + CHUNK_TEXT

Generates vectors via RAG_ENGINE_PKG.EMBED_CHUNKS

Stores metadata in AI_EMBEDDINGS

Example Trigger

plsql
Copy code
RAG_ENGINE_PKG.EMBED_CHUNKS(
    P_CHUNKS => RAG_ENGINE_PKG.CHUNK_TEXT(:P30_TEXT),
    P_DOC_ID => :P30_DOC_ID,
    P_CLASSIFICATION => :P30_CLASSIFICATION,
    P_LABEL => :P30_LABEL);
⚙️ Page 40 – Policy Monitor
Admin-only page to enable/disable policies or redaction rules.

Action	Procedure
Enable Policy	UPDATE CFG_AI_POLICY SET ENABLED_FLAG='Y'
Disable Policy	UPDATE CFG_AI_POLICY SET ENABLED_FLAG='N'
Refresh Rules	AI_POLICY_UTIL.APPLY_REDACTION test function

🧾 4. Security Model
Aspect	Mechanism
Authentication	EBS ICX token via EBS_SESSION_UTIL
Authorization	APEX roles mapped to EBS responsibilities
Data Access	Policy-filtered views and PL/SQL APIs only
Audit	Automatic entry in AI_USAGE_LOG per interaction
Compliance	ISO/NCA compatible with data classification tags

🧮 5. Integration with Governance Layer
Component	Used Object	Description
Policy Check	AI_POLICY_UTIL.IS_ACCESS_ALLOWED	Before embedding/retrieval
Redaction	AI_POLICY_UTIL.APPLY_REDACTION	Post-response masking
Audit	AI_USAGE_LOG	Logged in GENERATE_ANSWER

📈 6. UI Design Guidelines
Theme: Universal Theme 42 (light mode)

Primary Color: #C74634 (Oracle Red)

Secondary: #9FA6AD (Silver Gray)

Font: Inter / Open Sans

Icons: Lucide (“bot”, “shield”, “database”)

Layout Example (using Mermaid)

mermaid
Copy code
flowchart TD
  A[EBS Toolbar → Launch AI Assistant] --> B[APEX Login (Validate ICX)]
  B --> C[Page 10 – Chat Console]
  C --> D[RAG_ENGINE_PKG (Governed RAG Flow)]
  D --> E[Policy / Audit / Response Return]
  E --> F[User Display (APEX Response Region)]
🧭 7. Deployment Steps
Import the APEX App (f100.sql) to workspace EBS_AI_RAG.

Update Application Items: LLM_ENDPOINT, DEFAULT_POLICY_ID.

Configure Shared Component → Authentication Scheme: ICX Session Adapter.

Test launch from EBS toolbar URL.

Verify governance dashboard and audit trail records.

✅ 8. Testing Checklist
Area	Expected Outcome
ICX Session Validation	APEX accepts EBS token only
Redaction	All emails/IDs masked in response
Audit	Each chat logged in AI_USAGE_LOG
Context Retrieval	≤ 1 s for top-5 chunks
Response Latency	< 4 s (local LLM)

📎 9. Future Enhancements
Voice input integration (Arabic / English speech-to-text)

Vector index maintenance scheduler

Model feedback loop (“usefulness rating”)

APEX plug-in for AI chat widgets reusable across modules