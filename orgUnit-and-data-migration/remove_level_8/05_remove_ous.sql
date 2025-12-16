-------------------- DELETE ORGUNITS --------------------------------------------
---params to force show echo -a --echo-all

-- selects all descendants in an orgUnit
  \echo 'Starting remove orgunit tree proccess';
DO $$
  DECLARE
    datavalue_count int;
    eventvalue_count int;
    result_count int;
BEGIN
  SELECT COUNT(*) INTO datavalue_count FROM datavalue where sourceid in (select * from orgUnitsToDelete);
  IF datavalue_count = 0 THEN
    RAISE NOTICE 'datavalues not found';
    SELECT COUNT(*) INTO eventvalue_count FROM event where organisationunitid in (select * from orgUnitsToDelete);
    IF eventvalue_count = 0 THEN        
    WITH d as (
        DELETE FROM organisationunit WHERE organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

    --    DROP VIEW orgUnitsToDelete;
    ELSE
    RAISE NOTICE '% Events in event found, exiting', eventvalue_count;
    RAISE NOTICE 'For more info execute: select count(*) as events_count, p.name as program, p.uid as program_uid, ou.name as orgunit_name, ou.uid as orgunit_uid, ou.path
    from  event psi 
    inner join organisationunit ou on ou.organisationunitid=psi.organisationunitid
    inner join programstage ps on ps.programstageid=psi.programstageid
    inner join program p on p.programid=ps.programid
    where psi.organisationunitid in (select organisationunitid from orgUnitsToDelete) group by p.name, p.uid, ou.name, ou.uid, ou.path order by ou.path, p.name; ';
    END IF;
  ELSE
    RAISE NOTICE '% datavalues found, exiting', datavalue_count;
  RAISE NOTICE 'For more info execute:  select count(*) as datavalues, ds.uid, ds.name, ou.name as orgunit_name, ou.uid as orgunit_uid, ou.path from datavalue dv
  inner join organisationunit ou on ou.organisationunitid=dv.sourceid
  inner join dataelement de on dv.dataelementid=de.dataelementid
  inner join datasetelement dse on dse.dataelementid=de.dataelementid
  inner join dataset ds on dse.datasetid=ds.datasetid
  where dv.sourceid in (select organisationunitid from orgUnitsToDelete)
  group by ds.uid,ds.name,ou.name, ou.uid, ou.path order by ou.path;';
    SELECT COUNT(*) INTO eventvalue_count FROM event where organisationunitid in (select * from orgUnitsToDelete);
    IF eventvalue_count = 0 THEN        
    RAISE NOTICE '% Events in event found, exiting', eventvalue_count;
    RAISE NOTICE 'For more info execute: select count(*) as events_count, p.name as program, p.uid as program_uid, ou.name as orgunit_name, ou.uid as orgunit_uid, ou.path
    from  event psi 
    inner join organisationunit ou on ou.organisationunitid=psi.organisationunitid
    inner join programstage ps on ps.programstageid=psi.programstageid
    inner join program p on p.programid=ps.programid
    where psi.organisationunitid in (select organisationunitid from orgUnitsToDelete) group by p.name, p.uid, ou.name, ou.uid, ou.path order by ou.path, p.name; ';
    
    END IF;
  END IF;
END$$;
