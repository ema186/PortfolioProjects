select *
From PortfolioProject..CovidDeaths
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Assessing total cases vs total deaths. What percentage of people died from the people that were infected for each location. 
-- it shows the likelihood of dying if you contact covid per country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Assess where the location is United States (That is where the location has states in between)
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Assessing the total cases vs the population (This shows what percentage of the population got covid in the states)

SELECT location, date, total_cases, population, (total_cases/ population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Assessing the total cases vs the population (This shows what percentage of the population got covid in Nigeria)
SELECT location, date, total_cases, population, (total_cases/ population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'
ORDER BY 1,2

-- Assessing the total cases vs the population (This shows what percentage of the population got covid in the world)
SELECT location, date, total_cases, population, (total_cases/ population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- What country has the highest infection rate compared to the population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, max((total_cases/ population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 1,2

-- To look at the country with the highest PercentPopulationInfected
SELECT location, MAX(total_cases) as HighestInfectionCount, population, max((total_cases/ population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Assessing the countries with the highest death count per population

--SELECT location, population, MAX(CAST(total_deaths as int)) AS TotalDeathCount, Max((total_deaths/ population))*100 AS PercentDeathPerPopulation
--FROM PortfolioProject..CovidDeaths
--GROUP BY location, population
--ORDER BY PercentDeathPerPopulation DESC

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Removing the grouping of countries such as Africa, world, south America. Use 'where location is not null'

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the continent with the highest death count per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT  SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Let's assess the vaccination table
SELECT *
FROM PortfolioProject..CovidVaccinations

--Joining the covid death and covid vaccination table together using location and death
SELECT *
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Assessing total population vs vaccinations (The total amount of people in the world that have been vaccinated)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Assessing total population vs vaccinations (The total amount of people in the world that have been vaccinated checking the rolling count by location)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Another method 
--SUM(CONVERT(int, vac.new_vaccinations))

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/population)* 100
FROM PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT * , (RollingPeopleVaccinated/population)* 100
FROM #PercentPopulationVaccinated

-- Creating view to store data to be used for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated