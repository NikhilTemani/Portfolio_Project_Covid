/*
Queries used for Tableau Project
*/

-- 1. Globsl Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths, SUM(CAST(new_deaths AS float))/SUM(New_Cases)*100 AS Death_Percentage
From CovidDeaths
--Where location = 'India'
WHERE continent IS NOT null 


-- 2. Total Death Count Per Continent

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT continent, SUM(CAST(new_deaths as float)) as Total_Death_Count
FROM CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL 
--AND location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY Total_Death_Count desc

-- 3.Percent Population Infected Per Location

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count,  MAX(CAST(total_cases AS float))/CAST(population AS float)*100 AS Percent_Population_Infected
FROM CovidDeaths
--WHERE location = 'India'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected desc


-- 4. Percent Population Infected

SELECT Location, Population, date, MAX(total_cases) AS Highest_Infection_Count, MAX(CAST(total_cases AS float))/CAST(population AS float)*100 AS Percent_Population_Infected
FROM CovidDeaths
--WHERE location = 'India'
GROUP BY Location, Population, date
ORDER BY Percent_Population_Infected desc


