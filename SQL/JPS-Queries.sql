/* QUERIES-------------------------------------------------------------------------------------------------------------------
1. Most common job posting title
2. Companies with the most job postings
3. Most required skills by companies
4. Experience level required in job postings
4. Companies that have job postings in multiple countries
5. Average annual salary of job posting based on job title
6. Retrieve companies with the highest ratio of followers to employees
7. Companies with the highest average employee count over the last year
8. Average number of job postings per city
9. Companies with the highest number of job postings in the industry 'Computer & Network Security'
10. Calculating the average salary for specific skills required from job postings
11. Analysing job postings with specific specialities and the correspoding employee counts
12. Active Companies with the most followers on LinkedIn
13. Average number of job postings per month
14. Companies with the highest job posting for a specific skill
15. Companies offering the highest and lowest average salaries 
16. Most required experience level for specific skill
*/----------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
-- Most common job posting title
--------------------------------------------------------------------------------------------------

SELECT TOP 30 title as [job title], COUNT(*) as occurrence
FROM job_postings
GROUP BY title
ORDER BY occurrence DESC;

--------------------------------------------------------------------------------------------------
-- Companies with the most job postings
--------------------------------------------------------------------------------------------------

SELECT TOP 10 c.name as company, COUNT(*) as count
FROM job_postings jp
JOIN companies c ON jp.company_id = c.company_id
GROUP BY c.name
ORDER BY count DESC;

--------------------------------------------------------------------------------------------------
-- Most required skills by companies
--------------------------------------------------------------------------------------------------

SELECT  TOP 15 skill_name as skill, COUNT(*) as count
FROM job_skills
GROUP BY skill_name
ORDER BY count DESC;

--------------------------------------------------------------------------------------------------
-- Experience level required in job postings
--------------------------------------------------------------------------------------------------

SELECT experience_level, COUNT(*) AS count
FROM job_postings
GROUP BY experience_level
ORDER BY count DESC;

--------------------------------------------------------------------------------------------------
-- Companies that have job postings in multiple countries
--------------------------------------------------------------------------------------------------

SELECT c.name, COUNT(DISTINCT jp.location) AS [number of countries]
FROM companies c
JOIN job_postings jp ON c.company_id = jp.company_id
GROUP BY c.company_id, c.name
HAVING COUNT(DISTINCT jp.location) > 1
order by [number of countries] desc;

--------------------------------------------------------------------------------------------------
-- Average annual salary of job posting based on job title
--------------------------------------------------------------------------------------------------

SELECT
    jp.title as [Job Title], 
    CAST(
        AVG(
            CASE 
                WHEN s.pay_period = 'HOURLY' THEN s.med_salary * 40 * 52
                WHEN s.pay_period = 'WEEKLY' THEN s.med_salary * 52
                WHEN s.pay_period = 'MONTHLY' THEN s.med_salary * 12
                WHEN s.pay_period = 'YEARLY' THEN s.med_salary
                WHEN s.pay_period = 'ONCE' THEN s.med_salary
                ELSE s.med_salary
            END
        ) AS DECIMAL(18, 2)) 
        as [Average Annual Salary],
    s.currency as [Currency]
FROM 
    job_postings jp
JOIN 
    salaries s ON jp.job_id = s.job_idt
GROUP BY 
    jp.title, s.currency
ORDER BY 
    [Average Annual Salary] DESC;


--------------------------------------------------------------------------------------------------
-- Companies with the highest ratio of followers to employees
--------------------------------------------------------------------------------------------------

SELECT TOP 100 c.company_id, c.name,
	    CAST(
        AVG(
            CASE
                WHEN ec.employee_count > 0 THEN ec.follower_count * 1.0 / ec.employee_count
                ELSE 0  -- or NULL, depending on how you want to handle the case
            END
        	 ) AS DECIMAL(10, 1)) AS [followers/employees]
