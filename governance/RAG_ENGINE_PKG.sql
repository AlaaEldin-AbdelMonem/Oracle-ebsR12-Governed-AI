--------------------------------------------------------------------------------
-- File: RAG_ENGINE_PKG.sql
-- Project: Oracle-ebsR12-Governed-AI
-- Purpose: Retrieval-Augmented Generation engine inside Oracle DB 23ai
-- Author : Alaaeldin Abdelmonem
-- Version: 1.1 (2025-10-27)
--------------------------------------------------------------------------------
-- Dependencies:
--   • DBMS_VECTOR, DBMS_VECTOR_CHAIN (Oracle 23ai)
--   • AI_POLICY_UTIL from /governance/
--   • AI_USAGE_LOG (audit)
--   • AI_EMBEDDINGS (vector storage table, see below)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SECTION 1. SUPPORTING TABLE (VECTOR STORAGE)
--------------------------------------------------------------------------------
CREATE TABLE AI_EMBEDDINGS (
    DOC_ID              NUMBER,
    CHUNK_NO            NUMBER,
    CHUNK_TEXT          CLOB,
    VECTOR_EMB          VECTOR,
    CLASSIFICATION_LEVEL VARCHAR2(20),
    SENSITIVITY_LABEL    VARCHAR2(20),
    CREATED_AT          TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT PK_AI_EMBEDDINGS PRIMARY KEY (DOC_ID, CHUNK_NO)
);

CREATE INDEX AI_EMBEDDINGS_VEC_IDX
ON AI_EMBEDDINGS (VECTOR_EMB)
INDEXTYPE IS VECTOR_IDX;

--------------------------------------------------------------------------------
-- SECTION 2. PACKAGE SPECIFICATION
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE RAG_ENGINE_PKG AS

  -- Extract textual content from a BLOB (PDF/DOCX)
  FUNCTION EXTRACT_TEXT (
      P_BLOB       IN BLOB,
      P_MIME_TYPE  IN VARCHAR2
  ) RETURN CLOB;

  -- Split text into overlapping semantic chunks
  FUNCTION CHUNK_TEXT (
      P_TEXT       IN CLOB,
      P_MAX_WORDS  IN NUMBER   DEFAULT 128,
      P_OVERLAP    IN NUMBER   DEFAULT 10
  ) RETURN DBMS_VECTOR.VECTOR_TEXT_TAB;

  -- Embed and store text chunks
  PROCEDURE EMBED_CHUNKS (
      P_CHUNKS        IN DBMS_VECTOR.VECTOR_TEXT_TAB,
      P_MODEL_NAME    IN VARCHAR2 DEFAULT 'E5_MULTILINGUAL',
      P_DOC_ID        IN NUMBER,
      P_CLASSIFICATION IN VARCHAR2 DEFAULT 'INTERNAL',
      P_LABEL          IN VARCHAR2 DEFAULT 'GEN'
  );

  -- Retrieve relevant context for a query
  FUNCTION RETRIEVE_CONTEXT (
      P_QUERY     IN CLOB,
      P_TOP_K     IN NUMBER DEFAULT 5,
      P_POLICY_ID IN NUMBER DEFAULT 1
  ) RETURN CLOB;

  -- Full RAG call: retrieve + call LLM + apply redaction + audit
  FUNCTION GENERATE_ANSWER (
      P_USER       IN VARCHAR2,
      P_MODULE     IN VARCHAR2,
      P_QUERY      IN CLOB,
      P_MODEL_NAME IN VARCHAR2 DEFAULT 'E5_MULTILINGUAL',
      P_POLICY_ID  IN NUMBER DEFAULT 1
  ) RETURN CLOB;

END RAG_ENGINE_PKG;
/

