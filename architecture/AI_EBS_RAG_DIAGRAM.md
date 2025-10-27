🧩 1️⃣ AI_EBS_RAG_DIAGRAM.drawio

Below is the XML source for your Draw.io file.
Save this text as:
/architecture/AI_EBS_RAG_DIAGRAM.drawio
and open it at https://app.diagrams.net
.

<mxfile host="app.diagrams.net" modified="2025-10-27T10:00:00Z" agent="GPT-5" version="23.0.9">
  <diagram id="OracleEBSRAG" name="Oracle EBS Governed AI">
    <mxGraphModel dx="1600" dy="1000" grid="1" gridSize="10" guides="1" tooltips="1" connect="1">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        
        <!-- EBS -->
        <mxCell id="EBS" value="Oracle EBS R12.x (HRMS / FIN / SCM / CRM)" style="rounded=1;fillColor=#9FA6AD;strokeColor=#0D1B2A;fontSize=14;fontStyle=1;fontColor=#0D1B2A;" vertex="1" parent="1">
          <mxGeometry x="100" y="180" width="250" height="80" as="geometry"/>
        </mxCell>

        <!-- APEX -->
        <mxCell id="APEX" value="Oracle APEX 23ai / ORDS" style="rounded=1;fillColor=#C74634;strokeColor=#0D1B2A;fontSize=14;fontStyle=1;fontColor=#FFFFFF;" vertex="1" parent="1">
          <mxGeometry x="430" y="180" width="250" height="80" as="geometry"/>
        </mxCell>

        <!-- DB -->
        <mxCell id="DB23AI" value="Oracle DB 23ai (RAG Engine + Governance)" style="rounded=1;fillColor=#FFFFFF;strokeColor=#C74634;dashed=0;fontSize=14;fontStyle=1;fontColor=#0D1B2A;" vertex="1" parent="1">
          <mxGeometry x="760" y="180" width="280" height="80" as="geometry"/>
        </mxCell>

        <!-- LLM -->
        <mxCell id="LLM" value="On-Prem / OCI Private LLM" style="rounded=1;fillColor=#0D1B2A;strokeColor=#C74634;fontColor=#FFFFFF;fontSize=14;fontStyle=1;" vertex="1" parent="1">
          <mxGeometry x="1120" y="180" width="250" height="80" as="geometry"/>
        </mxCell>

        <!-- Connectors -->
        <mxCell id="EBS_APEX" style="edgeStyle=elbowEdgeStyle;rounded=1;strokeColor=#C74634;endArrow=block;" edge="1" source="EBS" target="APEX" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="APEX_DB" style="edgeStyle=elbowEdgeStyle;rounded=1;strokeColor=#C74634;endArrow=block;" edge="1" source="APEX" target="DB23AI" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="DB_LLM" style="edgeStyle=elbowEdgeStyle;rounded=1;strokeColor=#C74634;endArrow=block;" edge="1" source="DB23AI" target="LLM" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Governance Box -->
        <mxCell id="Governance" value="Governance Layer: Policy (CFG_AI_POLICY), Redaction (CFG_REDACTION_RULE), Audit (AI_USAGE_LOG)" style="shape=swimlane;fillColor=none;strokeColor=#C74634;dashed=1;fontSize=12;fontStyle=1;fontColor=#0D1B2A;" vertex="1" parent="1">
          <mxGeometry x="740" y="140" width="640" height="150" as="geometry"/>
        </mxCell>

        <!-- Labels -->
        <mxCell id="Label1" value="ICX Session / Token" style="text;strokeColor=none;fontColor=#0D1B2A;fontSize=12;fontStyle=2;" vertex="1" parent="1">
          <mxGeometry x="310" y="150" width="150" height="30" as="geometry"/>
        </mxCell>
        <mxCell id="Label2" value="REST / PL/SQL Calls" style="text;strokeColor=none;fontColor=#0D1B2A;fontSize=12;fontStyle=2;" vertex="1" parent="1">
          <mxGeometry x="600" y="150" width="150" height="30" as="geometry"/>
        </mxCell>
        <mxCell id="Label3" value="UTL_HTTP / REST API" style="text;strokeColor=none;fontColor=#0D1B2A;fontSize=12;fontStyle=2;" vertex="1" parent="1">
          <mxGeometry x="960" y="150" width="150" height="30" as="geometry"/>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>

📘 2️⃣ AI_EBS_RAG_DIAGRAM.md

(for GitHub or APEX documentation viewer with live Mermaid preview)

Save as:
/architecture/AI_EBS_RAG_DIAGRAM.md

# 🧠 Oracle EBS Governed AI — Architecture Diagram

![Oracle EBS Governed AI Banner](../Oracle-EBS-AI.png)

---

## 🔗 Logical Architecture (Mermaid)

```mermaid
flowchart LR
    A[EBS User] -->|Launch Menu / Toolbar| B[EBS R12.x (HRMS / FIN / SCM / CRM)]
    B -->|ICX Token| C[Oracle APEX 23ai / ORDS]
    C -->|REST / PL/SQL Calls| D[Oracle DB 23ai<br>RAG Engine + Governance]
    D -->|UTL_HTTP / REST API| E[On-Prem / OCI Private LLM]
    E -->|Redacted Response| F[APEX Chat UI]

🧱 Deployment Layers
graph TD
  subgraph App_Tier_1[EBS Application Tier]
    EBS[EBS Forms / OACORE]
  end

  subgraph App_Tier_2[APEX Application Tier]
    APEX[APEX 23ai + ORDS]
  end

  subgraph Data_Tier[Database Tier]
    DB23AI[Oracle DB 23ai (Vectors, Policies, Audit)]
  end

  subgraph AI_Tier[AI Layer]
    LLM[On-Prem / Private LLM]
  end

  EBS --> APEX --> DB23AI --> LLM

🛡️ Governance Overlay
flowchart TB
    Policy[CFG_AI_POLICY] --> Redaction[CFG_REDACTION_RULE]
    Redaction --> Audit[AI_USAGE_LOG]
    Audit --> Dashboard[APEX Governance Dashboard]


Color Legend

Layer	Color	Description
EBS / APEX / LLM	Oracle Red (#C74634)	Application layers
Governance	Gray (#9FA6AD)	Policy & audit layer
Data	Blue (#0D1B2A)	Database core layer

File Reference

Draw.io source → /architecture/AI_EBS_RAG_DIAGRAM.drawio

Markdown (this file) → /architecture/AI_EBS_RAG_DIAGRAM.md