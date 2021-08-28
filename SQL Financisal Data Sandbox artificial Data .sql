/****** Script for SelectTopNRows command from SSMS  ******/
WITH CTE AS(
SELECT 
	 EOMONTH(convert(datetime, [DATE], 103)) AS [Month End], MONTH(convert(datetime, [DATE], 103)) AS Month_Number, DATENAME(Month, convert(datetime, [DATE], 103)) AS [Month_Name], Datepart(Year, convert(datetime, [DATE], 103)) AS Year
	,CASE [Country] WHEN '1' THEN 'England' WHEN '4' THEN 'France' WHEN '2' THEN 'Ireland' END AS Country 
      ,[CONTRACT]
      ,[PRODUCT]
    
   , 
SUM(TRY_CONVERT(FLOAT,[Invested Units])) AS [Invested Units],
SUM(TRY_CONVERT(FLOAT,[Units Value])) AS [Units Value]
,
     [CODE]
      ,[DESCRIPTION Code]
      
  
  
  FROM dbo.[Financial_data_sandbox_query_artificial_data_inflows]
  WHERE 
 [DESCRIPTION Code] IN ('SPI', 'INSTALLMENT', 'FIRST PREMIUM', 'COUPON RE-INVESTMENT')
 GROUP BY [CONTRACT]
      ,[PRODUCT]
      
   , 
    [Code]
      ,[DESCRIPTION Code]
      , [Date], Country, [Invested units]
  ),

CTE2 AS(
SELECT DISTINCT  POLICY_SHORT_NUMBER, POLICY_ID, POLICY_NUMBER
  FROM dbo.policy_bridge) , 

  CTE3 AS ( 
  SELECT [Month End], Month_Name, Month_Number, [YEAR], Country,  Product, , [Code], [DESCRIPTION Code], [Invested Units], [Units Value], POLICY_ID, POLICY_NUMBER
  FROM CTE
  LEFT JOIN CTE2 ON   CTE.[CONTRACT] = CTE2.POLICY_SHORT_NUMBER)

  ,
  Investments  AS(
  SELECT  [Month End], Month_Name, Month_Number, [YEAR], [Code], [DESCRIPTION Code], [Invested Units] [Units], [Units Value] 
 , ( [Invested Units] * [Units Value])  [Amount],
  Country,  Product [Product Code], POLICY_NUMBER
  FROM CTE3)
  ,
  Tab1 AS(
SELECT 
	  EOMONTH(convert(datetime, [DATE], 103)) AS [Month End], MONTH(convert(datetime, [DATE], 103)) AS Month_Number, DATENAME(Month, convert(datetime, [DATE], 103)) AS [Month_Name], Datepart(Year, convert(datetime, [DATE], 103)) AS Year
	,CASE [Country] WHEN '1' THEN 'England' WHEN '4' THEN 'France' WHEN '2' THEN 'Ireland' END AS Country 
      ,[CONTRACT]
      ,[PRODUCT]
     
   , 
SUM(TRY_CONVERT(FLOAT,[DISINVESTED UNITS])) AS [Units],
SUM(TRY_CONVERT(FLOAT,[LAST VALUE ])) AS [Units Value] ,
SUM(TRY_CONVERT(FLOAT,[AMOUNT     ])) AS Amount
,
     [CODE]
      ,[DESCRIPTION CODE]
    
  
  
  FROM dbo.[Financial_data_sandbox_query_artificial_data_outflows]
  WHERE 
 [DESCRIPTION CODE] IN ('Surrender', 'PARTIAL SURRENDER'   , 'MATURITY')

 GROUP BY [CONTRACT]
      ,[PRODUCT]
  
,
     [CODE]
      ,[DESCRIPTION CODE]
     , [Date], Country
  ),

  Tab2 AS(
SELECT DISTINCT  POLICY_SHORT_NUMBER, POLICY_ID, POLICY_NUMBER
  FROM dbo.[Client_to_policy_bridge]) , 

  Tab3 AS ( 
  SELECT [Month End], Month_Name, Month_Number, [YEAR], Country,  Product, [Code], [DESCRIPTION CODE], [Units], [Units Value], POLICY_ID, POLICY_NUMBER
  FROM Tab1
  LEFT JOIN  Tab2 ON   Tab1.[CONTRACT] =  Tab2.POLICY_SHORT_NUMBER), 


    Disinvestment AS(

  SELECT  [Month End], Month_Name, Month_Number, [YEAR], [Code], [DESCRIPTION CODE], [Units], [Units Value] 
 , ( [Units] * [Units Value])  [Amount],
  Country,  Product [Product Code], POLICY_NUMBER
  FROM Tab3)
 ,
INVDISINV AS(
 SELECT * 
 FROM Investments
 UNION 
 SELECT * 
 FROM Disinvestment)


 , 
 INVDISINV_Table AS(
 SELECT 
 [Month End], Month_Name, Month_Number, [YEAR],  [Code], [DESCRIPTION CODE], [Units], [Units Value] 
 ,  [Amount],
  Country,   [Product Code], POLICY_NUMBER,
 
 SUM(CASE WHEN [DESCRIPTION OPERATION CODE] IN ('Surrender', 'PARTIAL SURRENDER'   , 'MATURITY') THEN Amount END) AS [Out Flows], 
 SUM(CASE WHEN [DESCRIPTION OPERATION CODE] IN 'SPI', 'INSTALLMENT', 'FIRST PREMIUM', 'COUPON RE-INVESTMENT') THEN Amount END) AS [In Flows]
 FROM INVDISINV

  GROUP BY 
 
 [Month End], Month_Name, Month_Number, [YEAR], [Code], [DESCRIPTION CODE], [Units], [Units Value] 
 ,  [Amount],
  Country,   [Product Code], POLICY_NUMBER )

  ,
  INVDISINVADDFB AS(
  SELECT *,  (ISNULL([In Flows], 0) - ISNULL([Out Flows], 0)) AS [Net Flows]
  FROM INVDISINV_Table) 