--------------------------------------------------------------------------------
-- SECTION 3. PACKAGE BODY
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY RAG_ENGINE_PKG AS

  ------------------------------------------------------------------------------
  FUNCTION EXTRACT_TEXT (
      P_BLOB       IN BLOB,
      P_MIME_TYPE  IN VARCHAR2
  ) RETURN CLOB IS
    V_TEXT CLOB;
  BEGIN
    V_TEXT := DBMS_VECTOR_CHAIN.UTL_TO_TEXT(
                blob_content  => P_BLOB,
                mime_type     => P_MIME_TYPE,
                language_hint => 'auto');
    RETURN V_TEXT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Error extracting text: '||SQLERRM;
  END EXTRACT_TEXT;

  ------------------------------------------------------------------------------
  FUNCTION CHUNK_TEXT (
      P_TEXT       IN CLOB,
      P_MAX_WORDS  IN NUMBER   DEFAULT 128,
      P_OVERLAP    IN NUMBER   DEFAULT 10
  ) RETURN DBMS_VECTOR.VECTOR_TEXT_TAB IS
    V_CHUNKS DBMS_VECTOR.VECTOR_TEXT_TAB;
  BEGIN
    SELECT COLUMN_VALUE
      BULK COLLECT INTO V_CHUNKS
      FROM TABLE(DBMS_VECTOR.UTL_TO_CHUNKS(
        P_TEXT,
        JSON_OBJECT(
          'by' VALUE 'words',
          'max' VALUE P_MAX_WORDS,
          'overlap' VALUE P_OVERLAP,
          'normalize' VALUE 'all'
        )
      ));
    RETURN V_CHUNKS;
  END CHUNK_TEXT;

  ------------------------------------------------------------------------------
  PROCEDURE EMBED_CHUNKS (
      P_CHUNKS        IN DBMS_VECTOR.VECTOR_TEXT_TAB,
      P_MODEL_NAME    IN VARCHAR2 DEFAULT 'E5_MULTILINGUAL',
      P_DOC_ID        IN NUMBER,
      P_CLASSIFICATION IN VARCHAR2 DEFAULT 'INTERNAL',
      P_LABEL          IN VARCHAR2 DEFAULT 'GEN'
  ) IS
    V_VEC VECTOR;
  BEGIN
    FOR I IN 1 .. P_CHUNKS.COUNT LOOP
      V_VEC := DBMS_VECTOR.EMBED_TEXT(P_MODEL_NAME, P_CHUNKS(I));
      INSERT INTO AI_EMBEDDINGS
        (DOC_ID, CHUNK_NO, CHUNK_TEXT, VECTOR_EMB, CLASSIFICATION_LEVEL, SENSITIVITY_LABEL)
      VALUES
        (P_DOC_ID, I, P_CHUNKS(I), V_VEC, P_CLASSIFICATION, P_LABEL);
    END LOOP;
    COMMIT;
  END EMBED_CHUNKS;

  ------------------------------------------------------------------------------
  FUNCTION RETRIEVE_CONTEXT (
      P_QUERY     IN CLOB,
      P_TOP_K     IN NUMBER DEFAULT 5,
      P_POLICY_ID IN NUMBER DEFAULT 1
  ) RETURN CLOB IS
    V_QVEC    VECTOR;
    V_CONTEXT CLOB := EMPTY_CLOB();
  BEGIN
    V_QVEC := DBMS_VECTOR.EMBED_TEXT('E5_MULTILINGUAL', P_QUERY);
    FOR R IN (
      SELECT CHUNK_TEXT
      FROM AI_EMBEDDINGS
      ORDER BY VECTOR_DISTANCE(VECTOR_EMB, V_QVEC)
      FETCH FIRST P_TOP_K ROWS ONLY
    ) LOOP
      V_CONTEXT := V_CONTEXT || R.CHUNK_TEXT || CHR(10);
    END LOOP;
    RETURN AI_POLICY_UTIL.APPLY_REDACTION(V_CONTEXT);
  END RETRIEVE_CONTEXT;

  ------------------------------------------------------------------------------
  FUNCTION GENERATE_ANSWER (
      P_USER       IN VARCHAR2,
      P_MODULE     IN VARCHAR2,
      P_QUERY      IN CLOB,
      P_MODEL_NAME IN VARCHAR2 DEFAULT 'E5_MULTILINGUAL',
      P_POLICY_ID  IN NUMBER DEFAULT 1
  ) RETURN CLOB IS
    V_CONTEXT   CLOB;
    V_RESPONSE  CLOB;
    V_PAYLOAD   CLOB;
    V_HTTP_REQ  UTL_HTTP.REQ;
    V_HTTP_RESP UTL_HTTP.RESP;
    V_BUFFER    VARCHAR2(32767);
    V_API_URL   VARCHAR2(4000) := 'http://llm-gateway.local/v1/chat/completions';
  BEGIN
    V_CONTEXT := RETRIEVE_CONTEXT(P_QUERY, 5, P_POLICY_ID);

    V_PAYLOAD := JSON_OBJECT(
                   'model' VALUE P_MODEL_NAME,
                   'messages' VALUE JSON_ARRAY(
                     JSON_OBJECT('role' VALUE 'system', 'content' VALUE 'You are an enterprise assistant for Oracle EBS.'),
                     JSON_OBJECT('role' VALUE 'user', 'content' VALUE P_QUERY||CHR(10)||'Context:'||V_CONTEXT)
                   )
                 ).TO_CLOB;

    V_HTTP_REQ := UTL_HTTP.BEGIN_REQUEST(V_API_URL, 'POST', 'HTTP/1.1');
    UTL_HTTP.SET_HEADER(V_HTTP_REQ, 'Content-Type', 'application/json');
    UTL_HTTP.WRITE_TEXT(V_HTTP_REQ, V_PAYLOAD);
    V_HTTP_RESP := UTL_HTTP.GET_RESPONSE(V_HTTP_REQ);

    LOOP
      UTL_HTTP.READ_TEXT(V_HTTP_RESP, V_BUFFER, 32767);
      V_RESPONSE := V_RESPONSE || V_BUFFER;
    END LOOP;
    UTL_HTTP.END_RESPONSE(V_HTTP_RESP);

    INSERT INTO AI_USAGE_LOG (
      USERNAME, MODULE_NAME, PROMPT_TEXT, RETRIEVED_CONTEXT,
      MODEL_NAME, RESPONSE_SUMMARY, POLICY_ID, REDACTED_FLAG
    )
    VALUES (
      P_USER, P_MODULE, P_QUERY, V_CONTEXT,
      P_MODEL_NAME, V_RESPONSE, P_POLICY_ID, 'Y'
    );
    COMMIT;

    RETURN V_RESPONSE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Error generating answer: '||SQLERRM;
  END GENERATE_ANSWER;

END RAG_ENGINE_PKG;
/
--------------------------------------------------------------------------------
-- END OF FILE
--------------------------------------------------------------------------------
