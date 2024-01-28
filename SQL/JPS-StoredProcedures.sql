/* STORED PROCEDURES-------------------------------------------------------------------------------------------------------------------
1. VALIDATE INSERT IN JOB POSTINGS STORED PROCEDURE
2. VALIDATE UPDATE ON JOB POSTINGS STORED PROCEDURE
3. GET JOB POSTINGS BY LOCATION (WITH PAGINATION) STORED PROCEDURE
*/----------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATE INSERT IN JOB POSTINGS STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE ValidateInsertJobPostings
@job_id bigint,
@company_id bigint,
@title NVARCHAR(MAX),
@description NVARCHAR(MAX),
@work_type NVARCHAR(MAX),
@experience_level NVARCHAR(MAX),
@location NVARCHAR(MAX),
@job_posting_url NVARCHAR(MAX)
AS
BEGIN
    -- Validate work_type
    IF @work_type NOT IN ('Full-time', 'Contract', 'Internship', 'Volunteer', 'Part-time', 'Temporary', 'Other')
    BEGIN
        RAISERROR ('Invalid work_type. Allowed values are Full-time, Contract, Internship, Volunteer, Part-time, Temporary and Other.', 16, 1);
        RETURN;
    END

    -- Validate experience_level
    IF @experience_level NOT IN ('Director','Executive','Associate','Not Specified','Internship','Entry level','Mid-Senior level')
    BEGIN
        RAISERROR ('Invalid experience level. Allowed values are Director, Executive, Associate, Not Specified, Internship, Entry level and Mid-Senior Level', 16, 1);
        RETURN;
    END

    -- Validate job_posting_url
    IF @job_posting_url NOT LIKE 'https://www.linkedin.com/jobs/%'
    BEGIN
        RAISERROR ('Invalid URL format. URLs should start with ''https://www.linkedin.com/jobs/''.', 16, 1);
        RETURN;
    END

    -- If all fields are valid, insert data
    INSERT INTO job_postings (job_id, company_id, title, description, work_type, experience_level, location, job_posting_url)
    VALUES (@job_id, @company_id,@title,@description, @work_type, @experience_level, @location, @job_posting_url)
END;

-- Example 
EXEC ValidateInsertJobPostings 
@job_id = 395888427, 
@company_id = 630152, 
@title = 'Software Engineer', 
@description = 'This is a job description.', 
@work_type = 'Full-time', 
@experience_level = 'Mid-Senior level', 
@location = 'New York, NY', 
@job_posting_url = 'https://www.linkedin.com/jobs/view/...'

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATE UPDATE ON JOB POSTINGS STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE ValidateUpdateJobPostings
    @job_id bigint,
    @company_id bigint = NULL,
    @title NVARCHAR(MAX) = NULL,
    @description NVARCHAR(MAX) = NULL,
    @work_type NVARCHAR(MAX) = NULL,
    @experience_level NVARCHAR(MAX) = NULL,
    @location NVARCHAR(MAX) = NULL,
    @job_posting_url NVARCHAR(MAX) = NULL
AS
BEGIN
    -- Check if the job_id exists
    IF NOT EXISTS (SELECT 1 FROM job_postings WHERE job_id = @job_id)
    BEGIN
        RAISERROR ('Record with job_id %d does not exist.', 16, 1, @job_id);
        RETURN;
    END

    -- Validate work_type
    IF @work_type IS NOT NULL AND @work_type NOT IN ('Full-time', 'Contract', 'Internship', 'Volunteer', 'Part-time', 'Temporary', 'Other')
    BEGIN
        RAISERROR ('Invalid work_type. Allowed values are Full-time, Contract, Internship, Volunteer, Part-time, Temporary, and Other.', 16, 1);
        RETURN;
    END

    -- Validate experience_level
    IF @experience_level IS NOT NULL AND @experience_level NOT IN ('Director', 'Executive', 'Associate', 'Not Specified', 'Internship', 'Entry level', 'Mid-Senior level')
    BEGIN
        RAISERROR ('Invalid experience level. Allowed values are Director, Executive, Associate, Not Specified, Internship, Entry level, and Mid-Senior Level', 16, 1);
        RETURN;
    END

    -- Validate job_posting_url
    IF @job_posting_url IS NOT NULL AND @job_posting_url NOT LIKE 'https://www.linkedin.com/jobs/%'
    BEGIN
        RAISERROR ('Invalid URL format. URLs should start with ''https://www.linkedin.com/jobs/''.', 16, 1);
        RETURN;
    END

    -- Update only the specified attributes
    UPDATE job_postings
    SET
        company_id = COALESCE(@company_id, company_id),
        title = COALESCE(@title, title),
        description = COALESCE(@description, description),
        work_type = COALESCE(@work_type, work_type),
        experience_level = COALESCE(@experience_level, experience_level),
        location = COALESCE(@location, location),
        job_posting_url = COALESCE(@job_posting_url, job_posting_url)
    WHERE job_id = @job_id;
END;

-- Example 

SELECT TOP 5 * from job_postings;

DECLARE @job_id bigint = 102339515;
DECLARE @company_id bigint = 630152;
DECLARE @title NVARCHAR(MAX) = NULL
DECLARE @description NVARCHAR(MAX) = NULL;
DECLARE @work_type NVARCHAR(MAX) = 'Part-time';
DECLARE @experience_level NVARCHAR(MAX) = NULL;
DECLARE @location NVARCHAR(MAX) = 'San Francisco, CA';
DECLARE @job_posting_url NVARCHAR(MAX) = NULL;

EXEC ValidateUpdateJobPostings
    @job_id,
    @company_id,
    @title,
    @description,
    @work_type,
    @experience_level,
    @location,
    @job_posting_url;

SELECT * FROM job_postings where job_id = 102339515;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GET JOB POSTINGS BY LOCATION (WITH PAGINATION) STORED PROCEDURE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE sp_GetJobPostingsByLocation
    @location NVARCHAR(MAX),
    @page INT = 1,
    @pageSize INT = 100
AS
BEGIN
    SELECT *
    FROM job_postings
    WHERE location = @location
    ORDER BY job_id
    OFFSET (@page - 1) * @pageSize ROWS
    FETCH NEXT @pageSize ROWS ONLY;
END;

-- Example 
DECLARE @location_search NVARCHAR(MAX) = 'San Francisco, CA';

DECLARE @page INT = 1;
DECLARE @pageSize INT = 100;
EXEC sp_GetJobPostingsByLocation @location_search, @page, @pageSize;