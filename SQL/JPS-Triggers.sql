/* TRIGGERS----------------------------------------------------------------------------------------------------------
1. JOB POSTING INSERT, UPDATE AND DELETE TRIGGER
2. DELETION OF JOB POSTINGS AUDITS TRIGGER
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

-- Example 
select top 10 * from job_postings;
delete from job_postings where job_id = 3958427;
update job_postings set experience_level = 'Internship' where  job_id = 133196985;
select * from job_postings_audit;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETION OF JOB POSTINGS AUDITS TRIGGER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER trg_prevent_modifications_job_postings_audit
ON job_postings_audit
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Modifications on job_postings_audit are not allowed.', 16, 1);
END;

-- Example
DELETE FROM job_postings_audit WHERE audit_id=2;