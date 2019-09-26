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
	t1.latit,
	
ROW_NUMBER()OVER(PARTITION BY species, observer, obsdate ORDER BY species) as RN
	FROM observation_noempty as t1
)
SELECT * FROM CTE WHERE RN = 1;

--Creating the observer intensity for block  
create table blockwise as
	select block, count(id) from observation_noempty_nodup group by block;

--Adding the various landuse categories to the blockwise table

create table landuse as
select * from block_landuse;

alter table blockwise 
add built_up int;

UPDATE blockwise 
SET built_up = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Bebouwd';

update blockwise 
set built_up = 0
where built_up isNULL;

alter table blockwise 
add drynaturalterrain int;

UPDATE blockwise 
SET drynaturalterrain = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Droog natuurlijk terrein';

update blockwise 
set drynaturalterrain = 0
where drynaturalterrain isNULL;

alter table blockwise 
add greenhouse int;

UPDATE blockwise 
SET greenhouse = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Glastuinbouw';

update blockwise 
set greenhouse = 0
where greenhouse isNULL;

alter table blockwise 
add railroad int;

UPDATE blockwise 
SET railroad = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Spoorweg';

update blockwise 
set railroad = 0
where railroad isNULL;

alter table blockwise 
add naturereserves int;

UPDATE blockwise 
SET naturereserves = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='nature reserves';

update blockwise 
set naturereserves = 0
where naturereserves isNULL;

alter table blockwise 
add companysite int;

UPDATE blockwise 
SET companysite = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Bedrijfsterrein';

update blockwise 
set companysite = 0
where companysite isNULL;

alter table blockwise 
add wetnaturalterrain int;

UPDATE blockwise 
SET wetnaturalterrain = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Nat natuurlijk terrein';

update blockwise 
set wetnaturalterrain = 0
where wetnaturalterrain isNULL;

alter table blockwise 
add airport int;

UPDATE blockwise 
SET airport = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Vliegveld';

update blockwise 
set airport = 0
where airport isNULL;

alter table blockwise 
add forest int;

UPDATE blockwise 
SET forest = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Bos';

update blockwise 
set forest = 0
where forest isNULL;

alter table blockwise 
add coastalwater int;

UPDATE blockwise 
SET coastalwater = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Coastal water';

update blockwise 
set coastalwater = 0
where coastalwater isNULL;

alter table blockwise 
add semibuilt int;

UPDATE blockwise 
SET semibuilt = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Semi-bebouwd';

update blockwise 
set semibuilt = 0
where semibuilt isNULL;

alter table blockwise 
add agriculture int;

UPDATE blockwise 
SET agriculture = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Landbouw';

update blockwise 
set agriculture = 0
where agriculture isNULL;

alter table blockwise 
add recreation int;

UPDATE blockwise 
SET recreation = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Recreatie';

update blockwise 
set recreation = 0
where recreation isNULL;

alter table blockwise 
add water int;

UPDATE blockwise 
SET water = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Water';

update blockwise 
set water = 0
where water isNULL;

alter table blockwise 
add mainRoad int;

UPDATE blockwise 
SET mainRoad = 1 
FROM landuse 
WHERE blockwise.block = landuse.block and landuse.category='Hoofdweg';

update blockwise 
set mainRoad = 0
where mainRoad isNULL;

--Adding the road length to the blockwise table

alter table blockwise 
add road int;

UPDATE blockwise 
SET road = block_road_access.roadlength 
FROM block_road_access 
WHERE blockwise.block = block_road_access.block;

update blockwise 
set road = 0
where road isNULL;

--Adding the biodiversity to the blockwise table

alter table blockwise 
add biodiverse int;

UPDATE blockwise 
SET biodiverse = biodiversity.aves2012_2016 
FROM biodiversity 
WHERE blockwise.block = biodiversity.block;

update blockwise 
set biodiverse = 0
where biodiverse isNULL;

--Removing the block column as it is not significant in the ML

alter table blockwise
drop column block;

