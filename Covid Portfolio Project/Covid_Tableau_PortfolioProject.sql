/*
Queries for Tableau Project
COVID 19 Data Exploration

Skills used: JOINS, WINDOW FUNCTIONS, AGGREGATE FUNCTIONS, CONVERTING DATA TYPES, Common Table Expression (CTE), Creating VIEWs.

*/

--1. Total Cases, Total Deaths and Death Percentage.

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as bigint)) as Total_Deaths, (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 AS death_percentage 
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null

--2. Total Deaths in each continent.

SELECT location, SUM(cast(new_deaths as bigint)) as Total_Deaths
FROM Portfolio_Project..CovidDeaths
WHERE continent is null
AND location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY location
ORDER BY Total_Deaths desc

--3. Percentage of Population infected in each continent.

SELECT location, population, MAX(total_cases) as max_infection_count, MAX(total_cases/population)*100 as percent_population_infected
FROM Portfolio_Project..CovidDeaths
WHERE continent is null
AND location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY location, population
ORDER BY percent_population_infected desc


--4. Percentage of Population infected in each country.

SELECT location, population, MAX(total_cases) as max_infection_count, MAX(total_cases/population)*100 as percent_population_infected
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
--AND location like '%India%'
AND location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY location, population
ORDER BY percent_population_infected desc

--5. Percentage of Population infected in each country (with date column).

SELECT location, population,date, MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 as percent_population_infected
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
--AND location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY location, population, date
ORDER BY percent_population_infected desc

--Count number of continents in dataset
	--select count(distinct continent)
	--from Portfolio_Project..CovidDeaths 


----JOINING COVID DEATHS and COVID VACCINATIONS table

--SELECT *
--FROM Portfolio_Project..CovidDeaths as dea
--JOIN Portfolio_Project..CovidVaccinations as vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date


-- 6. To find total deaths and vaccincation doses administered

SELECT dea.continent, dea.location, dea.date, dea.population, dea.total_cases, dea.total_deaths ,vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) as cumulative_people_vaccinated
FROM Portfolio_Project..CovidDeaths as dea
JOIN Portfolio_Project..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--AND dea.location = 'India'
AND dea.location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
ORDER BY 2,3

-- 7. Population and Population Percentage Vaccinated in each Continent.

SELECT vac.location,dea.population, MAX(cast(people_vaccinated as bigint)) as Partially_Vaccinated, MAX(cast(people_fully_vaccinated as bigint)) as Fully_Vaccinated,
MAX(cast(vac.people_vaccinated as bigint)/dea.population) as Partially_Vaccinated_Percentage, MAX(cast(vac.people_fully_vaccinated as bigint)/dea.population) as Fully_Vaccinated_Percentage
FROM Portfolio_Project..CovidDeaths as dea
	 JOIN Portfolio_Project..CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE vac.continent is null
AND dea.location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY vac.location, dea.population
ORDER BY vac.location

-- 8. Population and Population Percentage Vaccinated in each Country.

SELECT vac.location,dea.population, MAX(cast(people_vaccinated as bigint)) as Partially_Vaccinated, MAX(cast(people_fully_vaccinated as bigint)) as Fully_Vaccinated,
MAX(cast(vac.people_vaccinated as bigint)/dea.population) as Partially_Vaccinated_Percentage, MAX(cast(vac.people_fully_vaccinated as bigint)/dea.population) as Fully_Vaccinated_Percentage
FROM Portfolio_Project..CovidDeaths as dea
	 JOIN Portfolio_Project..CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE vac.continent is not null
AND dea.location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY vac.location, dea.population
ORDER BY vac.location

-- 9. Population and Population Percentage Vaccinated in each Country. (with date column)

SELECT vac.location,dea.population, vac.date, MAX(cast(people_vaccinated as bigint)) as Partially_Vaccinated, MAX(cast(people_fully_vaccinated as bigint)) as Fully_Vaccinated,
MAX(cast(vac.people_vaccinated as bigint)/dea.population) as Partially_Vaccinated_Percentage, MAX(cast(vac.people_fully_vaccinated as bigint)/dea.population) as Fully_Vaccinated_Percentage
FROM Portfolio_Project..CovidDeaths as dea
	 JOIN Portfolio_Project..CovidVaccinations as vac
	 ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE vac.continent is not null
AND dea.location not in ('World','European Union','International', 'High income' , 'Low income', 'Lower middle income', 'Upper middle income')
GROUP BY vac.location, dea.population, vac.date
ORDER BY vac.location, vac.date


-- The data obtained from the queries mentioned above, have been exported to Excel and further cleaned before importing in Tableau.


-- Use CTE (Common Table Expression)

WITH Popln_vs_Vacc (Continent, Location, Date, Population, New_Vaccinations, Cumulative_People_Vaccinated)

AS

(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cumulative_people_vaccinated
	FROM Portfolio_Project..CovidDeaths as dea
	JOIN Portfolio_Project..CovidVaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY dea.location,dea.date
)

SELECT *, (Cumulative_People_Vaccinated/Population)*100 as Total_Vac_Percentage
FROM Popln_vs_Vacc
--WHERE Location like '%India%'


-- Create Temporary Table

--DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
	(
		Continent varchar(255),
		Location varchar(255),
		Date datetime,
		Population numeric,
		New_Vaccinations numeric,
		Cumulative_People_Vaccinated numeric,
	)

--SELECT * FROM PercentPopulationVaccinated

INSERT INTO PercentPopulationVaccinated

		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
			SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as cumulative_people_vaccinated
		FROM Portfolio_Project..CovidDeaths as dea
		JOIN Portfolio_Project..CovidVaccinations as vac
			ON dea.location = vac.location
			AND dea.date = vac.date
		WHERE dea.continent is not null

SELECT *, (Cumulative_People_Vaccinated/Population)*100 as Total_Vac_Percentage
FROM PercentPopulationVaccinated


-- CREATE VIEW to Store Data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated_view

GO

CREATE VIEW [PercentPopulationVaccinated_view]  
	
AS

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(convert(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
		dea.date) as cumulative_people_vaccinated
	FROM Portfolio_Project..CovidDeaths as dea
	JOIN Portfolio_Project..CovidVaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	
GO

--(Using GO at the beginning and end of the query helps with the encountered error: "CREATE VIEW must be the only statement in the batch".

SELECT * 
FROM PercentPopulationVaccinated