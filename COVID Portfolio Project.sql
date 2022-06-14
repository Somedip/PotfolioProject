
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Data that we are going to be using

Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases Vs Total Deaths
-- Likelihood of dying if you are diagnosed with covid in your country(India)

Select Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India'
order by 1,2

-- Total Cases Vs Popultaion
-- Percentage of population that got Covid in India

Select Location, date, total_cases,  Population, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
where location like '%India' 
order by 1,2

-- Countries with highest infection rates compared to population

Select Location,Population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPoplulationInfected
From PortfolioProject..CovidDeaths
-- where location like '%India'
group by Location,Population
order by PercentPoplulationInfected desc

-- Countries with Higehst death count per popluation

Select Location, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%India'
group by Location
order by TotalDeathCount desc

-- for removing world or continents having  null values

Select Location, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%India'
where continent is not null
group by Location
order by TotalDeathCount desc

-- I want to aggregate by Continents now just to see the total death counts per continents

Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%India'
where continent is not null
group by continent
order by TotalDeathCount desc

Select location, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%India'
where continent is null
group by location
order by TotalDeathCount desc

-- Showing continents with highest death counts per population

Select continent, max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%India'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global number

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage--,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%India'
where continent is not null
group by date
order by 1,2

--Overall Cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage--,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where location like '%India'
where continent is not null
--group by date
order by 1,2

-- **********************************************

-- Total populations vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population ) *100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population ) *100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Creating a Temp table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population ) *100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- For droping a table and if we want any alterations to be done 

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population ) *100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated




-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast( vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population ) *100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3



