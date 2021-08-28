--/****** The first CTE-cteTotalSales-is similar to the one in the preceding example, except that the WHERE clause
 has been further qualified to include sales only from 2020. 
After I define cteTotalSales, I add a comma, and then define cteTargetDiff, which calculates the difference 
between the sales total and the sales quota.

The new CTE definition specifies three columns for the result set: SalesPersonID, SalesQuota, and QuotaDiff. 
As you would expect, the CTE query returns three columns. The first is the salesperson ID. The second is the 
sales quota. However, because a sales quota is not defined for some salespeople I use a CASE statement. If the
 value is null, that value is set to 0, otherwise the actual SalesQuota value is used.

The final column returned is the difference between the net sales and sales quota. Again, I use a CASE statement. 
If the SalesQuota value is null, then the NetSales value is used, otherwise the sales quota is subtracted from the net sales
 to arrive at the difference. The idea here is to play with CTE's and prove how useful they can be.
 ******/


WITH 
  cteTotalSales (SalesPersonID, NetSales)
  AS
  (
    SELECT SalesPersonID, ROUND(SUM(SubTotal), 2)
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
      AND OrderDate BETWEEN '2020-01-01 00:00:00.000' 
        AND '2020-12-31 23:59:59.000'
    GROUP BY SalesPersonID
  ),
  cteTargetDiff (SalesPersonID, SalesQuota, QuotaDiff)
  AS
  (
    SELECT ts.SalesPersonID,
      CASE 
        WHEN sp.SalesQuota IS NULL THEN 0
        ELSE sp.SalesQuota
      END, 
      CASE 
        WHEN sp.SalesQuota IS NULL THEN ts.NetSales
        ELSE ts.NetSales - sp.SalesQuota
      END
    FROM cteTotalSales AS ts
      INNER JOIN Sales.SalesPerson AS sp
      ON ts.SalesPersonID = sp.BusinessEntityID
  )
SELECT 
  sp.FirstName + ' ' + sp.LastName AS FullName,
  sp.City,
  ts.NetSales,
  td.SalesQuota,
  td.QuotaDiff
FROM Sales.vSalesPerson AS sp
  INNER JOIN cteTotalSales AS ts
    ON sp.BusinessEntityID = ts.SalesPersonID
  INNER JOIN cteTargetDiff AS td
    ON sp.BusinessEntityID = td.SalesPersonID
ORDER BY ts.NetSales DESC