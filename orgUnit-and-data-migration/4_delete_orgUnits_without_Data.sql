-------------------- DELETE ORGUNITS --------------------------------------------
---params to force show echo -a --echo-all

-- selects all descendants in an orgUnit
\echo 'Dropping last orgUnitsToDelete view';

DROP VIEW if exists orgUnitsToDelete;
\echo 'Recreating orgUnitsToDelete view';
CREATE VIEW orgUnitsToDelete AS
select organisationunitid from organisationunit where path like '%OLD_COUNTRY_ID%' and uid <> 'OLD_COUNTRY_ID';
-- order by  hierarchylevel desc;

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
    SELECT COUNT(*) INTO eventvalue_count FROM programstageinstance where organisationunitid in (select * from orgUnitsToDelete);
    IF eventvalue_count = 0 THEN        
        SELECT COUNT(*) INTO result_count FROM orgUnitsToDelete;
        raise notice 'Orgunits to be deleted: %', result_count;
        RAISE NOTICE 'Event datavalues not found';
        -------------------- DELETE ORGUNITS --------------------------------------------

        -- Delete related data

        RAISE NOTICE 'Removing trackedentitydatavalueaudit ou references';
        WITH d as (
        DELETE FROM trackedentitydatavalueaudit where programstageinstanceid in (select programstageinstanceid from  programstageinstance where organisationunitid in (select * from orgUnitsToDelete)) RETURNING *) SELECT COUNT(*) into result_count
        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing programstageinstancecomments ou references';
        WITH d as (
        DELETE FROM programstageinstancecomments where programstageinstanceid in (select programstageinstanceid from  programstageinstance where organisationunitid in (select * from orgUnitsToDelete)) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing programstageinstance ou references';
        WITH d as (
        DELETE FROM programstageinstance where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing trackedentityattributevalue ou references';
        WITH d as (
        DELETE FROM trackedentityattributevalue where trackedentityinstanceid in (select trackedentityinstanceid from  trackedentityinstance where organisationunitid in (select * from orgUnitsToDelete)) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing trackedentityattributevalueaudit ou references';
        WITH d as (
        DELETE FROM trackedentityattributevalueaudit where trackedentityinstanceid in (select trackedentityinstanceid from  trackedentityinstance where organisationunitid in (select * from orgUnitsToDelete)) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing datasetsource ou references';
        WITH d as (
		DELETE FROM datasetsource where sourceid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing orgunitgroupmembers ou references';
        WITH d as (
		DELETE FROM orgunitgroupmembers where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing program_organisationunits ou references';
        WITH d as (
        DELETE FROM program_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing programstageinstance ou references';
        WITH d as (
        DELETE FROM programstageinstance where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count;

        RAISE NOTICE 'Removing _orgunitstructure ou references';
        WITH d as (
        DELETE FROM  _orgunitstructure where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing _datasetorganisationunitcategory ou references';
        WITH d as (
        DELETE FROM  _datasetorganisationunitcategory where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing _organisationunitgroupsetstructure ou references';
        WITH d as (
        DELETE FROM  _organisationunitgroupsetstructure where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing datavalueaudit ou references';
        WITH d as (
        DELETE FROM  datavalueaudit where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing categoryoption_organisationunits ou references';
        WITH d as (
        DELETE FROM  categoryoption_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing chart_organisationunits ou references';
        WITH d as (
        DELETE FROM  chart_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing dataapproval ou references';
        WITH d as (
        DELETE FROM  dataapproval where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing dataapprovalaudit ou references';
        WITH d as (
        DELETE FROM  dataapprovalaudit where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing eventchart_organisationunits ou references';
        WITH d as (
        DELETE FROM  eventchart_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing eventreport_organisationunits ou references';
        WITH d as (
        DELETE FROM  eventreport_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing interpretation ou references';
        WITH d as (
        DELETE FROM  interpretation where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing lockexception ou references';
        WITH d as (
        DELETE FROM  lockexception where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing mapview_organisationunits ou references';
        WITH d as (
        DELETE FROM  mapview_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing organisationunitattributevalues ou references';
        WITH d as (
        DELETE FROM  organisationunitattributevalues where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing program_organisationunits ou references';
        WITH d as (
        DELETE FROM  program_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing programinstanceaudit ou references';
        WITH d as (
        DELETE FROM  programinstanceaudit where programinstanceid in (select programinstanceid from programinstance where organisationunitid in (select * from orgUnitsToDelete)) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing programinstance ou references';
        WITH d as (
        DELETE FROM  programinstance where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing programmessage ou references';
        WITH d as (
        DELETE FROM  programmessage where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing reporttable_organisationunits ou references';
        WITH d as (
        DELETE FROM  reporttable_organisationunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing trackedentityinstance ou references';
        WITH d as (
        DELETE FROM  trackedentityinstance where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing userdatavieworgunits ou references';
        WITH d as (
        delete     from  userdatavieworgunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing usermembership ou references';
        WITH d as (
        DELETE FROM  usermembership where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing userteisearchorgunits ou references';
        WITH d as (
        DELETE FROM  userteisearchorgunits where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing validationresult ou references';
        WITH d as (
        DELETE FROM  validationresult where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing completedatasetregistration ou references';
        WITH d as (
        DELETE FROM completedatasetregistration where sourceid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        --new tables in 2.34
        RAISE NOTICE 'Removing configuration ou references';
        WITH d as (
        DELETE FROM configuration WHERE selfregistrationorgunit in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing minmaxdataelement ou references';
        WITH d as (
        DELETE FROM minmaxdataelement WHERE sourceid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing trackedentityprogramowner ou references';
        WITH d as (
        DELETE FROM trackedentityprogramowner WHERE organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        RAISE NOTICE 'Removing visualization_organisationunits ou references';
        WITH d as (
        DELETE FROM visualization_organisationunits WHERE organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        IF EXISTS(SELECT FROM information_schema.views where table_name = '_view_nhwa_data_audit')
        THEN
        RAISE NOTICE 'Removing _view_nhwa_data_audit ou references';
        WITH d as (
        DELETE FROM  _view_nhwa_data_audit where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 
        END IF;

        --this view not exists in preprod
        IF EXISTS(SELECT FROM information_schema.views where table_name = '_view_test2')
        THEN
        RAISE NOTICE 'Removing _view_test2 ou references';
        WITH d as (
        DELETE FROM  _view_test2 where organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count
		        FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 
        END IF;

        RAISE NOTICE 'Removing organisationunits';
		WITH d as (
        DELETE FROM organisationunit WHERE organisationunitid in (select * from orgUnitsToDelete) RETURNING *) SELECT COUNT(*) into result_count FROM d;
        RAISE NOTICE 'Affected rows: %', result_count; 

        DROP VIEW orgUnitsToDelete;
    ELSE
		RAISE NOTICE '% Events in programstageinstance found, exiting', eventvalue_count;
		RAISE NOTICE 'For more info execute: select count(*) as events_count, p.name as program, p.uid as program_uid, ou.name as orgunit_name, ou.uid as orgunit_uid, ou.path
		from  programstageinstance psi 
		inner join organisationunit ou on ou.organisationunitid=psi.organisationunitid
		inner join programstage ps on ps.programstageid=psi.programstageid
		inner join program p on p.programid=ps.programid
		where psi.organisationunitid in (select organisationunitid from orgUnitsToDelete) group by p.name, p.uid, ou.name, ou.uid, ou.path order by ou.path, p.name; ';
    END IF;
  ELSE
    RAISE NOTICE '% datavalues found, exiting', datavalue_count;
	RAISE NOTICE 'For more info execute: 	select count(*) as datavalues, ds.uid, ds.name, ou.name as orgunit_name, ou.uid as orgunit_uid, ou.path from datavalue dv
	inner join organisationunit ou on ou.organisationunitid=dv.sourceid
	inner join dataelement de on dv.dataelementid=de.dataelementid
	inner join datasetelement dse on dse.dataelementid=de.dataelementid
	inner join dataset ds on dse.datasetid=ds.datasetid
	where dv.sourceid in (select organisationunitid from orgUnitsToDelete)
	group by ds.uid,ds.name,ou.name, ou.uid, ou.path order by ou.path;';
    SELECT COUNT(*) INTO eventvalue_count FROM programstageinstance where organisationunitid in (select * from orgUnitsToDelete);
    IF eventvalue_count = 0 THEN        
		RAISE NOTICE '% Events in programstageinstance found, exiting', eventvalue_count;
		RAISE NOTICE 'For more info execute: select count(*) as events_count, p.name as program, p.uid as program_uid, ou.name as orgunit_name, ou.uid as orgunit_uid, ou.path
		from  programstageinstance psi 
		inner join organisationunit ou on ou.organisationunitid=psi.organisationunitid
		inner join programstage ps on ps.programstageid=psi.programstageid
		inner join program p on p.programid=ps.programid
		where psi.organisationunitid in (select organisationunitid from orgUnitsToDelete) group by p.name, p.uid, ou.name, ou.uid, ou.path order by ou.path, p.name; ';
		
	  END IF;
  END IF;
END$$;