FROM companies c
JOIN employee_counts ec ON c.company_id = ec.company_id
GROUP BY c.company_id, c.name
ORDER BY [followers/employees] DESC;

--------------------------------------------------------------------------------------------------
-- Companies with the highest average employee count over the last year
--------------------------------------------------------------------------------------------------

SELECT TOP 100 c.name, c.state, c.country, c.address, AVG(ec.employee_count) AS [Average Employee Count]
FROM companies c
JOIN employee_counts ec ON c.company_id = ec.company_id
WHERE dbo.ConvertUnixTimestampToDatetime(ec.time_recorded) >= DATEADD(YEAR, -1, GETDATE())
GROUP BY c.company_id, c.name, c.state, c.country, c.city, c.address, c.url
ORDER BY [Average Employee Count] DESC;

--------------------------------------------------------------------------------------------------
-- Average number of job postings per city
--------------------------------------------------------------------------------------------------
SELECT c.city, AVG(posting_count) AS [average postings per city]
FROM companies c
LEFT JOIN (
    SELECT company_id, COUNT(*) AS posting_count
    FROM job_postings
    GROUP BY company_id
) jp_count ON c.company_id = jp_count.company_id
GROUP BY c.city
ORDER BY [average postings per city] DESC;

--------------------------------------------------------------------------------------------------
-- Companies with the highest number of job postings in the industry 'Computer & Network Security'
--------------------------------------------------------------------------------------------------
SELECT c.company_id, c.name, COUNT(jp.job_id) AS [number of job postings]
FROM companies c
JOIN job_postings jp ON c.company_id = jp.company_id
JOIN company_industries ci ON c.company_id = ci.company_id
WHERE ci.industry = 'IT Services and IT Consulting'
GROUP BY c.company_id, c.name
ORDER BY [number of job postings] DESC;

select * from job_skills;

--------------------------------------------------------------------------------------------------
-- Calculating the average salary for specific skills required from job postings
--------------------------------------------------------------------------------------------------
WITH SkillJobPostings AS (
    SELECT jp.job_id, jp.title, js.skill_name
    FROM job_postings jp
    JOIN job_skills js ON jp.job_id = js.job_id
    WHERE js.skill_name IN ('Sales', 'Information Technology', 'Design')
)
SELECT sjp.skill_name, 
       COUNT(sjp.job_id) AS [number of postings],
	   CAST(
		   AVG(
			   CASE 
				   WHEN sal.pay_period = 'HOURLY' THEN sal.med_salary * 40 * 52
				   WHEN sal.pay_period = 'WEEKLY' THEN sal.med_salary * 52
				   WHEN sal.pay_period = 'MONTHLY' THEN sal.med_salary * 12
				   WHEN sal.pay_period = 'YEARLY' THEN sal.med_salary
				   WHEN sal.pay_period = 'ONCE' THEN sal.med_salary
				   ELSE sal.med_salary
			   END
		   ) AS DECIMAL(18,2))
		AS [average yearly salary]
FROM SkillJobPostings sjp
JOIN salaries sal ON sjp.job_id = sal.job_id
GROUP BY sjp.skill_name
ORDER BY [average yearly salary] DESC;


select * from company_specialities;

--------------------------------------------------------------------------------------------------
-- Analysing job postings with specific specialities and the correspoding employee counts
--------------------------------------------------------------------------------------------------

WITH SpecialityJobPostings AS (
    SELECT jp.company_id, js.speciality
    FROM job_postings jp
    JOIN company_specialities js ON jp.company_id = js.company_id
    WHERE js.speciality IN ('Advertising', 'Recruiting', 'Development','Construction')
)

SELECT sjp.speciality, 
       COUNT(ec.company_id) AS [number of companies],
       AVG(ec.employee_count) AS [average employee count]
FROM SpecialityJobPostings sjp
JOIN employee_counts ec ON sjp.company_id = ec.company_id
GROUP BY sjp.speciality
ORDER BY [number of companies] DESC;

