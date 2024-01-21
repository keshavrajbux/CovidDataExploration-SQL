/*
Project Credit : Alex The Analyst, https://github.com/AlexTheAnalyst/PortfolioProjects

Covid 19 Data Exploration 

Skills demonstrated: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

/* Query 1: Total Covid Deaths by Continent
Selects all columns from the CovidDeaths table in the TrialRun schema where the continent is not null and orders the results by the third and fourth columns. */
Select *
From TrialRun..CovidDeaths
Where continent is not null 
order by 3,4


/* Query 2: Initial Data Selection
Selects specific columns (Location, date, total_cases, new_cases, total_deaths, population) from CovidDeaths 
where the continent is not null and orders by location and date. */

Select Location, date, total_cases, new_cases, total_deaths, population
From TrialRun..CovidDeaths
Where continent is not null 
order by 1,2


-- Query 3: Total Cases vs Total Deaths by State
-- Compares total cases and total deaths in states, calculating the death percentage, ordered by location and date.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From TrialRun..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Query 4: Total Cases vs Population
-- Shows the percentage of population infected with Covid by comparing total cases and population, ordered by location and date.


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From TrialRun..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Query 5: Countries with Highest Infection Rate
-- Identifies countries with the highest infection rate compared to population, ordered by the percentage of population infected in descending order.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From TrialRun..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Query 6: Countries with Highest Death Count per Population
-- Lists countries with the highest death count per population, ordered by total death count in descending order.

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From TrialRun..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- Query 7: Death Count by Continent
-- Shows continents with the highest death count per population, ordered by total death count in descending order.

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From TrialRun..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Query 8: Global Covid Statistics
--Provides global numbers including total cases, total deaths, and death percentage, ordered by date.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From TrialRun..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Query 9: Total Population vs Vaccinations
-- Compares total population with new vaccinations, showing the percentage of the population that has received at least one Covid vaccine, ordered by location and date.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From TrialRun..CovidDeaths dea
Join TrialRun..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Query 10: Using CTE for Population vs Vaccinations
-- Calculates rolling people vaccinated using Common Table Expressions (CTE) and shows the percentage of population vaccinated, ordered by location and date.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From TrialRun..CovidDeaths dea
Join TrialRun..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Query 11: Using Temp Table for Population vs Vaccinations
-- Uses a temporary table to calculate rolling people vaccinated and displays the percentage of population vaccinated, ordered by location and date.

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From TrialRun..CovidDeaths dea
Join TrialRun..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Query 12: Creating View for Population vs Vaccinations
-- Creates a view named PercentPopulationVaccinated to store data for later visualizations, similar to Query 10.
-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From TrialRun..CovidDeaths dea
Join TrialRun..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


