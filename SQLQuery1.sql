	Select *
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		order by 3,4

	--select *
	--from [Portfolio Project]..CovidVaccinations
	--order by 3,4

	Select Location, date, total_cases, new_cases, total_deaths, population
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		order by 1,2

	--Total Cases vs. Total Deaths
	
	Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage 
		from [Portfolio Project]..CovidDeaths
		where location like '%states%' and continent is not null
		order by 1,2
	
	--Total Cases vs. Population
	
	Select Location, date, (total_cases), population , (Total_cases/population)*100 as PositivePercentage
		from [Portfolio Project]..CovidDeaths
		where location like '%states%'and continent is not null
		order by 1,2

	--Highest Infection Rates
	
	Select Location, max(total_cases) as HighestInfectionCount, population , max((Total_cases/population))*100 as PercentPopulationInfected 
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		group by location, population
		order by PercentPopulationInfected desc
	

	--Highest Death Count per Population
	
	Select Location, max(cast(total_deaths as int)) as TotalDeathCount  
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		group by location
		order by TotalDeathCount desc


	Select continent, max(cast(total_deaths as int)) as TotalDeathCount  
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		group by continent
		order by TotalDeathCount desc
	
	--Global Numbers

	Select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage 
		from [Portfolio Project]..CovidDeaths
		--where location like '%states%'
		where continent is not null
		group by date
		order by 1,2
	
	
	
	Select  sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage 
		from [Portfolio Project]..CovidDeaths
		--where location like '%states%'
		where continent is not null
		--group by date
		order by 1,2

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		from [Portfolio Project]..CovidDeaths dea
		join [Portfolio Project]..CovidVaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
		where dea.continent is not null
		order by 2,3

--Total Population vs. Vaccinations

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
	--, (rollingpeoplevaccinated)/dea.population)*100
		from [Portfolio Project]..CovidDeaths dea
		join [Portfolio Project]..CovidVaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
		where dea.continent is not null
		order by 2,3

With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
	--, (rollingpeoplevaccinated)/dea.population)*100
		from [Portfolio Project]..CovidDeaths dea
		join [Portfolio Project]..CovidVaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
		where dea.continent is not null
		--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100 
From PopvsVac


With PopvsVac (continent, location, population, new_vaccinations, rollingpeoplevaccinated)
as
(
	Select dea.continent, dea.location, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location) as rollingpeoplevaccinated
	--, (rollingpeoplevaccinated)/dea.population)*100
		from [Portfolio Project]..CovidDeaths dea
		join [Portfolio Project]..CovidVaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
		where dea.continent is not null
		--order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100 
From PopvsVac



Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
	--, (rollingpeoplevaccinated)/dea.population)*100
		from [Portfolio Project]..CovidDeaths dea
		join [Portfolio Project]..CovidVaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
		--where dea.continent is not null
		--order by 2,3
	
	Select *, (rollingpeoplevaccinated/population)*100 
		From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
	--, (rollingpeoplevaccinated)/dea.population)*100
		from [Portfolio Project]..CovidDeaths dea
		join [Portfolio Project]..CovidVaccinations vac
			on dea.location = vac.location
			and dea.date = vac.date
		where dea.continent is not null
		--order by 2,3

Create View USPositiveTests as 
	Select Location, date, (total_cases), population , (Total_cases/population)*100 as PositivePercentage
		from [Portfolio Project]..CovidDeaths
		where location like '%states%'and continent is not null
		--order by 1,2

Create View DeathCount as 
	Select Location, max(cast(total_deaths as int)) as TotalDeathCount  
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		group by location
		--order by TotalDeathCount desc

Create View DeathPercentage as 
	Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage 
		from [Portfolio Project]..CovidDeaths
		where continent is not null
		--order by 1,2