--Select * 
--From portfolioprojectt..CovidDeaths$
--order by 3,4

--Select * 
--From portfolioprojectt..CovidVaccinations$
--order by 3,4

-- Selecting data that we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioprojectt..CovidDeaths$
order by 1, 2

-- Looking at total cases vs total deaths
-- death_percentage now shows chance you will die if infected by covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From portfolioprojectt..CovidDeaths$
Where location like '%kingdom%'
order by 1, 2

-- Looking at total_cases vs population

Select Location, date, total_cases,  Population, (total_cases/Population)*100 as infection_rate
From portfolioprojectt..CovidDeaths$
Where location like '%kingdom%'
order by 1, 2

-- Looking at highest infection rates

Select Location, MAX(total_cases) as peak_infection,  Population, Max((total_cases/Population))*100 as infection_rate
From portfolioprojectt..CovidDeaths$
Group By Population, Location
order by infection_rate desc

-- Looking at death counts

Select Location, Max(cast(total_deaths as int)) as death_count
From portfolioprojectt..CovidDeaths$
Where continent is not null
Group By Population, Location
order by death_count desc

-- continents with highest death count

--Select location, Max(cast(total_deaths as int)) as death_count
--From portfolioprojectt..CovidDeaths$
--Where continent is null
--Group By location
--order by death_count desc

Select continent, MAX(cast(total_deaths as int)) as death_count
From portfolioprojectt..CovidDeaths$
Where continent is not null
Group by continent
order by death_count desc

-- global numbers

Select date, SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From portfolioprojectt..CovidDeaths$
Where continent is not null
Group by date 
order by 1,2

Select SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From portfolioprojectt..CovidDeaths$
Where continent is not null 

-- second table
-- total pop vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_count
From portfolioprojectt..CovidDeaths$ dea
Join portfolioprojectt..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3

-- Using CTE

With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_count) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_count
From portfolioprojectt..CovidDeaths$ dea
Join portfolioprojectt..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (rolling_count/population)*100 as rolling_rate
From pop_vs_vac

-- Temp Table

DROP Table if exists #percent_pop_vac
Create Table #percent_pop_vac
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_count numeric
)

Insert into #percent_pop_vac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_count
From portfolioprojectt..CovidDeaths$ dea
Join portfolioprojectt..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (rolling_count/population)*100 as rolling_rate
From #percent_pop_vac

-- Creating view for storing data visualisation

Create View percent_pop_vac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_count
From portfolioprojectt..CovidDeaths$ dea
Join portfolioprojectt..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null