BEGIN;

DO $$
DECLARE
    r RECORD;
    v_sql TEXT;
    v_old_uid TEXT := '2viWXSdot02';
    v_new_uid TEXT := 'bviWXSdot02';
    v_updated_rows INT;
BEGIN
    RAISE NOTICE 'Starting update from "%" to "%"...', v_old_uid, v_new_uid;

    FOR r IN
        SELECT
            t.relname AS table_name,
            a.attname AS column_name,
            typ.typname AS data_type
        FROM pg_class t
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_attribute a ON a.attrelid = t.oid
        JOIN pg_type typ ON typ.oid = a.atttypid
        WHERE n.nspname = 'public'
          AND t.relkind = 'r'
          AND a.attnum > 0
          AND NOT a.attisdropped
          AND a.attgenerated = ''
          AND typ.typname IN ('text', 'varchar', 'json', 'jsonb')
          AND t.relname NOT LIKE 'analytics%'
          AND t.relname NOT LIKE '\_%' ESCAPE '\'
    LOOP
        IF r.data_type = 'jsonb' THEN
            v_sql := format(
                'UPDATE %I SET %I = replace(%I::text, %L, %L)::jsonb WHERE %I::text LIKE %L',
                r.table_name, r.column_name, r.column_name, v_old_uid, v_new_uid, r.column_name, '%' || v_old_uid || '%'
            );
        ELSIF r.data_type = 'json' THEN
            v_sql := format(
                'UPDATE %I SET %I = replace(%I::text, %L, %L)::json WHERE %I::text LIKE %L',
                r.table_name, r.column_name, r.column_name, v_old_uid, v_new_uid, r.column_name, '%' || v_old_uid || '%'
            );
        ELSE
            v_sql := format(
                'UPDATE %I SET %I = replace(%I::text, %L, %L) WHERE %I::text LIKE %L',
                r.table_name, r.column_name, r.column_name, v_old_uid, v_new_uid, r.column_name, '%' || v_old_uid || '%'
            );
        END IF;

        EXECUTE v_sql;
        GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

        IF v_updated_rows > 0 THEN
            RAISE NOTICE '✓ Updated [ % . % ]: % rows changed',
                         r.table_name, r.column_name, v_updated_rows;
        END IF;
    END LOOP;
END $$;

COMMIT;
