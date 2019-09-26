--Creating new view with no empty observations
CREATE VIEW obs_noempty AS
SELECT *
FROM observation
WHERE obstime <> '';

--Ordering duplicates by groups:
WITH cte AS (
SELECT 
    species,
	observer,
    obsdate,
    COUNT(*) occurrences
FROM obs_noempty
GROUP BY
    species,
	observer,
    obsdate
HAVING 
    COUNT(*) > 1
)
SELECT 
	tab1.id,
	tab1.species,
	tab1.observer,
	tab1.obsdate,
	tab1.block,
	tab1.longit,
	tab1.latit,
	tab1.obstime
FROM obs_noempty AS tab1
	INNER JOIN cte ON
		cte.species = tab1.species AND
		cte.observer = tab1.observer AND
		cte.obsdate = tab1.obsdate 
ORDER BY
	tab1.species,
	tab1.observer,
	tab1.obsdate;
	

--Deleting duplicates
CREATE VIEW nodup AS
WITH CTE AS (
    SELECT
        	t1.id,
       	t1.species, 
       	t1.observer, 
       	t1.obsdate,
	t1.block,
	t1.longit,
	t1.latit,
	
ROW_NUMBER()OVER(PARTITION BY species, observer, obsdate ORDER BY species) as RN
	FROM obs_noempty as t1
)
SELECT * FROM CTE WHERE RN = 1;

--adding holidays and month to days 
create table days as
select * from days;

select * from days;
ALTER TABLE days
ALTER COLUMN mdate TYPE varchar;

alter table days
add dmonth varchar;

update days
set dmonth='jan' 
where mdate LIKE '201701%';

update days
set dmonth='feb' 
where mdate LIKE '201702%';

update days
set dmonth='mar' 
where mdate LIKE '201703%';

update days
set dmonth='apr' 
where mdate LIKE '201704%';

update days
set dmonth='may' 
where mdate LIKE '201705%';

update days
set dmonth='jun' 
where mdate LIKE '201706%';

alter table days
add holidays int;

update days
set holidays = 1
where dow = 0 OR dow = 6;

update days
set holidays = 1
where natholiday = 'true';

update days
set holidays = 0
where holidays isNULL;

--Creating the observer intensity 
create table obs_ins as
	select block, count(id),obsdate from nodup group by obsdate,block;

--Change obsintencity date type column to varchar
ALTER TABLE obs_ins
ALTER COLUMN obsdate TYPE varchar;

--Remove character from date in table
UPDATE obs_ins
SET obsdate = REPLACE (obsdate, '-','');

--Creating month column 

alter table obs_ins
add dmonth varchar;

update obs_ins
set dmonth='jan' 
where obsdate LIKE '201701%';

update obs_ins
set dmonth='feb' 
where obsdate LIKE '201702%';

update obs_ins
set dmonth='mar' 
where obsdate LIKE '201703%';

update obs_ins
set dmonth='apr' 
where obsdate LIKE '201704%';

update obs_ins
set dmonth='may' 
where obsdate LIKE '201705%';

update obs_ins
set dmonth='jun' 
where obsdate LIKE '201706%';

--Eliminate the duplicates in precipitation
create table precip as
select * from public.precipitation;

alter table precip
ALTER COLUMN dtime TYPE varchar;

create table precipitation as 
select avg(precip), dtime, block from precip
group by dtime, block;

--Eliminate the duplicates in temperature
create table temper as
select * from public.temperature;

alter table temper
ALTER COLUMN dtime TYPE varchar;

create table temperature as 
select avg(temper), dtime, block from public.temperature
group by dtime, block;

--Adding the temperature column to the intensity table
create table observer2 as 
select obs_ins.dmonth,obs_ins.count, obs_ins.block, obs_ins.obsdate, temperature.avg  from 
obs_ins
inner join temperature on 
obs_ins.block = temperature.block and 
obs_ins.obsdate = cast(temperature.dtime as varchar);

alter table observer2
add temper double precision; 

update observer2 
set temper = observer2.avg 
where block > 0; 

--Adding the precipitation to the observer intensity

create table observer3 as 
select observer2.count, observer2.dmonth, observer2.block, observer2.obsdate, observer2.temper, precipitation.avg 
from observer2
inner join precipitation on 
observer2.block = precipitation.block and 
observer2.obsdate = cast(precipitation.dtime as varchar);

alter table observer3
add precip double precision;

update observer3
set precip = observer3.avg 
where block > 0; 

--Copying and creating the final table with all the parameters and target variable
create table obs_ins_month as
select * from observer3;

select sum(observer3.count), precip,temper from obs_ins_month group by dmonth;

--Removing not required columns for the ml 

alter table obs_ins_month
drop column block;

alter table obs_ins_month
drop column dmonth;

alter table obs_ins_month
drop column obsdate;

--creating month wise tables

create table obs_ins_jan as
select observer3.count, precip, temper, road, biodiverse from observer3 where dmonth = 'jan';

create table obs_ins_feb as
select observer3.count, precip, temper, road, biodiverse from observer3 where dmonth = 'feb';

create table obs_ins_mar as
select observer3.count, precip, temper, road, biodiverse from observer3 where dmonth = 'mar';

create table obs_ins_apr as
select observer3.count, precip, temper, road, biodiverse from observer3 where dmonth = 'apr';

create table obs_ins_may as
select observer3.count, precip, temper, road, biodiverse from observer3 where dmonth = 'may';

create table obs_ins_jun as
select observer3.count, precip, temper, road, biodiverse from observer3 where dmonth = 'jun';

--Month wise precipitation average for the block

create table Mon_precip as 
select dmonth, block, sum(observer3.count), avg(observer3.precip) from observer3 group by dmonth,block;

alter table Mon_precip
add precip double precision;

update mon_precip
set precip = mon_precip.avg;

--Month wise temperaature average for the block


create table mon_temper as 
select dmonth, block, sum(observer3.count), avg(observer3.temper) from observer3 group by dmonth,block;

alter table mon_temper
add temper double precision;

update mon_temper
set temper = mon_temper.avg;

--MONTH WISE AGGREGATION

create table test1 as
select mon_temper.block,mon_temper.sum, mon_temper.temper, mon_precip.precip
from mon_temper
inner join mon_precip
on mon_temper.dmonth = mon_precip.dmonth and mon_temper.block = mon_precip.block;

-- adding biodiverse

alter table test1
add biodiverse int;

UPDATE test1 
SET biodiverse = biodiversity.aves2012_2016 
FROM biodiversity 
WHERE test1.block = biodiversity.block;

update test1 
set biodiverse = 0
where biodiverse isNULL;

--adding holidays

alter table test1
add holidays int;

UPDATE test1 
SET holidays = days.holidays
FROM days
WHERE test1.dmonth = days.dmonth;

update test1 
set holidays = 0
where holidays isNULL;

--adding road length

alter table test1
add road double precision;


UPDATE test1
SET road = block_road_access.roadlength 
FROM block_road_access 
WHERE test1.block = block_road_access.block;

update test1 
set road = 0
where road isNULL;

--THE FINAL MONTHWISE TABLE WITH THE AVERAGE TEMPERATURE AND PRECIPITATION

create table monthwise as 
select test1.sum, temper, precip, biodiverse, road, holidays from test1;