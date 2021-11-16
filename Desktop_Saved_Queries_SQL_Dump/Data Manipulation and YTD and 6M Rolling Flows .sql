-- Rolling 6M NETFLOWS -- 

 WITH AUM_Table as(
SELECT  CONVERT (datetime,convert(char(8),[REPORT_DATE])) AS [Month], 
H.FundClassName, H.FundName, H.ISIN,
	  D.ACCOUNT_NUMBER,
	     CASE  D.ACCOUNT_NUMBER
		 WHEN 'CFU0067409' THEN 'Fondsdepot Bank GmbH' 
	  WHEN 'CFU0067410' THEN 'dbfp' 
	  WHEN 'CFU0067096' THEN 'Pateo Investment, Berlin' 
	  WHEN 'CFU0062074' THEN 'Augsburger Aktienbank AG'
	  WHEN 'CFU0067004' THEN 'Commerzbank'
	  WHEN 'ARX0000001' THEN 'Attrax'
	  WHEN 'CFU0064043' THEN 'HSBC Trinkhaus'
	   WHEN 'CFU0064003' THEN 'DWP'
	   WHEN 'CFU0067268' THEN 'DWP' 
  ELSE 'Unallocated' END AS  [FB PARTNERS] 

      ,N.[DEALER_CODE]
      ,[Product Name], 
    [Total All NAV] [AUM]
  FROM [MED_EDW].[edw].[net_inflows] N
  LEFT JOIN MED_EDW.edw.acct_dealer_account D ON DEALER_ACCOUNT_ID = D.ID
  LEFT JOIN [MED_EDW].[edw].[fund_class_history] H ON N.FUND_CLASS_HISTORY_ID = H.ID
  WHERE ACCOUNT_NUMBER IN (
  'IAM0000001', 'RZB0000001', 'ARX0000001', 'BDL1111593', 'CFU0067096', 'CFU0013463', 'CFU0024705', 'CFU0086131', 'CFU0000001', 
  'CFU0064062', 'CFU0064011', 'CFU0017740', 'CFU0067003', 'CFU0062087', 'CFU0012173', 'CFU0062126', 'CFU0017642', 'CFU0064043', 
  'CFU0067268', 'CFU0062013', 'CFU0064003', 'CFU0067004', 'CFU0062074', 'CFU0067409'
  )
  AND DAY(CONVERT (datetime,convert(char(8),[REPORT_DATE]))) = (
  SELECT  CASE WHEN DATENAME(DW, (EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE]))))) = 'SATURDAY' THEN 
  DAY(EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE]))))-1 WHEN DATENAME(DW, (EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE]))))) = 'SUNDAY' THEN
  DAY(EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE]))))-2 ELSE DAY(EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE])))) END))

  , 
  NEW_AUM_TABLE AS(
  SELECT EOMONTH(MONTH) AS Month_End , FundClassName, FundName, ISIN, ACCOUNT_NUMBER, [FB PARTNERS], DEALER_CODE, [Product Name], SUM(AUM) AS AUM
  FROM AUM_Table
  GROUP BY EOMONTH(MONTH) , FundClassName, FundName, ISIN, ACCOUNT_NUMBER, [FB PARTNERS], DEALER_CODE, [Product Name]
  )

  ,
  Old_Flows_Table AS
  (
  SELECT EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE]))) AS [Month End], YEAR(EOMONTH(CONVERT (datetime,convert(char(8),[REPORT_DATE])))) AS [Year],
H.FundClassName, H.FundName, H.ISIN,
	  D.ACCOUNT_NUMBER,

	 CASE  D.ACCOUNT_NUMBER
		 WHEN 'CFU0067409' THEN 'Fondsdepot Bank GmbH' 
	  WHEN 'CFU0067410' THEN 'dbfp' 
	  WHEN 'CFU0067096' THEN 'Pateo Investment, Berlin' 
	  WHEN 'CFU0062074' THEN 'Augsburger Aktienbank AG'
	  WHEN 'CFU0067004' THEN 'Commerzbank'
	  WHEN 'ARX0000001' THEN 'Attrax'
	  WHEN 'CFU0064043' THEN 'HSBC Trinkhaus'
	   WHEN 'CFU0064003' THEN 'DWP'
	   WHEN 'CFU0067268' THEN 'DWP' 
  ELSE 'Unallocated' END AS  [FB PARTNERS]

      ,N.[DEALER_CODE]
      ,[Product Name], 
	  FUND_CLASS_HISTORY_ID
      ,SUM([Subscriptions]) AS Subs 
      ,SUM([Redemptions]) AS Reds
      ,SUM([Net Inflow]) AS [Net Flows]
	
    
  FROM [MED_EDW].[edw].[net_inflows] N
  LEFT JOIN MED_EDW.edw.acct_dealer_account D ON DEALER_ACCOUNT_ID = D.ID
  LEFT JOIN [MED_EDW].[edw].[fund_class_history] H ON N.FUND_CLASS_HISTORY_ID = H.ID
  WHERE ACCOUNT_NUMBER IN (
  'IAM0000001', 'RZB0000001', 'ARX0000001', 'BDL1111593', 'CFU0067096', 'CFU0013463', 'CFU0024705', 'CFU0086131', 'CFU0000001', 
  'CFU0064062', 'CFU0064011', 'CFU0017740', 'CFU0067003', 'CFU0062087', 'CFU0012173', 'CFU0062126', 'CFU0017642', 'CFU0064043', 
  'CFU0067268', 'CFU0062013', 'CFU0064003', 'CFU0067004', 'CFU0062074', 'CFU0067409')
  GROUP BY 
  REPORT_DATE,
  D.ACCOUNT_NUMBER
      ,N.[DEALER_CODE]
      ,[Product Name],
	  H.FundClassName, H.FundName, H.ISIN, FUND_CLASS_HISTORY_ID)
	  ,

	  Flows_Table AS(
	  SELECT  [Month End], Year, FundClassName, FundName, ISIN,
	  ACCOUNT_NUMBER, [DEALER_CODE], SUM(Subs) AS Subs 
      ,SUM(Reds) AS Reds
      ,SUM([Net Flows]) AS [Net Flows]
      ,[Product Name], 
	  FUND_CLASS_HISTORY_ID
	  FROM Old_Flows_Table
	  GROUP BY  [Month End], Year, FundClassName, FundName, ISIN,
	  ACCOUNT_NUMBER, [DEALER_CODE] ,[Product Name], 
	  FUND_CLASS_HISTORY_ID

	  )

	  , 
	  DISTINCTVALUE AS(
	  SELECT DISTINCT ISIN, ACCOUNT_NUMBER
	  FROM Flows_Table
	  ) ,

	  NEW_BBCH_TABLE AS(
	  SELECT [Month End], cast(Flows_Table.ISIN as varchar(15)) as ISIN,cast(Flows_table.FundName as varchar(50)) as FundName,Flows_Table.ACCOUNT_NUMBER, [FB PARTNERS] ,SUM(SUBS) AS SUBS , SUM(REDS) AS REDS , (SUM(SUBS) - SUM(REDS)) as [Net Flows]  ,SUM(AUM) as AUM
	  FROM Flows_Table
	  LEFT JOIN DISTINCTVALUE ON Flows_Table.ISIN = DISTINCTVALUE.ISIN and DISTINCTVALUE.ACCOUNT_NUMBER = Flows_Table.ACCOUNT_NUMBER
	  LEFT JOIN NEW_AUM_TABLE ON DISTINCTVALUE.ISIN = NEW_AUM_TABLE.ISIN and DISTINCTVALUE.ACCOUNT_NUMBER = NEW_AUM_TABLE.ACCOUNT_NUMBER 
	  and Flows_Table.[Month End] = NEW_AUM_TABLE.Month_End

	  WHERE Flows_Table.ISIN <> '0'
	  GROUP BY [Month End], Flows_Table.ISIN, Flows_Table.ACCOUNT_NUMBER,  Flows_table.FundName, [FB PARTNERS]) 
	  ,
	  FINAL_TAB AS(

	  SELECT * , 'Clearstream' as [TA], CASE ACCOUNT_NUMBER WHEN  'Unallocated' THEN 'Retail' ELSE 'Instituitional' END AS [Investor Type],
sum([Net Flows]) over (partition by ISIN, Account_Number order by YEAR([Month End]),  MONTH([Month End]) rows between 5 preceding and current row) as [6m_Netflows],
sum([Net Flows]) over (partition by ISIN, Account_Number order by YEAR([Month End]),  MONTH([Month End]) rows between 7 preceding and current row) as [8m_Netflows],
	  SUM(SUBS) over(partition by ISIN, Account_Number, YEAR([Month End]) order by Year([Month End]),[Month End] rows unbounded preceding) as YTD_Subs,
	  SUM(REDS) over(partition by ISIN, Account_Number, YEAR([Month End]) order by Year([Month End]),[Month End] rows unbounded preceding) as YTD_Reds,
	  SUM([Net Flows]) over(partition by ISIN, Account_Number, YEAR([Month End]) order by Year([Month End]),[Month End] rows unbounded preceding) as YTD_NetFlows
	  FROM NEW_BBCH_TABLE
	 )
	 , NEWTAB AS(
	  SELECT [Month End], ISIN, FundName , SUBS, REDS, [Net Flows], [6m_Netflows], [8m_Netflows] ,YTD_Subs, YTD_Reds, YTD_NetFlows, AUM, ACCOUNT_NUMBER, [FB PARTNERS] as [ACCOUNT_NAME], TA, [Investor Type]
	  FROM FINAL_TAB)

	  ,
	    sq as 
