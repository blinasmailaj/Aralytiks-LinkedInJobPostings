-----------------------------------------------------------------------------------------------------------------------
-- DATABASE SCHEMA
-----------------------------------------------------------------------------------------------------------------------

create database linkedInJobPostingsDB;
use linkedInJobPostingsDB;

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
    PRIMARY KEY (company_id, industry),
	FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

CREATE TABLE company_specialities (
    company_id BIGINT,
    speciality NVARCHAR(255), 
	PRIMARY KEY (company_id, speciality),
	FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

CREATE TABLE employee_counts (
	employee_count_id INT IDENTITY PRIMARY KEY,
    company_id BIGINT,
    employee_count INT,
    follower_count INT,
    time_recorded INT,
	FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);

CREATE TABLE job_postings (
    job_id BIGINT PRIMARY KEY,
    company_id BIGINT,
    title NVARCHAR(MAX),
    description NVARCHAR(MAX),
    work_type NVARCHAR(MAX),
	experience_level NVARCHAR(MAX),
    location NVARCHAR(MAX),
    listed_time BIGINT,
    job_posting_url NVARCHAR(MAX),
	FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
	);

CREATE TABLE job_skills (
    job_id BIGINT,
    skill_name NVARCHAR(255),
    PRIMARY KEY (job_id,skill_name),
	FOREIGN KEY (job_id) REFERENCES job_postings(job_id) ON DELETE CASCADE
);

CREATE TABLE salaries (
    salary_id INT PRIMARY KEY,
    job_id BIGINT,
    med_salary DECIMAL(18, 2) ,
    pay_period NVARCHAR(MAX),
    currency NVARCHAR(MAX),
    compensation_type NVARCHAR(MAX),
	FOREIGN KEY (job_id) REFERENCES job_postings(job_id) ON DELETE CASCADE
);
