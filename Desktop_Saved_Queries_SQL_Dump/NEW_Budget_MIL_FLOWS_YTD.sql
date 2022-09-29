USE MED_EDW;
WITH BASE AS(
  SELECT 
    DISTINCT d.DATE AS DATE, 
    CASE WHEN p.COMPANY_CODE = '01' THEN 1 WHEN p.COMPANY_CODE = '02' THEN 2 WHEN p.COMPANY_CODE = '04' THEN 3 END AS COMPANY_ID, 
    p.ID AS PRODUCT_ID, 
    t.ID AS TRANSACTION_SUBTYPE_ID 
  FROM 
    [edw].[life_insurance_product] AS p, 
    [edw].[life_insurance_transaction_subtype] AS t, 
    [edw].[life_insurance_premium_details] AS d 
  WHERE 
    p.ID <> 0 -- filter out dummy product id
    AND t.ID IN (3, 4, 5, 6, 7, 8, 9)
), 
PREMS AS(
  SELECT 
    a.DATE, 
    a.COMPANY_ID, 
    a.PRODUCT_ID, 
    a.TRANSACTION_SUBTYPE_ID, 
    ISNULL(b.AMOUNT, 0) AMOUNT, 
    b.POLICY_ID 
  FROM 
    BASE AS a 
    LEFT OUTER JOIN edw.life_insurance_premium_details AS b ON b.DATE = a.DATE 
    AND b.COMPANY_ID = a.COMPANY_ID 
    AND b.PRODUCT_ID = a.PRODUCT_ID 
    AND b.TRANSACTION_SUBTYPE_ID = a.TRANSACTION_SUBTYPE_ID
), 
Aggd as(
  SELECT 
    DISTINCT LP.CODE [Product Code], 
    CATEGORY, 
    TERRITORY, 
    s.name as TransactionType, 
    DATE, 
    sum(
      ISNULL(AMOUNT, 0)
    ) as AMOUNT, 
    count(Policy_ID) as POLICY_COUNT, 
    PRODUCT_ID, 
    COMPANY_ID, 
    TRANSACTION_SUBTYPE_ID 
  from 
    PREMS p 
    LEFT JOIN [MED_EDW].[edw].[life_insurance_product] LP ON product_id = LP.ID 
    LEFT JOIN [MED_EDW].[edw].[life_insurance_transaction_subtype] S ON transaction_subtype_id = S.ID 
    LEFT JOIN [MED_EDW].[edw].[life_insurance_company] C ON company_id = C.ID 
  WHERE 
    TRANSACTION_SUBTYPE_ID IN (7, 8, 9) 
  group by 
    TERRITORY, 
    s.name, 
    LP.code, 
    DATE, 
    PRODUCT_ID, 
    COMPANY_ID, 
    TRANSACTION_SUBTYPE_ID, 
    LP.CATEGORY, 
    LP.NAME
), 
MIL_Premiums AS(
  select 
    *, 
    SUM(AMOUNT) OVER (
      PARTITION BY LEFT(DATE, 4), 
      COMPANY_ID, 
      CATEGORY, 
      [Product Code], 
      PRODUCT_ID, 
      TRANSACTION_SUBTYPE_ID 
      ORDER BY 
        LEFT(DATE, 4), 
        DATE ROWS UNBOUNDED PRECEDING
    ) AMOUNT_YTD, 
    SUM(POLICY_COUNT) OVER (
      PARTITION BY LEFT(DATE, 4), 
      COMPANY_ID, 
      CATEGORY, 
      [Product Code], 
      PRODUCT_ID, 
      TRANSACTION_SUBTYPE_ID 
      ORDER BY 
        LEFT(DATE, 4), 
        DATE ROWS UNBOUNDED PRECEDING
    ) POLICY_COUNT_YTD 
  from 
    Aggd
)
, Inflow as(
SELECT    CATEGORY,
          cast(cast([date] as varchar(10)) as date) AS Date ,
sum(AMount) as Actual
		,TERRITORY [Country]
  FROM MIL_Premiums
  where TransactionType IN ('New Business','Regular Premium','Single Premium Injection') and TERRITORY = 'Spain'
  and year( cast(cast([date] as varchar(10)) as date)) > '2020'
  GRoup By  CATEGORY, 
	  cast(cast([date] as varchar(10)) as date), TERRITORY)
	  