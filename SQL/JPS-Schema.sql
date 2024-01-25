-----------------------------------------------------------------------------------------------------------------------
-- DATABASE SCHEMA
-----------------------------------------------------------------------------------------------------------------------

create database linkedin_job_postings_db;
use linkedin_job_postings_db;

CREATE TABLE job_postings (
    job_id BIGINT PRIMARY KEY,
    company_id BIGINT,
    title NVARCHAR(MAX),
    description NVARCHAR(MAX),
    work_type NVARCHAR(MAX),
	experience_level NVARCHAR(MAX),
    location NVARCHAR(MAX),
    job_posting_url NVARCHAR(MAX)
	);

CREATE TABLE companies (
    company_id BIGINT PRIMARY KEY,
    name NVARCHAR(MAX),
    state NVARCHAR(MAX),
    country NVARCHAR(MAX),
    city NVARCHAR(MAX),
    address NVARCHAR(MAX),
    url NVARCHAR(MAX)
);

CREATE TABLE company_industries (
    company_id BIGINT,
    industry NVARCHAR(255),
    PRIMARY KEY (company_id, industry)
);

CREATE TABLE company_specialities (
	speciality_id INT IDENTITY PRIMARY KEY,
    company_id BIGINT,
    speciality NVARCHAR(500), 
);

CREATE TABLE employee_counts (
    company_id BIGINT,
    employee_count INT,
    follower_count INT,
    time_recorded FLOAT,
	PRIMARY KEY (company_id, time_recorded)
);

CREATE TABLE job_skills (
    job_id BIGINT,
    skill_name NVARCHAR(255),
    PRIMARY KEY (job_id,skill_name)
);

CREATE TABLE salaries (
    salary_id INT PRIMARY KEY,
    job_id BIGINT,
    med_salary NVARCHAR(MAX) ,
    pay_period NVARCHAR(MAX),
    currency NVARCHAR(MAX),
    compensation_type NVARCHAR(MAX)
);

ALTER TABLE job_postings
    ADD FOREIGN KEY (company_id) REFERENCES companies(company_id);

ALTER TABLE company_industries
    ADD FOREIGN KEY (company_id) REFERENCES companies(company_id);

ALTER TABLE company_specialities
    ADD FOREIGN KEY (company_id) REFERENCES companies(company_id);

ALTER TABLE employee_counts
    ADD FOREIGN KEY (company_id) REFERENCES companies(company_id);

ALTER TABLE job_skills
    ADD FOREIGN KEY (job_id) REFERENCES job_postings(job_id);

ALTER TABLE salaries
    ADD FOREIGN KEY (job_id) REFERENCES job_postings(job_id);

