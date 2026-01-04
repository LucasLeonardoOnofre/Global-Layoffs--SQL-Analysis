# Global Layoffs Data Analysis (SQL)

## Project Overview
This project analyzes global company layoffs data using **SQL**, with a focus on **data cleaning**, **standardization**, and **exploratory data analysis (EDA)** to uncover trends across companies, industries, locations, and time.

The analysis follows a structured workflow commonly used in real-world analytics projects:
1. Data Cleaning and Preparation  
2. Exploratory Data Analysis (EDA)

All transformations and analysis are performed using SQL to demonstrate querying proficiency, data integrity handling, and analytical thinking.

---

## Dataset
The raw dataset is provided as a CSV file and contains company layoff information across multiple countries and industries.

**File included in this repository:**
- `layoffs.csv` — raw layoffs dataset used for cleaning and analysis

The raw CSV file is preserved and never modified directly. All cleaning steps are performed on staging tables created from this source.

---

## Phase 1: Data Cleaning

### Objective
Prepare a reliable, consistent, and analysis-ready dataset by removing duplicates, standardizing values, and handling missing data while preserving the original raw data.

### Key Steps
- Created staging tables to avoid modifying raw data
- Identified and removed duplicate records using `ROW_NUMBER()` and window functions
- Standardized categorical fields:
  - Company names (trimmed whitespace)
  - Industry labels (e.g., unifying Crypto-related values)
  - Country names (removing trailing punctuation)
- Converted date fields from text format to proper `DATE` data type
- Handled null and blank values:
  - Replaced blank strings with `NULL`
  - Populated missing industry values using company-level joins
- Removed helper columns used only during the cleaning process

### Result
A clean and structured dataset (`layoffs_staging2`) suitable for accurate analysis.

---

## Phase 2: Exploratory Data Analysis (EDA)

### Objective
Explore the cleaned dataset to identify trends, patterns, and outliers related to global layoffs.

### Analysis Focus
- Layoff trends over time
- Companies most impacted by layoffs
- Industries with the highest number of layoffs
- Geographic distribution of layoffs
- Severity of layoffs, including full company shutdowns

### Key Analyses
- Largest single layoff events
- Companies with the highest cumulative layoffs
- Layoffs aggregated by:
  - Country
  - Location
  - Industry
  - Company stage
- Year-over-year layoff trends
- Top companies by layoffs per year using ranking window functions
- Monthly and cumulative (rolling) layoffs over time

### Techniques Used
- Aggregations using `GROUP BY`
- Window functions (`DENSE_RANK`, rolling totals)
- Common Table Expressions (CTEs)
- Time-series analysis

---

## Tools and Technologies
- SQL (MySQL)
- Window Functions
- Common Table Expressions (CTEs)

---

## Repository Structure
```text
├── layoffs.csv                            -- Raw dataset
├── Data Cleaning-Project Layoffs.sql      -- Data cleaning and preparation
├── Project Layoffs EDA.sql                -- Exploratory data analysis
└── README.md                              -- Project documentation
