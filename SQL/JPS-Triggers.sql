/* TRIGGERS----------------------------------------------------------------------------------------------------------
1. JOB POSTING INSERT, UPDATE AND DELETE TRIGGER
2. COMPANY CASCADE DELETE TRIGGER
3. JOB POSTINGS CASCADE DELETE TRIGGER
5. JOB POSTING EXPERIENCE LEVEL VALIDATION TRIGGER
4. JOB POSTING URL VALIDATION TRIGGER
*/ -------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOB POSTING INSERT, UPDATE AND DELETE TRIGGER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE job_postings_audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    action_type NVARCHAR(10), -- 'INSERT', 'UPDATE', or 'DELETE'
    job_id BIGINT,
    company_id BIGINT,
    title NVARCHAR(MAX),
    description NVARCHAR(MAX),
    work_type NVARCHAR(MAX),
    experience_level NVARCHAR(MAX),
    location NVARCHAR(MAX),
    job_posting_url NVARCHAR(MAX),
    audit_timestamp DATETIME DEFAULT GETDATE()
);

-- Create the trigger
CREATE TRIGGER trg_audit_job_postings
ON job_postings
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the trigger was called recursively
    IF (SELECT TRIGGER_NESTLEVEL()) > 1
    BEGIN
        RETURN;
    END

    -- INSERT case
    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO job_postings_audit (action_type, job_id, company_id, title, description, work_type, experience_level, location, job_posting_url)
        SELECT 'INSERT', job_id, company_id, title, description, work_type, experience_level, location, job_posting_url
        FROM INSERTED;
    END

    -- UPDATE case
    ELSE IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO job_postings_audit (action_type, job_id, company_id, title, description, work_type, experience_level, location, job_posting_url)
        SELECT 'UPDATE', i.job_id, i.company_id, i.title, i.description, i.work_type, i.experience_level, i.location, i.job_posting_url
        FROM INSERTED i
        INNER JOIN DELETED d ON i.job_id = d.job_id;
    END

    -- DELETE case
    ELSE IF NOT EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO job_postings_audit (action_type, job_id, company_id, title, description, work_type, experience_level, location, job_posting_url)
        SELECT 'DELETE', job_id, company_id, title, description, work_type, experience_level, location, job_posting_url
        FROM DELETED;
    END
END;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPANY CASCADE DELETE TRIGGER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER trg_cascade_delete
ON companies
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the trigger was called recursively
    IF (SELECT TRIGGER_NESTLEVEL()) > 1
    BEGIN
        RETURN;
    END
    -- Delete related records in company_industries
    DELETE FROM company_industries
    WHERE company_id IN (SELECT company_id FROM DELETED);

    -- Delete related records in company_specialities
    DELETE FROM company_specialities
    WHERE company_id IN (SELECT company_id FROM DELETED);

    -- Delete related records in employee_counts
    DELETE FROM employee_counts
    WHERE company_id IN (SELECT company_id FROM DELETED);

    -- Delete related records in job_postings
    DELETE FROM job_postings
    WHERE company_id IN (SELECT company_id FROM DELETED);
END;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOB POSTINGS CASCADE DELETE TRIGGER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create the trigger
CREATE TRIGGER trg_cascade_delete_job_postings
ON job_postings
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the trigger was called recursively
    IF (SELECT TRIGGER_NESTLEVEL()) > 1
    BEGIN
        RETURN;
    END

    -- Delete related records in job_skills
    DELETE FROM job_skills
    WHERE job_id IN (SELECT job_id FROM DELETED);

    -- Delete related records in salaries
    DELETE FROM salaries
    WHERE job_id IN (SELECT job_id FROM DELETED);
END;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOB POSTING EXPERIENCE LEVEL VALIDATION TRIGGER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER trg_validate_experience_level
ON job_postings
BEFORE INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the trigger was called recursively
    IF (SELECT TRIGGER_NESTLEVEL()) > 1
    BEGIN
        RETURN;
    END

    -- Check for valid experience levels
    IF EXISTS (SELECT 1 FROM INSERTED WHERE experience_level NOT IN ('Director','Executive','Associate','Not Specified','Internship','Entry level','Mid-Senior level'))
    BEGIN
        RAISEERROR ('Invalid experience level. Allowed values are Director, Executive, Associate, Not Specified, Internship, Entry level and Mid-Senior Level', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOB POSTING URL VALIDATION TRIGGER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TRIGGER trg_validate_url_format
ON job_postings
BEFORE INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the trigger was called recursively
    IF (SELECT TRIGGER_NESTLEVEL()) > 1
    BEGIN
        RETURN;
    END

    -- Check for valid URL format
    IF EXISTS (SELECT 1 FROM INSERTED WHERE job_posting_url NOT LIKE 'https://www.linkedin.com/jobs/%')
    BEGIN
        RAISEERROR ('Invalid URL format. URLs should start with ''https://www.linkedin.com/jobs/''.', 16, 1);
        ROLLBACK;
        RETURN;
    END
END;

