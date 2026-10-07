DO $$
DECLARE
    r RECORD;
    v_sql TEXT;
    v_record RECORD;
BEGIN
    RAISE NOTICE '=== STARTING COMPREHENSIVE INVALID UID SEARCH (TEXT + JSONB) ===';

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
          AND t.relname NOT LIKE 'analytics%'
          AND t.relname NOT LIKE '\_%' ESCAPE '\'
          -- Excluir explícitamente eventdatavalues en la tabla event
          AND NOT (t.relname = 'event' AND a.attname = 'eventdatavalues')
          AND (
              -- OPCIÓN A: Columnas de texto con nombre relacionado a UID
              (typ.typname IN ('text', 'varchar') AND (a.attname = 'uid' OR a.attname LIKE '%uid'))
              OR
              -- OPCIÓN B: Cualquier columna JSON o JSONB (excepto la excluida arriba)
              (typ.typname IN ('json', 'jsonb'))
          )
    LOOP
        IF r.data_type IN ('json', 'jsonb') THEN
            -- Búsqueda dentro de JSON/JSONB extrayendo todas las cadenas de texto
            v_sql := format(
                'SELECT matches[1] AS invalid_uid ' ||
                'FROM %I, ' ||
                'regexp_matches(%I::text, %L, %L) AS matches ' ||
                'LIMIT 100',
                r.table_name, r.column_name, '"([0-9][a-zA-Z0-9]{10})"', 'g'
            );
        ELSE
            -- Búsqueda estándar en columnas de texto
            v_sql := format(
                'SELECT %I::text AS invalid_uid FROM %I WHERE %I::text ~ %L LIMIT 100',
                r.column_name, r.table_name, r.column_name, '^[0-9][a-zA-Z0-9]{10}$'
            );
        END IF;

        -- Ejecutar la consulta dinámica
        FOR v_record IN EXECUTE v_sql LOOP
            RAISE NOTICE 'Table: % | Column: % (% ) | Invalid UID: %',
                         r.table_name, r.column_name, r.data_type, v_record.invalid_uid;
        END LOOP;

    END LOOP;

    RAISE NOTICE '=== SEARCH COMPLETED ===';
END $$;
