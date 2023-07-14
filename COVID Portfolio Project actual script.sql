SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from covidDeaths$ order by 1,2

ALTER TABLE covidDeaths$
ALTER COLUMN total_cases BIGINT;

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 1,2

--Shows what persentage of population got Covid

Select Location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
order by 1,2

--Loking at countries with higher Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as int)/(Population)))*100 as 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location,Population
order by PercentPopulationInfected desc


--Let's Breaks Things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathsCount desc

--Showing countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location,Population
order by TotalDeathsCount desc

--Global Number
Select SUM(CAST(new_deaths AS INT)) as total_deaths,SUM(new_cases) as total_case,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Having SUM(new_cases) <> 0
order by 1,2

-- Loking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covidVaccinations$ vac
join PortfolioProject..covidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With popvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covidVaccinations$ vac
join PortfolioProject..covidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from popvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continate nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covidVaccinations$ vac
join PortfolioProject..covidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

--Creating View to store data for later visulations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.covidVaccinations$ vac
join PortfolioProject..covidDeaths$ dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated