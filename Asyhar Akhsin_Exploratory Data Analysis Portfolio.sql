SELECT *
FROM CovidDeaths
ORDER BY 3,4 asc

--------------------------------------------------------------------------------------
-- Select Data that going to be using
Select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--------------------------------------------------------------------------------------
-- Death percentage by total cases
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
wHERE location LIKE 'Indonesia'
ORDER BY 1,2

--------------------------------------------------------------------------------------
-- Cases percentage by total populations
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
wHERE location LIKE 'Indonesia'
ORDER BY 1,2

--------------------------------------------------------------------------------------
-- Countries with highest Infection rate compared to population
With InfectedRated as
(
	Select Location, max(total_cases) as highestInfectionCount, population, max((total_cases/population))*100 as PercentPopulationInfected
	from CovidDeaths
	Group by location, population
)
Select *, 
Case 
When PercentPopulationInfected >= 10 then 'HIGH Infection'
When PercentPopulationInfected between 5 and 9.99 then 'MODERATE Infection'
When PercentPopulationInfected <= 4.99 then 'LOW Infection'
end
From InfectedRated

--------------------------------------------------------------------------------------
-- Countries with highest death counts per populations

Select *
from CovidDeaths

Select location, max(cast (total_deaths as int)) as HighestDeathCounts, population, 
(max(cast (total_deaths as int))/population)*100 as DeathPercentage
from CovidDeaths
Where continent is not null
-- Tujuan where is not null adalah untuk menghilangkan continent yang bernilai NULL
Group By location, population
Order By HighestDeathCounts desc

Select continent, max(cast (total_deaths as int)) as HighestDeathCounts
from CovidDeaths
Where continent is not null
-- Tujuan where is not null adalah untuk menghilangkan continent yang bernilai NULL
Group By continent
Order By HighestDeathCounts desc

-- Count cases and deaths day by day
Select date, Sum(new_cases) as NewCases, SUM(CAST (new_deaths as float)) as NewDeaths, 
Sum(cast(new_deaths as float))/sum(new_cases) * 100 as DeathPercentageOverCases
FROM CovidDeaths
Where continent is not null
group by date
order by 1

Select Sum(new_cases) as NewCases, SUM(CAST (new_deaths as float)) as NewDeaths, 
Sum(cast(new_deaths as float))/sum(new_cases) * 100 as DeathPercentageOverCases
FROM CovidDeaths
Where continent is not null
-- group by date
order by 1

--------------------------------------------------------------------------------------
-- Join 2 Tables

Select dea.location, vac.male_smokers
From CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

	--
	Select dea.continent, dea.location, dea.date, dea.population, 
	(Cast(vac.new_vaccinations as float)), -- atau 
	(Convert(float, vac.new_vaccinations))
	-- CAST STATEMENT dan CONVERT digunakan untuk kepentingan pengubahan DATATYPE secara KONDISIONAL
From CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Order by 5 desc;

-- Total Population vs Vaccinations
With PopvsVAC as
(
	Select dea.continent, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float))over(Partition By dea.location order by dea.location, dea.date) as RollTotalVaccEachDay
	From CovidDeaths dea
	join CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		Where dea.continent is not null
)
Select *, ((RollTotalVaccEachDay)/population)*100 as Percentage
from PopvsVAC;

--Temp Table
Drop Table if Exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
location nvarchar(225),
Date datetime,
population numeric,
New_Vaccination numeric,
RollTotalVaccEachDay numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float))over(Partition By dea.location order by dea.location, dea.date) as RollTotalVaccEachDay
	From CovidDeaths dea
	join CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		--Where dea.continent is not null

Select *, ((RollTotalVaccEachDay)/population)*100 as Percentage
from #PercentPopulationVaccinated;

-- Create View to store data for later visualization
/* 
VIEW akan membuat hasil kueri menjadi permanen dan bisa disimpan untuk visualisasi 
tanpa harus save output secara terpisah
*/
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float))over(Partition By dea.location order by dea.location, dea.date) as RollTotalVaccEachDay
	From CovidDeaths dea
	join CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		Where dea.continent is not null

select *
from PercentPopulationVaccinated