(
SELECT *,
EOMONTH(dateadd(DD, -1, dateadd(YY,datediff(yy,0,[Month End]),0))) as Decprevyear
FROM  NEWTAB
)

,  sq2 as
(
select	a.*, b.AUM as Decprevyear_AUM, b.YTD_NetFlows as [Last_Yr_YTD Net Flows], b.YTD_Subs as [Last_yr_YTD Subs]
from sq as a
left join sq as b on a.ISIN=b.ISIN and a.ACCOUNT_NUMBER=b.ACCOUNT_NUMBER and a.Decprevyear=b.[Month End])

,
FINAL_Flows_Tab AS(
SELECT * , MONTH([Month End]) AS Month_Number, DATENAME(Month, [Month End]) AS [Month_Name], Datepart(Year, [Month End]) AS Year,
CASE WHEN ACCOUNT_NUMBER = 'CFU0067409' THEN	'FONDSDEPOT BANK GMBH'   WHEN ACCOUNT_NUMBER = 		
'CFU0062074' THEN	'AUGSBURGER AKTIENBANK AG'	
   WHEN ACCOUNT_NUMBER =  'CFU0067004' then	'COMMERZBANK AG W/FRANKFURT U. XETRA'   WHEN ACCOUNT_NUMBER = 
'CFU0064003' THEN	'DWPBANK (EX.WPS)'	 WHEN ACCOUNT_NUMBER = 
'CFU0062013' THEN	'CACEIS BANK GERMANY CLIENTS ACC.'  WHEN ACCOUNT_NUMBER = 		
'CFU0067268' THEN	'DWPBANK W/DZ BANK AG'	 WHEN ACCOUNT_NUMBER = 
'CFU0064043' THEN	'HSBC TRINKAUS + BURKHARDT AG'	 WHEN ACCOUNT_NUMBER = 	
'CFU0017642' THEN	'BANK JULIUS BAER + CO AG/FUNDS' WHEN ACCOUNT_NUMBER = 
'CFU0062126' THEN	'BNP PARIBAS DEUTSCHLAND/CONSORSBANK'		 WHEN ACCOUNT_NUMBER = 
'CFU0012173' THEN	'ERSTE GROUP BANK AG -CLIENT DEP.'	 WHEN ACCOUNT_NUMBER = 
'CFU0062087' THEN	'ING-DIBA AG'		 WHEN ACCOUNT_NUMBER = 
'CFU0067003' THEN	'DB AG SD CLT CBL N/A'  WHEN ACCOUNT_NUMBER = 
'CFU0017740' THEN	'SS BK INT GMBH-SUCCURSALE ITALIA'		 WHEN ACCOUNT_NUMBER = 
'CFU0064011' THEN	'DEUTSCHE APOTHEKER- U. AERZTEBANK'		 WHEN ACCOUNT_NUMBER = 
'CFU0064062' THEN	'Targobank AG & CO KGAA	'	 WHEN ACCOUNT_NUMBER = 
'CFU0000001' THEN 'Clearstream (old Ac)'		 WHEN ACCOUNT_NUMBER = 
'CFU0086131'  THEN 'BG de Patrimoines Prives-Clients AC'  WHEN ACCOUNT_NUMBER = 		
'CFU0024705' THEN	 'Edmond de Rothschild (Monaco)/MF-Stock DIV'	 WHEN ACCOUNT_NUMBER = 	
'CFU0013463' THEN	'UBS SWITZERLAND AG'		 WHEN ACCOUNT_NUMBER = 
'CFU0067096' THEN	'FIL FNDSB.GMBH SPER. W/KOMM.GES.'	 WHEN ACCOUNT_NUMBER = 
'BDL1111593' THEN	'Banque de Luxembourg'		 WHEN ACCOUNT_NUMBER = 
'IAM0000001' THEN 'International Fund Services & Asset Management Sa'  WHEN ACCOUNT_NUMBER = 		
'RZB0000001' THEN	'Raiffeisen Bank International AG (Austria)'	 WHEN ACCOUNT_NUMBER = 	
'ARX0000001' THEN	'Attrax SA a/c Wegen Kundenanteilenundenanteilen'		END AS [ACCOUNT HOLDER]
from sq2
)

SELECT *
FROM FINAL_Flows_Tab
