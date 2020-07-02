-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS flight_outCountry CASCADE;
DROP VIEW IF EXISTS flight_inCountry CASCADE;
DROP VIEW IF EXISTS domestic_flight CASCADE;
DROP VIEW IF EXISTS international_flight CASCADE;
DROP VIEW IF EXISTS domestic_35 CASCADE;
DROP VIEW IF EXISTS domestic_50 CASCADE;
DROP VIEW IF EXISTS international_35 CASCADE;
DROP VIEW IF EXISTS international_50 CASCADE;
DROP VIEW IF EXISTS domestic_35_price CASCADE;
DROP VIEW IF EXISTS domestic_50_price CASCADE;
DROP VIEW IF EXISTS international_35_price CASCADE;
DROP VIEW IF EXISTS international_50_price CASCADE;
DROP VIEW IF EXISTS refund_flights CASCADE;
DROP VIEW IF EXISTS join_flight CASCADE;
DROP VIEW IF EXISTS join_name CASCADE;
-- Define views for your intermediate steps here:
create view flight_outCountry(fid, outCountry,sdep,sarv) as(
select flight.id, airport.country,flight.s_dep, flight.s_arv
from flight, airport
where flight.outbound = airport.code
);

create view flight_inCountry(fid, inCountry,sdep,sarv) as(
select flight.id, airport.country,flight.s_dep, flight.s_arv
from flight, airport
where flight.inbound = airport.code
);

create view domestic_flight(fid, dcountry, acountry,sdep,sarv) as(
select flight_outCountry.fid, flight_outCountry.outCountry,flight_inCountry.inCountry,
flight_outCountry.sdep,flight_outCountry.sarv
from flight_outCountry join flight_inCountry on 
outCountry = inCountry and flight_outCountry.fid = flight_inCountry.fid
);

create view international_flight(fid, dcountry, acountry,sdep,sarv) as(
select flight_outCountry.fid, flight_outCountry.outCountry,flight_inCountry.inCountry,
flight_outCountry.sdep,flight_outCountry.sarv
from flight_outCountry join flight_inCountry on 
outCountry <> inCountry and flight_outCountry.fid = flight_inCountry.fid
);


create view domestic_35(fid, dcountry, acountry,sdep,sarv,actual_dep,actual_arv) as(
select domestic_flight.fid,
domestic_flight.dcountry,domestic_flight.acountry,
domestic_flight.sdep,domestic_flight.sarv,
departure.datetime,arrival.datetime
from domestic_flight,departure,arrival
where domestic_flight.fid = departure.flight_id and domestic_flight.fid = arrival.flight_id and
	(departure.datetime-domestic_flight.sdep)>='04:00:00' and
	(departure.datetime-domestic_flight.sdep)<'10:00:00' and
	(departure.datetime-domestic_flight.sdep)<=(arrival.datetime-domestic_flight.sarv)*2
);

create view domestic_50(fid, dcountry, acountry,sdep,sarv,actual_dep,actual_arv) as(
select domestic_flight.fid,
domestic_flight.dcountry,domestic_flight.acountry,
domestic_flight.sdep,domestic_flight.sarv,
departure.datetime,arrival.datetime
from domestic_flight,departure,arrival
where domestic_flight.fid = departure.flight_id and domestic_flight.fid = arrival.flight_id and
	(departure.datetime-domestic_flight.sdep)>='10:00:00' and
	(departure.datetime-domestic_flight.sdep)<=(arrival.datetime-domestic_flight.sarv)*2
);


create view international_35(fid, dcountry, acountry,sdep,sarv,actual_dep,actual_arv) as(
select international_flight.fid,
international_flight.dcountry,international_flight.acountry,
international_flight.sdep,international_flight.sarv,
departure.datetime,arrival.datetime
from international_flight,departure,arrival
where international_flight.fid = departure.flight_id and international_flight.fid = arrival.flight_id and
	(departure.datetime-international_flight.sdep)>='04:00:00' and
	(departure.datetime-international_flight.sdep)<'10:00:00' and
	(departure.datetime-international_flight.sdep)<=(arrival.datetime-international_flight.sarv)*2
);

create view international_50(fid, dcountry, acountry,sdep,sarv,actual_dep,actual_arv) as(
select international_flight.fid,
international_flight.dcountry,international_flight.acountry,
international_flight.sdep,international_flight.sarv,
departure.datetime,arrival.datetime
from international_flight,departure,arrival
where international_flight.fid = departure.flight_id and international_flight.fid = arrival.flight_id and
	(departure.datetime-international_flight.sdep)>='10:00:00' and
	(departure.datetime-international_flight.sdep)<=(arrival.datetime-international_flight.sarv)*2
);

create view domestic_35_price(fid, seat_class, amount,year) as(
select domestic_35.fid, booking.seat_class, (0.35*(booking.price)),extract(year from domestic_35.actual_arv)
from domestic_35,booking
where domestic_35.fid = booking.flight_id
);

create view domestic_50_price(fid, seat_class, amount,year) as(
select domestic_50.fid, booking.seat_class, (0.5*(booking.price)),extract(year from domestic_50.actual_arv)
from domestic_50,booking
where domestic_50.fid = booking.flight_id
);

create view international_35_price(fid, seat_class, amount,year) as(
select international_35.fid, booking.seat_class, (0.35*(booking.price)),extract(year from international_35.actual_arv)
from international_35,booking
where international_35.fid = booking.flight_id
);

create view international_50_price(fid, seat_class, amount,year) as(
select international_50.fid, booking.seat_class, (0.5*(booking.price)),extract(year from international_50.actual_arv)
from international_50,booking
where international_50.fid = booking.flight_id
);


create view refund_flights(fid,seat_class, amount,year) as(
(select * from domestic_35_price) union all
(select * from domestic_50_price) union all
(select * from international_35_price) union all
(select * from international_50_price)
);

create view join_flight(fid, airlinecode, seat_class, amount,year) as(
select refund_flights.fid, flight.airline, refund_flights.seat_class, refund_flights.amount, refund_flights.year
from flight, refund_flights
where flight.id = refund_flights.fid
);

create view join_name(airlinecode, airlinename, year, seat_class, amount) as(
select join_flight.airlinecode, airline.name,join_flight.year, join_flight.seat_class, join_flight.amount
from join_flight,airline
where airline.code = join_flight.airlinecode
);




-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2

select airlinecode, airlinename, year, seat_class, sum(amount)
from join_name
group by (airlinecode, airlinename, year, seat_class);
