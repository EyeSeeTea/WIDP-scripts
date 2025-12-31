-- Tabla con UIDs a comprobar
DROP TABLE IF EXISTS tmp_uids_to_check;
CREATE TABLE tmp_uids_to_check (
  uid TEXT PRIMARY KEY
);

-- Tabla con hits en dataentryform.htmlcode
DROP TABLE IF EXISTS tmp_dataentryform_hits;
CREATE TABLE tmp_dataentryform_hits (
  target_uid TEXT NOT NULL,
  dataentryformid INTEGER,
  form_uid TEXT,
  form_name TEXT,
  form_lastupdated TIMESTAMP,
  PRIMARY KEY (target_uid, dataentryformid)
);

