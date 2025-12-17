-- ===================================================================
-- 01_create_rm_tables.sql
-- Helper tables for cleaning level-8 org units (> 18 months)
-- ===================================================================

-- Universe: level-8 org units older than 18 months
DROP TABLE IF EXISTS rm_ou_level8_18m_task;
CREATE TABLE rm_ou_level8_18m_task (
    organisationunitid bigint PRIMARY KEY
);

-- Level-8 >18m org units that HAVE data
DROP TABLE IF EXISTS rm_ou_level8_with_data_task;
CREATE TABLE rm_ou_level8_with_data_task (
    organisationunitid bigint PRIMARY KEY
);

-- Final list of org units to delete (by internal ID)
DROP TABLE IF EXISTS rm_ou_to_delete_task;
CREATE TABLE rm_ou_to_delete_task (
    organisationunitid bigint PRIMARY KEY
);

-- Final list of org units to delete (by UID, for export/import between servers)
DROP TABLE IF EXISTS rm_ou_to_delete_uid_task;
CREATE TABLE rm_ou_to_delete_uid_task (
    uid character(11) PRIMARY KEY
);

