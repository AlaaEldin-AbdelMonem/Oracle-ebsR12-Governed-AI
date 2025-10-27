--------------------------------------------------------------------------------
-- File: ebs_session_util_pkg.sql
-- Project: Oracle-ebsR12-Governed-AI
-- Purpose: Secure session-context bridge between Oracle EBS R12.x and APEX 23ai
-- Author : Alaaeldin Abdelmonem
-- Version: 1.0 (2025-10-27)
--------------------------------------------------------------------------------
-- Overview
--   • Validates EBS ICX_SESSION_TOKEN received via APEX (P10_ICX_TOKEN)
--   • Returns authenticated user context: USER_ID, USER_NAME, RESP_ID, RESP_NAME
--   • Stores minimal runtime context into APEX global temporary table
--   • Enables SSO-style launch from EBS to APEX without password prompt
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE ebs_session_util_pkg AS

  TYPE t_user_context IS RECORD (
      user_id         NUMBER,
      user_name       VARCHAR2(100),
      resp_id         NUMBER,
      resp_name       VARCHAR2(240),
      language_code   VARCHAR2(10),
      validation_msg  VARCHAR2(200)
  );

  FUNCTION get_user_context (
      p_icx_token IN VARCHAR2
  ) RETURN t_user_context;

  PROCEDURE register_apex_session (
      p_icx_token IN VARCHAR2,
      p_apex_user OUT VARCHAR2
  );

END ebs_session_util_pkg;
/

--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY ebs_session_util_pkg AS

  FUNCTION get_user_context (
      p_icx_token IN VARCHAR2
  ) RETURN t_user_context IS
      v_ctx t_user_context;
  BEGIN
      SELECT fu.user_id,
             fu.user_name,
             fr.responsibility_id,
             fr.responsibility_name,
             NVL(fnd_global.current_language, 'US'),
             'VALID'
      INTO   v_ctx.user_id,
             v_ctx.user_name,
             v_ctx.resp_id,
             v_ctx.resp_name,
             v_ctx.language_code,
             v_ctx.validation_msg
      FROM   fnd_user fu,
             fnd_responsibility_tl fr,
             icx_sessions icx
      WHERE  icx.session_id = p_icx_token
      AND    icx.user_id    = fu.user_id
      AND    fu.end_date   IS NULL
      AND    ROWNUM = 1;

      RETURN v_ctx;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          v_ctx.validation_msg := 'INVALID TOKEN';
          RETURN v_ctx;
  END get_user_context;

  PROCEDURE register_apex_session (
      p_icx_token IN VARCHAR2,
      p_apex_user OUT VARCHAR2
  ) IS
      v_ctx t_user_context;
  BEGIN
      v_ctx := get_user_context(p_icx_token);
      IF v_ctx.validation_msg = 'VALID' THEN
          p_apex_user := v_ctx.user_name;
          -- Optionally cache to a GTT for multi-page use
          INSERT INTO app_session_context
            (apex_session_id, user_id, user_name, resp_id, language_code, created_at)
          VALUES
            (v('APP_SESSION'), v_ctx.user_id, v_ctx.user_name, v_ctx.resp_id,
             v_ctx.language_code, SYSDATE);
      ELSE
          RAISE_APPLICATION_ERROR(-20001, 'Invalid ICX token.');
      END IF;
  END register_apex_session;

END ebs_session_util_pkg;
/
--------------------------------------------------------------------------------
-- END OF FILE
--------------------------------------------------------------------------------
