SELECT *
FROM CovidDeath
WHERE continent IS NULL
ORDER BY 3,4

SELECT *
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccination
--ORDER BY 3,4

-- select data that we're going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2

-- look at the total cases and total death, calculate the percentage of death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeath
WHERE location = 'Indonesia' AND continent IS NOT NULL
ORDER BY 1,2

--look at the total cases and population, calculate the percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS cases_percentage
FROM CovidDeath
WHERE location = 'Indonesia' AND continent IS NOT NULL
ORDER BY 1,2

--look at the countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_total_cases, MAX(total_cases/population)*100 AS cases_percentage
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY cases_percentage DESC

--look at the countries with highest death cases compared to population
SELECT location, MAX(CAST(total_deaths as INT)) AS highest_total_death
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_total_death DESC

--look at the continent with highest death cases compared to population
SELECT continent, MAX(CAST(total_deaths as INT)) AS highest_total_death
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_total_death DESC

--look at global cases
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2

--look at the total population vs vaccinations
SELECT vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) AS peopleVaccinated
, (SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date)/population)*100
FROM CovidDeath AS dea
JOIN CovidVaccination AS vac
ON dea.location = vac.location 
WHERE vac.continent IS NOT NULL
AND dea.date = vac.date
ORDER BY 1,2,3

--use common table expression
WITH PopsVac (continent, location, date, population, new_vaccinations, peopleVaccinated)
as
(
SELECT vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) AS peopleVaccinated
FROM CovidDeath AS dea
JOIN CovidVaccination AS vac
ON dea.location = vac.location 
WHERE vac.continent IS NOT NULL
AND dea.date = vac.date
)
SELECT *, (peopleVaccinated/population)*100 
FROM PopsVac

--use temp table

DROP TABLE IF EXISTS #percentPopulationVaccinated2
CREATE TABLE #percentPopulationVaccinated2
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peopleVaccinated numeric
)

INSERT INTO #percentPopulationVaccinated2

SELECT vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) AS peopleVaccinated
FROM CovidDeath AS dea
JOIN CovidVaccination AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE vac.continent IS NOT NULL

SELECT *, (peopleVaccinated/population)*100 
FROM #percentPopulationVaccinated2

-- create view to store data for visualization
CREATE VIEW percentPopulationVaccinated2 AS
SELECT vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY vac.location ORDER BY vac.location, vac.date) AS peopleVaccinated
FROM CovidDeath AS dea
JOIN CovidVaccination AS vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE vac.continent IS NOT NULL

SELECT *
FROM percentPopulationVaccinated2
