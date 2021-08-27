/******  Advanced Budget Query to Make sure that the user can pick any month of any year and see the Actual YTD
 against the budget on a line graph for that particular year. 
This involves tricky unions to call back the months and of course the data is using month keys 
challenging myself further to remember to convert them into date time. I also have to use a subsdtring to get the months.
 This Query is long and in fact takes up many more lines of code but the process is quite similar bar a group by clause and order by at the end. ***/

 SELECT 
   EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS [Month End],  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
      ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
      ,SUM([% Difference]) AS [% of Difference]
  FROM AdventureWorksDW2019.dbo.Dimbudget
 Group by date
 UNION
SELECT --11 months to come for Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-11, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
      ,SUM([% Difference]) AS [% of Difference]
FROM AdventureWorksDW2019.dbo.Dimbudget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12') 
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-11, convert(char(8),[date])))), date

UNION
SELECT --10 months to come for Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-10, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
      ,SUM([% Difference]) AS [% of Difference]
FROM AdventureWorksDW2019.dbo.Dimbudget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11') 
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-10, convert(char(8),[date])))), date
UNION
SELECT --9 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-9, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
      ,SUM([% Difference]) AS [% of Difference]
FROM AdventureWorksDW2019.dbo.Dimbudget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10') 
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-9, convert(char(8),[date])))), date
UNION
SELECT --8 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-8, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-8, convert(char(8),[date])))), date
UNION
SELECT --7 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-7, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-7, convert(char(8),[date])))), date
UNION

SELECT --6 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-6, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-6, convert(char(8),[date])))), date
UNION

SELECT --5 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-5, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07', '06')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-5, convert(char(8),[date])))), date
UNION
SELECT --4 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-4, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07', '06', '05')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-4, convert(char(8),[date])))), date
UNION
SELECT --3 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-3, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07', '06', '05', '04')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-3, convert(char(8),[date])))), date
UNION
SELECT --2 months to come for Sept, Oct, Nov, Dec
 EOMONTH(CONVERT( Varchar, DATEADD(month,-2, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07', '06', '05', '04', '03')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-2, convert(char(8),[date])))), date
UNION
SELECT 
 EOMONTH(CONVERT( Varchar, DATEADD(month,-1, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07', '06', '05', '04', '03', '02')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month,-1, convert(char(8),[date])))), date
UNION
SELECT 
 EOMONTH(CONVERT( Varchar, DATEADD(month,1, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('12','11', '10','09', '08', '07', '06', '05', '04', '03', '02', '01')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month, 1, convert(char(8),[date])))), date
UNION
SELECT 
 EOMONTH(CONVERT( Varchar, DATEADD(month,2, convert(char(8),[date])))),
  EOMONTH(CONVERT (datetime,convert(char(8),[date]))) AS MONTH
       ,SUM([Budget]) AS Budget
      ,SUM([Actual]) AS Actual
      ,SUM([Delta]) AS Delta
       FROM AdventureWorksDW2019.dbo.budget
WHERE SUBSTRING(convert(char(8),[date]),5,2) IN ('01')
GROUP BY  EOMONTH(CONVERT( Varchar, DATEADD(month, 2, convert(char(8),[date])))), date
UNION ............................................................