/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


-- SELECT Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..Covid_Deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio_Project..Covid_Deaths
WHERE location like '%states%'
AND continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM Portfolio_Project..Covid_Deaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolio_Project..Covid_Deaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolio_Project..Covid_Deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(CAST(new_cases AS int)) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(CAST(New_Cases AS int))*100 AS DeathPercentage
FROM Portfolio_Project..Covid_Deaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2


--joining both vaccination AND death tables

SELECT dea.continent, dea.location, dea.date
FROM Portfolio_Project..Covid_Deaths AS dea
JOIN Portfolio_Project..Covid_Vaccinations AS vac
ON dea.location = vac.location
--AND CAST(dea.date AS datetime2) = vac.date 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT vac.continent, vac.location, vac.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by vac.Location ORDER BY vac.location, vac.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exISts #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later vISualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
JOIN Portfolio_Project..Covid_Vaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
