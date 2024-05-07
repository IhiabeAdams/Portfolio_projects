use portfolio_project;
select * from covid_deaths;
select * from covid_vaccine limit 10;
describe covid_deaths;

 update covid_deaths
  set total_deaths=null
  where total_deaths= '';
  
 alter table covid_deaths 
  modify column total_deaths int;
  
  alter table covid_deaths 
  modify column date date;
  
  update covid_deaths
  set total_cases = null
  where total_cases='';
  
   alter table covid_deaths 
  modify column total_cases int;
  
  describe covid_deaths;

-- select the data that we're going to be using
select location, date, total_cases, new_cases, total_deaths, population
 from covid_deaths
order by 1,2;
set sql_safe_updates=0;

-- changing the date format to sql supported 
UPDATE covid_deaths
SET date =
CASE WHEN date LIKE '%/%' THEN
date_format(str_to_date(date, '%d/%m/%Y'), '%Y-%m-%d')
 WHEN date LIKE '%-%' THEN date_format(STR_TO_DATE(date, '%d-%m-%y'), '%Y-%m-%d')
 ELSE NULL
 END;
 
 select location, date, total_cases, new_cases, total_deaths, population
 from covid_deaths
order by 1,2;
 
-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
 from covid_deaths
order by 1,2;
-- or
select location, date, total_cases, new_cases, total_deaths, round((total_deaths/total_cases)*100,2) as deathPercentage
 from covid_deaths
order by 1,2;

-- looking at total cases vs population
-- shows the percentage of the population got covid
select location, date, total_cases, population, (total_cases/population)*100 as Percentage_Population_Infected
 from covid_deaths;  
 
 -- countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as percent_population_infected
 from covid_deaths
 group by location, population
 order by 1,2;
 -- or
 select location, population, max(total_cases) as highest_infection_count, round(max((total_cases/population))*100,2) as percent_population_infected
 from covid_deaths
 group by location, population
 order by 1,2;
 
-- showing the countries with the highest death count per population
select location, population, max(total_deaths) as Death_count, max(total_deaths/population)*100 as Percentage_highest_death_rate
 from covid_deaths
  group by location, population
  order by death_count desc;
  
 select location, max(total_deaths) as Death_count
 from covid_deaths
  where continent is not null
  group by location
  order by death_count desc;
  
  -- Let's Breaks things down by continent. 
select continent, max(total_deaths) as Death_count
from covid_deaths
where continent is not null
group by continent
order by death_count desc;

-- showing continent with highest death count per population
select continent, max(total_deaths) as total_death_Count, max(total_deaths/population)*100 as Total_death_per_population
 from covid_deaths
 where continent is not null
group by continent
order by total_death_Count desc;

-- global numbers
select date, sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from covid_deaths
where continent is not null
group by date
order by 1,2;

-- showing global new cases and global deaths
select sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as deathPercentage
from covid_deaths
where continent is not null
-- group by date
order by 1,2;
 
 select * from covid_vaccine;
 
 UPDATE covid_vaccine
SET date =
CASE WHEN date LIKE '%/%' THEN
date_format(str_to_date(date, '%d/%m/%Y'), '%Y-%m-%d')
 WHEN date LIKE '%-%' THEN date_format(STR_TO_DATE(date, '%d-%m-%y'), '%Y-%m-%d')
 ELSE NULL
 END;
 
alter table covid_vaccine
modify column date date;
alter table  covid_vaccine

modify column date date;
 
 update covid_vaccine
 set new_vaccinations = null
 where new_vaccinations = '';
 
 alter table covid_vaccine
 modify column new_vaccinations int;
 
select *
from
covid_deaths d
join
covid_vaccine v
on d.location = v.location
and d.date=v.date;
 
describe covid_vaccine; 

-- showing the total populations vs vaccinations 
 select d.date, d.continent, d.location, d.population, v.new_vaccinations
 from
 covid_deaths d
 join
 covid_vaccine v
 on d.location = v.location
 and d.date=v.date
 where d.continent is not null
 order by 1,3;
 
 select d.date, d.continent, d.location, d.population, v.new_vaccinations, sum(new_vaccinations)
 over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
 from
 covid_deaths d
 join
 covid_vaccine v
 on d.location = v.location
 and d.date=v.date
 where d.continent is not null
 order by 1,3;
 
 -- using CTE
 with popvsvac(date, continent, location,population,new_vaccinations, RollingPeopleVaccinated)
 as
 (
  select d.date, d.continent, d.location, d.population, v.new_vaccinations, sum(new_vaccinations)
 over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
 from
 covid_deaths d
 join
 covid_vaccine v
 on d.location = v.location
 and d.date=v.date
 where d.continent is not null
 -- order by 1,3
 )
 select *, ( RollingPeopleVaccinated/population)*100
 from popvsvac
 
 -- creating view to store data for later
 create view popvsvac as
with popvsvac(date, continent, location,population,new_vaccinations, RollingPeopleVaccinated)
 as
 (
  select d.date, d.continent, d.location, d.population, v.new_vaccinations, sum(new_vaccinations)
 over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
 from
 covid_deaths d
 join
 covid_vaccine v
 on d.location = v.location
 and d.date=v.date
 where d.continent is not null
 -- order by 1,3
 )
 select *, ( RollingPeopleVaccinated/population)*100
 from popvsvac
 
 SELECT * FROM popvsvac;
 
 
 
 
 
 