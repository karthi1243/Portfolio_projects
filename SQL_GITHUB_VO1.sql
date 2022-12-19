--Data exploration
--open source : covid data from https://ourworldindata.org/covid-deaths from feb 2020 to dec 2022
--Total number of deaths with respect to number of cases reported

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM project_1..covidDeath
WHERE continent IS NOT NULL
ORDER by 1,2;

-- likelihood of death if someone contracts covid with respect to location(example India)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM project_1..covidDeath
WHERE location LIKE 'Ind%'
ORDER by 1,2;

--which country has the highest infected rate with respect to its population? or What percentage of the population has got covid
SELECT location, population, MAX(total_cases) as highest_cases_reported, MAX((total_cases/population))*100 as infected_rate
FROM project_1..covidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER by infected_rate desc;

--percentage of population dead due to covid.
SELECT location, population, MAX(CAST(total_deaths AS int)) as highest_deaths_reported
FROM project_1..covidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER by highest_deaths_reported desc;


--If we want to do the same with continent 

SELECT continent, MAX(CAST(total_deaths AS int)) as highest_deaths_reported
FROM project_1..covidDeath
WHERE continent IS NOT  NULL
GROUP BY continent
ORDER by highest_deaths_reported desc;

--Global numbers or across the world

SELECT date, SUM(new_cases) AS total_cases_date, SUM(cast(new_deaths AS int)) as total_death_date, (SUM(CAST(new_deaths AS int))/SUM(new_cases)*100) AS death_percentage
FROM project_1..covidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 4 desc;

--for overall death and cases

SELECT SUM(new_cases) AS total_cases_date, SUM(cast(new_deaths AS int)) as total_death_date, (SUM(CAST(new_deaths AS int))/SUM(new_cases)*100) AS death_percentage
FROM project_1..covidDeath
WHERE continent IS NOT NULL

--considering population vs vaccination
-- Uding JOIN function 

SELECT * --basic JOIN function
FROM project_1..covidDeath AS dea
JOIN project_1..covidVaccination AS vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 3,4;

-- population and vaccination relation
SELECT dea.continent,dea.date,dea.location, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS roolingcount_peoplevaccinated 
FROM project_1..covidDeath AS dea
 JOIN project_1..covidVaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 3,2;

-- Percentage of population vacinnated with respect to each country
-- Using CTE(Common table expression)

WITH popvsvac(continent,date,location,population,new_vaccinations,roolingcount_peoplevaccinated)
AS
(SELECT dea.continent,dea.date,dea.location, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS roolingcount_peoplevaccinated 
FROM project_1..covidDeath AS dea
 JOIN project_1..covidVaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

)
SELECT *, (roolingcount_peoplevaccinated/population) * 100 AS percentage_vaccinated
FROM popvsvac
ORDER BY 3,2,1;

--using temporary table

DROP TABLE IF  exists #poppercentage
CREATE TABLE #poppercentage
(
continent nvarChar(253),
date datetime,
location nvarChar(253),
population numeric,
new_vaccinations numeric,
roolingcount_peoplevaccinated numeric
)
INSERT INTO #poppercentage 
SELECT dea.continent,dea.date,dea.location, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS roolingcount_peoplevaccinated 
FROM project_1..covidDeath AS dea
 JOIN project_1..covidVaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 


SELECT  *,(roolingcount_peoplevaccinated/population) * 100 AS percentage_vaccinated
FROM #poppercentage
ORDER BY 3,2,1;

--Creating view

CREATE VIEW popvsvac AS 
SELECT dea.continent,dea.date,dea.location, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations))OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS roolingcount_peoplevaccinated 
FROM project_1..covidDeath AS dea
 JOIN project_1..covidVaccination AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 3,2;











