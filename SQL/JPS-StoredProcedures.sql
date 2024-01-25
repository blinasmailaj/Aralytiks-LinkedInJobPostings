/* STORED PROCEDURES-------------------------------------------------------------------------------------------------------------------
1. JOB POSTING INSERTION STORED PROCEDURE
2. UPDATE COMPANY STORED PROCEDURE
3. GET POSTINGS BY LOCATION STORED PROCEDURE
*/----------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOB POSTING INSERTION STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_InsertJobPosting
    @company_id BIGINT,
    @title NVARCHAR(MAX),
    @description NVARCHAR(MAX),
    @work_type NVARCHAR(MAX),
    @experience_level NVARCHAR(MAX),
    @location NVARCHAR(MAX),
    @job_posting_url NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO job_postings (company_id, title, description, work_type, experience_level, location, job_posting_url)
    VALUES (@company_id, @title, @description, @work_type, @experience_level, @location, @job_posting_url);
END;

-- USAGE EXAMPLE
DECLARE @company_id_insert BIGINT = 1;
DECLARE @title_insert NVARCHAR(MAX) = 'Software Developer';
DECLARE @description_insert NVARCHAR(MAX) = 'Exciting software development opportunity...';
DECLARE @work_type_insert NVARCHAR(MAX) = 'Full-Time';
DECLARE @experience_level_insert NVARCHAR(MAX) = 'Mid Level';
DECLARE @location_insert NVARCHAR(MAX) = 'San Francisco, CA';
DECLARE @job_posting_url_insert NVARCHAR(MAX) = 'https://www.linkedin.com/jobs/123';

EXEC sp_InsertJobPosting
    @company_id_insert,
    @title_insert,
    @description_insert,
    @work_type_insert,
    @experience_level_insert,
    @location_insert,
    @job_posting_url_insert;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE COMPANY STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_UpdateCompany
    @company_id BIGINT,
    @name NVARCHAR(MAX),
    @address NVARCHAR(MAX),
    @url NVARCHAR(MAX)
AS
BEGIN
    UPDATE companies
    SET name = @name, address = @address, url = @url
    WHERE company_id = @company_id;
END;

-- USAGE EXAMPLE
DECLARE @company_id_update BIGINT = 1;
DECLARE @name_update NVARCHAR(MAX) = 'Updated Company Name';
DECLARE @address_update NVARCHAR(MAX) = 'Updated Company Address';
DECLARE @url_update NVARCHAR(MAX) = 'https://www.updated-company.com';

EXEC sp_UpdateCompany
    @company_id_update,
    @name_update,
    @address_update,
    @url_update;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GET POSTINGS BY LOCATION STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE sp_GetJobPostingsByLocation
    @location NVARCHAR(MAX)
AS
BEGIN
    SELECT *
    FROM job_postings
    WHERE location = @location;
END;

-- USAGE EXAMPLE
DECLARE @location_search NVARCHAR(MAX) = 'San Francisco, CA';
EXEC sp_GetJobPostingsByLocation @location_search;
