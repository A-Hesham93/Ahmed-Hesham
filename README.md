# Ahmed-Hesham
# Covid19 Portolio Project


/*
Covid 19 Data Exploration
*/

Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null 
order by 3,4



-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null 
order by 1,2




-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
from [Portfolio Project]..CovidDeaths
where location like '%states'
order by 1,2



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population,total_cases, (total_cases/population)*100 as 'infection Percentage'
from [Portfolio Project]..CovidDeaths
where location like '%states'
order by 1,2



-- Countries with Highest Infection Rate compared to Population

select location, population,max(total_cases) as highestinfectedcountry, max(total_cases/population)*100 as 'infection Percentage'
from [Portfolio Project]..CovidDeaths
group by location, population
order by 'infection Percentage' desc



-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as 'total deaths count'
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by 'total deaths count' desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as 'total deaths count'
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by 'total deaths count' desc




-- GLOBAL NUMBERS

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as 'Death Percentage'
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2

select *
from [Portfolio Project]..CovidVaccinations




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

with popvsvac (continent, location,date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac




-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated





-- Creating View to store data for later visualizations

use [Portfolio Project]
go
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated
