-- Cleansed Dim_CustomerTable
SELECT 
c.customerkey AS CustomerKey
      --,[GeographyKey]
      --,[CustomerAlternateKey]
      --,[Title]
      ,c.[FirstName] AS [First Name]
      --,[MiddleName]
      ,c.[LastName] AS [Last Name]
	  ,c.[FirstName] +' '+ [LastName] AS [Full Name], 
	  --Join First and Last Name
      --,[NameStyle]
      --,[BirthDate]
      --,[MaritalStatus]
      --.[Suffix]
      CASE c.Gender WHEN 'M' Then 'Male' WHEN 'F' THEN 'FEMALE' END AS Gender,
      --,[EmailAddress]
      --,[YearlyIncome]
      --,[TotalChildren]
      c.[DateFirstPurchase],
      c.[CommuteDistance],
	  g.city AS [Customer City] -- JOIN Customer City From Geography Table 
  FROM [dbo].[DimCustomer] AS c 
  LEFT JOIN dbo.dimgeography AS g ON g.GeographyKey = c.geographykey
  ORDER BY 
  CustomerKey ASC;
  
  
  /****** Cleansed Dim_DateTable ***/
SELECT [DateKey]
      ,[FullDateAlternateKey] AS Date
      ,[DayNumberOfWeek]
      ,[EnglishDayNameOfWeek]
      --[SpanishDayNameOfWeek]
      --[FrenchDayNameOfWeek]
      --[DayNumberOfMonth]
      --[DayNumberOfYear]
      ,[WeekNumberOfYear] AS WeekNr
      ,LEFT([EnglishMonthName],3) AS MonthShort
	  ,[EnglishMonthName]
      --[SpanishMonthName]
      --[FrenchMonthName]
      ,[MonthNumberOfYear] AS MonthNr
      ,[CalendarQuarter]
      ,[CalendarYear]

  FROM [AdventureWorksDW2019].[dbo].[DimDate]
  WHERE CalendarYear BETWEEN 2018 AND 2020;
  
  -- Adam Ruane - Cleansed FACT_Internet Sales Table
SELECT [ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
     -- ,[PromotionKey]
    --  ,[CurrencyKey]
     -- ,[SalesTerritoryKey]
      ,[SalesOrderNumber]
     -- ,[SalesOrderLineNumber]
      --,[RevisionNumber]
      --,[OrderQuantity]
      --,[UnitPrice]
      --,[ExtendedAmount]
      --,[UnitPriceDiscountPct]
      --,[DiscountAmount]
     -- ,[ProductStandardCost]
     -- ,[TotalProductCost]
      ,[SalesAmount]
     -- ,[TaxAmt]
     -- ,[Freight]
     -- ,[CarrierTrackingNumber]
   --   ,[CustomerPONumber]
    --  ,[OrderDate]
     -- ,[DueDate]
     -- ,[ShipDate]
  FROM [AdventureWorksDW2019].[dbo].[FactInternetSales]

  WHERE 
  LEFT (OrderDateKey, 4) >= YEAR(GETDATE()) -1 -- Ensuring it will only bring in 1 years of date from every Extraction.
  OR
  DER BY 
  OrderDate ASC 
  
  
  
  --Cleansed Dim_Products Table
SELECT 
       P.[ProductKey]
      ,P.[ProductAlternateKey] AS [ProductItemCode]
   
      --,[WeightUnitMeasureCode]
     -- ,[SizeUnitMeasureCode]
      ,P.[EnglishProductName] AS [Product Name]
	  ,PS.[EnglishProductSubcategoryName] AS [Sub Category] -- JOINED in Sub Category Table
	  ,PC.EnglishProductCategoryName AS [Product Category] -- Joined in from Category Tbale
      --,[SpanishProductName]
     -- ,[FrenchProductName]
      --,[StandardCost]
      --,[FinishedGoodsFlag]
      ,P.[Color] AS [Product Colour] 
      ,P.[SafetyStockLevel]
      ,P.[ReorderPoint]
      ,P.[ListPrice]
      ,P.[Size] AS [Product Size]
      --[SizeRange]
      --,[Weight]
      --,[DaysToManufacture]
      ,[ProductLine] AS [Product Line]
      --,[DealerPrice]
      --,[Class]
      --,[Style]
      ,P.[ModelName] AS [Product Model Name] 
      ,P.[LargePhoto]
      ,P.[EnglishDescription] AS [Product Description] 
      --,[FrenchDescription]
     -- ,[ChineseDescription]
      --,[ArabicDescription]
      --,[HebrewDescription]
      --,[ThaiDescription]
      --,[GermanDescription]
      --,[JapaneseDescription]
      --,[TurkishDescription]
     -- ,[StartDate]
     -- ,[EndDate]
      --,[Status]
	  ,ISNULL (P.Status, 'Out Dated') AS [Product Status]
  FROM [dbo].[DimProduct] as P
  LEFT JOIN dbo.DimProductSubCategory AS PS ON PS.ProductSubCategoryKey = P.ProductSubCategoryKey
  LEFT JOIN dbo.DimProductCategory AS PC ON PS.ProductCategoryKey = PC.ProductCategoryKey
  ORDER BY 
  P.ProductKey asc;