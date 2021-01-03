-- Date Definition Language

create database wildfire;

use wildfire;

create table county (
	county_id int primary key auto_increment,
    county_name varchar(50) not null unique,
    seat_city varchar(50) not null,
    date_est varchar(50) not null,
    population int not null,
    area_sq_mi int not null);

create table rainfall (
	rainfall_id int primary key auto_increment,
    station_elevation double not null,
    month_recorded date not null,
    max_daily_precip double,
    total_monthly_precip double,
    county_id int not null,
	foreign key (county_id) references county(county_id));
    
create table drought_status (
	drought_id int primary key auto_increment,
    no_drought decimal not null,
    D0 decimal not null,
    D1 decimal not null,
    D2 decimal not null,
    D3 decimal not null,
    D4 decimal not null,
    valid_start date,
    valid_end date,
    county_id int not null,
    foreign key (county_id) references county(county_id));
    
create table air_quality (
	air_quality_id int primary key auto_increment,
    date date not null,
    aqi int not null,
    category varchar(45) not null,
    defining_parameter varchar(45) not null,
    defining_site varchar(45) not null,
    number_of_sites_reporting int not null,
    county_id int not null,
    foreign key (county_id) references county(county_id));
    
create table fire (
	fire_id int primary key auto_increment,
    acres_burned int not null,
    air_tankers int,
    crews_involved int,
    personnel int,
    dozers int,
    extinguished date,
    fatalities int,
    helicopters int,
    injuries int,
    latitude decimal not null,
    longitude decimal not null,
    major_incident tinyint not null,
    name varchar(45) not null,
    started date not null,
    structures_destroyed int,
    structures_damaged int,
    structures_evacuated int,
    structure_threatened int,
    water_tenders int,
    county_id int not null,
    foreign key (county_id) references county(county_id));
    
create table event (
	fire_id int,
    air_quality_id int not null,
    drought_id int not null,
    county_id int not null,
    date date not null,
	foreign key (fire_id) references fire(fire_id),
    foreign key (air_quality_id) references air_quality(air_quality_id),
    foreign key (drought_id) references drought_status(drought_id),
    foreign key (county_id) references county(county_id));

-- Data Manipulation Language

-- script to change empty string values to null for crew_involved table 
-- we ran this script for a lot of columns and just changed the values
update fire
set crew_involed = if(crew_involved = '', null, crew_involved);

-- Script to add values for primary key, initially data did not have primary keys, the columns were initially set as 
-- nullable ints and changed to primary keys after values were populated, this was done for the fire and drought_status tables as well
alter table `air_quality`
modify column `air_quality_id` int(32) unsigned primary key auto_increment;

-- inserting records into event table
insert into event 
select f.fire_id, a.air_quality_id, d.drought_id, a.county_id, a.date
from air_quality a
left join drought_status d on (a.date <= d.valid_end and a.date >= d.valid_start and d.county_id = a.county_id)
left join fire f on (a.county_id = f.county_id and a.date <= f.started and a.date >= f.extinguished);

-- Query to compare air quality with and without active fires
select nf.county_name, Average_AQI_without_Active_Fire, Average_AQI_with_Active_Fire
from 
(select c.county_name, avg(aqi) as 'Average_AQI_without_Active_Fire'
from event e 
join county c using(county_id)
join air_quality a using (air_quality_id)
where fire_id is null
group by e.county_id) nf
join 
(select c.county_name, avg(aqi) as 'Average_AQI_with_Active_Fire'
from event e 
join county c using(county_id)
join air_quality a using (air_quality_id)
where fire_id is not null
group by e.county_id) f
using (county_id);

-- Query computing disaster statistics by county from 2013-2019
select county_name, avg(aqi), sum(acres_burned), sum(d1), sum(d2), sum(d3), sum(d4)
from event e
left join fire f using(fire_id)
join drought_status d using(drought_id)
join air_quality a using(air_quality_id)
join county c on(c.county_id = e.county_id);

