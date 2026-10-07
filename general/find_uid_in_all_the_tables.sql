DO $$
DECLARE
    r RECORD;
    v_sql TEXT;
    v_count INT;
    v_target_uid TEXT := '2viWXSdot02';
BEGIN
    RAISE NOTICE 'Starting search...';

    FOR r IN
        SELECT
            t.relname AS table_name,
            a.attname AS column_name
        FROM pg_class t
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_attribute a ON a.attrelid = t.oid
        JOIN pg_type typ ON typ.oid = a.atttypid
        WHERE n.nspname = 'public'
          AND t.relkind = 'r'
          AND a.attnum > 0
          AND NOT a.attisdropped
          AND typ.typname IN ('text', 'varchar', 'json', 'jsonb')
          AND t.relname NOT LIKE 'analytics%'
          AND t.relname NOT LIKE '\_%' ESCAPE '\'
    LOOP
        v_sql := format(
            'SELECT count(*) FROM %I WHERE %I::text LIKE %L',
            r.table_name, r.column_name, '%' || v_target_uid || '%'
        );

        EXECUTE v_sql INTO v_count;

        IF v_count > 0 THEN
            RAISE NOTICE 'Match in table: [ % ] | Column: [ % ] | #: %',
                         r.table_name, r.column_name, v_count;
        END IF;
    END LOOP;
END $$;

