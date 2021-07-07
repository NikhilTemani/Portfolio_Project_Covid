/*
Covid Data Exploration 

Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

CREATE TABLE CovidDeaths
(
	iso_code VARCHAR(10),
	continent VARCHAR(50),
	location VARCHAR(50),
	date DATE,
	population bigint,
	total_cases INT,
	new_cases INT,
	new_cases_smoothed float,
	total_deaths INT,
	new_deaths INT,
	new_deaths_smoothed float,
	total_cases_per_million float,
	new_cases_per_million float,
	new_cases_smoothed_per_million float,
	total_deaths_per_million float,
	new_deaths_per_million float,
	new_deaths_smoothed_per_million float,
	reproduction_rate  float,
	icu_patients INT,
	icu_patients_per_million float,
	hosp_patients INT,
	hosp_patients_per_million float,
	weekly_icu_admissions float,
	weekly_icu_admissions_per_million float,
	weekly_hosp_admissions float,
	weekly_hosp_admissions_per_million float,
	new_tests INT
);

CREATE TABLE CovidVaccinations(
	iso_code VARCHAR(10),
	continent VARCHAR(50),
	location VARCHAR(50),
	date DATE,
	new_tests INT,
	total_tests INT,
	total_tests_per_thousand float,
	new_tests_per_thousand float,
	new_tests_smoothed INT,
	new_tests_smoothed_per_thousand float,
	positive_rate float,
	tests_per_case float,
	tests_units VARCHAR(50),
	total_vaccinations INT,
	people_vaccinated INT,
	people_fully_vaccinated INT,
	new_vaccinations INT,
	new_vaccinations_smoothed INT,
	total_vaccinations_per_hundred float,
	people_vaccinated_per_hundred float,
	people_fully_vaccinated_per_hundred float,
	new_vaccinations_smoothed_per_million INT ,
	stringency_index float,
	population_density float,
	median_age float,
	aged_65_older float,
	aged_70_older float,
	gdp_per_capita float,
	extreme_poverty float,
	cardiovasc_death_rate float,
	diabetes_prevalence float,
	female_smokers float,
	male_smokers float,
	handwashing_facilities float,
	hospital_beds_per_thousand float,
	life_expectancy float,
	human_development_index float,
	excess_mortality float
);

---Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT null

--Total Cases vs Total Deaths In India
--Since total_deaths was input as a INT. So, I had to change the data type to a float.

SELECT Location, date, total_cases, total_deaths,
CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS Death_Percentage
FROM CovidDeaths
WHERE Location = 'India'
ORDER BY location, date desc

----Total Cases vs Population in India
--Shows what percentage of population infected by Covid

SELECT Location, date, total_cases, population, 
CAST(total_cases AS float)/CAST(population AS float)*100 AS Population_Percentage
FROM CovidDeaths
WHERE Location = 'India'

--Countries with highest Infection rate as compared to population

SELECT Location, MAX(total_cases) AS Highest_Infection_Count, population, 
MAX(CAST(total_cases AS float)/CAST(population AS float)*100) AS Percentage_Population_Infected
FROM CovidDeaths
WHERE total_cases IS NOT NULL AND continent IS NOT NULL
GROUP BY Location, population
ORDER BY Percentage_Population_Infected desc 

--Countries with highest Death Count compared to population

SELECT Location, MAX(CAST(total_deaths AS float)) AS Total_Death_Count
FROM CovidDeaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count desc

--BY CONTINENT

--Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count desc

-- Continents Total Cases vs Total Deaths 

SELECT continent,date, total_cases,total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1,2 DESC

-- Total Cases vs Continent Population

SELECT continent,date,population,total_cases, CAST(total_cases AS float)/CAST(population AS float)*100 AS Cases_Per_Population
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
ORDER BY 1,2

--Worldwide cases, deaths, and death percentage.

SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS float)) as Total_Deaths
, SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 AS Death_Percentage
FROM CovidDeaths
						
-- Join covid deaths table with covid vaccinations table

SELECT * 
FROM CovidDeaths AS CD
INNER JOIN CovidVaccinations AS CV
	ON CD.location = CV.location
	AND CD.date = CV.date

---- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
FROM CovidDeaths AS CD
INNER JOIN CovidVaccinations AS CV
ON CD.location = CV.location AND
   CD.date = CV.date
WHERE CD.continent IS NOT null AND CV.new_vaccinations IS NOT NULL
ORDER BY 1,2,3 DESC;
 
 
--Total vaccination rolling count

With PopvsVac(Continent, Location, Date, Population, new_vaccination, Rolling_People_Vaccinated)
as
(
	SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CV.new_vaccinations) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
	FROM CovidDeaths AS CD
	INNER JOIN CovidVaccinations AS CV
	ON CD.location = CV.location AND
   	CD.date = CV.date
 	WHERE CD.continent IS NOT null AND CV.new_vaccinations IS NOT NULL
)
SELECT *,
CAST(Rolling_People_Vaccinated AS float)/CAST(population as float)*100 AS Total_People_Vaccinated_Percentage
FROM PopvsVac

---Temp Table
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS Percent_Population_Vaccinated

CREATE TABLE Percent_Population_Vaccinated
(
	continent VARCHAR(255),
	Location VARCHAR(255),
	date DATE,
	Population float,
	new_vaccinations float,
	Rolling_People_Vaccinated float
);
	
INSERT INTO Percent_Population_Vaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CV.new_vaccinations) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
	FROM CovidDeaths AS CD
	INNER JOIN CovidVaccinations AS CV
	ON CD.location = CV.location AND
   	CD.date = CV.date
 	WHERE CD.continent IS NOT null;	

SELECT * ,
CAST(Rolling_People_Vaccinated AS float)/CAST(population as float)*100 AS Total_People_Vaccinated_Percentage
FROM Percent_Population_Vaccinated
WHERE new_vaccinations IS NOT NULL

-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CV.new_vaccinations) OVER (Partition by CD.location ORDER BY CD.location, CD.date) AS Rolling_People_Vaccinated
	--(Rolling_People_Vaccinated/population)*100
	FROM CovidDeaths AS CD
	JOIN CovidVaccinations AS CV
	ON CD.location = CV.location AND
   	CD.date = CV.date
 	WHERE CD.continent IS NOT null AND CV.new_vaccinations IS NOT NULL
