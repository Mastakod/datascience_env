--select * from PortfolioProjects..CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects.dbo.CovidDeaths
where continent is not null
order by 1,2




-- Looking for the Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects.dbo.CovidDeaths
where location like '%states%'
order by 1,2




-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
where location like '%states%'

-- Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population
select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc


-- Showing Continents with highest death count per population
-- Let's break things down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


-- Global Numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null
--group by date
order by 1, 2


-- Looking at Total Population vs Vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 -- will need a CTE or Temp Table in order to reuse the alias RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths cd
join PortfolioProjects..CovidVaccinations cv
on cd.date = cv.date and cd.location = cv.location
where cd.continent is not null
order by 1, 2, 3

-- Use CTE

WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths cd
join PortfolioProjects..CovidVaccinations cv
on cd.date = cv.date and cd.location = cv.location
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated from PopvsVac
order by 1, 2, 3


-- Use Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths cd
join PortfolioProjects..CovidVaccinations cv
on cd.date = cv.date and cd.location = cv.location
where cd.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated
order by 1, 2, 3


-- Creating views to store data for later visualizations

Create view PercentPopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths cd
join PortfolioProjects..CovidVaccinations cv
on cd.date = cv.date and cd.location = cv.location
where cd.continent is not null


select * from PercentPopulationVaccinated