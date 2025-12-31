# Category Option Combo Checks

Scripts to assess whether a set of categoryOptionCombos (COCs) can be safely removed. They load a list of COC UIDs, check for usage across data values, audits, data element operands, events (as AOC), and data entry forms, and export CSV summaries.

## Prerequisites
- Access to the target DHIS2 PostgreSQL database with permissions to create temp tables and write server-side files via `COPY`.
- `jq` available where you run the helper command.
- A JSON file named `cocs_to_remove.json` with structure:
  ```json
  {
    "categoryOptionCombos": [
      { "id": "UID1" },
      { "id": "UID2" }
    ]
  }
  ```

## Workflow
1) Create staging tables  
   In `psql`, run:
   ```
   \i categoryOptionCombo_checks/01-createtables.sql
   ```

2) Generate insert script for the target UIDs  
   From the repo root, build `02_load_uids.sql` from your JSON:
   ```
   jq -r '.categoryOptionCombos[].id | "INSERT INTO tmp_uids_to_check(uid) VALUES (\"" + . + "\") ON CONFLICT DO NOTHING;"' cocs_to_remove.json \
     | sed "s/\"/'/g" \
     > 02_load_uids.sql
   ```

3) Load the target UIDs  
   In `psql`, run:
   ```
   \i 02_load_uids.sql
   ```

4) (Optional) Populate data entry form hits  
   If you need to detect references inside `dataentryform.htmlcode`, insert rows into `tmp_dataentryform_hits` before exporting. Example pattern:
   ```
   INSERT INTO tmp_dataentryform_hits (target_uid, dataentryformid, form_uid, form_name, form_lastupdated)
   SELECT t.uid,
          def.dataentryformid,
          def.uid,
          def.name,
          def.lastupdated
   FROM tmp_uids_to_check t
   JOIN dataentryform def ON def.htmlcode ILIKE '%' || t.uid || '%';
   ```

5) Export checks to CSV  
   In `psql`, run:
   ```
   \i categoryOptionCombo_checks/03-check_cocs_to_csv.sql
   ```
   - Writes CSVs to `/tmp` on the DB server (`01_datavalue_summary.csv` … `09_coc_final_summary.csv`). Adjust paths in the script if needed.
   - Uses `analytics_rs_periodstructure` to render period ISO codes in data value details; adjust if your schema differs.

6) Review results  
   - `01_*`, `02_*`, `03_*`, `04_*`, `05_*`, `06_*`, `07_*` give per-COC usage across data values, audits, DE operands, and events.  
   - `08_*` lists any data entry form hits you inserted.  
   - `09_coc_final_summary.csv` provides a status flag:
     - `IN_USE_*` variants indicate blocking references.
     - `REFERENCED_IN_DATAENTRYFORM` indicates only form HTML references.
     - `SAFE_CANDIDATE` means no detected references.
