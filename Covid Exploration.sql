-- Select Data that we are going to be using

Select Location, date,continent, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1, 2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPecentage
From PortfolioProject..CovidDeaths
Where location like '%state%'
	and continent is not null
Order by 1, 2

-- Looking at Total Cases vs Population
-- Show that percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)* 100 as CasesPecentage
From PortfolioProject..CovidDeaths
--where location like '%state%'
Where continent is not null
Order by 1, 2

-- Looking at Coutries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestinfectionCount, Max((total_cases/population))*100
	as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc

-- Show Coutries with Highest Death Count per Popucation
Select Location, population, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

 -- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- dbo.CovidDeaths combine with CovidVaccinations
Select dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Order by 1, 2, 3

-- Loooking at Total Population vs Vaccinations

-- USE CTE

With PopvsVac (Continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths as dea
	Join PortfolioProject..CovidVaccinations as vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) 
	OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float, vac.new_vaccinations)) 
		OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths as dea
	Join PortfolioProject..CovidVaccinations as vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null

Select *
From PercentPopulationVaccinated