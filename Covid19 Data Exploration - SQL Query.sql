-- I select all columns from Covid_Deaths and Covid_Vaccinations
-- I orderd by the 3rd and then the 4th columns (location and date)
-- So that I can view my tables

SELECT *
FROM Covid_Deaths
ORDER BY 3,4

SELECT *
FROM Covid_Vaccinations
ORDER BY 3,4




-- I select the columns I'll be using from the Covid_Deaths table, ordering by location and date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
ORDER BY 1,2




-- I find for each location (country) the total population, total cases,total deaths, percerntage of population infected and perentage of population dead through Covid 19.
-- From the biggest to the samllest

SELECT Location,max(population) as Total_population, max(total_cases) as Total_cases, max(Cast(total_deaths as int))as Total_deaths,
		max(total_cases/population)*100 as Percentage_of_population_infected,
		max(total_deaths/population)*100 as Percentage_of_population_dead_through_covid
FROM Covid_Deaths
WHERE Continent is not null
GROUP BY location
ORDER BY Total_Deaths desc




-- I find each continent's population, total cases, total deaths, percentage of infected and percentage of population 
-- dead through to Covid

SELECT Continent, max(population) as Population, max(cast(Total_cases as int)) as Total_cases, max(cast(total_deaths as int)) as Total_death,
		max(total_cases/population) as Percentage_of_population_infected,
		max(total_deaths/population) as Percentage_of_population_dead_through_Covid
FROM Covid_Deaths
WHERE Continent is not null
GROUP BY Continent
ORDER BY Percentage_of_population_dead_through_Covid desc




-- Showing the global total cases per day and the global total deaths per day
--( I used "sum" because the sum of the new cases for each date equals the total case for that date, and the sum of the new deaths equals
-- the total deaths for that day )

SELECT Date, sum(cast(new_cases as int)) as Total_cases_per_date, sum(cast(new_deaths as int)) as Total_deaths_per_date
FROM Covid_Deaths
WHERE continent is not null
GROUP BY Date
ORDER BY Date




--Showing the overall global toal cases and total death as of 25/07/2022

SELECT max(date) as Last_date_recorded, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths
FROM Covid_Deaths
WHERE continent is not null



-- I find the percentage of deaths per total case for each day in Nigeria,
-- the percentage of the population infected for each day in Nigeria,
-- and percentage of the total population dead through Covid for each date in asc order

SELECT Location, Date, Total_cases, (Cast (total_deaths as int)) as Total_deaths, Population, (total_deaths/total_cases)*100 as Percentage_of_death_Per_Total_case, (total_cases/population)*100
		as Percentage_of_population_infected, (total_deaths/population)*100 as Percentage_of_population_dead_through_covid
FROM Covid_Deaths
WHERE location = 'Nigeria'
ORDER BY 2




-- Joining the two  tables together based on the location and date. showing total vaccination and cummulative vaccination per day

SELECT D.Continent, D.Location, D.Date, D.Population, V.New_vaccinations,
		sum(cast(V.new_Vaccinations as int)) over (partition by D.location order by D.location, D.date) as cummulative_vaccinations
FROM Covid_Deaths as D
JOIN Covid_Vaccinations as V
	ON D.location = V.location
	AND D.date = V.date
WHERE D.Continent is not null
ORDER BY 2,3




-- Using the last statement as a CTE (common table expression), I write a querry to find the percentage of the population vaccinated
-- for each location per day

WITH CTE_1 as(
SELECT D.Continent, D.Location, D.Date, D.Population, V.New_vaccinations,
		sum(cast(V.new_Vaccinations as int)) over (partition by D.location order by D.location, D.date) as Cummulative_vaccinations
FROM Covid_Deaths as D
JOIN Covid_Vaccinations as V
	ON D.location = V.location
	AND D.date = V.date  
WHERE D.Continent is not null)
--ORDER BY 2,3)
SELECT *, (cummulative_vaccinations/population)*100 as Percentage_of_population_vaccinated
FROM CTE_1




-- I Created View for  Countries_totapopulation_totalcases_totaldeaths_percerntage_of_population_infected
--and_perentage_of_population_dead_through_Covid 19

CREATE VIEW Each_country_data as
SELECT Location,max(population) as Total_population, max(total_cases) as Total_cases, max(Cast(total_deaths as int))as Total_deaths,
		max(total_cases/population)*100 as Percentage_of_population_infected,
		max(total_deaths/population)*100 as Percentage_of_population_dead_through_covid
FROM Covid_Deaths
WHERE Continent is not null
GROUP BY location
--ORDER BY Total_Deaths desc