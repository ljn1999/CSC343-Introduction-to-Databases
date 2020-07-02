-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS happened_flight CASCADE;
DROP VIEW IF EXISTS plane_info CASCADE;
DROP VIEW IF EXISTS flight_passenger CASCADE;
DROP VIEW IF EXISTS plane_cap_percent CASCADE;
DROP VIEW IF EXISTS very_low CASCADE;
DROP VIEW IF EXISTS low CASCADE;
DROP VIEW IF EXISTS fair CASCADE;
DROP VIEW IF EXISTS normal CASCADE;
DROP VIEW IF EXISTS high CASCADE;
DROP VIEW IF EXISTS allplane CASCADE;
DROP VIEW IF EXISTS join1 CASCADE;
DROP VIEW IF EXISTS join2 CASCADE;
DROP VIEW IF EXISTS join3 CASCADE;
DROP VIEW IF EXISTS join4 CASCADE;
DROP VIEW IF EXISTS join5 CASCADE;

-- Define views for your intermediate steps here:
create view happened_flight(fid, tailnumber) as(
select flight.id, flight.plane
from flight, departure
where flight.id = departure.flight_id
);

create view plane_info(fid,tailnumber,cap) as(
select happened_flight.fid, happened_flight.tailnumber, (plane.capacity_economy+plane.capacity_business+plane.capacity_first)
from happened_flight, plane
where happened_flight.tailnumber = plane.tail_number
);

create view flight_passenger(fid, num_passenger) as(
select happened_flight.fid, count(booking.id)
from booking right join happened_flight
on booking.flight_id = happened_flight.fid
group by happened_flight.fid
);

create view plane_cap_percent(fid, tailnumber, cap_percent) as(
select plane_info.fid, plane_info.tailnumber, (flight_passenger.num_passenger*100/plane_info.cap)
from plane_info, flight_passenger
where plane_info.fid = flight_passenger.fid
);

create view very_low(tailnumber, count_very_low) as(
select tailnumber, count(fid)
from plane_cap_percent
where cap_percent >= 0 and cap_percent <= 20
group by tailnumber
);

create view low(tailnumber, count_low) as(
select tailnumber, count(fid)
from plane_cap_percent
where cap_percent > 20 and cap_percent <= 40
group by tailnumber
);

create view fair(tailnumber, count_fair) as(
select tailnumber, count(fid)
from plane_cap_percent
where cap_percent > 40 and cap_percent <= 60
group by tailnumber
);

create view normal(tailnumber, count_normal) as(
select tailnumber, count(fid)
from plane_cap_percent
where cap_percent > 60 and cap_percent <= 80
group by tailnumber
);

create view high(tailnumber, count_high) as(
select tailnumber, count(fid)
from plane_cap_percent
where cap_percent > 80
group by tailnumber
);

create view allplane(airline,tailnumber) as(
select airline, tail_number
from plane
);

create view join1(airline,tailnumber,very_low) as(
select allplane.airline, allplane.tailnumber, very_low.count_very_low
from allplane natural left join very_low
);

create view join2(airline,tailnumber,very_low, low) as(
select join1.airline, join1.tailnumber, join1.very_low, low.count_low
from join1 natural left join low
);

create view join3(airline,tailnumber,very_low,low,fair) as(
select join2.airline, join2.tailnumber, join2.very_low, join2.low, fair.count_fair
from join2 natural left join fair
);

create view join4(airline,tailnumber,very_low,low,fair,normal) as(
select join3.airline, join3.tailnumber, join3.very_low, join3.low, join3.fair, normal.count_normal
from join3 natural left join normal
);

create view join5(airline,tailnumber,very_low,low,fair,normal,high) as(
select join4.airline, join4.tailnumber, join4.very_low, join4.low, join4.fair, join4.normal, high.count_high
from join4 natural left join high
);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
select airline,tailnumber,coalesce(very_low, 0),coalesce(low, 0),coalesce(fair, 0),coalesce(normal, 0),coalesce(high, 0)
from join5;


