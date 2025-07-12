-- SQL project : Data Cleaning

-- Creating a duplicate of the raw file just incase 

SELECT *
FROM wordlayoff.layoffs;

CREATE TABLE wordlayoff.layoffs_dup
LIKE wordlayoff.layoffs;


INSERT layoffs_dup
SELECT * 
FROM layoffs;

SELECT *
FROM layoffs_dup;

-- 1. REMOVE DUPLICATE

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_dup;

WITH duplicate_cte AS
(
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
	`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_dup

)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT * 
FROM layoffs_dup
WHERE company = "Cazoo";

-- We won't be able to delete the rows with number greater than one because we can't update a CTE.
-- "Delete" is like an update statement. The solution i will suggest is that we create a new table include a row_num then filter
-- to get rows that the "row_num" is greater than 1 after that we delete the "row_num" column

CREATE TABLE `layoffs_dup2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_dup2;

INSERT INTO layoffs_dup2
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
	`date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_dup;


SELECT *
FROM layoffs_dup2;

DELETE
FROM layoffs_dup2
WHERE row_num >1;

-- 2. STANDARDIZE DATA

SELECT company, TRIM(company) -- Removing whitespaces
FROM layoffs_dup2;

UPDATE layoffs_dup2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_dup2
ORDER BY 1;


SELECT *
FROM layoffs_dup2
WHERE industry LIKE "Crypto%";

UPDATE layoffs_dup2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

SELECT DISTINCT TRIM( TRAILING "." FROM country)
FROM layoffs_dup2
ORDER BY 1;

UPDATE layoffs_dup2
SET country = TRIM( TRAILING "." FROM country)
WHERE country LIKE "United State%";

SELECT *
FROM layoffs_dup2;

-- Changing date column from text to datetime object

SELECT `date`,
STR_TO_DATE (`date`, "%m/%d/%Y")
FROM layoffs_dup2;


UPDATE layoffs_dup2
SET `date` = STR_TO_DATE (`date`, "%m/%d/%Y");

ALTER TABLE layoffs_dup2
MODIFY COLUMN `date` DATE;


-- REMOVING THE BLANK AND NULL COLUMNS

SELECT *
FROM layoffs_dup2
WHERE industry IS NULL
OR industry = "";

SELECT *
FROM layoffs_dup2
WHERE company = "Bally's Interactive";

SELECT *
FROM layoffs_dup2 t1
JOIN layoffs_dup2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry= "" )
AND t2.industry IS NOT NULL;

UPDATE layoffs_dup2
SET industry = NULL
WHERE industry = "";

UPDATE layoffs_dup2 t1
JOIN layoffs_dup2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry= "" )
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_dup2;

ALTER TABLE layoffs_dup2
DROP COLUMN row_num


