--select NAME as Morningstar_PG , PEERGROUP_AVERAGE_OGC, ASSET_WEIGHTED_FEES as AssetWeightedOGC
--from DEV_MED_DATAHUB.MORNINGSTAR.VW_WAREHOUSEXML_CATEGORY 



WITH SplittedCountry as(
select ISIN, fund_legal_name, KIID_ONGOING_CHARGE, c.value::string as CountryName, NET_ASSETS_SHARE_CLASS_EUR
from morningstar.vw_warehousexml_fundshareclass,
     lateral flatten(input=>split(country_available_for_sale, ',')) c
    )
    , CountryFees as(
    select CountryName, KIID_ONGOING_CHARGE, ISIN, fund_legal_name, NET_ASSETS_SHARE_CLASS_EUR
    from SplittedCountry
    where CountryName IS NOT NULL
    AND KIID_ONGOING_CHARGE IS NOT NULL
     AND CountryName != ''
)

, Category as(
select distinct CountryName
from CountryFees
)

, assetfees as(

select a.CountryName , AVG(B.KIID_ONGOING_CHARGE * B.NET_ASSETS_SHARE_CLASS_EUR)/AVG(B.NET_ASSETS_SHARE_CLASS_EUR) AS ASSET_WEIGHTED_FEES,
AVG(B.KIID_ONGOING_CHARGE) AS PEERGROUP_AVERAGE_OGC
 from Category A
  left join CountryFees B on B.CountryName = A.CountryName
group by A.CountryName)

  SELECT A.* 
  ,ASSET_WEIGHTED_FEES
  ,PEERGROUP_AVERAGE_OGC as SimpleweightedAvgOGC
FROM  Category A
INNER JOIN assetfees AS B
ON A.COUNTRYNAME=B.COUNTRYNAME

  