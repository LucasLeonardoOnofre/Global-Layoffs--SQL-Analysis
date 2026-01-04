-- =====================================================
-- DATA CLEANING - LAYOFFS PROJECT 
-- =====================================================
-- Objective:
-- Clean and prepare the layoffs dataset for analysis by:
-- 1. Removing duplicate records
-- 2. Standardizing inconsistent values
-- 3. Handling null and blank values
-- 4. Removing unnecessary columns
-- =====================================================

-- =====================================================
-- INITIAL DATA INSPECTION & STAGING
-- =====================================================
-- Raw data overview
SELECT *
FROM world_layoffs.layoffs;

-- Create a staging table to preserve the raw dataset
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging
LIKE world_layoffs.layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

SELECT *
FROM layoffs_staging;
-- =====================================================
-- 1. REMOVING DUPLICATES
-- =====================================================
-- Identify duplicate rows using ROW_NUMBER
SELECT *
FROM (
    SELECT 
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY 
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
) duplicates
WHERE row_num > 1;


-- Validate whether identified rows are true duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Oda';


-- Create a second staging table including a helper column for deduplication
CREATE TABLE `layoffs_staging2` (   -- Creating another Table with an extra Column 'row_num' hold number of duplicates
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int   -- EXTRA COLUMN
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--  Populate the new table and assign row numbers
INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY company,location, industry , 
					 total_laid_off, percentage_laid_off,`date`,
					 stage,country,funds_raised_millions) As row_nums
FROM layoffs_staging;
-- Review duplicates before deletion
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Delete duplicate records
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Verify duplicates have been removed
SELECT *
FROM layoffs_staging2;

-- =====================================================
-- 2. STANDARDIZING DATA
-- =====================================================
-- Remove leading and trailing spaces from company names
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry naming conventions
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Clean country names (remove trailing punctuation)
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date column to proper DATE format
SELECT 
    `date`,
    STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Modify column data type after successful conversion
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- =====================================================
-- 3. HANDLING NULL AND BLANK VALUES
-- =====================================================
-- Identify rows where key layoff metrics are missing
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Convert blank industry values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Identify missing industry values using company-level matches
SELECT 
    t1.industry,
    t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Populate missing industry values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Remove known remaining duplicate records
DELETE
FROM layoffs_staging2
WHERE company = 'Airbnb'
  AND row_num > 1;

-- Validate deletion
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Final duplicate verification
WITH Duplicate_Industry AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_nums
    FROM layoffs_staging2
)
SELECT *
FROM Duplicate_Industry
WHERE row_nums > 1;
-- =====================================================
-- 4. REMOVE HELPER COLUMNS
-- =====================================================

-- Drop temporary column used for deduplication
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final cleaned dataset
SELECT *
FROM world_layoffs.layoffs_staging2;
