/********************************************************************************************
    🦠 COVID-19 DATA ANALYSIS PROJECT – by Mariam Sharedeh
    Database: dbo.CovidDeaths / dbo.CovidVaccinations
    Description:
        This SQL script analyzes the COVID-19 dataset using aggregate, analytical, 
        and window functions to extract key insights.
********************************************************************************************/


/*------------------------------------------------------------------------------------------
  1️⃣ BASIC EXPLORATION: Cases, Deaths, and Mortality Rate by Country and Date
------------------------------------------------------------------------------------------*/
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / NULLIF(total_cases, 0)) * 100, 2) AS mortality_rate
FROM dbo.CovidDeaths;
-- 🧠 Calculates daily mortality rate = (deaths / cases) × 100 for each country and date.


/*------------------------------------------------------------------------------------------
  2️⃣ GLOBAL OVERVIEW: Mortality Rate per Country
------------------------------------------------------------------------------------------*/
SELECT 
    continent,
    location,
    ROUND(MAX(total_deaths) / NULLIF(MAX(total_cases), 0) * 100, 2) AS mortality_rate
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY mortality_rate DESC;
-- 💡 Uses MAX() to get final totals per country, then computes mortality rate.


/*------------------------------------------------------------------------------------------
  3️⃣ FILTERED EXAMPLES: Mortality Rate for Specific Regions
------------------------------------------------------------------------------------------*/
-- Europe
SELECT 
    continent,
    location,
    ROUND(MAX(total_deaths) / NULLIF(MAX(total_cases), 0) * 100, 2) AS mortality_rate
FROM dbo.CovidDeaths
WHERE location LIKE '%europ%'
GROUP BY continent, location
ORDER BY mortality_rate DESC;

-- Syria
SELECT 
    continent,
    location,
    ROUND(MAX(total_deaths) / NULLIF(MAX(total_cases), 0) * 100, 2) AS mortality_rate
FROM dbo.CovidDeaths
WHERE location LIKE '%syr%'
GROUP BY continent, location
ORDER BY mortality_rate DESC;

-- France
SELECT 
    continent,
    location,
    date,
    population,
    ROUND(total_deaths / NULLIF(total_cases, 0) * 100, 2) AS mortality_rate
FROM dbo.CovidDeaths
WHERE location LIKE '%Fran%';
-- 🧠 Filters by country name to observe local mortality rate over time.


/*------------------------------------------------------------------------------------------
  4️⃣ DEATHS VS POPULATION
------------------------------------------------------------------------------------------*/
-- Percentage of the population that died
SELECT 
    continent,
    location,
    date,
    population,
    ROUND(total_deaths / NULLIF(population, 0) * 100, 2) AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%Fran%';

-- Percentage of the population infected
SELECT 
    continent,
    location,
    date,
    population,
    ROUND(total_cases / NULLIF(population, 0) * 100, 2) AS InfectionPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%Fran%';


/*------------------------------------------------------------------------------------------
  5️⃣ COUNTRIES WITH HIGHEST INFECTION RATE
------------------------------------------------------------------------------------------*/
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(MAX(total_cases) / NULLIF(population, 0) * 100, 2) AS PercentagePopulationAffected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationAffected DESC;
-- 📊 Shows which countries have the highest proportion of population infected.


/*------------------------------------------------------------------------------------------
  6️⃣ TOTAL DEATHS PER COUNTRY
------------------------------------------------------------------------------------------*/
SELECT 
    location,
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM dbo.CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC;
-- ⚙️ CAST ensures the column is treated as numeric (not text) before applying MAX().


/*------------------------------------------------------------------------------------------
  7️⃣ WHY CAST INT OR FLOAT?
------------------------------------------------------------------------------------------*/
-- INT → arrondit les valeurs à un entier (utile pour des décomptes simples)
-- FLOAT → conserve les décimales (utile pour calculs de pourcentages, ratios, etc.)
-- Exemple :
-- CAST(total_deaths AS INT)    → 125
-- CAST(total_deaths AS FLOAT)  → 125.75


/*------------------------------------------------------------------------------------------
  8️⃣ TOTAL DEATHS PER CONTINENT
------------------------------------------------------------------------------------------*/
SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS TotalDeath
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC;
-- 🧭 Returns the highest total death count observed in each continent.


/*------------------------------------------------------------------------------------------
  9️⃣ DAILY NEW CASES AND DEATHS WORLDWIDE
------------------------------------------------------------------------------------------*/
SELECT 
    date,
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    ROUND(SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS DailyDeathRate
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
-- 📈 Aggregates global daily data to monitor pandemic evolution.


/*------------------------------------------------------------------------------------------
  🔟 GLOBAL SUMMARY
------------------------------------------------------------------------------------------*/
SELECT 
    SUM(new_cases) AS GlobalNewCases,
    SUM(CAST(new_deaths AS INT)) AS GlobalNewDeaths,
    ROUND(SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0) * 100, 2) AS GlobalDeathRate
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL;
-- 🌍 Global totals and average death rate.


/*------------------------------------------------------------------------------------------
  11️⃣ VACCINATION PROGRESS (JOIN)
------------------------------------------------------------------------------------------*/
SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TheSumPerLocation
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location 
   AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;
-- 💉 Tracks cumulative vaccinations per country using a window function.


/*------------------------------------------------------------------------------------------
  12️⃣ USING CTE TO CALCULATE PERCENTAGE OF POPULATION VACCINATED
------------------------------------------------------------------------------------------*/
WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS INT)) 
            OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM dbo.CovidDeaths dea
    JOIN dbo.CovidVaccinations vac
        ON dea.location = vac.location 
       AND dea.date = vac.date 
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       ROUND((RollingPeopleVaccinated / NULLIF(population, 0)) * 100, 2) AS PercentPopulationVaccinated
FROM PopvsVac
WHERE location LIKE 'France';
-- 🧾 CTE (Common Table Expression) improves readability.
-- 🎯 Calculates rolling sum of vaccinated people per country as % of total population.


/********************************************************************************************
  END OF SCRIPT
********************************************************************************************/
