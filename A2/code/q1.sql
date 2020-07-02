-- Q1. Airlines

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
    pass_id INT,
    name VARCHAR(100),
    airlines INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Took_flight CASCADE;
DROP VIEW IF EXISTS Took_flight_passenger CASCADE;

-- Define views for your intermediate steps here:
create view Took_flight(fid,airline) AS(
select Flight.id, Flight.airline
from Flight, Departure
where Flight.id = Departure.flight_id);

create view Took_flight_passenger(pid,fid,airline) As(
select Booking.pass_id, Took_flight.fid, Took_flight.airline
from Booking join Took_flight on Booking.flight_id = Took_flight.fid);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
select Passenger.id, Passenger.firstname||' '||Passenger.surname, count(distinct airline)
from Passenger left join Took_flight_passenger on Took_flight_passenger.pid = Passenger.id
group by Passenger.id;
