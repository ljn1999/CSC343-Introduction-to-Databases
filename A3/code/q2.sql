SET SEARCH_PATH TO wetworldschema;

DROP TABLE IF EXISTS q2 CASCADE;
CREATE TABLE q2
(
    mid int,
    avg_price int,
    email varchar(100)
);

DROP VIEW IF EXISTS monitor_avg_rating CASCADE;
DROP VIEW IF EXISTS dive_site_avg_rating CASCADE;
DROP VIEW IF EXISTS monitor_site CASCADE;
DROP VIEW IF EXISTS monitor_rate_site CASCADE;
DROP VIEW IF EXISTS monitor_rate_site_rate CASCADE;
DROP VIEW IF EXISTS all_possible_monitors CASCADE;
DROP VIEW IF EXISTS fail_monitors CASCADE;
DROP VIEW IF EXISTS result_monitors CASCADE;
DROP VIEW IF EXISTS booking_result_monitor CASCADE;
DROP VIEW IF EXISTS booking_result_monitor_price CASCADE;
DROP VIEW IF EXISTS result CASCADE;

create view monitor_avg_rating as (
select mid, avg(monitor_rate) as m_rate
from bookings
group by mid
);

create view dive_site_avg_rating as (
select sid, avg(site_rate) as s_rate
from dive_site_rate
group by sid
);

create view monitor_site as (
select mid, sid
from bookings
);

create view monitor_rate_site as (
select monitor_site.mid as mid, m_rate, sid
from monitor_site, monitor_avg_rating
where monitor_site.mid = monitor_avg_rating.mid
);

create view monitor_rate_site_rate as (
select monitor_rate_site.mid as mid, m_rate, monitor_rate_site.sid, s_rate
from monitor_rate_site, dive_site_avg_rating
where monitor_rate_site.sid = dive_site_avg_rating.sid
);

create view all_possible_monitors as (
select mid
from bookings
);

create view fail_monitors as (
select mid
from monitor_rate_site_rate
where m_rate <= s_rate
);

create view result_monitors as (
(select mid from all_possible_monitors) EXCEPT (select mid from fail_monitors)
);

create view booking_result_monitor as (
select bid, bookings.mid, sid, dive_time, dive_type
from bookings, result_monitors
where bookings.mid = result_monitors.mid
);

create view booking_result_monitor_price as (
select booking_result_monitor.mid as mid, avg(price) as avg_price
from booking_result_monitor, monitor_price
where booking_result_monitor.sid = monitor_price.sid and booking_result_monitor.mid = monitor_price.mid
      and booking_result_monitor.dive_time = monitor_price.dive_time and booking_result_monitor.dive_type = monitor_price.dive_type
group by booking_result_monitor.mid
);

create view result as (
select booking_result_monitor_price.mid as mid, avg_price, email
from booking_result_monitor_price, monitor_info
where booking_result_monitor_price.mid = monitor_info.mid
);

INSERT INTO q2
select mid, avg_price, email
from result;
