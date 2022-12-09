SELECT *
FROM Portfolio_Project..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolio_Project..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases,new_cases,total_cases,population
FROM Portfolio_Project..CovidDeaths
ORDER BY 1,2

-- Looking at the total cases v/s total deaths
-- Shows the likelihood of dying if one contracts covid in your country


SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM Portfolio_Project..CovidDeaths
where location like '%india%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Coivd


SELECT location, date,  population, total_cases, (total_cases/population)*100 as pecentage_population_infected
FROM Portfolio_Project..CovidDeaths
--where location like '%india%'
ORDER BY 1,2


-- Countries with highest infection rate compared to Population
w


-- Global Numbers

-- Total cases vs Total Deaths based on Location

SELECT location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as death_percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 1,2

-- Total cases vs Total Deaths wrt Date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as death_percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Total cases vs Total Deaths

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as death_percentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--JOINING COVID DEATHS and COVID VACCINATIONS table

SELECT *
FROM Portfolio_Project..CovidDeaths as dea
JOIN Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as cumulative_people_vaccinated
FROM Portfolio_Project..CovidDeaths as dea
JOIN Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location = 'India'
ORDER BY 2,3

-- USE CTE (common table expression)

WITH Popln_vs_Vacc (Continent, Location, Date, Population, New_Vaccinations, Cumulative_People_Vaccinated)

AS

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as cumulative_people_vaccinated
FROM Portfolio_Project..CovidDeaths as dea
JOIN Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (Cumulative_People_Vaccinated/Population)*100 as Total_Vacc_Percentage
FROM Popln_vs_Vacc
WHERE Location = 'India'



-- TEMP TABLE


DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	Cumulative_People_Vaccinated numeric
)

INSERT INTO PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as cumulative_people_vaccinated
FROM Portfolio_Project..CovidDeaths as dea
JOIN Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Cumulative_People_Vaccinated/Population)*100
FROM PercentPopulationVaccinated

-- CREATE VIEW to Store Data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as cumulative_people_vaccinated
FROM Portfolio_Project..CovidDeaths as dea
JOIN Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated
