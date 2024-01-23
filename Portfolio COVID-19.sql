-- **Database Documentation**

-- **Schema Overview**
-- The PortfolioCOVID database consists of multiple table containing data related to COVID-19 pandemic.

-- Table					: CovidDeaths
-- Columns used & data type	: [Continent(nvarchar(255)), Location(nvarchar(255)), Date(datetime), Population(float), total_cases(float), total_deaths(nvarchar(255)), etc.]
-- Explanation				: This table contain information regarding COVID-19 cases and deaths, include location, date, total cases, total deaths, etc.
-- Dataset size				: Approximately 85,171 rows and 26 columns.

-- Table					: CovidVaccs
-- Columns used & data type	: [Continent(nvarchar(255)), Location(nvarchar(255)), Date(datetime), new_vaccinations(nvarchar(255)), total_vaccinations(nvarchar(255)), etc.]
-- Explanation				: This table contain information regarding COVID-19 vaccinations, include location, date, new vaccination, total vaccination, etc.
-- Dataset size				: Approximately 85,171 rows and 37 columns.

-- Dataset source : https://ourworldindata.org/covid-deaths
--					(CTRL + click to follow link)

-- **Introduction & Context**
-- In this analysis, we explored into the extensive data surrounding Covid-19 from PortfolioCovid database.
-- The primary aim is to gain insights into global and regional trends regarding infection rates, deaths, and the progress of vaccination efforts.
-- This exploration spans data from crucial years 2020 - 2021.


-- **Assumptions and Limitations**
-- To embark in this data journey, please acknowledge that the accuracy and completeness of this analysis hinge on the quality of the provided data.
-- Recognizing assumptions, such as variations in testing and reporting practices (e.g., differences in testing facility, reliability of testing methods, delays in reporting timelines, capacity of healthcare systems, and government policies and reporting compliance), is essential in interpreting the result and diminishing biases.


-- **Queries and Analysis Notes**

-- **Basic Exploration : Filtering and Ordering**
-- My initial attempt involves a basic exploration, filtering out null continent values to reduce bias in the data analyzing process and ordering the result by location and date to sort the data for a chronological understanding of COVID-19 data. 
 
-- Notes :
-- Filtering out null continent value is essential for focusing on valid and relevant data.
-- Ordering by location and date allows for a structured chronological presentation.

SELECT *
FROM 
	PortfolioCOVID..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	location, date;


-- **Global and Indonesia-Specific Metrics**

-- 1. **Indonesia's Total Covid-19 Cases VS Total Deaths Percentage**
-- Moving forward, we focused on Indonesia, aiming to understand the total cases, death percentages, and infected population percentages from 2020 - 2021.

-- Notes :
-- - Aggregate function used to calculate percentages of total death percetages based on total cases.
-- - Rounded to 2 decimal places to improve data readability.
-- - Filters for data only from Indonesia, and orders the result by location and date for a chronological view.

SELECT 
	Location, 
	Date, 
	total_cases, 
	total_deaths, ROUND((total_deaths/total_cases)*100,2) AS Death_Percentage
FROM 
	PortfolioCOVID..CovidDeaths
WHERE 
	Location = 'Indonesia'
ORDER BY 
	Location, Date;


-- 2. **Total Cases vs Population Affected by Covid-19 Percentage in Indonesia**
-- This query calculate the percentage of population affected by COVID-19 in Indonesia and orders the data chronologically.

-- Notes :
-- - The SELECT query calculates the percentage of the population affected by COVID-19.
-- - Rounded with 2 decimal places for enhanced data readability.
-- - Filters for data only from Indonesia and is sorted by location and date for better chronological ordering.

SELECT 
	Location, 
	Date, 
	population, 
	total_cases, 
	ROUND((total_cases/population)*100,2) AS Infected_Population
FROM 
	PortfolioCOVID..CovidDeaths
WHERE 
	Location = 'Indonesia'
ORDER BY
	Location, Date;


-- **Global and Regional Comparative Analysis**

-- 3. **Countries with Highest Infection Rate per Population**
-- This queries identifies countries with the highest infection rates per population. 

-- Notes :
-- - Using MAX aggregate function to find the maximum infection rate for each countries as InfectedPopulationPercentage column.
-- - Sorted in descending order to highlight countries with the highest infection rates.

SELECT 
	Location, 
	population, 
	MAX(total_cases) AS HighestInfection, 
	MAX((total_cases/population))*100 AS InfectedPopulationPercentage
FROM 
	PortfolioCOVID..CovidDeaths
GROUP BY 
	Location, population
ORDER BY
	InfectedPopulationPercentage DESC;


-- 4. **Countries with the Highest Deaths per Population**
-- This queries identifies countries with the highest total death per population. 

-- Notes :
-- - MAX was used to highlight highest total deaths (converted to integer).
-- - Grouped by Location to present the highest result based on location.
-- - Sorted by TotalDeathsCount in descending order for clarity.

SELECT 
	Location, 
	MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM 
	PortfolioCOVID..CovidDeaths
WHERE 
	continent IS NOT NULL
GROUP BY 
	Location
ORDER BY 
	TotalDeathsCount DESC;


-- 5. **Continents with Highest Deaths Count per Population**
-- This queries identifies continents with the highest total death per population. 

-- Notes :
-- - MAX was used to highlight highest total deaths (converted to integer).
-- - Filtering out null Continent values to removes biases.
-- - Grouped by Continent and sorted in descending order by TotalDeathsCount for clarity.

SELECT 
	continent, 
	MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM 
	PortfolioCOVID..CovidDeaths
WHERE 
		continent IS NOT NULL
GROUP BY
	continent
ORDER BY
	TotalDeathsCount DESC;


-- 6. **Global Overview Metrics**

-- Global Covid-19 Numbers
-- A broad view of the pandemic's impact is offered through this query, summarizing total cases, deaths, and death percentages globally.

-- Notes :
-- Using SUM to calculate total infection cases, total new deaths (converted to integer), and death percentages by population.
-- Sorted by total cases and total deaths for a comparative view.

SELECT 
		SUM(total_cases) AS total_cases, 
		SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM 
	PortfolioCOVID..CovidDeaths
WHERE 
	continent IS NOT NULL
ORDER BY 
	total_cases, total_deaths;


-- 7. **Global Vaccination Progress**

-- **Total Global Populations vs Vaccinations**
-- Shifting the next focus to the vaccination effort, these queries detail the relationship between global populations, new vaccinations, and rolling vaccination percentages.

-- Notes :
-- - SUM function was used to get the total of new_vaccinations (converting to integer)
-- - Combined with OVER clause to get the total of new_vaccinations partition based on location and order the result by location and date to present it in chronological order.

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioCOVID..CovidDeaths dea
JOIN 
	PortfolioCOVID..CovidVaccs vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY
	location, date;
	

-- **Visualizations and Temporal Data Storage** 
-- To facilitate analysis and maintain code clarity, temporary tables and a view are introduced.

-- **CTE for Rolling Vaccination Percentages**
-- The Common table expression names Pop_vs_Vac acts as a structured and organized container. 
-- It is utilized to calculate rolling vaccination percentages.
-- By encapsulating rolling_people_vaccinated calculation in CTE, 
-- the main query utilizes the stored data to calculate rolling_people_vaccinated percentages with respect to the population.

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioCOVID..CovidDeaths dea
JOIN 
	PortfolioCOVID..CovidVaccs vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
SELECT 
	*, 
	(rolling_people_vaccinated/population)*100
FROM 
	Pop_vs_Vac;

	
-- **Temporary Table for Vaccination Progress**
-- The purpose of this temporary table, Percent_population_vaccinated, is to store and organize specific columns from the result sets of the query related to vaccination progress for later analysis or visualization.

-- Creating the temporary table to store vaccinations progress data
CREATE TABLE #Percent_population_vaccinated
(
Continent nvarchar(255),					-- Continent information
Location nvarchar(255),						-- Location information
Date datetime,								-- Date of the data
Population numeric,							-- Population data
New_vaccinations numeric,					-- New Vaccinations data
Rolling_people_vaccinated numeric			-- Rolling sum of New Vaccinations, calculated over partition by Location and order by location and date 
);

-- Populate the Temporary Table with relevant data
INSERT INTO #Percent_population_vaccinated
SELECT 
		dea.continent,
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations, 
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioCOVID..CovidDeaths dea
JOIN 
	PortfolioCOVID..CovidVaccs vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date;

-- **Querying Temporary Table for Visualization**
-- Retrieves all column from the temporary table Percent_population_vaccinated and include additional column calculated using an aggregate function.
-- This additional column represent the percentages of the population that has received vaccinations.

SELECT 
	*, 
	(rolling_people_vaccinated/population)*100 AS VaccinationPercentage
FROM 
	#Percent_population_vaccinated;


-- **View for Visualization Data Storage**
-- This view combine data from CovidDeaths as 'dea' and CovidVaccs as 'vac' tables and calculate rolling sum of new_vaccinations over partition by location.

CREATE VIEW Percent_population_vaccinated AS 
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioCOVID..CovidDeaths dea
JOIN 
	PortfolioCOVID..CovidVaccs vac
ON 
	dea.location = vac.location
	AND dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL;

-- **Display Visualization Data**

SELECT *
FROM 
	Percent_population_vaccinated;


-- **Comparisons and Trends**
-- The next sessions unveil comparative analysis of infection rates, deaths per population, and vaccination rates, offering insights into the diverse impact factors such as geography, demographics, healthcare systems, public health strategies, and economic conditions.
	

-- **Key Findings**
-- Unraveling the complexities within the dataset reveals vital insight into the trajectory of the pandemic. Here are the Key Findings :

-- 1. Patient Zero in Indonesia :
--	  - Identification of the earliest recorded COVID-19 case in Indonesia, shedding light on the initial stages and potential sources of the outbreak.

-- 2. Global Impact on Infection and Mortality Rates :
--	  - Comprehensive analysis of infection and death rates globally, uncovering pattern, hotspots, and the varying impact on different region.

-- 3. Remarkable Progress in Vaccination Efforts :
--	  - Highlighting significant advancements in vaccination campaigns, with a focus on the percentage of the population receiving vaccinations and the overall effectiveness of these initiatives.


-- **Recommendations**
-- As we conclude this analysis, practical recommendations come to the forefront.
-- These range from the urgency of vaccination to the adherence of essential health protocols, point up the significance of personal responsibility in controlling the spread of the virus.
-- Here are the key recommendations :
--	1. Get Vaccinated Promptly :
--	   - Prioritize receiving the COVID-19 vaccine as soon as possible.

--	2. Maintain social distancing :
--	   - Keep a minimum distance of 1 meter from others to reduce the risk of transmission.

--	3. Proper mask usage :
--	   - Wear a mask properly to protect yourself and others.

--	4. Practice respiratory hygiene :
--	   - Covers your mouth and nose when chouging or sneezing to prevent the spread of respiratory droplets.

--	5. Practice good hygiene and local health protocol :
--	   - Adhere to recommended hygiene practice and local healths protocol to minimize the risk of infection.

--	6. Self-isolate if symptomatic or Positive :
--	   - If you develop COVID-19 symptoms or tested positive, self-isolate until you recover to prevent further transmission.

--	7. Seek Immediate Medical Attention For Severe Symptoms :
--	   -- If you experiencing symptoms such as fever, persistent cough, or difficulty breathing, contact local health authorities immediately for guidance and assistance.

-- These recommendation serves as comprehensive guide to protect themselves and others, aligning with global health guideline.
-- source : https://www.who.int/emergencies/diseases/novel-coronavirus-2019/advice-for-public#:~:text=Avoid%20crowds%20and%20close%20contact,when%20you%20cough%20or%20sneeze.
--			(CTRL + click to follow link)	

-- **Conclusion**
-- In summary, the analysis of PortfolioCovid offers a valuable insight into the trajectory of the COVID-19 pandemic, as highlighted below :
--	1. Geographical Trends
--		- The data reveals clear pattern in infection and death rates accross different areas. Focusing the need of public health actions.

--	2. Vaccination Progress
--		- Good progress has been made in vaccinating more people, which is important for slowing the virus and reducing severe effects.

--	3. Indonesia's Patient Zero
--		- Finding the first COVID-19 case in Indonesia helps us understand how the outbreak started and where it might have came from, improving our knowledge of the virus origins.

--	4. Global Impact
--		- A thorough look at global infection and death rates reveals patterns, hotspots, and different impacts on region. 
--		- This insight helps to create specific strategies for managing the pandemic worldwide.

--	5. Personal Responsibilty
--		- The recommendation focused the need for personal responsibility, such as getting vaccinated, following health guidelines, and quickly reporting symptoms.
--		- These actions are crucial in controlling the virus's spread.

--	6. Limitation and consideration
--		- Recognizing the analysis limitations, like differences in testing and reporting methods, is vital for interpreting the results correctly.

-- In conclusion, this analysis provides a comprehensive view of COVID-19 pandemic, contributing to our understanding of its impact on a global and regional scale.
-- The identified trends and patterns offer valuable insight for governments, healthcare professionals, and the general public in navigating the ongoing challenges posed by the pandemic.