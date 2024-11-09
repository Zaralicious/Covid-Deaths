SELECT* FROM deathby_year
SELECT* FROM sexyear_age
SELECT* FROM yearmonth

--1.	Select all data from the "Deaths by Year" table.
SELECT* FROM deathby_year


--2.	Retrieve all records from the "Deaths by Year and Month" table where the year is 2021.
SELECT* FROM yearmonth WHERE year='2021'

--3.	Find the total number of excess deaths in the "Deaths by Year" table.
SELECT SUM(excess_mean) AS sum_of_excessdeath FROM deathby_year

--4.	Display the distinct years available in the "Deaths by Year" table.
SELECT DISTINCT year FROM deathby_year


--to assign primary key
ALTER TABLE deathby_year
ADD CONSTRAINT PK_excess_mean PRIMARY KEY (excess_mean)

ALTER TABLE sexyear_age
ADD CONSTRAINT PK_expected_mean PRIMARY KEY (expected_mean)

ALTER TABLE yearmonth
ADD CONSTRAINT PK_cumul_excess_mean PRIMARY KEY (cumul_excess_mean)




--5.	Find all records in the "Deaths by Year, Sex, and Age" table where the sex is "Female".
SELECT* FROM sexyear_age WHERE sex='female'

--6.	Calculate the average excess deaths per year in the "Deaths by Year" table.
SELECT AVG(excess_mean) AS avg_of_excessdeath FROM deathby_year

--7.	Retrieve the total excess deaths by region in the "Deaths by Year" table.
SELECT location, SUM(excess_mean) AS total_excess_mean FROM deathby_year GROUP BY location

--8.	Find the maximum and minimum excess deaths recorded in the "Deaths by Year and Month" table.
SELECT MAX(excess_mean) AS max_excessdeath FROM deathby_year
SELECT MIN(excess_mean) AS min_excessdeath FROM deathby_year

--9.	Count the number of records for each age group in the "Deaths by Year, Sex, and Age" table.
SELECT age_group, COUNT(age_group) AS count_age FROM sexyear_age GROUP BY age_group

--10.	Display records from the "Deaths by Year and Month" table where excess deaths are higher than the expected deaths.
SELECT * FROM yearmonth WHERE cumul_excess_high > expected_mean

--11.	Create a temporary table to store the total excess deaths by region and year from the "Deaths by Year" table and then select from it

CREATE TABLE #temp_Cov (
location varchar(50), total_excessdeaths int, year varchar(50))

INSERT INTO #temp_Cov
SELECT location,  SUM(excess_mean), year FROM deathby_year GROUP BY location, year

--12.	Using joins, find the regions and years where the number of excess deaths in the "Deaths by Year" table matches the number of excess deaths in the "Deaths by Year and Month" table aggregated by year.
SELECT deathby_year.excess_mean, deathby_year.location, deathby_year.year, yearmonth.location, yearmonth.year FROM deathby_year
LEFT JOIN yearmonth ON deathby_year.location=yearmonth.location
WHERE deathby_year.excess_mean=yearmonth.excess_mean

SELECT deathby_year.excess_mean, deathby_year.location, deathby_year.year FROM deathby_year
LEFT JOIN yearmonth ON deathby_year.location=yearmonth.location
WHERE deathby_year.excess_mean=yearmonth.excess_mean

--13.	Identify the regions with the highest total excess deaths in 2021 using a temporary table.
CREATE TABLE #temp_Cvd (
location varchar(50), total_excessdeaths int, year varchar(50))
INSERT INTO #temp_Cvd
SELECT location,  excess_mean, year FROM deathby_year WHERE year = '2021' 
SELECT * FROM #temp_Cvd ORDER BY total_excessdeaths DESC

--14.	Perform a join to compare the actual deaths to the expected deaths by region and month for the year 2021.
SELECT sexyear_age.excess_mean, sexyear_age.expected_mean FROM sexyear_age
LEFT JOIN yearmonth ON sexyear_age.location=yearmonth.location
WHERE sexyear_age.year = '2021'


--15.	Using joins, determine the average excess deaths by age group for each region in 2020 from the "Deaths by Year, Sex, and Age" table.

SELECT sexyear_age.age_group, sexyear_age.location, sexyear_age.year, AVG(sexyear_age.excess_mean) AS avg_excess_mean
FROM sexyear_age WHERE sexyear_age.year='2020'
 GROUP BY sexyear_age.age_group,sexyear_age.location, sexyear_age.year

 SELECT sexyear_age.age_group, sexyear_age.location, sexyear_age.year, AVG(sexyear_age.excess_mean) AS avg_excess_mean
 FROM sexyear_age
LEFT JOIN yearmonth ON sexyear_age.location=yearmonth.location
WHERE sexyear_age.year = '2020'
GROUP BY sexyear_age.age_group,sexyear_age.location, sexyear_age.year

--16.	Create a temporary table for expected vs. actual deaths comparison and use it to filter regions with a significant difference in deaths.
CREATE TABLE #temp_exp (
location varchar(50), expected_deaths int, actual_death int )
INSERT INTO #temp_exp
SELECT location,  expected_mean, excess_mean FROM sexyear_age ORDER BY location

--Open a case
SELECT * FROM #temp_exp

--17.	Find the regions where the difference between male and female excess deaths was greatest in 2021
SELECT location,  excess_mean, year, sex FROM sexyear_age WHERE year = '2021' 
ORDER BY excess_mean DESC

--18.	Use a join to calculate the total deaths by age group across different regions in 2021.
SELECT sexyear_age.age_group, sexyear_age.location, sexyear_age.year, SUM(sexyear_age.excess_mean) AS total_excess_mean
 FROM sexyear_age
LEFT JOIN yearmonth ON sexyear_age.location=yearmonth.location
WHERE sexyear_age.year = '2021'
GROUP BY sexyear_age.age_group,sexyear_age.location, sexyear_age.year

--19.	Find the regions where the reported excess deaths match the actual observed deaths for any given month.
SELECT yearmonth.location FROM yearmonth
WHERE yearmonth.excess_mean=yearmonth.acm_mean

--20.	Generate a report that shows the total number of excess deaths for each region for all available years by joining all three tables.
SELECT deathby_year.location, deathby_year.year, SUM(deathby_year.excess_mean) AS tot_excess_deaths FROM deathby_year
LEFT JOIN sexyear_age ON deathby_year.excess_mean=sexyear_age.excess_mean
LEFT JOIN yearmonth ON sexyear_age.excess_mean=yearmonth.excess_mean
GROUP BY deathby_year.location, deathby_year.year, deathby_year.excess_mean