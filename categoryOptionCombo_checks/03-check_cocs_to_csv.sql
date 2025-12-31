/* =======================================================================
   EXPORT ALL QUERIES TO CSV (PostgreSQL)
   - Uses SERVER-SIDE COPY (writes files on the DB server).
   - Change /tmp/coc_checks to your preferred server path.
   ======================================================================= */

-- 0) (Optional) create folder on the DB server beforehand:
-- mkdir -p /tmp/coc_checks


/* 1) DataValue hits per COC (dv_count > 0) -> 01_datavalue_summary.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    COUNT(dv.*)  AS dv_count,
    MAX(dv.lastupdated) AS dv_max_lastupdated,
    MAX(dv.created)     AS dv_max_created
  FROM target
  LEFT JOIN datavalue dv
    ON dv.categoryoptioncomboid = target.categoryoptioncomboid
  GROUP BY target.uid, target.name
  HAVING COUNT(dv.*) > 0
  ORDER BY dv_count DESC, coc_name, coc_uid
) TO '/tmp/01_datavalue_summary.csv'
CSV HEADER;


/* 2) DataValueAudit hits per COC (dva_count > 0) -> 02_datavalueaudit_summary.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    COUNT(dva.*) AS dva_count,
    MAX(dva.created) AS dva_max_created
  FROM target
  LEFT JOIN datavalueaudit dva
    ON dva.categoryoptioncomboid = target.categoryoptioncomboid
  GROUP BY target.uid, target.name
  HAVING COUNT(dva.*) > 0
  ORDER BY dva_count DESC, coc_name, coc_uid
) TO '/tmp/02_datavalueaudit_summary.csv'
CSV HEADER;


/* 3) DataValue details -> 03_datavalue_details.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    de.uid      AS dataelement_uid,
    de.name     AS dataelement_name,
    ou.uid      AS orgunit_uid,
    ou.name     AS orgunit_name,
    ps.iso      AS period_iso,
    COUNT(*)    AS dv_count
  FROM datavalue dv
  JOIN target
    ON target.categoryoptioncomboid = dv.categoryoptioncomboid
  JOIN dataelement de
    ON de.dataelementid = dv.dataelementid
  JOIN organisationunit ou
    ON ou.organisationunitid = dv.sourceid
  JOIN analytics_rs_periodstructure ps
    ON ps.periodid = dv.periodid
  GROUP BY target.uid, target.name, de.uid, de.name, ou.uid, ou.name, ps.iso
  ORDER BY target.name, dv_count DESC, de.name, ou.name, ps.iso
) TO '/tmp/03_datavalue_details.csv'
CSV HEADER;


/* 4) DataElementOperand hits per COC (deo_count > 0) -> 04_deo_summary.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    COUNT(deo.*) AS deo_count
  FROM target
  LEFT JOIN dataelementoperand deo
    ON deo.categoryoptioncomboid = target.categoryoptioncomboid
  GROUP BY target.uid, target.name
  HAVING COUNT(deo.*) > 0
  ORDER BY deo_count DESC, coc_name, coc_uid
) TO '/tmp/04_deo_summary.csv'
CSV HEADER;


/* 5) DataElementOperand details -> 05_deo_details.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    deo.dataelementoperandid,
    de.uid  AS dataelement_uid,
    de.name AS dataelement_name
  FROM dataelementoperand deo
  JOIN target
    ON target.categoryoptioncomboid = deo.categoryoptioncomboid
  LEFT JOIN dataelement de
    ON de.dataelementid = deo.dataelementid
  ORDER BY target.name, deo.dataelementoperandid
) TO '/tmp/05_deo_details.csv'
CSV HEADER;


/* 6) Event hits by AOC (event_aoc_count > 0) -> 06_event_aoc_summary.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    COUNT(e.*) AS event_aoc_count,
    MAX(e.lastupdated) AS event_max_lastupdated,
    MAX(e.created)     AS event_max_created
  FROM target
  LEFT JOIN event e
    ON e.attributeoptioncomboid = target.categoryoptioncomboid
  GROUP BY target.uid, target.name
  HAVING COUNT(e.*) > 0
  ORDER BY event_aoc_count DESC, coc_name, coc_uid
) TO '/tmp/06_event_aoc_summary.csv'
CSV HEADER;


/* 7) Event details by program/stage -> 07_event_details.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  )
  SELECT
    target.uid  AS coc_uid,
    target.name AS coc_name,
    p.uid       AS program_uid,
    p.name      AS program_name,
    ps.uid      AS programstage_uid,
    ps.name     AS programstage_name,
    COUNT(*)    AS event_count
  FROM event e
  JOIN target
    ON target.categoryoptioncomboid = e.attributeoptioncomboid
  JOIN programstage ps
    ON ps.programstageid = e.programstageid
  JOIN program p
    ON p.programid = ps.programid
  GROUP BY target.uid, target.name, p.uid, p.name, ps.uid, ps.name
  ORDER BY target.name, event_count DESC, program_name, programstage_name
) TO '/tmp/07_event_details.csv'
CSV HEADER;


/* 8) DataEntryForm hits -> 08_dataentryform_hits.csv
      IMPORTANT: This exports what's already in tmp_dataentryform_hits.
      If you need to (re)populate it, run your INSERT before this COPY.
*/
COPY (
  SELECT
    target_uid,
    form_uid,
    form_name,
    form_lastupdated
  FROM tmp_dataentryform_hits
  ORDER BY target_uid, form_name
) TO '/tmp/08_dataentryform_hits.csv'
CSV HEADER;


/* 9) Final summary -> 09_coc_final_summary.csv */
COPY (
  WITH target AS (
    SELECT coc.categoryoptioncomboid, coc.uid, coc.name
    FROM categoryoptioncombo coc
    JOIN tmp_uids_to_check t ON t.uid = coc.uid
  ),
  summary AS (
    SELECT
      target.uid  AS coc_uid,
      target.name AS coc_name,

      (SELECT COUNT(*) FROM datavalue dv WHERE dv.categoryoptioncomboid = target.categoryoptioncomboid) AS dv_count,
      (SELECT COUNT(*) FROM dataelementoperand deo WHERE deo.categoryoptioncomboid = target.categoryoptioncomboid) AS deo_count,
      (SELECT COUNT(*) FROM event e WHERE e.attributeoptioncomboid = target.categoryoptioncomboid) AS event_aoc_count,
      (SELECT COUNT(*) FROM datavalueaudit dva WHERE dva.categoryoptioncomboid = target.categoryoptioncomboid) AS dva_count,
      (SELECT COUNT(*) FROM tmp_dataentryform_hits h WHERE h.target_uid = target.uid) AS def_hits,

      CASE
        WHEN (SELECT COUNT(*) FROM datavalue dv WHERE dv.categoryoptioncomboid = target.categoryoptioncomboid) > 0
          THEN 'IN_USE_DATAVALUE'
        WHEN (SELECT COUNT(*) FROM dataelementoperand deo WHERE deo.categoryoptioncomboid = target.categoryoptioncomboid) > 0
          THEN 'IN_USE_DATAELEMENTOPERAND'
        WHEN (SELECT COUNT(*) FROM event e WHERE e.attributeoptioncomboid = target.categoryoptioncomboid) > 0
          THEN 'IN_USE_EVENT_AOC'
        WHEN (SELECT COUNT(*) FROM tmp_dataentryform_hits h WHERE h.target_uid = target.uid) > 0
          THEN 'REFERENCED_IN_DATAENTRYFORM'
        ELSE 'SAFE_CANDIDATE'
      END AS status
    FROM target
  )
  SELECT *
  FROM summary
  ORDER BY
    (dv_count > 0) DESC,
    dv_count DESC,
    deo_count DESC,
    event_aoc_count DESC,
    def_hits DESC,
    coc_name, coc_uid
) TO '/tmp/09_coc_final_summary.csv'
CSV HEADER;