-- Query computing average time to extinguish a fire
select year(started), avg(datediff(extinguished, started)) as 'time_to_extinguish'
from fire
where extinguished is not null and extinguished > started and not year(started) = 1969
group by year(started)
order by time_to_extinguish desc;

-- Average Number of personnel per Acre Burned by County (County Population added for Reference)
select county_name, avg(personnel/acres_burned) as 'personnel_per_acre', population
from fire f
join county c using (county_id)
where personnel is not null
group by  f.county_id
order by personnel_per_acre desc;

-- Comparison of Acres Burned per Square Mile and Precipitation per Square Mile
select county_name as 'County Name', sum(acres_burned)/area_sq_mi as 'Acres Burned per Sq Mile', sum(total_monthly_precip)/area_sq_mi as 'Precipitation per Sq Mile'
from event e
join county c using (county_id)
left join fire f using (fire_id)
join rainfall r on (r.county_id = e.county_id and e.date > month_recorded and e.date <= date_add(month_recorded, interval 7 day))
group by county_name;

-- Acres Burned per Year
select year(started), sum(acres_burned)
from fire
group by year(started)
order by started desc;

-- Number of Structures Destroyed by Year
Select year(started), sum(structures_destroyed), count(*)
From fire 
Group by year(started);

-- Total Acres Burnt between 2013-19 by County
Select county_name, ifnull(sum(acres_burned), 0) as ‘total_acres_burnt’
From fire join county using (county_id)
Group by county_name;

-- Time Series Analysis of monthly average AQI for california vs. Total acres burnt from 2013-2019.
Select year(date), month(date), avg(aqi), ifnull(sum(acres_burned), 0) as 'acres burned'
from air_quality a
left join fire f on (a.county_id = f.county_id and a.date < f.started and adddate(a.date, interval 4 day) >= f.started)
Group by year(date), month(date);

-- When is the worst time of year to be living in california? At what time of year do the most fires and highest AQIs happen? When do the least fires happen?
select month(started) as 'month', count(distinct name) as 'num_fires'
From air_quality a
left join fire f on (a.county_id = f.county_id and a.date < f.started and adddate(a.date, interval 4 day) >= f.started)
group by month
order by month;

-- Where is the worst place to live in California? In terms of worst average air quality, drought, and % area burned (1 acre = 0.0015625 sq. miles)
Select county_name, ((sum(acres_burned)*0.0015625) / area_sq_miles) as ‘percent_area_burned’, avg(aqi)
from fire f join county c on (f.county_id = c.county_id)
join air_quality a on (a.county_id = f.count_id and a.date < f.started and adddate(a.date, interval 4 day) >= f.started)
Group by county_name
Order by ‘percent_area_burned’, avg(aqi);

-- Do the counties with the highest rainfall have less impactful fires? Can we compare Acres Burned per Square Mile and total Precipitation?
select county_name as 'County Name', sum(acres_burned)/area_sq_mi as 'Acres Burned per Sq Mile', sum(total_monthly_precip) as 'Precipitation'
from event e
join county c using (county_id)
left join fire f using (fire_id)
join rainfall r on (r.county_id = e.county_id and e.date > month_recorded and e.date <= date_add(month_recorded, interval 4 day))
group by county_name;

-- What is the average AQI vs Acres burnt in each county? Is there any correlation between the two variables? 
Select county_name, sum(acres_burned), avg(aqi), population
from event e
join county c using (county_id)
left join fire f using (fire_id)
join air_quality a using (air_quality_id)
group by name, county_name;

-- Do the Top 15 counties with the highest average percent area in exceptional drought (d4) have more fires over this time period? 
Select county_name, (sum(D4) / count(drought_id)) as ‘avg_percent_area_in_D4’, count(distinct fire_id)
From county join drought using (county_id)
Join fire using (county_id)
Group by county_name
Order by avg_percent_area_in_D4 desc
Limit 15;
