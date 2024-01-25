/* QUERIES-------------------------------------------------------------------------------------------------------------------
1. Most common job posting title
2. Companies with the most job postings
3. Most required skills by companies
4. Companies that have job postings in multiple countries
5. Average annual salary of job posting based on job title
6. Retrieve companies with the highest ratio of followers to employees
7. Companies with the highest average employee count over the last year
8. Average number of job postings per city
9. Companies with the highest number of job postings in the industry 'Computer & Network Security'
10. Calculating the average salary for specific skills required from job postings
11. Analysing job postings with specific specialities and the correspoding employee counts
*/----------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------
-- Most common job posting title
--------------------------------------------------------------------------------------------------

SELECT top(10) title as [Job Title], COUNT(*) as [Count]
FROM job_postings
GROUP BY title
ORDER BY count DESC;

--------------------------------------------------------------------------------------------------
-- Companies with the most job postings
--------------------------------------------------------------------------------------------------

SELECT top(10) c.name as [Company], COUNT(*) as [Count]
FROM job_postings jp
JOIN companies c ON jp.company_id = c.company_id
GROUP BY c.name
ORDER BY count DESC;

--------------------------------------------------------------------------------------------------
-- Most required skills by companies
--------------------------------------------------------------------------------------------------

SELECT top(10) skill_name as [Skill], COUNT(*) as [Count]
FROM job_skills
GROUP BY skill_name
ORDER BY count DESC;

--------------------------------------------------------------------------------------------------
-- Companies that have job postings in multiple countries
--------------------------------------------------------------------------------------------------

SELECT c.company_id, c.name, COUNT(DISTINCT jp.location) AS num_countries
FROM companies c
JOIN job_postings jp ON c.company_id = jp.company_id
GROUP BY c.company_id, c.name
HAVING COUNT(DISTINCT jp.location) > 1;

--------------------------------------------------------------------------------------------------
-- Average annual salary of job posting based on job title
--------------------------------------------------------------------------------------------------

SELECT TOP 10 
    jp.title as [Job Title], 
    AVG(
        CASE 
            WHEN s.pay_period = 'HOURLY' THEN s.med_salary * 40 * 52
            WHEN s.pay_period = 'WEEKLY' THEN s.med_salary * 52
            WHEN s.pay_period = 'MONTHLY' THEN s.med_salary * 12
            WHEN s.pay_period = 'YEARLY' THEN s.med_salary
            WHEN s.pay_period = 'ONCE' THEN s.med_salary
            ELSE s.med_salary
        END
    ) as [Average Annual Salary],
    s.currency as [Currency]
FROM 
    job_postings jp
JOIN 
    salaries s ON jp.job_id = s.job_id
GROUP BY 
    jp.title, s.currency
ORDER BY 
    [Average Annual Salary] DESC;

	
--------------------------------------------------------------------------------------------------
-- Retrieve companies with the highest ratio of followers to employees
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

SELECT TOP 100 c.name, c.state, c.country, c.address, AVG(ec.employee_count) AS avg_employee_count
FROM companies c
JOIN employee_counts ec ON c.company_id = ec.company_id
WHERE dbo.ConvertUnixTimestampToDatetime(ec.time_recorded) >= DATEADD(YEAR, -1, GETDATE())
GROUP BY c.company_id, c.name, c.state, c.country, c.city, c.address, c.url
ORDER BY avg_employee_count DESC;


--------------------------------------------------------------------------------------------------
-- Average number of job postings per city
--------------------------------------------------------------------------------------------------
SELECT c.city, AVG(posting_count) AS avg_postings_per_city
FROM companies c
LEFT JOIN (
    SELECT company_id, COUNT(*) AS posting_count
    FROM job_postings
    GROUP BY company_id
) jp_count ON c.company_id = jp_count.company_id
GROUP BY c.city
ORDER BY avg_postings_per_city DESC;


--------------------------------------------------------------------------------------------------
-- Companies with the highest number of job postings in the industry 'Computer & Network Security'
--------------------------------------------------------------------------------------------------
SELECT c.company_id, c.name, COUNT(jp.job_id) AS num_job_postings
FROM companies c
JOIN job_postings jp ON c.company_id = jp.company_id
JOIN company_industries ci ON c.company_id = ci.company_id
WHERE ci.industry = 'IT Services and IT Consulting'
GROUP BY c.company_id, c.name
ORDER BY num_job_postings DESC;

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
       COUNT(sjp.job_id) AS num_job_postings,
       AVG(sal.med_salary) AS avg_salary
FROM SkillJobPostings sjp
JOIN salaries sal ON sjp.job_id = sal.job_id
GROUP BY sjp.skill_name
ORDER BY num_job_postings DESC;


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
       COUNT(ec.company_id) AS num_companies,
       AVG(ec.employee_count) AS avg_employee_count
FROM SpecialityJobPostings sjp
JOIN employee_counts ec ON sjp.company_id = ec.company_id
GROUP BY sjp.speciality
ORDER BY num_companies DESC;
