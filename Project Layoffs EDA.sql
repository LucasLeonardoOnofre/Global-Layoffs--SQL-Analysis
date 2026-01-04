-- =====================================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- =====================================================
-- Objective:
-- Explore the layoffs dataset to identify trends, patterns,
-- outliers, and notable insights across companies, industries,
-- locations, and time.
--
-- At this stage, no specific hypothesis is assumed; the goal
-- is to understand the data and uncover interesting signals.
-- =====================================================

SELECT *
FROM world_layoffs.layoffs_staging2;

-- =====================================================
-- BASIC EXPLORATION
-- =====================================================

-- Maximum number of employees laid off in a single event
SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;

-- =====================================================
-- LAYOFF SEVERITY (PERCENTAGE)
-- =====================================================

-- Identify the largest and smallest layoff percentages
SELECT 
    MAX(percentage_laid_off),  
    MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;


-- Companies that laid off 100% of their workforce
-- (Typically indicates company shutdowns)
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;


-- Ordering fully laid-off companies by funding raised
-- to understand the scale of failed organizations
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- =====================================================
-- AGGREGATED ANALYSIS (GROUP BY)
-- =====================================================

-- Companies with the largest single-day layoff events
SELECT 
    company, 
    total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the highest total layoffs across the dataset
SELECT 
    company, 
    SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Total layoffs by location
SELECT 
    location, 
    SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 10;

-- Total layoffs by country
SELECT 
    country, 
    SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- Total layoffs by year
SELECT 
    YEAR(date) AS year, 
    SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Total layoffs by industry
SELECT 
    industry, 
    SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Total layoffs by company stage
SELECT 
    stage, 
    SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- =====================================================
-- ADVANCED ANALYSIS
-- ====================================================
-- Top 3 companies with the highest layoffs per year
WITH Company_Year AS (
    SELECT 
        company, 
        YEAR(date) AS years, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
    SELECT 
        company, 
        years, 
        total_laid_off, 
        DENSE_RANK() OVER (
            PARTITION BY years 
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM Company_Year
)
SELECT 
    company, 
    years, 
    total_laid_off, 
    ranking
FROM Company_Year_Rank
WHERE ranking <= 3
  AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- =====================================================
-- TIME SERIES ANALYSIS
-- =====================================================
-- Monthly total layoffs
SELECT 
    SUBSTRING(date, 1, 7) AS dates, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- Rolling (cumulative) total of layoffs over time
WITH DATE_CTE AS (
    SELECT 
        SUBSTRING(date, 1, 7) AS dates, 
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY dates
)
SELECT 
    dates, 
    SUM(total_laid_off) OVER (ORDER BY dates ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
