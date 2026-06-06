-- ===================================================
-- ✅ COVID-19 Data Analytics Project
-- ✅ Created by: Anjali Shinde
-- ✅ Tool: MySQL Workbench
-- ===================================================

-- 1️⃣ Create the database
CREATE DATABASE IF NOT EXISTS CovidAnalytics;
USE CovidAnalytics;

-- 2️⃣ Create the main table
CREATE TABLE IF NOT EXISTS CovidDaily (
  ID INT AUTO_INCREMENT PRIMARY KEY,
  ProvinceState VARCHAR(100),
  CountryRegion VARCHAR(100),
  Latitude DECIMAL(10,6),
  Longitude DECIMAL(10,6),
  ReportDate DATE,
  Confirmed INT,
  Deaths INT,
  Recovered INT,
  Active INT,
  WHORegion VARCHAR(100)
);

-- 3️⃣ LOAD DATA (for reference)
-- Make sure your csv is in secure_file_priv folder!
-- Example: C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_data.csv

-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_data.csv'
-- INTO TABLE CovidDaily
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (ProvinceState, CountryRegion, Latitude, Longitude, ReportDate, Confirmed, Deaths, Recovered, Active, WHORegion);

-- 4️⃣ ✅ Total cases per country
SELECT 
  CountryRegion,
  SUM(Confirmed) AS TotalConfirmed,
  SUM(Deaths) AS TotalDeaths,
  SUM(Recovered) AS TotalRecovered
FROM CovidDaily
GROUP BY CountryRegion
ORDER BY TotalConfirmed DESC;

-- 5️⃣ ✅ Daily new cases
SELECT 
  CountryRegion,
  ReportDate,
  SUM(Confirmed) AS DailyConfirmed
FROM CovidDaily
GROUP BY CountryRegion, ReportDate
ORDER BY CountryRegion, ReportDate;

-- 6️⃣ ✅ Highest affected countries
SELECT 
  CountryRegion,
  SUM(Confirmed) AS TotalConfirmed
FROM CovidDaily
GROUP BY CountryRegion
ORDER BY TotalConfirmed DESC
LIMIT 10;

-- 7️⃣ ✅ Moving average (7-day window)
SELECT 
  CountryRegion,
  ReportDate,
  Confirmed,
  AVG(Confirmed) OVER (
    PARTITION BY CountryRegion 
    ORDER BY ReportDate 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS SevenDayAvg
FROM CovidDaily;

-- 8️⃣ ✅ Create a summary view
CREATE VIEW CountrySummary AS
SELECT 
  CountryRegion,
  SUM(Confirmed) AS TotalConfirmed,
  SUM(Deaths) AS TotalDeaths,
  SUM(Recovered) AS TotalRecovered
FROM CovidDaily
GROUP BY CountryRegion;

-- Test the view
SELECT * FROM CountrySummary;
