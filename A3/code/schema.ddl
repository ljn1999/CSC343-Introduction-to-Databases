drop schema if exists wetworldschema cascade;
create  schema  wetworldschema;
set search_path to wetworldschema;

/*** constraints we did not enforce ***/
/* constraint 1: divers must be at least 16 when a dive occurs: because it's a cross table constraint */
/* constraint 2: for each booking group, the number of members of the group should not exceed the capacity of monitor
                 and also the capacity of the dive site: because it's a cross table constraint */
/* constraint 3: No monitor is allowed to book more than one dives per 24 hours: we chose not to enforce because it is
                 difficult to get other tuples of the same table and make summation */

/*** relations for later reference begins ***/
CREATE TABLE diver_info( /* this relation provides basic information about divers */
                           did INT PRIMARY KEY, /* id of divers */
                           first_name VARCHAR(100) NOT NULL, /* first name of divers */
                           last_name VARCHAR(100), /* last name of divers (can be null) */
                           birthday DATE, /* date of birth of divers */
                           certification VARCHAR(4) CHECK (certification IN (null, 'NAUI', 'CMAS', 'PADI')), /* certification type of divers */
                           email VARCHAR(100) /* email address of divers */
);

create table monitor_info( /* this relation provides basic information about monitors */
                           mid INT PRIMARY KEY, /* id of monitors */
                           first_name VARCHAR(100) NOT NULL, /* first name of monitors */
                           last_name VARCHAR(100), /* last name of monitors (can be null) */
                           email VARCHAR(100) /* email of monitors */
);

create table dive_site_info( /* this relation provides basic information about dive sites */
                           sid INT PRIMARY KEY, /* id of dive sites */
                           site_name VARCHAR(100) NOT NULL, /* name of dive sites */
                           location VARCHAR(100) NOT NULL, /* location of dive sites */
                           price FLOAT NOT NULL /* price of dive sites */
);
/*** relations for later reference ends ***/

/*** more information about monitors begins ***/
create table monitor_privilege( /* this relation provides the privileges of monitors */
                           mid INT NOT NULL REFERENCES monitor_info, /* id of monitors */
                           sid INT NOT NULL REFERENCES dive_site_info, /* privileged dive sites of monitors */
                           PRIMARY KEY(mid, sid) /* a minotor can have multiple privileged dive sites */
);

create table monitor_price( /* this relation provides the price monitor service charges (the price of dive site does not count) */
                            /* a monitor has different charges in different time and different dive type */
                           mid INT NOT NULL REFERENCES monitor_info, /* id of monitors */
                           sid INT NOT NULL REFERENCES dive_site_info, /* id of dive sites */
                           dive_time VARCHAR(50) CHECK (dive_time IN ('morning', 'afternoon', 'night')), /* monitor's dive time */
                           dive_type VARCHAR(50) CHECK (dive_type IN ('open water', 'cave dive', 'deeper than 30 meters')), /* monitor's dive type */
                           price FLOAT NOT NULL, /* price the monitor charges */
                           PRIMARY KEY(mid, sid, dive_time, dive_type) /* a monitor has different charges in different time and different dive type */
);

create table monitor_cap( /* this relation provides the capcity of monitors */
                          /* a monitor has different capacity for different dive type */
                           mid INT NOT NULL REFERENCES monitor_info PRIMARY KEY, /* id of monitors */
                           capacity_o INT DEFAULT 0 CHECK (capacity_o >= 0), /* the monitor's capacity for open water should be >= 0 */
                           capacity_c INT DEFAULT 0 CHECK (capacity_c >= 0), /* the monitor's capacity for cave diving should be >= 0 */
                           capacity_d INT DEFAULT 0 CHECK (capacity_d >= 0) /* the monitor's capacity for deeper than 30 meters should be >= 0 */
);
/*** more information about monitors ends ***/

/*** more information about dive sites begins ***/
create table dive_site_type( /* this relation provides what types of diving each dive site provides */
                           sid INT NOT NULL REFERENCES dive_site_info, /* id of dive sites */
                           open_water BOOLEAN DEFAULT FALSE, /* provide open water or not */
                           cave_dive BOOLEAN DEFAULT FALSE, /* provide cave dive or not */
                           deeper_than_30_meters BOOLEAN DEFAULT FALSE, /* provide deeper dive or not */
                           PRIMARY KEY(sid) /* a dive site can provide multiple types of diving */
);

