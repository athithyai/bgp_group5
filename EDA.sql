-- Size of the population
SELECT COUNT(*)
FROM observation;

--Checking null values in data
SELECT *
FROM observation_noempty
WHERE species = '' OR species IS NULL OR observer = '' OR observer IS NULL OR obsdate IS NULL OR block IS NULL OR latit IS NULL OR longit IS NULL;

--Creating new view with no empty observations
CREATE VIEW observation_noempty AS
SELECT *
FROM observation
WHERE obstime <> '';

SELECT COUNT(*)
FROM observation_noempty;

--Displaying the categories by descendent order
SELECT COUNT(Id), species
  FROM observation_noempty
 GROUP BY species
 ORDER BY COUNT(Id) DESC

SELECT COUNT(Id), observer
  FROM observation_noempty
 GROUP BY observer
 ORDER BY COUNT(Id) DESC

-- Checking the maximum and minimum coordinates
select *
from observation_noempty
order by longit

select *
from observation_noempty
order by latit

select *
from observation_noempty
order by longit desc

select *
from observation_noempty
order by latit desc

-- Checking the first and last observation day
select *
from observation_noempty
order by obsdate

select *
from observation_noempty
order by obsdate desc

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

--checking for oversea records(block is null) in the precipitation and temperature 
select * from precipitation where block isNull;

select * from temperature where block isNull;

-- seeing the distinct categories in landuse table
select distinct(category) from landuse;



