select *
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4
  
  --Select Data that we are going to be using
  select location, date, total_cases, new_cases, total_deaths, population 
  from PortfolioProject..CovidDeath
  where continent is not null
  order by 1,2

  --Looking at Total cases vs Total Deaths
  --Shows Likelihood of dying if your contract covid in your country
  select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from PortfolioProject..CovidDeath 
  where location = 'india' and 
  continent is not null
  order by 1,2

  --Looking at Total cases vs Population
  --Shows what percentaion of population got covid in India
  select location,date,total_cases,population, (total_cases/population)*100 as PopulationinfectedPercentage
  from PortfolioProject..CovidDeath 
  where location ='india' and
  continent is not null
  order by 1,2

  --looking at the countries with Highest Infection Rate compare to Population
   select location,population,max(total_cases)as Highestinfectedcount,max((total_cases/population))*100 as PopulationinfectedPercentage
  from PortfolioProject..CovidDeath 
  where continent is not null
  group by location,population
  order by PopulationinfectedPercentage desc

  --Showing countries with highest Death Count per population
  select location, max(cast(total_cases as int)) as TotalDeathcount
  from PortfolioProject..CovidDeath
  where continent is not null
  group by location
  order by TotalDeathcount desc

  --Showing continent with highest Death count per population
  select continent, max(cast(total_cases as int)) as TotalDeathcount
  from PortfolioProject..CovidDeath
  where continent is not null	
  group by continent
  order by TotalDeathcount desc

  --Global Numbers
  select SUM(new_cases) as Totalnewcases ,SUM(cast(new_deaths as int)) as TotalNewDeaths,
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
  from PortfolioProject..CovidDeath

 --Looking at Total Population vs vaccination
 with popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 ( 
 select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location
 order by dea.date,dea.location) as RollingPeopleVaccinated
 from
 PortfolioProject..CovidDeath dea
 join
 PortfolioProject..CovidVaccination vac
 on 
 dea.location = vac.location and
 dea.date =vac.date
 where dea.continent is not null
 )
 select *,(RollingPeopleVaccinated/population)*100
 from popvsvac

 --Temp Table
 Drop table if exists #Percentpopulationvaccinated
 create table #Percentpopulationvaccinated
 (Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )


 insert into #Percentpopulationvaccinated
 select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location
 order by dea.date,dea.location) as RollingPeopleVaccinated
 from
 PortfolioProject..CovidDeath dea
 join
 PortfolioProject..CovidVaccination vac
 on 
 dea.location = vac.location and
 dea.date =vac.date
 --where dea.continent is not null
 select * ,(Rollingpeoplevaccinated/Population)*100
 from #Percentpopulationvaccinated

 --Creating View to store data for later Visualization

 use PortfolioProject
 CREATE VIEW Percentpopulationvaccinated1 as
 select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.location
 order by dea.date,dea.location) as RollingPeopleVaccinated
 from
 PortfolioProject..CovidDeath dea
 join
 PortfolioProject..CovidVaccination vac
 on 
 dea.location = vac.location and
 dea.date =vac.date
 where dea.continent is not null
 --order by 2,3
 select * 
 from Percentpopulationvaccinated1