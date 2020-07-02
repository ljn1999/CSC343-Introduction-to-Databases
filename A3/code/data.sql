INSERT INTO wetworldschema.dive_site_info (sid, site_name, location, price) VALUES (1, 'Bloody Bay Marine Park', 'Little Cayman', 10);
INSERT INTO wetworldschema.dive_site_info (sid, site_name, location, price) VALUES (2, 'Widow Maker’s Cave', 'Montego Bay', 20);
INSERT INTO wetworldschema.dive_site_info (sid, site_name, location, price) VALUES (3, 'Crystal Bay', 'Crystal Bay', 15);
INSERT INTO wetworldschema.dive_site_info (sid, site_name, location, price) VALUES (4, 'Batu Bolong', 'Batu Bolong', 15);
INSERT INTO wetworldschema.dive_site_cap (sid, capacity_day, capacity_night, capacity_cave, capacity_deep) VALUES (1, 10, 10, 10, 10);
INSERT INTO wetworldschema.dive_site_cap (sid, capacity_day, capacity_night, capacity_cave, capacity_deep) VALUES (2, 10, 10, 10, 10);
INSERT INTO wetworldschema.dive_site_cap (sid, capacity_day, capacity_night, capacity_cave, capacity_deep) VALUES (3, 10, 10, 10, 10);
INSERT INTO wetworldschema.dive_site_cap (sid, capacity_day, capacity_night, capacity_cave, capacity_deep) VALUES (4, 10, 10, 10, 10);
INSERT INTO wetworldschema.dive_site_equip_price (sid, mask, fins) VALUES (1, 5, 10);
INSERT INTO wetworldschema.dive_site_equip_price (sid, mask, fins) VALUES (2, 3, 5);
INSERT INTO wetworldschema.dive_site_equip_price (sid, fins, computer) VALUES (3, 5, 20);
INSERT INTO wetworldschema.dive_site_equip_price (sid, mask, computer) VALUES (4, 10, 30);

INSERT INTO wetworldschema.monitor_info (mid, first_name) VALUES (1, 'Maria');
INSERT INTO wetworldschema.monitor_info (mid, first_name) VALUES (2, 'John');
INSERT INTO wetworldschema.monitor_info (mid, first_name) VALUES (3, 'Ben');

INSERT INTO wetworldschema.monitor_cap (mid, capacity_o, capacity_c, capacity_d) VALUES (1, 10, 5, 5);
INSERT INTO wetworldschema.monitor_cap (mid, capacity_o, capacity_c, capacity_d) VALUES (2, 15, 15, 15);
INSERT INTO wetworldschema.monitor_cap (mid, capacity_o, capacity_c, capacity_d) VALUES (3, 15, 5, 5);

INSERT INTO wetworldschema.monitor_privilege (mid, sid) VALUES (1, 1);
INSERT INTO wetworldschema.monitor_privilege (mid, sid) VALUES (1, 2);
INSERT INTO wetworldschema.monitor_privilege (mid, sid) VALUES (1, 3);
INSERT INTO wetworldschema.monitor_privilege (mid, sid) VALUES (2, 1);
INSERT INTO wetworldschema.monitor_privilege (mid, sid) VALUES (2, 3);
INSERT INTO wetworldschema.monitor_privilege (mid, sid) VALUES (3, 2);

INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (1, 1, 'night', 'cave dive', 25);
INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (1, 2, 'morning', 'open water', 10);
INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (1, 2, 'morning', 'cave dive', 20);
INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (1, 3, 'afternoon', 'open water', 15);
INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (1, 4, 'afternoon', 'open water', 30);
INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (2, 1, 'morning', 'cave dive', 15);
INSERT INTO wetworldschema.monitor_price (mid, sid, dive_time, dive_type, price) VALUES (3, 2, 'morning', 'cave dive', 20);

INSERT INTO wetworldschema.diver_info (did, first_name, birthday, certification, email) VALUES (1, 'Michael', '1967-03-15', 'PADI', 'michael@dm.org');
INSERT INTO wetworldschema.diver_info (did, first_name, last_name, certification, email) VALUES (2, 'Dwight', 'Schrute', null, 'dwight@dm.org');
INSERT INTO wetworldschema.diver_info (did, first_name, last_name, certification, email) VALUES (3, 'Jim', 'Halpert', null, 'jim@dm.org');
INSERT INTO wetworldschema.diver_info (did, first_name, last_name, certification, email) VALUES (4, 'Pam', 'Beesly', null, 'pam@dm.org');
INSERT INTO wetworldschema.diver_info (did, first_name, last_name, birthday, certification, email) VALUES (5, 'Andy', 'Beesly', '1973-10-10', 'PADI', 'andy@dm.org');
INSERT INTO wetworldschema.diver_info (did, first_name, certification) VALUES (6, 'Phyllis', null);
INSERT INTO wetworldschema.diver_info (did, first_name, certification) VALUES (7, 'Oscar', null);

INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date, monitor_rate) VALUES (1, 1, 1, 2, 'morning', 'open water', '2019-07-20', 2);
INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date, monitor_rate) VALUES (2, 1, 1, 2, 'morning', 'cave dive', '2019-07-21', 0);
INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date, monitor_rate) VALUES (3, 1, 3, 1, 'morning', 'cave dive', '2019-07-22', 5);
INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date) VALUES (4, 1, 1, 2, 'night', 'cave dive', '2019-07-22');
INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date, monitor_rate) VALUES (5, 5, 1, 3, 'afternoon', 'open water', '2019-07-22', 1);
INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date, monitor_rate) VALUES (6, 5, 3, 3, 'morning', 'cave dive', '2019-07-23', 0);
INSERT INTO wetworldschema.bookings (bid, lead_id, mid, sid, dive_time, dive_type, dive_date, monitor_rate) VALUES (7, 5, 3, 3, 'morning', 'cave dive', '2019-07-24', 2);

INSERT INTO wetworldschema.dive_site_type (sid, open_water, cave_dive) VALUES (2, True, True);
INSERT INTO wetworldschema.dive_site_type (sid, cave_dive) VALUES (1, True);
INSERT INTO wetworldschema.dive_site_type (sid, open_water, cave_dive) VALUES (3, True, True);

INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (1, 1, 2);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (1, 1, 3);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (1, 1, 4);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (1, 1, 5);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (2, 1, 2);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (2, 1, 3);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (3, 1, 3);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (5, 5, 2);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (5, 5, 3);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (5, 5, 4);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (5, 5, 1);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (5, 5, 6);
INSERT INTO wetworldschema.booking_lead_group (bid, lead_id, member_id) VALUES (5, 5, 7);

INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (1, 3, 3);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (2, 2, 0);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (2, 4, 1);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (2, 3, 1);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (3, 5, 4);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (3, 4, 5);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (3, 1, 2);
INSERT INTO wetworldschema.dive_site_rate (sid, did, site_rate) VALUES (3, 7, 3);
