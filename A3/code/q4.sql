SET SEARCH_PATH TO wetworldschema;

DROP TABLE IF EXISTS q4 CASCADE;
CREATE TABLE q4
(
    sid int,
    highest int,
    lowest int,
    average int
);

DROP VIEW IF EXISTS booking_count_without_leader CASCADE;
DROP VIEW IF EXISTS booking_count CASCADE;
DROP VIEW IF EXISTS site_monitor_booking_count CASCADE;
DROP VIEW IF EXISTS booking_site_price CASCADE;
DROP VIEW IF EXISTS booking_site_monitor_price CASCADE;
DROP VIEW IF EXISTS booking_equipment_site CASCADE;
DROP VIEW IF EXISTS booking_equipment_mask_price CASCADE;
DROP VIEW IF EXISTS booking_equipment_regulator_price CASCADE;
DROP VIEW IF EXISTS booking_equipment_fins_price CASCADE;
DROP VIEW IF EXISTS booking_equipment_computer_price CASCADE;
DROP VIEW IF EXISTS booking_equipment_price CASCADE;
DROP VIEW IF EXISTS site_fee CASCADE;

create view booking_count_without_leader as (
select bid, count(*) as member_count
from booking_lead_group
group by bid
);

create view booking_count as (
select bookings.bid, coalesce(member_count, 0)+1 as member_count
from booking_count_without_leader full join bookings
on booking_count_without_leader.bid = bookings.bid
);

create view site_monitor_booking_count as (
select booking_count.bid, sid, mid, member_count, dive_time, dive_type
from bookings, booking_count
where bookings.bid = booking_count.bid
);

create view booking_site_price as (
select bid, site_monitor_booking_count.sid as sid, mid, dive_time, dive_type, (price * member_count) as site_price
from site_monitor_booking_count, dive_site_info
where site_monitor_booking_count.sid = dive_site_info.sid
);

create view booking_site_monitor_price as (
select bid, booking_site_price.sid as sid, site_price, case when price is null then 0 else price end as monitor_price
from booking_site_price left join monitor_price
on booking_site_price.mid = monitor_price.mid and booking_site_price.sid = monitor_price.sid
and booking_site_price.dive_time = monitor_price.dive_time and booking_site_price.dive_type = monitor_price.dive_type
);

create view booking_equipment_site as (
select booking_equipment.bid as bid, sid, equip, quantity
from booking_equipment, bookings
where bookings.bid = booking_equipment.bid
);

create view booking_equipment_mask_price as (
select bid, quantity * mask as mask_price
from booking_equipment_site, dive_site_equip_price
where booking_equipment_site.sid = dive_site_equip_price.sid and equip = 'mask'
);

create view booking_equipment_regulator_price as (
select bid, quantity * regulator as regulator_price
from booking_equipment_site, dive_site_equip_price
where booking_equipment_site.sid = dive_site_equip_price.sid and equip = 'regulator'
);

create view booking_equipment_fins_price as (
select bid, quantity * fins as fins_price
from booking_equipment_site, dive_site_equip_price
where booking_equipment_site.sid = dive_site_equip_price.sid and equip = 'fins'
);

create view booking_equipment_computer_price as (
select bid, quantity * computer as computer_price
from booking_equipment_site, dive_site_equip_price
where booking_equipment_site.sid = dive_site_equip_price.sid and equip = 'computer'
);

create view booking_equipment_price as (
select bid, (mask_price + regulator_price + fins_price + computer_price) as equip_price
from booking_equipment_mask_price natural join booking_equipment_regulator_price
natural join booking_equipment_fins_price natural join booking_equipment_computer_price
);

create view site_fee as (
select sid, max(coalesce(equip_price, 0) + site_price + monitor_price) as highest, min(coalesce(equip_price, 0) + site_price + monitor_price) as lowest, avg(coalesce(equip_price, 0) + site_price + monitor_price) as average
from booking_site_monitor_price left join booking_equipment_price
on booking_site_monitor_price.bid = booking_equipment_price.bid
group by sid
);

INSERT INTO q4
select sid, highest, lowest, average
from site_fee;
