--1. Table global cases
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2

--2. Table cases based on location
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM CovidDeath
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--3. Table percentage of population infected based on location
Select location, ISNULL(population,0) AS population, ISNULL(MAX(total_cases),0) AS HighestInfectionCount,  ISNULL(MAX((total_cases/population))*100,0) AS PercentPopulationInfected
FROM CovidDeath
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--4.  Table percentage of population infected based on location and date
SELECT location, ISNULL(population,0) AS population ,date, ISNULL(MAX(total_cases),0) AS HighestInfectionCount,  ISNULL(MAX((total_cases/population))*100,0) AS PercentPopulationInfected
FROM CovidDeath
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

