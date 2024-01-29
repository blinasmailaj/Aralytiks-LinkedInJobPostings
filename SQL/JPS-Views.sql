/* VIEWS----------------------------------------------------------------------------------------------------------
1. Evaluates skill demand by counting jobs and averaging employee counts per skill
2. Shows industry diversity by counting companies and averaging employee counts
3. Analyzes job distribution by experience levels, counting jobs and averaging employee counts
4. Shows the companyid,company name and the amount of job postings for each company
5. Creates a similar view to 'vw_CompanyJobCounts' with the distinc nr of job titles as addition
*/ -------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Evaluates skill demand by counting jobs and averaging employee counts per skill
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW vw_SkillDemandAnalysis   
AS  
SELECT
    js.skill_name,
    COUNT(DISTINCT jp.job_id) AS job_count,
    AVG(ec.employee_count) AS avg_employee_count
FROM
    job_skills js
JOIN
    job_postings jp ON js.job_id = jp.job_id
JOIN
    employee_counts ec ON jp.company_id = ec.company_id
GROUP BY
    js.skill_name;
 
-- Example

SELECT * FROM vw_SkillDemandAnalysis;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Shows industry diversity by counting companies and averaging employee counts
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW vw_DiversityInIndustries
AS 
SELECT
    ci.industry,
    COUNT(DISTINCT c.company_id) AS company_count,
    AVG(ec.employee_count) AS avg_employee_count
FROM
    company_industries ci
JOIN
    companies c ON ci.company_id = c.company_id
JOIN
    employee_counts ec ON c.company_id = ec.company_id
GROUP BY
    ci.industry;
 
  
-- Example
 select * from vw_DiversityInIndustries; 

--Analyzes job distribution by experience levels, counting jobs and averaging employee counts.
CREATE VIEW vw_ExperienceLevelAnalysis
AS 
SELECT
    jp.experience_level,
    COUNT(DISTINCT jp.job_id) AS job_count,
    AVG(ec.employee_count) AS avg_employee_count
FROM
    job_postings jp
JOIN
    employee_counts ec ON jp.company_id = ec.company_id
GROUP BY
    jp.experience_level;
 
-- Example

select * from vw_ExperienceLevelAnalysis;


--Shows the companyid,company name and the amount of job postings for each company

	CREATE VIEW vw_CompanyJobCounts AS
SELECT
    c.company_id,
    c.name AS company_name,
    COUNT(jp.job_id) AS total_job_postings
FROM
    companies c
LEFT JOIN
    job_postings jp ON c.company_id = jp.company_id
GROUP BY
    c.company_id, c.name;
 
		select * from vw_CompanyJobCounts
 
 
 -- Creates a similar view to 'vw_CompanyJobCounts' with the distinc nr of job titles as addition

	CREATE VIEW vw_CompanyJobTitleStats AS
SELECT
    c.company_id,
    c.name AS company_name,
    COUNT(jp.job_id) AS total_job_postings,
    COUNT(DISTINCT jp.title) AS distinct_job_titles
FROM
    companies c
LEFT JOIN
    job_postings jp ON c.company_id = jp.company_id
GROUP BY
    c.company_id, c.name;
 
 
	select * from vw_CompanyJobTitleStats