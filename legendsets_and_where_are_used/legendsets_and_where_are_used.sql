-- public legendSets and its dataElements 
  SELECT ls.uid, ls.name, e.uid, e.name
 FROM maplegendset ls
 INNER JOIN dataelementlegendsets lls ON lls.legendsetid = ls.maplegendsetid
 INNER JOIN dataelement e ON e.dataelementid = lls.dataelementid
 WHERE ls.publicAccess not like '--------'
 
 -- public legendSets and its datasets 
  SELECT ls.uid, ls.name
 FROM maplegendset ls
 INNER JOIN datasetlegendsets lls ON lls.legendsetid = ls.maplegendsetid
 INNER JOIN dataset e ON e.datasetid = lls.datasetid
 WHERE ls.publicAccess not like '--------'

 -- public legendSets and its indicators 
 SELECT ls.uid, ls.name, e.uid, e.name
 FROM maplegendset ls
 INNER JOIN indicatorlegendsets lls ON lls.legendsetid = ls.maplegendsetid
 INNER JOIN indicator e ON e.indicatorid = lls.indicatorid
 WHERE ls.publicAccess not like '--------'
 
  -- public legendSets and its programindicators 
  SELECT ls.uid, ls.name, e.uid, e.name
 FROM maplegendset ls
 INNER JOIN programindicatorlegendsets lls ON lls.legendsetid = ls.maplegendsetid
 INNER JOIN programindicator e ON e.programindicatorid = lls.programindicatorid
 WHERE ls.publicAccess not like '--------'
 
-- public legendSets and its trackedentityattributes 
  SELECT ls.uid, ls.name, e.uid, e.name
 FROM maplegendset ls
 INNER JOIN trackedentityattributelegendsets lls ON lls.legendsetid = ls.maplegendsetid
 INNER JOIN trackedentityattribute e ON e.trackedentityattributeid = lls.trackedentityattributeid
 WHERE ls.publicAccess not like '--------' 
 
-- public legendSets and its externalmaplayer 
  SELECT ls.uid, ls.name, e.uid, e.name
 FROM maplegendset ls
 INNER JOIN externalmaplayer e ON e.legendsetid = ls.maplegendsetid
 WHERE ls.publicAccess not like '--------' 
 
 -- public legendSets and its externalmaplayer 
   SELECT ls.uid, ls.name, map.uid, map.name
 FROM maplegendset ls
 INNER JOIN mapview e ON e.legendsetid = ls.maplegendsetid
 INNER JOIN mapmapviews mmv ON mmv.mapviewid = e.mapviewid
 INNER JOIN map ON map.mapid = mmv.mapid
 WHERE ls.publicAccess not like '--------' 
 
  -- public legendSets and its visualization 
   SELECT ls.uid, ls.name, e.uid, e.name
 FROM maplegendset ls
 INNER JOIN visualization e ON e.legendsetid = ls.maplegendsetid
 WHERE ls.publicAccess not like '--------' 

   -- public legendSets and its visualization and dashboards
   SELECT ls.uid, ls.name, e.uid, e.name, d.name "dashboard"
 FROM maplegendset ls
 INNER JOIN visualization e ON e.legendsetid = ls.maplegendsetid
 INNER JOIN dashboarditem di ON e.visualizationid = di.visualizationid
 INNER JOIN dashboard_items d_i ON di.dashboarditemid = d_i.dashboarditemid
 INNER JOIN dashboard d ON d_i.dashboardid = d.dashboardid
  WHERE ls.publicAccess not like '--------'

   -- public legendSets and its maps and dashboards
   SELECT ls.uid, ls.name, map.uid, map.name, d.name "dashboard"
 FROM maplegendset ls
 INNER JOIN mapview e ON e.legendsetid = ls.maplegendsetid
 INNER JOIN mapmapviews mmv ON mmv.mapviewid = e.mapviewid
 INNER JOIN map ON map.mapid = mmv.mapid
 INNER JOIN dashboarditem di ON map.mapid = di.mapid
 INNER JOIN dashboard_items d_i ON di.dashboarditemid = d_i.dashboarditemid
 INNER JOIN dashboard d ON d_i.dashboardid = d.dashboardid
 WHERE ls.publicAccess not like '--------'   
