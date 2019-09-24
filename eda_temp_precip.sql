--Counting the observations per block
SELECT COUNT(id), obsdate, block
FROM observation
GROUP BY obsdate, block
ORDER BY COUNT(id) DESC

--Eliminate the duplicates in precipitation
create table precipitation as 
select avg(precip), dtime, block from dupe_precipitation
group by dtime, block

--Checking the maximum and minimum precipitation values
select min(precip), max(precip) from dupe_precipitation

--Eliminate the duplicates in temperature
update temperature 
set precip =(select precipitation.avg from precipitation where temperature.block = precipitation.block
and temperature.dtime = precipitation.dtime )

--Checking the maximum and minimum temperature values
select min(temper), max(temper)
from dupe_temperature 