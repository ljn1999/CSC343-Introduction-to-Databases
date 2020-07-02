-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

CREATE VIEW n AS
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)


with recursive CTE as (
	(select inbound as dest, s_arv as arv_time, 1 as num
	 from flight
	 where outbound = 'YYZ' 
		and extract (year from s_dep) = (select extract (year from day) from day)
	 	and extract (month from s_dep) = (select extract (month from day) from day)
	 	and extract (day from s_dep) = (select extract (day from day) from day))
	UNION ALL
	(select inbound as dest, flight.s_arv as arv_time, num+1
	 from CTE join flight on CTE.dest = flight.outbound
	 where (s_dep - arv_time)< '24:00:00' and num < (select n from n))
		 
)


-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
select dest, num
from CTE;














