-- Data Exploratory

SELECT *
FROM layoffs_staging2;


-- Max total laid off is 12,000 and max percentage laid off is 100%
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


-- Amazon is a company that has the most total laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;

-- the duration is 3 years
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


-- Consumer is the most industry that has total laid off
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
;


-- United States has the most total laid off
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;


-- The year 2022 has the most total laid off
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;


-- The average of total laid off for each company
SELECT company, AVG(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;


-- This step is to find the total laid off for each month
SELECT SUBSTR(`date`,1,7) AS `month`, 
	   SUM(total_laid_off) AS total_lay_off
FROM layoffs_staging2
WHERE SUBSTR(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
;

WITH rolling_total_cte AS
(
SELECT SUBSTR(`date`,1,7) AS `month`, 
	   SUM(total_laid_off) AS total_lay_off
FROM layoffs_staging2
WHERE SUBSTR(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, 
		total_lay_off, 
		SUM(total_lay_off) OVER(ORDER BY `month`) as rolling_total
FROM rolling_total_cte;


-- This step is to show the top 5 company that has the most total laid off for year 2020 - 2023
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company,
	   YEAR(`date`), 
	   SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
ORDER BY 3 DESC
;

WITH company_year AS -- first CTE
(
SELECT company,
	   YEAR(`date`) AS years, 
	   SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY company,YEAR(`date`)
), 
company_year_rank AS -- second CTE
(
SELECT *, 
       DENSE_RANK() OVER(PARTITION BY years ORDER BY Total_Laid_Off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5
;














