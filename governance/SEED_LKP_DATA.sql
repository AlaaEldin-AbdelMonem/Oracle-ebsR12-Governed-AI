--------------------------------------------------------------------------------
-- File: SEED_LKP_DATA.sql
-- Project: Oracle-ebsR12-Governed-AI
-- Purpose: Seed script for lookup tables and baseline governance data
-- Author : Alaaeldin Abdelmonem
-- Version: 1.0 (2025-10-27)
--------------------------------------------------------------------------------

PROMPT ============================================
PROMPT  Loading Lookup and Baseline Configuration...
PROMPT ============================================

--------------------------------------------------------------------------------
-- SECTION 1. CLASSIFICATION LEVELS
--------------------------------------------------------------------------------

INSERT INTO LKP_CLASSIFICATION_LEVEL (CLASSIFICATION_LEVEL, CLASSIFICATION_NAME, DESCRIPTION)
VALUES ('PUBLIC', 'Public', 'Publicly shareable information.');

INSERT INTO LKP_CLASSIFICATION_LEVEL (CLASSIFICATION_LEVEL, CLASSIFICATION_NAME, DESCRIPTION)
VALUES ('INTERNAL', 'Internal', 'Internal corporate or system data.');

INSERT INTO LKP_CLASSIFICATION_LEVEL (CLASSIFICATION_LEVEL, CLASSIFICATION_NAME, DESCRIPTION)
VALUES ('CONFIDENTIAL', 'Confidential', 'Personal, HR, or financial data.');

INSERT INTO LKP_CLASSIFICATION_LEVEL (CLASSIFICATION_LEVEL, CLASSIFICATION_NAME, DESCRIPTION)
VALUES ('RESTRICTED', 'Restricted', 'Highly sensitive or regulated data.');

COMMIT;

--------------------------------------------------------------------------------
-- SECTION 2. SENSITIVITY LABELS
--------------------------------------------------------------------------------

INSERT INTO LKP_SENSITIVITY_LABEL (LABEL_CODE, LABEL_NAME, DESCRIPTION)
VALUES ('GEN', 'General', 'Non-sensitive data');

INSERT INTO LKP_SENSITIVITY_LABEL (LABEL_CODE, LABEL_NAME, DESCRIPTION)
VALUES ('PII', 'Personal', 'Personally identifiable information');

INSERT INTO LKP_SENSITIVITY_LABEL (LABEL_CODE, LABEL_NAME, DESCRIPTION)
VALUES ('FIN', 'Financial', 'Financial or payroll-related information');

INSERT INTO LKP_SENSITIVITY_LABEL (LABEL_CODE, LABEL_NAME, DESCRIPTION)
VALUES ('SEC', 'Security', 'Security tokens, passwords, or credentials');

COMMIT;

--------------------------------------------------------------------------------
-- SECTION 3. BASELINE REDACTION RULES
--------------------------------------------------------------------------------

INSERT INTO CFG_REDACTION_RULE (RULE_NAME, PATTERN, REPLACEMENT, DESCRIPTION)
VALUES ('Email Mask', '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}', '[REDACTED_EMAIL]', 'Mask email addresses');

INSERT INTO CFG_REDACTION_RULE (RULE_NAME, PATTERN, REPLACEMENT, DESCRIPTION)
VALUES ('Phone Mask', '\\+?[0-9]{10,15}', '[REDACTED_PHONE]', 'Mask phone numbers');

INSERT INTO CFG_REDACTION_RULE (RULE_NAME, PATTERN, REPLACEMENT, DESCRIPTION)
VALUES ('National ID Mask', '[0-9]{14}', '[REDACTED_ID]', 'Mask national IDs');

COMMIT;

--------------------------------------------------------------------------------
-- SECTION 4. DEFAULT AI POLICY
--------------------------------------------------------------------------------

INSERT INTO CFG_AI_POLICY (
    POLICY_NAME, MODEL_NAME, ALLOWED_CLASSIFICATION,
    ALLOWED_LABEL, ACTION_ON_VIOLATION, ENABLED_FLAG, CREATED_BY
)
VALUES (
    'Default Redaction Policy',
    'E5_MULTILINGUAL',
    'CONFIDENTIAL',
    'PII',
    'REDACT',
    'Y',
    'SYSTEM'
);

COMMIT;

--------------------------------------------------------------------------------
-- SECTION 5. CONFIRMATION MESSAGE
--------------------------------------------------------------------------------

PROMPT ============================================
PROMPT ✅ Seed Data Successfully Loaded
PROMPT - Classifications: 4
PROMPT - Sensitivity Labels: 4
PROMPT - Redaction Rules: 3
PROMPT - Policies: 1
PROMPT ============================================

--------------------------------------------------------------------------------
-- END OF FILE
--------------------------------------------------------------------------------
