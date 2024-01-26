/* USER FUNCTIONS -------------------------------------------------------------------------------------------------------------------
1. CONVERTING TIME_RECORDED TO DATETIME FORMAT
*/----------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
-- CONVERTING TIME_RECORDED TO DATETIME FORMAT
--------------------------------------------------------------------------------------------------
CREATE FUNCTION dbo.ConvertUnixTimestampToDatetime (@UnixTimestamp INT)
RETURNS DATETIME
AS
BEGIN
    DECLARE @Datetime DATETIME;
    SET @Datetime = DATEADD(SECOND, @UnixTimestamp, '19700101');
    RETURN @Datetime;
END;

-- Usage
DECLARE @UnixTimestamp INT = 1699139828;
SELECT dbo.ConvertUnixTimestampToDatetime(@UnixTimestamp) AS [Time Recorded Converted];
