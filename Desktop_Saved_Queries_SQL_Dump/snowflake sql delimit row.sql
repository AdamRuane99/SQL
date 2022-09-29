WITH SplittedCountry as(
select ISIN, fund_legal_name, KIID_ONGOING_CHARGE, c.value::string as CountryName
from morningstar.vw_warehousexml_fundshareclass,
     lateral flatten(input=>split(country_available_for_sale, ',')) c
    )
    
    select CountryName, KIID_ONGOING_CHARGE, ISIN, fund_legal_name
    from SplittedCountry
    where CountryName IS NOT NULL
    AND KIID_ONGOING_CHARGE IS NOT NULL
     