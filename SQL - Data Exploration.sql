/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- 1) View the imported raw data from the Excel worksheet that is being used

select *
from coviddeaths
where continent is not null
order by 3,4


-- 2) Select the columns of data we are interested in starting with

select location, date, total_cases, total_deaths
from coviddeaths
where continent is not null 
order by 1,2


-- 3) Total Cases vs Total Deaths
	-- Shows likelihood of dying if infected, by country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2


-- 4) Total Cases vs Population
	-- Shows the percentage of the population infected with covid, by country

select location, date, population, total_cases, (total_cases/population)*100 as population_percentage_infected
from coviddeaths
where continent is not null
order by 1,2 


-- 5) Countries with Highest Infection Percentage Compared to Population
	-- Shows the highest count of infections and the corresponding percentage of the population for each country

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as population_percentage_infected
from coviddeaths
where continent is not null
group by location, population
order by population_percentage_infected desc


-- 6) Countries with Highest Death Percentage Compared to Population
	-- Shows the highest count of deaths and the corresponding percentage of the population for each country

select location, population, max(cast(total_deaths as int)) as highest_death_count, max((cast(total_deaths as int)/population))*100 as population_percentage_deaths
from coviddeaths
where continent is not null
group by location, population
order by highest_death_count desc


-- 7) Highest Death Counts by Continent

select continent, max(cast(total_deaths as int)) as total_death_count
from coviddeaths
where continent is not null
group by continent
order by total_death_count desc


-- 8) Total Cases vs Total Death Percentage - Globally
	-- Shows the total count of cases and deaths in the world, and the corresponding percentage of deaths

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2


-- 9) Vaccination Counts
	-- Shows a rolling count of the population that has received at least one covid vaccine

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as rolling_vax_count
from coviddeaths d
join covidvax v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3


-- 10) Using a CTE to Perform Calculation on Partition By in Previous Query
	-- Adds the percentage of the population that has recieved at least one covid vaccine based on the rolling count from above

with rollvax (continent, location, date, population, new_vaccinations, rolling_vax_count)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as rolling_vax_count
from coviddeaths d
join covidvax v
on d.location = v.location and d.date = v.date
where d.continent is not null
)

select *, (rolling_vax_count/population)*100 as vax_percentage
from rollvax
order by 2,3


-- 11) Using a Temp Table to Perform Calculation on Partition By in Previous Query

drop table if exists #percentpopulationvax
create table #percentpopulationvax
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vax_count numeric
)

insert into #percentpopulationvax
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as rolling_vax_count
from coviddeaths d
join covidvax v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *, (rolling_vax_count/population)*100 as vax_percentage
from #percentpopulationvax
order by 2,3


-- 12) Creating a View to Store Data for Later Visualizations

create view vaxpercentage as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) over (partition by d.location order by d.location, d.date) as rolling_vax_count
from coviddeaths d
join covidvax v
on d.location = v.location and d.date = v.date
where d.continent is not null

select *
from vaxpercentage