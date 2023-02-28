SELECT * FROM Portfolio_Project.dbo.CovidDeaths
 ORDER BY 3, 4;

 --SELECT * FROM Portfolio_Project.dbo.CovidVacinations
 --ORDER BY 3, 4;

 -- Select Data that we are going to use
 
 SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM Portfolio_Project.dbo.CovidDeaths
  ORDER by 1, 2 ;

  --Looking at total case vs toal deaths

   SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM Portfolio_Project.dbo.CovidDeaths
  where location like '%china%'
  Order by DeathPercentage DESC


  --Looking at Total Cases vs Population
  -- It shows what percentege of a population got COVID.

  SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 as Percent_Population_Affected
  FROM Portfolio_Project.dbo.CovidDeaths
  --where location like '%russi%'
  Order by CovidPositiveTest DESC


  
  --Looking at countries with highest infection rate compared to population

   SELECT location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationAffected
  FROM Portfolio_Project.dbo.CovidDeaths
  --where location like '%russi%'
  Group by location, population
  Order by 4 DESC



  --Looikng at countries with highest death count per population

  SELECT location, population, MAX(cast(total_deaths as int)) as Total_Death_count
    FROM Portfolio_Project.dbo.CovidDeaths
	where continent is not null
	Group by Location, population
	Order by 3 desc


	--Looking at data by continents . total deaths should be casted as an integer, becuse of the data type in the table.
	 SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_count
    FROM Portfolio_Project.dbo.CovidDeaths
	where continent is not null
	Group by continent
	Order by 2 desc

	--GLOBAL DATA

  
  SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percenage  -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM Portfolio_Project.dbo.CovidDeaths
 -- where location like '%china%'
 where continent is not null
  --Group by date
  Order by 1,2

  --Looking at toltal population vs vaccination 
  --
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_vaccinated
   From Portfolio_Project..CovidDeaths dea
   Join Portfolio_Project..CovidVacinations vac
   on dea.location = vac.location
   and dea.date = vac.date	
   where dea.continent is not null
   order by 2,3


   --USE CTE
   WITH PopVsVac (Continent, Location, date, population,new_vaccinations, rolling_people_vaccinated)
   as 
   (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_vaccinated
   From Portfolio_Project..CovidDeaths dea
   Join Portfolio_Project..CovidVacinations vac
   on dea.location = vac.location
   and dea.date = vac.date	
   where dea.continent is not null)
   --order by 2,3)


  select *, (rolling_people_vaccinated/population)*100 
   from PopVsVac




   --TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)


insert into #PercentPopulationVaccinated
     Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_vaccinated
   From Portfolio_Project..CovidDeaths dea
   Join Portfolio_Project..CovidVacinations vac
   on dea.location = vac.location
   and dea.date = vac.date	
   --where dea.continent is not null
   order by 2,3

   select *, (rolling_people_vaccinated/population)*100 
   from #PercentPopulationVaccinated



  -- Creating view to store data for visualization

  Create View PercentPopulationVaccinated as
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rolling_people_vaccinated
   From Portfolio_Project..CovidDeaths dea
   Join Portfolio_Project..CovidVacinations vac
   on dea.location = vac.location
   and dea.date = vac.date	
   where dea.continent is not null
   --order by 2,3