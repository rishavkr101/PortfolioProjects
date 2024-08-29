select * from portfolioproject..CovidDeaths
order by 3,4

select * from portfolioproject..CovidVaccinations
order by 3,4

-- select Data that we are going to be using 

select Location , date , total_cases,total_deaths,population
from portfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths 
-- shows liklyhood of dieing if you contract covid in india 
select Location , date , total_cases,total_deaths, (CAST(total_deaths AS FLOAT) / total_cases) * 100 AS Deathpercentage
from portfolioProject..CovidDeaths
where location like '%india'
order by 1,2


-- looking at total case vs population

select Location , date , total_cases,population, (CAST(total_cases AS FLOAT) / population) * 100 AS total_contract
from portfolioProject..CovidDeaths
where location like '%india'
order by 1,2

-- looking at countries with highest infection rate 
select Location , population, MAX(total_cases) as highestinfectioncount ,  MAX((CAST(total_cases AS FLOAT) / population) * 100) AS percentpopulation_infected
from portfolioProject..CovidDeaths
GROUP BY 
    Location, 
    population
ORDER BY percentpopulation_infected desc;


-- showing the countries with Highst death count per population

select Location  ,total_deaths,  max (CAST(total_deaths AS float) / population) * 100 AS death_count_perpopulation 
from portfolioProject..CovidDeaths
where continent is not null
GROUP BY 
    Location,
	total_deaths
ORDER BY death_count_perpopulation  desc;



-- showing the continents with highest death count per population
select continent , MAX(CAST(total_deaths AS float )) as TotaldeathsCount
from portfolioProject..CovidDeaths
where continent is not  null
group by continent
order by TotaldeathsCount desc



-- global numbers

select date , SUM(new_cases) as total_cases ,SUM(new_deaths) as total_deaths,(SUM(CAST(new_deaths as  float))/SUM(new_cases))*100 as DeathPercentage
from portfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- looking at total population vs total population 

--USE CTE
With PopvsVac  (Continent, Location , Date, Population, New_vaccination,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeoplVaccinated --(rolling_poplvaccinated/population)*100
from portfolioProject.. CovidDeaths dea
join portfolioProject.. Covidvaccinations vac
  on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(cast(RollingPeopleVaccinated as float)/Population)*100
from PopvsVac




-- TEMP TABLE

Drop Table if exists PercentagePopulationVaccinated
Create Table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentagePopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeoplVaccinated --(rolling_poplvaccinated/population)*100
from portfolioProject.. CovidDeaths dea
join portfolioProject.. Covidvaccinations vac
  on dea.location = vac.location
      and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(cast(RollingPeopleVaccinated as float)/population)*100  rollpercent
from PercentagePopulationVaccinated





-- creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.location, dea.date) as RollingPeoplVaccinated --(rolling_poplvaccinated/population)*100
from portfolioProject.. CovidDeaths dea
join portfolioProject.. Covidvaccinations vac
  on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null



select * 
From PercentPopulationVaccinated