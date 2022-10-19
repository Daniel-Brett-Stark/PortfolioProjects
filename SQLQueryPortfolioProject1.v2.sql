Select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

Select *
from PortfolioProject..CovidVaccinations$
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in the United States

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percent of population got covid
Select Location, date, total_cases,population, (total_cases/population)*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population , Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentOfPopulationInfected
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentOfPopulationInfected desc

--Showing Countries with Highest Death Count per Country

--Select Location , Max(total_deaths) as TotalDeathCount
--from PortfolioProject..CovidDeaths$
--Where location like '%states%'
--and continent is not null
--Group by Location
--order by TotalDeathCount desc

--BREAK THINGS DOWN BY COUNTRY

Select location , Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

---BREAK THINGS DOWN BY CONTINENT

Select continent , Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc



Select location , Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is null
--Causes to only look at continent info/info that's location is 'null' instead of looking at all info where location is not null
Group by location
order by TotalDeathCount desc

--Showing the continents with the highest death count per country 

Select continent , Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/Sum(new_cases)*100 as DeathPercentage--total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations
--USE CTE
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaaccinated
Create Table #PercentPopulationVaaccinated
(
Continent, nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaaccinated
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaaccinated


--Creating View to store data for latter visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated
