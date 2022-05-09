SELECT * 
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE continent is not null
ORDER BY 3, 4

SELECT *
FROM COVID_Portfolio_Project..Covid_Vaccinations
WHERE continent is not null
ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE continent is not null
Order BY 1, 2

--Comparing Total Cases to Total Deaths in the US
--Likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
AS Death_Percentage
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE location like 'United States%'
and continent is not null
ORDER BY 1, 2

--Comparing Total Cases to Population in the US
--What percentage of the US population got COVID?

SELECT Location, date, population, total_cases, (total_cases/population)*100
AS Infection_Rate
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE location like 'United States%'
and continent is not null
ORDER BY 1, 2

--Looking at countries with highest infection rate

SELECT Location, population, MAX(total_cases) AS HIghestInfectionCount, MAX((total_cases/population))*100 AS Infection_Rate 
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY Infection_Rate desc

--Showing countries with highest death count

SELECT Location, MAX(cast(total_deaths AS int)) AS Total_Death_Count 
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count desc

--Showing continents with highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS Total_Death_Count 
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

--Death rate, globally

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as INT)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Rate
FROM COVID_Portfolio_Project..Covid_Deaths
WHERE continent is not null
ORDER BY 1, 2

--Joining two tables together
--Comparing total population to vaccinations
--CTE


WITH PopsVac (Continent,location, date, population, new_vaccinations, Rolling_Vax_Count) AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vax_Count
FROM COVID_Portfolio_Project..Covid_Deaths dea
JOIN COVID_Portfolio_Project..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (Rolling_Vax_Count/population)*100 
FROM PopsVac

--TEMP TABLE

DROP TABLE IF exists #PercentageVaccinated
CREATE TABLE #PercentagedVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_Vax_Count numeric
)

INSERT INTO #PercentagedVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vax_Count
FROM COVID_Portfolio_Project..Covid_Deaths dea
JOIN COVID_Portfolio_Project..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *, (Rolling_Vax_Count/population)*100 
FROM #PercentagedVaccinated


-- Creating VIEW for Tableau visualization

CREATE VIEW PercentageVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vax_Count
FROM COVID_Portfolio_Project..Covid_Deaths dea
JOIN COVID_Portfolio_Project..Covid_Vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentageVaccinated