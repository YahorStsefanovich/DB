/*a) выполните код, созданный во втором задании второй лабораторной работы. 
 ƒобавьте в таблицу dbo.StateProvince пол€ SalesYTD MONEY и SumSales MONEY.  
 “акже создайте в таблице вычисл€емое поле SalesPercent,  
 вычисл€ющее процентное выражение значени€ в поле SumSales от значени€ в поле SalesYTD.*/
ALTER TABLE dbo.stateprovince
    ADD salesytd MONEY;

ALTER TABLE dbo.stateprovince
    ADD sumsales MONEY;

ALTER TABLE dbo.stateprovince
    ADD salespercent AS Round(salesytd / sumsales * 100, 0) persisted;

/*b) создайте временную таблицу #StateProvince, с первичным ключом по полю StateProvinceID. 
 ¬ременна€ таблица должна включать все пол€ таблицы dbo.StateProvince за исключением пол€ SalesPercent.*/
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

/*c) заполните временную таблицу данными из dbo.StateProvince.  
ѕоле SalesYTD заполните значени€ми из таблицы Sales.SalesTerritory.  
ѕосчитайте сумму продаж (SalesYTD) дл€ каждой территории (TerritoryID)  
в таблице Sales.SalesPerson и заполните этими значени€ми поле SumSales.  
ѕодсчет суммы продаж осуществите в Common Table Expression (CTE).*/
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

/*d) удалите из таблицы dbo.StateProvince одну строку (где StateProvinceID = 5)*/
DELETE
FROM dbo.stateprovince
WHERE stateprovinceid = 5;

/*e) напишите Merge выражение, использующее dbo.StateProvince как target, 
а временную таблицу как source. ƒл€ св€зи target и source используйте StateProvinceID. 
ќбновите пол€ SalesYTD и SumSales, если запись присутствует в source и target. 
≈сли строка присутствует во временной таблице, но не существует в target, 
добавьте строку в dbo.StateProvince. ≈сли в dbo.StateProvince присутствует така€ строка, 
которой не существует во временной таблице, удалите строку из dbo.StateProvince.*/
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