create table dive_site_cap( /* this relation provides the capacity of each dive site, cap depends on both time and type */
                           sid INT NOT NULL REFERENCES dive_site_info PRIMARY KEY, /* id of dive sites */
                           capacity_day INT DEFAULT 0 CHECK (capacity_day >= 0), /* capacity of daylight diving should be >= 0 */
                           capacity_night INT DEFAULT 0 CHECK (capacity_day >= capacity_night and capacity_night >= 0), /* capacity for night should >= 0 and smaller than capacity of daylight diving */
                           capacity_cave INT DEFAULT 0 CHECK (capacity_day >= capacity_cave and capacity_cave >= 0), /* capacity for cave should >= 0 and smaller than capacity of daylight diving */
                           capacity_deep INT DEFAULT 0 CHECK (capacity_day >= capacity_deep and capacity_deep >= 0) /* capacity for deeper should >= 0 and smaller than capacity of daylight diving */

);

create table dive_site_equip_price( /* this relation indicates what equipment each dive site provides and how much the equipments charge */
                           sid INT NOT NULL REFERENCES dive_site_info, /* id of dive sites */
                           mask FLOAT CHECK (mask >= 0), /* price of mask, should be >=0 */
                           regulator FLOAT CHECK (regulator >= 0), /* price of regulator, should be >= 0 */
                           fins FLOAT CHECK (fins >= 0), /* price of fins, should be >= 0 */
                           computer FLOAT CHECK (computer >= 0), /* price of computer, should be >= 0 */
                           video BOOLEAN, /* the dive site provides free video or not */
                           snack BOOLEAN, /* the dive site provides free snack or not */
                           hot_shower BOOLEAN, /* the dive site provides free hot_shower or not */
                           towel BOOLEAN, /* the dive site provides free towel or not */
                           PRIMARY KEY(sid)
);
/*** more information about dive sites ends ***/

/*** relation connecting divers, monitors and dive sites begins ***/
create table bookings( /* this relation provides booking information */
                           bid INT PRIMARY KEY, /* booking id */
                           lead_id INT NOT NULL REFERENCES diver_info, /* lead diver's id of the booking */
                           mid INT NOT NULL REFERENCES monitor_info, /* monitor's id of the booking */
                           sid INT NOT NULL REFERENCES dive_site_info, /* dive site id of the booking */
                           dive_time VARCHAR(50) NOT NULL CHECK (dive_time IN ('morning', 'afternoon', 'night')), /* dive time of the booking */
                           dive_type VARCHAR(50) NOT NULL CHECK (dive_type IN ('open water', 'cave dive', 'deeper than 30 meters')), /* dive type of the booking */
                           dive_date DATE NOT NULL, /* date of schedule */
                           credit_card INT, /* credit card number of the booking */
                           monitor_rate INT CHECK (monitor_rate>=0 and monitor_rate<=5), /* monitor's rate made by the lead, can be null, if not null, should be an int between 0 to 5 */
                           UNIQUE(lead_id, dive_date, dive_time) /* a lead diver cannot book more than 1 diving in the same date and time */
);
/*** relation connecting divers, monitors and dive sites ends ***/

/*** relation connecting lead divers and group member divers begins ***/
create table booking_lead_group( /* this relation provides what a booking group is made up of */
                           bid INT NOT NULL REFERENCES bookings, /* booking id */
                           lead_id INT NOT NULL REFERENCES diver_info, /* lead diver's id of the booking */
                           member_id INT NOT NULL REFERENCES diver_info, /* group member's id of the booking */
                           PRIMARY KEY(bid, lead_id, member_id) /* a lead diver can lead multiple divers per booking */
);
/*** relation connecting lead divers and group member divers ends ***/

/*** relation connecting booking and dive site begins ***/
create table dive_site_rate( /* this relation indicates the divers' rate towards the dive site through bookings */
                           sid INT NOT NULL REFERENCES dive_site_info, /* dive site id */
                           did INT NOT NULL REFERENCES diver_info, /* id of diver who makes the rate */
                           site_rate INT CHECK (site_rate>=0 and site_rate<=5), /* rate can be null, and if not null, should be an int between 0 to 5 */
                           PRIMARY KEY(sid, did) /* divers can make at most one rate per booking */
);
/*** relation connecting booking and dive site ends ***/

/*** relation connecting booking and divers begins ***/
create table booking_equipment( /* the relation indicates what the divers used for each booking, will be used for price calculation */
                           bid INT NOT NULL REFERENCES bookings, /* booking id */
                           equip VARCHAR(100) NOT NULL CHECK (equip IN ('mask', 'regulator', 'fins', 'computer')), /* what equipment the lead diver booked */
                           quantity INT NOT NULL, /* how many equipment the diver group booked */
                           PRIMARY KEY(bid, equip) /* in each booking, each diver can use multiple equipments */
);
/*** relation connecting booking and divers ends ***/
