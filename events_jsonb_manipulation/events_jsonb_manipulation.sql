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

--examle of select and delete dataelemnt+value from a program
SELECT programstageinstanceid
FROM programstageinstance
WHERE eventdatavalues-> 'v86CHHosXCi' ->> 'value' = 'false' and programstageinstanceid IN(
SELECT psi.programstageinstanceid
FROM program p
INNER JOIN programinstance pi ON p.programid = pi.programid
INNER JOIN programstageinstance psi ON pi.programinstanceid = psi.programinstanceid
WHERE p.name like 'ENTO%');

--update only the porgramstageinstanceid from the select query
update programstageinstance set eventdatavalues = eventdatavalues - 'v86CHHosXCi' WHERE eventdatavalues-> 'v86CHHosXCi' ->> 'value' = 'false' 
and programstageinstanceid IN(10721070,10721058,10721068,10721076,10721077,10720962,10720963,10720946,10720940,10720976,10720961,10721069,10720821,10721064,10721051,10721052,10721071,10721081,10721072,10720981,10721056,10720987,10721061,10720977,10721049,10720967,10720853,10720965,10720937,10720934,10720970,10720973,10720915,10721057,10721067,10720858,10721050,10721055,10721062,10720974,10720966,10720945,10720828,10720971,10720850,10720875,10720980,10720866,10720982,10720975,10720912,10720944,10720910,10720964,10721078,10720911,10720947,10720942,10721063,10720935,10721059,10720941,10720972,10720943,10720978,10720916,10720968,10721048,10720979,10720874,10720983,10720969,10720960,10720938,10720936,10720984,10720862,10720869,10720914,10721079,10720939,10721054,10721075,10720913,10721060,10721080,10720948);
