--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER by 1,2

-- Looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india'
ORDER by 1,2

-- looking at total cases vs population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india'
ORDER by 1,2

-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india'
GROUP BY location, population
ORDER by PercentPopulationInfected desc


-- showing countries with the highest desth count per population

SELECT location, MAX (cast (total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india'
WHERE continent is not null
GROUP BY location
ORDER by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT


--showing the continents with the highest deathcounts

SELECT continent, MAX (cast (total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india'
WHERE continent is not null
GROUP BY continent
ORDER by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india'
where continent is not null
GROUP BY date
ORDER by 1,2

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india'
where continent is not null
--GROUP BY date
ORDER by 1,2


--Looking at total population vs vaccination
SELECT D.continent, D.location, D.date, D.population, Vac.new_vaccinations,
SUM(convert(int,Vac.new_vaccinations)) OVER (Partition By D.location order by D.location , d.date) as RollingPeopleVacccinated--, (RollingPeopleVacccinated)*100
FROM PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccinations Vac
	ON D.location = Vac.location
	and D.date = Vac.date
where D.continent is not null
ORDER by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVacccinated)
as
(
SELECT D.continent, D.location, D.date, D.population, Vac.new_vaccinations,
SUM(convert(int,Vac.new_vaccinations)) OVER (Partition By D.location order by D.location , d.date) as RollingPeopleVacccinated--, (RollingPeopleVacccinated)*100
FROM PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccinations Vac
	ON D.location = Vac.location
	and D.date = Vac.date
where D.continent is not null
--ORDER by 2,3
)
Select *, (RollingPeopleVacccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RPV numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RPV/Population)*100
From #PercentPopulationVaccinated



-- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated

























