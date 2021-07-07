DROP VIEW if exists updateroles;
CREATE VIEW updateroles AS select ugm.userid, (select userroleid from userrole where name='System - WIDP IT Team') as userroleid from usergroupmembers ugm inner join usergroup ug on ugm.usergroupid=ug.usergroupid where ug.uid='sCjEPgiOhP1';


insert into userrolemembers select * from updateroles  ON CONFLICT DO NOTHING;