--------------------------------------------------------------------------------------------------
-- Active Companies with the most followers on LinkedIn
--------------------------------------------------------------------------------------------------

WITH RankedCompanies AS (
    SELECT c.name, ec.follower_count,
    ROW_NUMBER() OVER (PARTITION BY c.company_id ORDER BY ec.time_recorded DESC) AS RowNum
    FROM companies c
    INNER JOIN employee_counts ec ON c.company_id = ec.company_id
)
SELECT TOP 10 name, follower_count
FROM RankedCompanies
WHERE RowNum = 1
ORDER BY follower_count DESC;

--------------------------------------------------------------------------------------------------
-- Average number of job postings per month
--------------------------------------------------------------------------------------------------

SELECT
    c.name AS company_name,
    COUNT(j.job_id) / COUNT(DISTINCT CONVERT(NVARCHAR(6), dbo.ConvertUnixTimestampToFormattedDate(j.listed_time), 112)) 
	AS [average postings per month]
FROM
    companies c
JOIN
    job_postings j ON c.company_id = j.company_id
GROUP BY
    c.name
ORDER BY
    [average postings per month] DESC;

select top 5  listed_time from job_postings;

--------------------------------------------------------------------------------------------------
-- Companies with the highest job posting for a specific skill
--------------------------------------------------------------------------------------------------

WITH SkillJobPostings AS (
    SELECT jp.company_id, js.skill_name
    FROM job_postings jp
    JOIN job_skills js ON jp.job_id = js.job_id
    WHERE js.skill_name = 'Accounting/Auditing'
)
SELECT sjp.company_id, c.name, COUNT(*) AS [Number of postings]
FROM SkillJobPostings sjp
JOIN companies c ON sjp.company_id = c.company_id
JOIN job_postings jp ON sjp.company_id = jp.company_id
GROUP BY sjp.company_id, c.name
ORDER BY [Number of postings] DESC;

--------------------------------------------------------------------------------------------------
-- Companies offering the highest and lowest average salaries 
--------------------------------------------------------------------------------------------------
SELECT
    c.name AS company_name,
	CAST(
		AVG(
			CASE 
				WHEN s.pay_period = 'HOURLY' THEN s.med_salary * 40 * 52  -- 40 hours per week and 52 weeks per year
				WHEN s.pay_period = 'WEEKLY' THEN s.med_salary * 52
				WHEN s.pay_period = 'MONTHLY' THEN s.med_salary
				WHEN s.pay_period = 'YEARLY' THEN s.med_salary / 12  
				ELSE 0 
			END
		) as DECIMAL(18,2))
	AS [Average Monthly Paycheck]
FROM
    companies c
JOIN
    job_postings jp ON c.company_id = jp.company_id
JOIN
    salaries s ON jp.job_id = s.job_id
GROUP BY
    c.company_id, c.name
ORDER BY
     [Average Monthly Paycheck] DESC;

--------------------------------------------------------------------------------------------------
--  Most required experience level for specific skill
--------------------------------------------------------------------------------------------------

WITH SkillExperienceLevels AS (
    SELECT 
        js.skill_name,
        jp.experience_level,
        COUNT(*) AS num_postings
    FROM 
        job_postings jp
    JOIN 
        job_skills js ON jp.job_id = js.job_id
    GROUP BY 
        js.skill_name, jp.experience_level
)
, RankedExperienceLevels AS (
    SELECT
        skill_name,
        experience_level,
        num_postings,
        ROW_NUMBER() OVER (PARTITION BY skill_name ORDER BY num_postings DESC) AS rank_within_skill
    FROM
        SkillExperienceLevels
)
SELECT
    skill_name,
    experience_level,
    num_postings
FROM
    RankedExperienceLevels
WHERE
    rank_within_skill = 1
ORDER BY
    skill_name, num_postings DESC;