-- ===================================================================
-- 03_build_rm_ou_to_delete.sql
-- Compute final list of org units to delete
-- ===================================================================

-- 1) Reset final tables
TRUNCATE TABLE rm_ou_to_delete_task;
TRUNCATE TABLE rm_ou_to_delete_uid_task;

-- 2) Fill rm_ou_to_delete_task:
--    universe (level-8 >18m)
--    minus org units with data
INSERT INTO rm_ou_to_delete_task (organisationunitid)
SELECT b.organisationunitid
FROM rm_ou_level8_18m_task b
LEFT JOIN rm_ou_level8_with_data_task d
       USING (organisationunitid)
WHERE d.organisationunitid IS NULL;  -- no data


-- 3) Fill rm_ou_to_delete_uid_task with the corresponding UIDs
INSERT INTO rm_ou_to_delete_uid_task (uid)
SELECT ou.uid
FROM rm_ou_to_delete_task t
JOIN organisationunit ou USING (organisationunitid);


-- 4) Optional: make orgUnitsToDelete view for your existing deletion script
DROP VIEW IF EXISTS orgUnitsToDelete;

CREATE VIEW orgUnitsToDelete AS
SELECT organisationunitid
FROM rm_ou_to_delete_task;

