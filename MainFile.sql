--Let's take a look at the data

SELECT location, date, total_cases, new_cases, total_deaths  
FROM `just-metric-261905.CovidData.Covid_Deaths`
ORDER BY 1,2;

--Let's find out the death percentage which shows the chances of dying if you contract covid by dates

SELECT location, date, total_cases, total_deaths, (total_deaths)/(total_cases) * 100 AS Death_Percentage  
FROM `just-metric-261905.CovidData.Covid_Deaths`
ORDER BY 1,2;

--Let's find out the percentage of population that contracted covid.

SELECT location, population, MAX(total_cases) AS Total_Cases, MAX(total_cases)/population * 100 AS Infection_Percentage
FROM `just-metric-261905.CovidData.Covid_Deaths`
GROUP BY 1,2
ORDER BY Infection_Percentage DESC;

--Let's find out the countries with highest deaths per population

SELECT location, population, MAX(total_deaths) AS Total_Deaths
FROM `just-metric-261905.CovidData.Covid_Deaths`
WHERE location NOT LIKE '%income%' AND continent IS NOT NULL
GROUP BY 1,2
ORDER BY Total_Deaths DESC;

--Let's take a look at the continental stats
--Total Deaths

SELECT location, population, MAX(total_deaths) AS Total_Deaths
FROM `just-metric-261905.CovidData.Covid_Deaths`
WHERE location NOT LIKE '%income%' AND
location NOT LIKE 'World' AND
location NOT LIKE '%nal%' AND 
continent IS NULL
GROUP BY 1,2
ORDER BY Total_Deaths DESC; 

--Total Cases

SELECT location, population, MAX(total_cases) AS Total_Cases
FROM `just-metric-261905.CovidData.Covid_Deaths`
WHERE location NOT LIKE '%income%' AND
location NOT LIKE 'World' AND
location NOT LIKE '%nal%' AND 
continent IS NULL
GROUP BY 1,2
ORDER BY Total_Cases DESC; 

--Let's check out some global stats
--New Cases by Date

SELECT date, SUM(new_cases) AS New_Cases
FROM `just-metric-261905.CovidData.Covid_Deaths` 
GROUP BY date
ORDER BY date, New_Cases;

--Death Percentage globally by date

SELECT date, SUM(new_cases) AS New_Cases, SUM(new_deaths) AS Deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percentage
FROM `just-metric-261905.CovidData.Covid_Deaths` 
WHERE new_cases != 0
GROUP BY date
ORDER BY date;

--Overall Global Stats

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases) * 100 AS Death_Percentage
FROM `just-metric-261905.CovidData.Covid_Deaths` 
WHERE new_cases != 0;

--Now let's take a look at the vaccinations stats also and to do that we first need to join the two tables
--Let's take a look at total number of vaccinations by date

SELECT d.continent, d.location, d.population, d.date, v.new_vaccinations
FROM `just-metric-261905.CovidData.Covid_Deaths` AS d
JOIN `just-metric-261905.CovidData.Covid_Vaccinations` AS v 
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY d.location,d.date;

--Let's find out the total vaccinations after every date

SELECT d.continent, d.location, d.population, d.date, v.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Total_Vaccinated_Untill_Now
FROM `just-metric-261905.CovidData.Covid_Deaths` AS d
JOIN `just-metric-261905.CovidData.Covid_Vaccinations` AS v 
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY d.location,d.date;

--Let's find out the percentage of people vaccinated till date by dates

WITH VAC_PERCENT 
AS (SELECT d.continent, d.location, d.population, d.date, v.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Total_Vaccinated_Untill_Now
FROM `just-metric-261905.CovidData.Covid_Deaths` AS d
JOIN `just-metric-261905.CovidData.Covid_Vaccinations` AS v 
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL)

SELECT *, (Total_Vaccinated_Untill_Now/Population) * 100 AS Percent_Vaccinated
FROM VAC_PERCENT;

--Let's try the same process with a temp table

DROP TABLE IF EXISTS CovidData.Vaccinated_Percent;
CREATE TABLE CovidData.Vaccinated_Percent(Continent STRING, Location STRING, Population INT64, Date DATE, New_Vaccinations INT64, Total_Vaccinated_Untill_Now INT64)
AS
 SELECT d.continent, d.location, d.population, d.date, v.new_vaccinations,
 SUM(new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Total_Vaccinated_Untill_Now
 FROM `just-metric-261905.CovidData.Covid_Deaths` AS d
 JOIN `just-metric-261905.CovidData.Covid_Vaccinations` AS v 
 ON d.location = v.location 
 AND d.date = v.date
 WHERE d.continent IS NOT NULL
 ORDER BY d.location,d.date
;

SELECT *, (Total_Vaccinated_Untill_Now/Population) * 100 AS Percent_Vaccinated
FROM CovidData.Vaccinated_Percent















