select *
from PortfolioProject..CovidDeaths
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--likelihood of death if got Covid
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Ind%'
order by 1,2

--Total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as affectedPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 5 desc

--countries with highest infection rate
select location ,population, MAX(total_cases) as highestInfected,Max(total_cases/population)*100 as highestinfectedpercentage
from PortfolioProject..CovidDeaths
group by location,population
order by highestinfectedpercentage desc

--countries with highest death rate per population
select location , MAX(cast(total_deaths as int)) as highestDeath
from PortfolioProject..CovidDeaths
where continent is not null--while using null it shows only those countries which are not continent while we use is null it shows the only the continents
group by location
order by highestDeath desc


--breaking things based on continent
select continent,MAX(cast(total_deaths as int)) as highestdeath--cast is used to transform one data type to int
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by highestdeath desc

--global numbers
select SUM(new_cases)as totalcases,SUM(cast(new_deaths as int))as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


--Total Population vs vaccination
select Dea.continent, Dea.location,Dea.date,Vac.new_vaccinations,--we need to specify the aliased table names so that the sql server can undrestand from which table the data is to be displayed
SUM(cast(Vac.new_vaccinations as int)) Over (Partition By Dea.location Order By Dea.location,Dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths as Dea
join PortfolioProject..CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
order by 2,3

--in order to find the ratio of the number of rolling  people vaccinated by total population we cannot use the column just created directly
--in that case we need either Common Table Expression(CTE) or Temporary Tables

--use CTE
with PopvsVac(continent,Location,Date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select Dea.continent, Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,--we need to specify the aliased table names so that the sql server can undrestand from which table the data is to be displayed
SUM(cast(Vac.new_vaccinations as int)) Over (Partition By Dea.location Order By Dea.location,Dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths as Dea
join PortfolioProject..CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
where Dea.continent is not NULL


)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
select Dea.continent, Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,--we need to specify the aliased table names so that the sql server can undrestand from which table the data is to be displayed
SUM(cast(Vac.new_vaccinations as int)) Over (Partition By Dea.location Order By Dea.location,Dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths as Dea
join PortfolioProject..CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date

select *,(RollingPeopleVaccinated/Population)*100
from #percentpopulationvaccinated

--creating data to store data for visualizations
CREATE VIEW percentviewpopulation as
select Dea.continent, Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,--we need to specify the aliased table names so that the sql server can undrestand from which table the data is to be displayed
SUM(cast(Vac.new_vaccinations as int)) Over (Partition By Dea.location Order By Dea.location,Dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths as Dea
join PortfolioProject..CovidVaccinations as Vac
on Dea.location=Vac.location
and Dea.date=Vac.date
