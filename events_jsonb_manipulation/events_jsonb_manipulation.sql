--------------------------------------------------------------------------------------------------
--- Scripts to count, read, update, migrate and delete data on events with jsonb-type fields -----
--------------------------------------------------------------------------------------------------

---- 1. COUNTING EVENTS
-- counts the events with values for a DE in a program
SELECT eventdatavalues->'DATAELEMENTUID'->>'value', count(*)
FROM programstageinstance WHERE programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
GROUP BY eventdatavalues->'DATAELEMENTUID'->>'value'
;

-- counts the total events having a DE in a program
SELECT  count(*)
FROM programstageinstance 
WHERE eventdatavalues ? 'DATAELEMENTUID'   
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;

---- 2. REPLACING VALUES
-- Selects all entries for a program and a Dataelements
SELECT programstageinstanceid, created, eventdatavalues->>'DATAELEMENTUID'
FROM programstageinstance
WHERE eventdatavalues-> 'DATAELEMENTUID' ->> 'value' = 'searched_value'
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;

-- replaces a value in a particular dataelement and program
UPDATE programstageinstance 
SET eventdatavalues = jsonb_set(eventdatavalues, '{DATAELEMENTUID,value}', '"New_value_here"'::jsonb, false)
WHERE eventdatavalues-> 'DATAELEMENTUID' ->> 'value' = 'old_value' 
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;

-- manual check of some of the updated events
SELECT programstageinstanceid, created, eventdatavalues->>'DATAELEMENTUID'
FROM programstageinstance
WHERE programstageinstanceid IN(
85636, 78450, 158775
)
;

---- 3. MIGRATING VALUES FROM ONE DE TO ANOTHER (REPLACING KEYS)
-- selects all events from a program and shows the values for a particular DE
SELECT programstageinstanceid, created, eventdatavalues->'zoECkkkCPdP'->'value'
FROM programstageinstance
WHERE programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;
 
 -- selects only events with a particular DE for a program
SELECT programstageinstanceid, created, eventdatavalues->'DATAELEMENTUID'
FROM programstageinstance
WHERE eventdatavalues ? 'DATAELEMENTUID'  
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;

-- replaces a key by another keeping its values
 UPDATE programstageinstance
SET eventdatavalues = jsonb_set(eventdatavalues #- '{OLD_DATAELEMENTUID}',
                                '{NEW_DATAELEMENTUID}',
                                eventdatavalues#>'{OLD_DATAELEMENTUID}')
WHERE eventdatavalues ? 'OLD_DATAELEMENTUID'   -- avoids processing events without that DE
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;

---- 4. DELETING VALUES

-- 4.1 DELETES object by key for a particular DE

UPDATE programstageinstance
SET eventdatavalues = eventdatavalues - 'DATAELEMENTUID_TODELETE'
WHERE eventdatavalues ? 'DATAELEMENTUID_TODELETE'  -- avoids processing events without that DE
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
;

-- 4.2 DELETES properties at second level (to test)
-- created a function 
create or replace function remove_nested_object(obj jsonb, key_to_remove text)
		returns jsonb language sql immutable as $$
			select jsonb_object_agg(key, value- key_to_remove)
			from jsonb_each(obj)
		$$;

-- removes the object by updating the entry without the object
update programstageinstance
set eventdatavalues = remove_nested_object(eventdatavalues, 'DATAELEMENTUID_TODELETE')
where eventdatavalues::text like '%"DATAELEMENTUID_TODELETE":%'
AND programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name = 'program_name'
)
