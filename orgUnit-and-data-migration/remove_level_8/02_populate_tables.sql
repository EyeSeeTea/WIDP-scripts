-- ===================================================================
-- 02_fill_rm_tables.sql
-- Populate helper tables for cleaning level-8 org units (> 18 months)
-- ===================================================================

-- 1) level-8 org units older than 18 months
INSERT INTO rm_ou_level8_18m_task (organisationunitid)
SELECT DISTINCT ou.organisationunitid
FROM organisationunit ou
WHERE ou.hierarchylevel = 8
  AND ou.created < current_date - INTERVAL '18 months';

-- 2) Mark org units that HAVE data

-- 2.1 datavalue
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN datavalue dv
  ON dv.sourceid = b.organisationunitid
ON CONFLICT DO NOTHING;

-- 2.2 datavalueaudit
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN datavalueaudit dva
  ON dva.organisationunitid = b.organisationunitid
ON CONFLICT DO NOTHING;

-- 2.3 trackedentity
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN trackedentity te
  ON te.organisationunitid = b.organisationunitid
ON CONFLICT DO NOTHING;

-- 2.4 enrollment
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN enrollment en
  ON en.organisationunitid = b.organisationunitid
ON CONFLICT DO NOTHING;

-- 2.5 event
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN event ev
  ON ev.organisationunitid = b.organisationunitid
ON CONFLICT DO NOTHING;

-- 2.6 completedatasetregistration
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN completedatasetregistration cdr
  ON cdr.sourceid = b.organisationunitid
ON CONFLICT DO NOTHING;

-- 2.7 trackedentityprogramowner
INSERT INTO rm_ou_level8_with_data_task (organisationunitid)
SELECT DISTINCT b.organisationunitid
FROM rm_ou_level8_18m_task b
JOIN trackedentityprogramowner tpo
  ON tpo.organisationunitid = b.organisationunitid
ON CONFLICT DO NOTHING;

