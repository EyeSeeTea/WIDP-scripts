-- ====== ON PROD: generate CSV of UIDs to delete ======

-- Create table with UIDs of org units to delete
DROP TABLE IF EXISTS rm_ou_to_delete_uid_task;
CREATE TABLE rm_ou_to_delete_uid_task (
    uid character(11) PRIMARY KEY
);

-- Fill it from the org units to delete (by ID)
INSERT INTO rm_ou_to_delete_uid_task (uid)
SELECT ou.uid
FROM rm_ou_to_delete_task t
JOIN organisationunit ou USING (organisationunitid);

-- Export UIDs to CSV (run in psql)
\COPY rm_ou_to_delete_uid_task TO '/path/ou_to_delete_uids.csv' WITH (FORMAT csv, HEADER true);



-- ====== ON DESTINE: import UIDs and resolve local IDs ======

-- Create table with imported UIDs
DROP TABLE IF EXISTS rm_ou_to_delete_uid_task;
CREATE TABLE rm_ou_to_delete_uid_task (
    uid character(11) PRIMARY KEY
);

-- Import UIDs from CSV (run in psql)
\COPY rm_ou_to_delete_uid_task FROM '/path/ou_to_delete_uids.csv' WITH (FORMAT csv, HEADER true);

-- Fill rm_ou_to_delete_task using local organisationunitid
TRUNCATE TABLE rm_ou_to_delete_task;

INSERT INTO rm_ou_to_delete_task (organisationunitid)
SELECT ou.organisationunitid
FROM rm_ou_to_delete_uid_task u
JOIN organisationunit ou ON ou.uid = u.uid;
