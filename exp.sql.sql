 --portfolio project
select * from [portfolio project].dbo.CovidDeaths
where continent is null

select * from [portfolio project].dbo.CovidDeaths
where continent is not null

 --selecting data 


Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio project].dbo.CovidDeaths

Select Location, date, total_cases, new_cases, total_deaths, population
From [portfolio project].dbo.CovidDeaths
Where continent is not null 
order by 1,2

--deaths/cases

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [portfolio project].dbo.CovidDeaths
--Where location like '%india%' (or)
where location = 'india'
and continent is not null 
order by 1,2

--cases/population

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project].dbo.CovidDeaths
Where location like '%india%'
order by 4 desc

--deaths/population

Select Location, date, population,total_deaths, (total_deaths/population)*100 as DeathPercentage 
From [portfolio project].dbo.CovidDeaths
where location = 'india'
and continent is not null 
order by 1,2

--max_death/location

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project].dbo.CovidDeaths
--Where location like '%afg%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--population_infected_by_%

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project].dbo.CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project].dbo.CovidDeaths
--Where location like '%ind%' --gives continent
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--world_numbers

select date,sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
from [portfolio project].dbo.CovidDeaths
where location = 'india'
group by date

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [portfolio project].dbo.CovidDeaths
where continent is not null 
--Group By date
order by 1,2

--vaccinations
select * from [portfolio project].dbo.CovidVaccinations

--people received atleast one vacciantion

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--with cte
With vaccinatedpopulation (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From [portfolio project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (PeopleVaccinated/Population)*100 as vacdone
From vaccinatedpopulation

--temptable

drop table if exists #vaccinatedpopulations
Create Table #vacciantedpopulations
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #vacciantedpopulations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location  Order by dea.location, dea.Date) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (PeopleVaccinated/Population)*100 as vacdone
From #vacciantedpopulations

-- for visualization

create view vacciantedpopulations as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From [portfolio project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

