select * from datavalue where sourceid in (select organisationunitid from organisationunit where uid in ("uid1","uid2")):

select * from datavalueaudit where organisationunitid in (select organisationunitid from organisationunit where uid in ("uid1","uid2")):


 select * from trackedentitydatavalueaudit where programstageinstanceid in (select programstageinstanceid from programstageinstance where organisationunitid in (select organisationunitid from organisationunit where uid in ("uid1","uid2")));
 
select * from programinstance where organisationunitid in ("uid1","uid2");

select * from programstageinstance where organisationunitid in ("uid1","uid2");

select * from trackedentityinstance where organisationunitid in ("uid1","uid2");

select * from trackedentityprogramowner where organisationunitid in ("uid1","uid2"); //not sure about what does this table.

select * from datavalue where dataelementid in (select dataelementid from dataelement where valuetype='ORGANISATION_UNIT') and value in ("uid1","uid2"):
select * from datavalueaudit where dataelementid in (select dataelementid from dataelement where valuetype='ORGANISATION_UNIT') and value in ("uid1","uid2"):

SELECT foo.* FROM (SELECT uid AS event, json.key AS dataElement, jsonb_extract_path_text(json.value, 'value') AS orgUnit
FROM programstageinstance, jsonb_each(programstageinstance.eventdatavalues) AS json
WHERE json.key IN (select uid from dataelement where valuetype='ORGANISATION_UNIT')) AS foo
WHERE foo.orgUnit IN ('uid1', 'uid2');
