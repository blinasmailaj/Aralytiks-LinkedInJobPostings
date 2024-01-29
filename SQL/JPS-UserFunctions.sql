/* USER FUNCTIONS -------------------------------------------------------------------------------------------------------------------
1. CONVERTING TIME_RECORDED TO DATETIME FORMAT
2. CONVERTING LISTED_TIME TO DATETIME FORMAT
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

DECLARE @UnixTimestamp BIGINT = 1692644648;
SELECT dbo.ConvertUnixTimestampToDatetime(@UnixTimestamp) AS [Formatted Date];

--------------------------------------------------------------------------------------------------
-- CONVERTING LISTED_TIME TO DATETIME FORMAT
--------------------------------------------------------------------------------------------------

CREATE FUNCTION ConvertUnixTimestampToFormattedDate
(
    @UnixTimestamp BIGINT
)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @ConvertedDate DATETIME = DATEADD(MILLISECOND, @UnixTimestamp % 1000, DATEADD(SECOND, @UnixTimestamp / 1000, '19700101 00:00:00:000'));
    
    RETURN FORMAT(@ConvertedDate, 'yyyy/MM/dd');
END;

DECLARE @UnixTimestamp BIGINT = 1699050000000;
SELECT dbo.ConvertUnixTimestampToFormattedDate(@UnixTimestamp) AS [Formatted Date];
