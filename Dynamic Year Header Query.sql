
/****** Creating a Dynamic Header of Date/Year to output YTD Values for each year.  ******/
USE AdventureWorksDW2019;
GO;

DECLARE @SqlStatement NVARCHAR(MAX)
,@ListToPivot NVARCHAR(MAX)SET @ListToPivot= (SELECT CONCAT('[',YEAR(GETDATE()),'],','[',YEAR(DATEADD(yy,-1,GETDATE())),'],','[',YEAR(DATEADD(yy,-2,GETDATE())),'],','[',YEAR(DATEADD(yy,-3,GETDATE())),']'))SET @SqlStatement = N'
SELECT *
FROM
(
SELECT YEAR(Report_Date) Report_Date, Product_Code, Sales FROM dbo.FactInternetSales
) q1
PIVOT
(
SUM(Sales)
FOR Report_Date
IN (
'+@ListToPivot+'
)
) AS PivotTable ORDER BY PivotTable.Product_Code
';EXEC(@SqlStatement)

