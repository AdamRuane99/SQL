USE MED_EDW;
with mgtfeewaivers as(
  SELECT 
    FundClassCode, 
    ISIN, 
    IsCurrent, 
    ManagementFeesRate, 
    MIN(SCD_Start_Date) AS StartDate, 
    MAX(SCD_End_Date) AS EndDate 
  FROM 
    edw.fund_class_history 
  WHERE 
    ISIN IN (
      SELECT 
        ISIN 
      FROM 
        edw.fund_class_history 
      GROUP BY 
        ISIN 
      HAVING 
        Count (DISTINCT ManagementFeesRate) > 1
    ) --OR Count (DISTINCT InvestmentFeesRate) > 1
  GROUP BY 
    FundClassCode, 
    FundClassName, 
    ISIN, 
    IsCurrent, 
    Fund_Launch_Date, 
    Fund_Close_Date, 
    SubsRedsFundClassCode, 
    SubsRedsFundClassName, 
    ClassCode, 
    FundCode, 
    FundName, 
    FundCategory, 
    FundLevelAssetClass, 
    HedgedUnitsYN, 
    HedgeFundGroupingClassCode, 
    HedgeFundGroupingClassName, 
    Class, 
    FundAssetClass, 
    UmbrellaCode, 
    UmbrellaName, 
    UmbrellaClassCode, 
    UmbrellaClassName, 
    Alpha_BMK_Target, 
    InvestmentFeesRate, 
    CashFeesRate, 
    ManagementFeesRate, 
    RiskFeesRate, 
    ServicingFeeRate, 
    Daily_Class_NAV_Variance_Threshold_Limit, 
    YTD_Class_NAV_Variance_Threshold_Limit, 
    Daily_H_v_UH_NAV_Variance_Threshold_Limit, 
    Inv_Fee_Code_AC, 
    Inv_Fee_Code_NS, 
    Cash_Fee_Code_AC, 
    Cash_Fee_Code_NS, 
    Man_Fee_Code_AC, 
    Man_Fee_Code_NS, 
    Per_Fee_Code_AC, 
    Per_Fee_Code_NS, 
    Risk_Fee_Code_AC, 
    Risk_Fee_Code_NS, 
    Servicing_Fee_Code_AC, 
    Servicing_Fee_Code_NS, 
    Fund_Management_Type, 
    RepresentativeFundClass_Status, 
    RepresentativeFundCode, 
    Hedged_Unhedged_FundCode, 
    Hedged_Unhedged_FundName
), 
maxStartDate as(
  select 
    mgtfeewaivers.*, 
    Sub_FundName, 
    max(startDate) as StartDater 
  from 
    mgtfeewaivers 
    left join med_edw.Product.MasterFundClassData md on md.ISIN = mgtfeewaivers.ISIN 
  where 
    StartDate in (
      select 
        max(startdate) 
      from 
        mgtfeewaivers 
      group by 
        ISIN
    ) 
  group by 
    FundClassCode, 
    mgtfeewaivers.ISIN, 
    [Management Fee], 
    Sub_FundName, 
    IsCurrent, 
    [ManagementFeesRate], 
    StartDate, 
    EndDate
), 
minStartDate as(
  select 
    mgtfeewaivers.*, 
    Sub_FundName, 
    min(startDate) as StartDater 
  from 
    mgtfeewaivers 
    left join med_edw.Product.MasterFundClassData md on md.ISIN = mgtfeewaivers.ISIN 
  where 
    StartDate in (
      select 
        min(startdate) 
      from 
        mgtfeewaivers 
      group by 
        ISIN
    ) 
  group by 
    FundClassCode, 
    mgtfeewaivers.ISIN, 
    [Management Fee], 
    Sub_FundName, 
    IsCurrent, 
    [ManagementFeesRate], 
    StartDate, 
    EndDate
), 
mgtwaived as(
  select 
    maxStartDate.ISIN, 
    maxStartDate.FundClassCode, 
    maxStartDate.Sub_FundName, 
    maxStartDate.ManagementFeesRate as CurrentMgtFee, 
    cast(
      cast(
        maxStartDate.StartDate as varchar(10)
      ) as date
    ) as LastChangeDate, 
    minStartDate.ManagementFeesRate as PreviousMgtFee, 
    minStartDate.StartDate as PreviousDatechange, 
    (
      maxStartDate.ManagementFeesRate - minStartDate.ManagementFeesRate
    ) as waiver 
  from 
    maxStartDate 
    left join minStartDate on minStartDate.ISIN = maxStartDate.ISIN
),
cashmgtfeewaivers as(
  SELECT 
    FundClassCode, 
    ISIN, 
    IsCurrent, 
    CashFeesRate, 
    MIN(SCD_Start_Date) AS StartDate, 
    MAX(SCD_End_Date) AS EndDate 
  FROM 
    edw.fund_class_history 
  WHERE 
    ISIN IN (
      SELECT 
        ISIN 
      FROM 
        edw.fund_class_history 
      GROUP BY 
        ISIN 
      HAVING 
        Count (DISTINCT CashFeesRate) > 1
    ) --OR Count (DISTINCT InvestmentFeesRate) > 1
  GROUP BY 
    FundClassCode, 
    FundClassName, 
    ISIN, 
    IsCurrent, 
    Fund_Launch_Date, 
    Fund_Close_Date, 
    SubsRedsFundClassCode, 
    SubsRedsFundClassName, 
    ClassCode, 
    FundCode, 
    FundName, 
    FundCategory, 
    FundLevelAssetClass, 
    HedgedUnitsYN, 
    HedgeFundGroupingClassCode, 
    HedgeFundGroupingClassName, 
    Class, 
    FundAssetClass, 
    UmbrellaCode, 
    UmbrellaName, 
    UmbrellaClassCode, 
    UmbrellaClassName, 
    Alpha_BMK_Target, 
    InvestmentFeesRate, 
    CashFeesRate, 
    ManagementFeesRate, 
    RiskFeesRate, 
    ServicingFeeRate, 
    Daily_Class_NAV_Variance_Threshold_Limit, 
    YTD_Class_NAV_Variance_Threshold_Limit, 
    Daily_H_v_UH_NAV_Variance_Threshold_Limit, 
    Inv_Fee_Code_AC, 
    Inv_Fee_Code_NS, 
    Cash_Fee_Code_AC, 
    Cash_Fee_Code_NS, 
    Man_Fee_Code_AC, 
    Man_Fee_Code_NS, 
    Per_Fee_Code_AC, 
    Per_Fee_Code_NS, 
    Risk_Fee_Code_AC, 
    Risk_Fee_Code_NS, 
    Servicing_Fee_Code_AC, 
    Servicing_Fee_Code_NS, 
    Fund_Management_Type, 
    RepresentativeFundClass_Status, 
    RepresentativeFundCode, 
    Hedged_Unhedged_FundCode, 
    Hedged_Unhedged_FundName
), 
cashmaxStartDate as(
  select 
    cashmgtfeewaivers.*, 
    Sub_FundName, 
    max(startDate) as StartDater 
  from 
    cashmgtfeewaivers 
    left join med_edw.Product.MasterFundClassData md on md.ISIN = cashmgtfeewaivers.ISIN 
  where 
    StartDate in (
      select 
        max(startdate) 
      from 
        cashmgtfeewaivers 
      group by 
        ISIN
    ) 
  group by 
    FundClassCode, 
    cashmgtfeewaivers.ISIN, 
    CashFeesRate, 
    Sub_FundName, 
    IsCurrent, 
    CashFeesRate, 
    StartDate, 
    EndDate
), 
cashminStartDate as(
  select 
    cashmgtfeewaivers.*, 
    Sub_FundName, 
    min(startDate) as StartDater 
  from 
    cashmgtfeewaivers 
    left join med_edw.Product.MasterFundClassData md on md.ISIN = cashmgtfeewaivers.ISIN 
  where 
    StartDate in (
      select 
        min(startdate) 
      from 
        cashmgtfeewaivers 
      group by 
        ISIN
    ) 
  group by 
    FundClassCode, 
    cashmgtfeewaivers.ISIN, 
    CashFeesRate, 
    Sub_FundName, 
    IsCurrent, 
    CashFeesRate, 
    StartDate, 
    EndDate
), 
cashmgtwaived as(
  select 
    cashmaxStartDate.ISIN, 
    cashmaxStartDate.FundClassCode, 
    cashmaxStartDate.Sub_FundName, 
    cashmaxStartDate.CashFeesRate as CurrentcashMgtFee, 
    cast(
      cast(
        cashmaxStartDate.StartDate as varchar(10)
      ) as date
    ) as LastChangeDate, 
    c.CashFeesRate as PreviouscashMgtFee, 
    c.StartDate as PreviousDatechange, 
    (
      cashmaxStartDate.CashFeesRate - c.CashFeesRate
    ) as cashwaiver 
  from 
    cashmaxStartDate 
    left join     cashminStartDate c
 on c.ISIN = cashmaxStartDate.ISIN
  where 
    (
     cashmaxStartDate.CashFeesRate - c.CashFeesRate
    ) is not null
)
,
invmgtfeewaivers as(
  SELECT 
    FundClassCode, 
    ISIN, 
    IsCurrent, 
    InvestmentFeesRate, 
    MIN(SCD_Start_Date) AS StartDate, 
    MAX(SCD_End_Date) AS EndDate 
  FROM 
    edw.fund_class_history 
  WHERE 
    ISIN IN (
      SELECT 
        ISIN 
      FROM 
        edw.fund_class_history 
      GROUP BY 
        ISIN 
      HAVING 
        Count (DISTINCT InvestmentFeesRate) > 1
    ) 
  GROUP BY 
    FundClassCode, 
    FundClassName, 
    ISIN, 
    IsCurrent, 
    Fund_Launch_Date, 
    Fund_Close_Date, 
    SubsRedsFundClassCode, 
    SubsRedsFundClassName, 
    ClassCode, 
    FundCode, 
    FundName, 
    FundCategory, 
    FundLevelAssetClass, 
    HedgedUnitsYN, 
    HedgeFundGroupingClassCode, 
    HedgeFundGroupingClassName, 
    Class, 
    FundAssetClass, 
    UmbrellaCode, 
    UmbrellaName, 
    UmbrellaClassCode, 
    UmbrellaClassName, 
    Alpha_BMK_Target, 
    InvestmentFeesRate, 
    CashFeesRate, 
    ManagementFeesRate, 
    RiskFeesRate, 
    ServicingFeeRate, 
    Daily_Class_NAV_Variance_Threshold_Limit, 
    YTD_Class_NAV_Variance_Threshold_Limit, 
    Daily_H_v_UH_NAV_Variance_Threshold_Limit, 
    Inv_Fee_Code_AC, 
    Inv_Fee_Code_NS, 
    Cash_Fee_Code_AC, 
    Cash_Fee_Code_NS, 
    Man_Fee_Code_AC, 
    Man_Fee_Code_NS, 
    Per_Fee_Code_AC, 
    Per_Fee_Code_NS, 
    Risk_Fee_Code_AC, 
    Risk_Fee_Code_NS, 
    Servicing_Fee_Code_AC, 
    Servicing_Fee_Code_NS, 
    Fund_Management_Type, 
    RepresentativeFundClass_Status, 
    RepresentativeFundCode, 
    Hedged_Unhedged_FundCode, 
    Hedged_Unhedged_FundName
), 
maxStartDatee as(
  select 
    invmgtfeewaivers.*, 
    Sub_FundName, 
    max(startDate) as StartDater 
  from 
    invmgtfeewaivers 
    left join med_edw.Product.MasterFundClassData md on md.ISIN = invmgtfeewaivers.ISIN 
  where 
    StartDate in (
      select 
        max(startdate) 
      from 
        invmgtfeewaivers 
      group by 
        ISIN
    ) 
  group by 
    FundClassCode, 
    invmgtfeewaivers.ISIN,  
    Sub_FundName, 
    IsCurrent, 
    InvestmentFeesRate, 
    StartDate, 
    EndDate
), 
minStartDatee as(
  select 
    invmgtfeewaivers.*, 
    Sub_FundName, 
    min(startDate) as StartDater 
  from 
    invmgtfeewaivers 
    left join med_edw.Product.MasterFundClassData md on md.ISIN = invmgtfeewaivers.ISIN 
  where 
    StartDate in (
      select 
        min(startdate) 
      from 
        invmgtfeewaivers 
      group by 
        ISIN
    ) 
  group by 
    FundClassCode, 
    invmgtfeewaivers.ISIN, 
    Sub_FundName, 
    IsCurrent, 
    InvestmentFeesRate, 
    StartDate, 
    EndDate
), 
invwaivers as(
  select 
    maxStartDatee.ISIN, 
    maxStartDatee.FundClassCode, 
    maxStartDatee.Sub_FundName, 
    maxStartDatee.InvestmentFeesRate as CurrentinvMgtFee, 
    cast(
      cast(
        maxStartDatee.StartDate as varchar(10)
      ) as date
    ) as LastChangeDate, 
    minStartDatee.InvestmentFeesRate as PreviousinvMgtFee, 
    minStartDatee.StartDate as PreviousDatechange, 
    (
      maxStartDatee.InvestmentFeesRate - minStartDatee.InvestmentFeesRate
    ) as waiver 
  from 
    maxStartDatee 
    left join minStartDatee on minStartDatee.ISIN = maxStartDatee.ISIN 
  where 
    (
      maxStartDatee.InvestmentFeesRate - minStartDatee.InvestmentFeesRate
    ) is not null
), 
final as(
  select 
    mgtwaived.*, 
    invwaivers.ISIN as ISINN, 
    invwaivers.FundClassCode as Fund, 
    invwaivers.Sub_FundName as Subfund, 
    CurrentinvMgtFee, 
    invwaivers.LastChangeDate as LastInvChangeDate, 
    PreviousinvMgtFee, 
    invwaivers.PreviousDatechange as PreviousInvChangeDate, 
    invwaivers.waiver as InvWaiver , 
	cashmgtwaived.CurrentcashMgtFee, 
	cashwaiver,
	cashmgtwaived.LastChangeDate as LastCashchangeDate
  from 
    mgtwaived Full 
    outer join invwaivers on invwaivers.ISIN = mgtwaived.ISIN FULL
	outer join cashmgtwaived on cashmgtwaived.ISIN = mgtwaived.ISIN
) 
select 
  CASE WHEN ISIN IS NULL THEN ISINN ELSE ISIN end as ISIN, 
  CASE WHEN FundClassCode IS NULL THEN Fund ELSE FundClassCode end as FundCode, 
  CASE WHEN Sub_FundName IS NULL THEN Subfund else Sub_FundName end as SubfundName, 
  CurrentMgtFee, 
  LastChangeDate, 
  PreviousMgtFee, 
  PreviousDatechange, 
  CurrentinvMgtFee, 
  LastInvChangeDate, 
  PreviousinvMgtFee, 
  PreviousInvChangeDate ,
  waiver as MgtFeeWaiver, 
 CurrentcashMgtFee, cashwaiver, LastCashchangeDate ,
  InvWaiver
from 
  final