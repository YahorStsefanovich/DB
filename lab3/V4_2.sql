/*a) ��������� ���, ��������� �� ������ ������� ������ ������������ ������. 
 �������� � ������� dbo.StateProvince ���� SalesYTD MONEY � SumSales MONEY.  
 ����� �������� � ������� ����������� ���� SalesPercent,  
 ����������� ���������� ��������� �������� � ���� SumSales �� �������� � ���� SalesYTD.*/
ALTER TABLE dbo.stateprovince
    ADD salesytd MONEY;

ALTER TABLE dbo.stateprovince
    ADD sumsales MONEY;

ALTER TABLE dbo.stateprovince
    ADD salespercent AS Round(salesytd / sumsales * 100, 0) persisted;

/*b) �������� ��������� ������� #StateProvince, � ��������� ������ �� ���� StateProvinceID. 
 ��������� ������� ������ �������� ��� ���� ������� dbo.StateProvince �� ����������� ���� SalesPercent.*/
CREATE TABLE #stateprovince 
(
    stateprovinceid [INT] NOT NULL,
    stateprovincecode [NCHAR](3) COLLATE sql_latin1_general_cp1_ci_as NOT NULL,
    countryregioncode [NVARCHAR](3) COLLATE sql_latin1_general_cp1_ci_as NOT
        NULL,
    NAME VARCHAR(50) NOT NULL,
    territoryid [INT] NOT NULL,
    modifieddate [DATETIME] NOT NULL,
    countrynum [INT],
    salesytd MONEY,
    sumsales MONEY
);

/*c) ��������� ��������� ������� ������� �� dbo.StateProvince.  
���� SalesYTD ��������� ���������� �� ������� Sales.SalesTerritory.  
���������� ����� ������ (SalesYTD) ��� ������ ���������� (TerritoryID)  
� ������� Sales.SalesPerson � ��������� ����� ���������� ���� SumSales.  
������� ����� ������ ����������� � Common Table Expression (CTE).*/
WITH sumsales_cte
         AS (SELECT ST.territoryid,
                    Sum(ST.saleslastyear) AS SumSales
             FROM dbo.stateprovince AS SP
                      JOIN sales.salesterritory AS ST
                           ON SP.territoryid = ST.territoryid
             GROUP BY ST.territoryid)
INSERT INTO #stateprovince 
    SELECT SP.stateprovinceid,
    SP.stateprovincecode,
    SP.countryregioncode,
    SP.NAME,
    SP.territoryid,
    SP.modifieddate,
    SP.countrynum,
    ST.saleslastyear,
    SS.sumsales
FROM [dbo].[stateprovince] AS SP
    JOIN sales.salesterritory AS ST
ON SP.territoryid = ST.territoryid
    JOIN sumsales_cte AS SS
    ON SS.territoryid = SP.territoryid;

/*d) ������� �� ������� dbo.StateProvince ���� ������ (��� StateProvinceID = 5)*/
DELETE
FROM dbo.stateprovince
WHERE stateprovinceid = 5;

/*e) �������� Merge ���������, ������������ dbo.StateProvince ��� target, 
� ��������� ������� ��� source. ��� ����� target � source ����������� StateProvinceID. 
�������� ���� SalesYTD � SumSales, ���� ������ ������������ � source � target. 
���� ������ ������������ �� ��������� �������, �� �� ���������� � target, 
�������� ������ � dbo.StateProvince. ���� � dbo.StateProvince ������������ ����� ������, 
������� �� ���������� �� ��������� �������, ������� ������ �� dbo.StateProvince.*/
MERGE dbo.stateprovince AS TARGET 
using #stateprovince AS SOURCE 
ON TARGET.stateprovinceid = source.stateprovinceid 
WHEN matched THEN
UPDATE SET TARGET.salesytd = SOURCE.salesytd,
    TARGET.sumsales = SOURCE.sumsales
    WHEN NOT matched THEN
INSERT VALUES (stateprovincecode,
               countryregioncode,
               NAME,
               territoryid,
               modifieddate,
               countrynum,
               salesytd,
               sumsales)
    WHEN NOT matched BY source THEN
DELETE;