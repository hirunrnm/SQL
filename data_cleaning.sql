-- DATA CLEANING
-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or blank values
-- 4. Remove any columns

## ก่อนที่จะ Clean สร้างตารางใหม่ขึ้นมา อย่าไปทำใน RAW DATA
CREATE TABLE layoffs_staging
LIKE layoffs; # สร้างตารางที่มาจาก layoffs

SELECT *
FROM layoffs_staging;

# insert all data from layoffs
INSERT layoffs_staging 
SELECT *
FROM layoffs;



-- 1. Remove Duplicates
-- Find duplicate
## เลือกทุก columns ในการทำ partition
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
						SELECT *,
						ROW_NUMBER() OVER(
						PARTITION BY company,
                        location, industry, total_laid_off, percentage_laid_off, `date`,
                        stage, country, funds_raised_millions) AS row_num
						FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- DELETE DUPLICATE
# สร้าง copy table from layoffs_staging 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT # add row_num
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,
			 location, industry, total_laid_off, percentage_laid_off, `date`,
		     stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;



-- 2. Standardize the data
# เช็คที่column company มีบาง row ที่มีเว้นวรรคให้ใช้ TRIM
SELECT company, TRIM(company)
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET company = TRIM(company)
;

# บาง Row เขียนว่า Cryptocurrency and Crypto Currency
## Find and replace to Crypto
SELECT *
FROM layoffs_staging2
WHERE industry LIKE "Crypto%"
;

UPDATE layoffs_staging2
SET industry = "Crypto" 
WHERE industry LIKE "Crypto%";

# United States. ลงท้ายด้วย . ให้ลบออก
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

# เปลี่ยน Format วันที่เป็น m/d/y Yให้เป็นตัวใหญ่เสมอ 
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

## change data type from STR to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;



-- 3. Null values or blank values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

# เช็ค Missing Values หรือ NULL
SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

### ถ้ามีค่าว่างให้เปลี่ยนเป็น NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

### SELF JOIN TABLE for looking the NULL values and NOT NULL from 2 tables
### เปรียบเทียบ 2 ตารางเพื่อหาค่าว่างและไม่ว่าง
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

### UPDATE
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

# check
SELECT company,industry
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

### Bally's is the only one row that is still NULL since there is only one in the table.
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';


### ถ้าไม่สามารถคำนวนหาค่าของ Null value ได้ ก็ลบทิ้ง
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;



-- 4. Remove any columns
SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;




















