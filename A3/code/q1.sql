SET SEARCH_PATH TO wetworldschema;

DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1
(
    open_water INT,
    cave_diving INT,
    beyond_30m INT
);

DROP VIEW IF EXISTS  open_water_site CASCADE;
DROP VIEW IF EXISTS  cave_diving_site CASCADE;
DROP VIEW IF EXISTS  beyond_30m_site CASCADE;
DROP VIEW IF EXISTS  ow_monitor_site CASCADE;
DROP VIEW IF EXISTS  cd_monitor_site CASCADE;
DROP VIEW IF EXISTS  b30_monitor_site CASCADE;
DROP VIEW IF EXISTS  ow CASCADE;
DROP VIEW IF EXISTS  cd CASCADE;
DROP VIEW IF EXISTS  b30 CASCADE;

create view open_water_site as (
select sid
from dive_site_type
where open_water = True 
);

create view cave_diving_site as (
select sid
from dive_site_type
where cave_dive = True 
);

create view beyond_30m_site as (
select sid
from dive_site_type
where deeper_than_30_meters = True 
);

create view ow_monitor_site as (
select open_water_site.sid as sid, monitor_privilege.mid as mid
from open_water_site natural join monitor_privilege
);

create view cd_monitor_site as (
select cave_diving_site.sid as sid, monitor_privilege.mid as mid
from cave_diving_site natural join monitor_privilege
);

create view b30_monitor_site as (
select beyond_30m_site.sid as sid, monitor_privilege.mid as mid
from beyond_30m_site natural join monitor_privilege
);

create view ow as (
select count(distinct sid) as ow_num
from ow_monitor_site natural join monitor_cap
where monitor_cap.capacity_o > 0
);

create view cd as (
select count(distinct sid) as cd_num
from cave_diving_site natural join monitor_cap
where monitor_cap.capacity_c > 0
);

create view b30 as (
select count(distinct sid) as b30_num
from b30_monitor_site natural join monitor_cap
where monitor_cap.capacity_d > 0
);

insert into q1 
select ow_num, cd_num, b30_num
from ow, cd, b30;
