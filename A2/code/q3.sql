-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS flight_430 CASCADE;
DROP VIEW IF EXISTS airportin CASCADE;
DROP VIEW IF EXISTS airportio CASCADE;
DROP VIEW IF EXISTS direct CASCADE;
DROP VIEW IF EXISTS count_direct CASCADE;
DROP VIEW IF EXISTS onecon CASCADE;
DROP VIEW IF EXISTS count_onecon CASCADE;
DROP VIEW IF EXISTS twocon CASCADE;
DROP VIEW IF EXISTS count_twocon CASCADE;
DROP VIEW IF EXISTS join_routes CASCADE;
DROP VIEW IF EXISTS earliest CASCADE;
DROP VIEW IF EXISTS join_count2 CASCADE;
DROP VIEW IF EXISTS join_count3 CASCADE;
DROP VIEW IF EXISTS join_count_time CASCADE;
DROP VIEW IF EXISTS CAD_city CASCADE;
DROP VIEW IF EXISTS USA_city CASCADE;
DROP VIEW IF EXISTS city_pair CASCADE;
DROP VIEW IF EXISTS nozero CASCADE;

-- Define views for your intermediate steps here:
create view flight_430(outairport, inairport, s_dep, s_arv) as(
select outbound, inbound, s_dep, s_arv
from flight 
where extract(day from s_dep)=30 and extract(month from s_dep)=04 and extract(year from s_dep)=2020 and
extract(day from s_arv)=30 and extract(month from s_arv)=04 and extract(year from s_arv)=2020
);

create view airportin(outairport, inairport, s_dep, s_arv,incity,incountry) as(
select flight_430.outairport, flight_430.inairport, flight_430.s_dep, flight_430.s_arv, airport.city, airport.country
from flight_430, airport
where airport.code = flight_430.inairport
);

create view airportio(outairport, inairport, s_dep, s_arv,incity,incountry,outcity,outcountry) as(
select airportin.outairport, airportin.inairport, airportin.s_dep, airportin.s_arv, airportin.incity, airportin.incountry, airport.city, airport.country
from airportin, airport
where airport.code = airportin.outairport
);

create view direct(outairport, inairport, s_dep, s_arv,incity,incountry,outcity,outcountry) as(
select outairport, inairport, s_dep, s_arv,incity,incountry,outcity,outcountry
from airportio
where (incountry = 'Canada' and outcountry = 'USA') or (incountry = 'USA' and outcountry = 'Canada')
);

create view count_direct(outcity,incity,count_route) as(
select direct.outcity, direct.incity, count(*)
from direct
group by (outcity,incity)
); 

create view onecon(outairport, inairport, s_dep, s_arv,incity,incountry,outcity,outcountry) as(
select a1.outairport,a2.inairport,a1.s_dep,a2.s_arv,a2.incity,a2.incountry,a1.outcity,a1.outcountry
from airportio a1, airportio a2
where a1.inairport = a2.outairport and a2.s_dep - a1.s_arv >= '00:30:00' and ((a1.outcountry = 'Canada' and a2.incountry = 'USA') or (a1.outcountry = 'USA' and a2.incountry = 'Canada'))
);

create view count_onecon(outcity,incity,count_route) as(
select onecon.outcity, onecon.incity, count(*)
from onecon
group by (outcity,incity)
); 

create view twocon(outairport, inairport, s_dep, s_arv,incity,incountry,outcity,outcountry) as(
select a1.outairport,a3.inairport,a1.s_dep, a3.s_arv, a3.incity, a3.incountry,a1.outcity,a1.outcountry
from airportio a1, airportio a2, airportio a3
where a1.inairport = a2.outairport and a2.inairport = a3.outairport
	and a2.s_dep - a1.s_arv >= '00:30:00' and a3.s_dep - a2.s_arv >= '00:30:00'
	and ((a1.outcountry = 'Canada' and a3.incountry = 'USA') or (a1.outcountry = 'USA' and a3.incountry = 'Canada'))
);

create view count_twocon(outcity,incity,count_route) as(
select twocon.outcity, twocon.incity, count(*)
from twocon
group by (outcity,incity)
); 

create view join_routes as(
(select * from direct) union all
(select * from onecon) union all
(select * from twocon)
);

create view earliest(outcity, incity, earliest_arv) as(
select join_routes.outcity, join_routes.incity, min(s_arv)
from join_routes
group by (outcity, incity)
);

create view join_count2(outcity, incity, count_direct, count_onecon) as(
select count_direct.outcity, count_direct.incity, count_direct.count_route, count_onecon.count_route
from count_direct full join count_onecon
on count_direct.outcity = count_onecon.outcity and count_direct.incity = count_onecon.incity 
);

create view join_count3(outcity, incity, count_direct, count_onecon, count_twocon) as(
select join_count2.outcity, join_count2.incity, join_count2.count_direct, join_count2.count_onecon, count_twocon.count_route
from join_count2 full join count_twocon
on join_count2.outcity = count_twocon.outcity and join_count2.incity = count_twocon.incity 
);

create view join_count_time(outcity, incity, count_direct, count_onecon, count_twocon, earliest_time) as(
select join_count3.outcity, join_count3.incity, join_count3.count_direct, join_count3.count_onecon, join_count3.count_twocon, earliest.earliest_arv
from join_count3 join earliest
on join_count3.outcity = earliest.outcity and join_count3.incity = earliest.incity 
);

create view CAD_city(CAD_city) as(
select city
from airport
where country = 'Canada'
);

create view USA_city(USA_city) as(
select city
from airport
where country = 'USA'
);

create view city_pair(outcity, incity) as(
(select CAD_city.CAD_city, USA_city.USA_city
from CAD_city, USA_city) union
(select USA_city.USA_city, CAD_city.CAD_city
from CAD_city, USA_city)
);

create view nozero(outcity,incity, count_direct, count_onecon, count_twocon, earliest) as(
select city_pair.outcity, city_pair.incity, 
join_count_time.count_direct, join_count_time.count_onecon, join_count_time.count_twocon, 
join_count_time.earliest_time
from city_pair full join join_count_time
on city_pair.outcity = join_count_time.outcity and city_pair.incity = join_count_time.incity
);




-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
select outcity,incity, coalesce(count_direct, 0), coalesce(count_onecon, 0), coalesce(count_twocon, 0), earliest
from nozero





















