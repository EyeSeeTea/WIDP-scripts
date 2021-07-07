
------------------------------ REASSINGS DATA FROM ONE ORGUNIT TO ANOTHER ------------------------------

 --- Just for info, not needed to perform the query -- select which tables has organisationunitid or sourceid
 select table_name from information_schema.columns where column_name = 'organisationunitid';
 select table_name from information_schema.columns where column_name = 'sourceid';
 
----------------------------------------------------------------------------------------------------------


CREATE TEMPORARY TABLE old_new_ou (old_id integer, old_uid character varying(11), new_id integer, new_uid character varying(11) );

-- Preparation: put old uids and new uid in two columns in Excel, copy paste to notepad++ and apply following regex (note the space in between is really a tab)
-- ([A-Za-z0-9]+)	([A-Za-z0-9]+)
-- \('$1', '$2'\),

INSERT INTO old_new_ou (old_uid, new_uid) VALUES
('OLD_OU_ID1', 'NEW_OU_ID1'),
('OLD_OU_ID2', 'NEW_OU_ID2')
;

-- looks for the UIDs and sets the also the ids (that changes from one DB to another)
UPDATE old_new_ou SET (new_id) = (SELECT organisationunitid FROM organisationunit where uid = new_uid);
UPDATE old_new_ou SET (old_id) = (SELECT organisationunitid FROM organisationunit where uid = old_uid);



-- replaces old id by new id
SELECT count(*) FROM datavalue t, old_new_ou WHERE t.sourceid = old_new_ou.old_id;
UPDATE datavalue AS t SET sourceid = old_new_ou.new_id FROM old_new_ou WHERE t.sourceid = old_new_ou.old_id;
-- requires more complex UPDATE for program values, since trackedentitydatavalue does not have a sourceid field (but its related programstageinstance)

UPDATE orgunitgroupmembers AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE datasetsource AS t SET sourceid = old_new_ou.new_id FROM old_new_ou WHERE t.sourceid = old_new_ou.old_id;
UPDATE program_organisationunits AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE programstageinstance AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE chart_organisationunits AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE completedatasetregistration AS t SET sourceid = old_new_ou.new_id FROM old_new_ou WHERE t.sourceid = old_new_ou.old_id;
UPDATE datavalueaudit AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE mapview_organisationunits AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE reporttable_organisationunits AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE userdatavieworgunits AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE usermembership AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE dataapprovalaudit AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;

UPDATE orgunitgroupmembers AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE programinstance AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE trackedentityinstance AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;
UPDATE trackedentityprogramowner AS t SET organisationunitid = old_new_ou.new_id FROM old_new_ou WHERE t.organisationunitid = old_new_ou.old_id;

-- updates also parent references in the same table
UPDATE organisationunit AS t SET parentid = old_new_ou.new_id FROM old_new_ou WHERE t.parentid = old_new_ou.old_id;

-- DELETES ou and check's also that nothing has been fogotten
DELETE FROM organisationunit WHERE organisationunitid IN (SELECT old_id FROM old_new_ou);

-- not needed, since it was a temporary table
DROP TABLE old_new_ou;




-- This section looks for ou UIDs inside text fields like numerator, filters or htmlcode in indicators, programIndicators and dataentryForms

-- First method:
-- TODO: this does not work, find better solution
-- SELECT uid, name, numerator from indicator WHERE numerator LIKE ANY (SELECT old_uid FROM old_new_ou);
-- SELECT uid, name, denominator from indicator WHERE denominator LIKE ANY ('%' || (SELECT old_uid FROM old_new_ou) || '%');

-- Second method
-- Not best solution, but it should work for small quantity of ou to replace (it multiplies the entire table by the number of ou)
-- For 5 ou, if there are 7000 indicators you will get a 35000-row view
CREATE VIEW indicator_check AS
(
SELECT 
* 
FROM 
( SELECT uid, name, numerator, denominator FROM indicator
) t1
INNER JOIN
(
    SELECT * from old_new_ou
) t2 ON 1= 1);

SELECT uid, name, numerator from indicator_check WHERE numerator LIKE ('%' || old_uid || '%');
SELECT uid, name, denominator from indicator_check WHERE denominator LIKE ('%' || old_uid || '%');
-- add UPDATE query

CREATE VIEW pi_check AS
(
SELECT 
* 
FROM 
( SELECT uid, name, expression, filter FROM programindicator
) t1
INNER JOIN
(
    SELECT * from old_new_ou
) t2 ON 1= 1);

SELECT uid, name, expression from pi_check WHERE expression LIKE ('%' || old_uid || '%');
SELECT uid, name, filter from pi_check WHERE filter LIKE ('%' || old_uid || '%');
-- add UPDATE query 


CREATE VIEW dentryform_check AS
(
SELECT 
* 
FROM 
( SELECT uid, name, htmlcode FROM dataentryform
) t1
INNER JOIN
(
    SELECT * from old_new_ou
) t2 ON 1= 1);

SELECT uid, name from dentryform_check WHERE htmlcode LIKE ('%' || old_uid || '%');
-- add UPDATE query if something found

DROP VIEW indicator_check;
DROP VIEW pi_check;
DROP VIEW dentryform_check;

--------------------------------------------------------------------------------------------------------------------

 --- restart Tomcat - even deleting analytics and redoing, graphs, charts and maps were looking for 102
 ------             No row with the given identifier exists: [org.hisp.dhis.organisationunit.OrganisationUnit#102]"
 
-------------------------------------------------------------------------------------------------------------