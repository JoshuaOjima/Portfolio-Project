SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE Continent is not null
ORDER BY 3,4


--SELECT *
--FROM [Portfolio Project]..[Covid Vaccinations]
--ORDER BY 3,4

-- SELECT THE DATA THAT WE ARE GOING TO BE USING
SELECT Location, Date, total_cases, new_cases, total_deaths, Population
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS
-- Shows the Likelyhood of dying if you contact covid in the US
SELECT Location, Date, total_cases,  total_deaths, (total_cases/total_deaths)
FROM [Portfolio Project]..CovidDeaths
ORDER BY 1,2


SELECT  Location, Date, total_cases,  total_deaths, CAST(total_deaths As Float) /total_cases *100 As DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where Location like '%Nigeria%'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT  Location, Date,Population, total_cases,   CAST(total_deaths As Float) /Population *100 As DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where Location like '%Nigeria%'
ORDER BY 1,2

--Looking  at the countries with highest infection rate compared to population
SELECT  Location, Population, MAX(total_cases) As Highestinfectioncount, MAX((total_cases/population))*100 As PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--Where Location like '%Nigeria%'
Group by Location, Population
ORDER BY PercentPopulationInfected desc

--Showing the countries with the highest death count per populatiuon
SELECT  Location, MAX(total_deaths) As TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where Location like '%Nigeria%'
WHERE Continent is not null
Group by Location
ORDER BY TotalDeathCount desc

-- Let's Break Things down by continent
--Showing the continents with the highest death count
SELECT  Location, MAX(total_deaths) As TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where Location like '%Nigeria%'
WHERE Continent is null
Group by location
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT  date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_cases)/ SUM(new_deaths)*100 as Deathpercentage
FROM [Portfolio Project]..CovidDeaths
--Where Location like '%Nigeria%'
WHERE Continent is not null
Group by date
ORDER BY 1,2

select location, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_cases)/SUM(new_deaths)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
Where Continent is null
group by location
order by 1,2


-- Looking at total population vs Vaccination

SELECT   dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
,(RollingpeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--WHEN divisor = 0 THEN NULL  -- Handle division by zero
	order by 2,3 


	--USE CTE

	With PopvsVac (Continant, Location, Date,Population, RollingPeopleVaccinated)
	as

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
,(RollingpeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--WHEN divisor = 0 THEN NULL  -- Handle division by zero
	--order by 2,3 

	Select *
	From PopvsVac

	--TEMP TABLE
	Drop Table if exists #PercentagePopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)






	Insert into #PercentPopulationVaccinated
	SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.Date)
as RollingPeopleVaccinated
,(RollingpeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..[Covid Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
	--WHEN divisor = 0 THEN NULL  -- Handle division by zero
	--order by 2,3 

	Select *
	From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

select Location, MAX(total_deaths) As TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where Location like '%Nigeria%'
WHERE Continent is null
Group by location
ORDER BY TotalDeathCount desc
