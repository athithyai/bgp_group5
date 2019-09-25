--Checking null values in data
SELECT *
FROM observation_noempty
WHERE species = '' OR species IS NULL OR observer = '' OR observer IS NULL OR obsdate IS NULL OR block IS NULL OR latit IS NULL OR longit IS NULL;

--Creating new view with no empty observations
CREATE VIEW observation_noempty AS
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
FROM observation_noempty
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
FROM observation_noempty AS tab1
	INNER JOIN cte ON
		cte.species = tab1.species AND
		cte.observer = tab1.observer AND
		cte.obsdate = tab1.obsdate 
ORDER BY
	tab1.species,
	tab1.observer,
	tab1.obsdate;
	

--Deleting duplicates
CREATE VIEW observation_noempty_nodup AS
WITH CTE AS (
    SELECT
        	t1.id,
       	t1.species, 
       	t1.observer, 
       	t1.obsdate,
	t1.block,
	t1.longit,
	t1.latit
	
ROW_NUMBER()OVER(PARTITION BY species, observer, obsdate ORDER BY species) as RN
	FROM observation_noempty as t1
)
SELECT * FROM CTE WHERE RN = 1;

--Creating the observer intensity 
create table obs_intensity as
	select block,obsdate, count(id) from observation_noempty_nodup;

--Change obsintencity date type column to varchar
ALTER TABLE obs_intensity
ALTER COLUMN obsdate TYPE varchar;

--Remove character from date in table
UPDATE obs_intensity
SET obsdate = REPLACE (obsdate, '-','');

--Creating dtime column
alter table obs_intensity 
add dtime varchar;

update obs_intensity 
set dtime = obsdate where 
block > 0;

--Eliminate the duplicates in precipitation
create table precipitation as 
select avg(precip), dtime, block from public.precipitation
group by dtime, block

--Changing date to string
ALTER TABLE precipitation
ALTER COLUMN dtime TYPE varchar;

--Eliminate the duplicates in temperature
create table temperature as 
select avg(temper), dtime, block from public.temperature
group by dtime, block

--Changing date to string
ALTER TABLE temperature
ALTER COLUMN dtime TYPE varchar;

--Adding the temperature column to the intensity table
create table observer2 as 
select obs_intensity.block, obs_intensity.dtime, temperature.avg  from 
obs_intensity
inner join temperature on 
obs_intensity.block = temperature.block and 
obs_intensity.dtime = temperature.dtime;

alter table observer2
add column temper;

update table observer2 
set temper = observer2.avg 
where block > 0; 

alter table observer2
drop column observer2.avg;

--Adding the precipitation to the observer intensity

create table observer3 as 
select observer2.block, observer2.dtime, observer2.temper, precipitation.avg 
from observer2
inner join precipication on 
obs_intensity.block = precipitation.block and 
obs_intensity.dtime = precipitation.dtime;

alter table observer3
add column precip;

update table observer3
set precip = observer3.avg 
where block > 0; 

alter table observer3
drop column observer3.avg;

--Adding the various landuse categories

alter table observer3 
add built_up int;

UPDATE observer3 
SET built_up = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Bebouwd';

update observer3 
set built_up = 0
where built_up isNULL;

alter table observer3 
add drynaturalterrain int;

UPDATE observer3 
SET drynaturalterrain = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Droog natuurlijk terrein';

update observer3 
set drynaturalterrain = 0
where drynaturalterrain isNULL;

alter table observer3 
add greenhouse int;

UPDATE observer3 
SET greenhouse = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Glastuinbouw';

update observer3 
set greenhouse = 0
where greenhouse isNULL;

alter table observer3 
add railroad int;

UPDATE observer3 
SET railroad = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Spoorweg';

update observer3 
set railroad = 0
where railroad isNULL;

alter table observer3 
add naturereserves int;

UPDATE observer3 
SET naturereserves = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='nature reserves';

update observer3 
set naturereserves = 0
where naturereserves isNULL;

alter table observer3 
add companysite int;

UPDATE observer3 
SET companysite = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Bedrijfsterrein';

update observer3 
set companysite = 0
where companysite isNULL;

alter table observer3 
add wetnaturalterrain int;

UPDATE observer3 
SET wetnaturalterrain = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Nat natuurlijk terrein';

update observer3 
set wetnaturalterrain = 0
where wetnaturalterrain isNULL;

alter table observer3 
add airport int;

UPDATE observer3 
SET airport = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Vliegveld';

update observer3 
set airport = 0
where airport isNULL;

alter table observer3 
add forest int;

UPDATE observer3 
SET forest = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Bos';

update observer3 
set forest = 0
where forest isNULL;

alter table observer3 
add coastalwater int;

UPDATE observer3 
SET coastalwater = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Coastal water';

update observer3 
set coastalwater = 0
where coastalwater isNULL;

alter table observer3 
add semibuilt int;

UPDATE observer3 
SET semibuilt = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Semi-bebouwd';

update observer3 
set semibuilt = 0
where semibuilt isNULL;

alter table observer3 
add agriculture int;

UPDATE observer3 
SET agriculture = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Landbouw';

update observer3 
set agriculture = 0
where agriculture isNULL;

alter table observer3 
add recreation int;

UPDATE observer3 
SET recreation = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Recreatie';

update observer3 
set recreation = 0
where recreation isNULL;

alter table observer3 
add water int;

UPDATE observer3 
SET water = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Water';

update observer3 
set water = 0
where water isNULL;


alter table observer3 
add mainRoad int;

UPDATE observer3 
SET mainRoad = 1 
FROM landuse 
WHERE observer3.block = landuse.block and landuse.category='Hoofdweg';

update observer3 
set mainRoad = 0
where mainRoad isNULL;

--Copying and creating the final table with all the parameters and target variable
create table final_obs as
select * from observer3
