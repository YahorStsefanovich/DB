/*a) выполните код, созданный во втором задании второй лабораторной работы. 
 Добавьте в таблицу dbo.StateProvince поля SalesYTD MONEY и SumSales MONEY.  
 Также создайте в таблице вычисляемое поле SalesPercent,  
 вычисляющее процентное выражение значения в поле SumSales от значения в поле SalesYTD.*/
ALTER TABLE dbo.stateprovince
    ADD salesytd MONEY;

ALTER TABLE dbo.stateprovince
    ADD sumsales MONEY;

ALTER TABLE dbo.stateprovince
    ADD salespercent AS Round(salesytd / sumsales * 100, 0) persisted;

/*b) создайте временную таблицу #StateProvince, с первичным ключом по полю StateProvinceID. 
 Временная таблица должна включать все поля таблицы dbo.StateProvince за исключением поля SalesPercent.*/
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
Поле SalesYTD заполните значениями из таблицы Sales.SalesTerritory.  
Посчитайте сумму продаж (SalesYTD) для каждой территории (TerritoryID)  
в таблице Sales.SalesPerson и заполните этими значениями поле SumSales.  
Подсчет суммы продаж осуществите в Common Table Expression (CTE).*/
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
а временную таблицу как source. Для связи target и source используйте StateProvinceID. 
Обновите поля SalesYTD и SumSales, если запись присутствует в source и target. 
Если строка присутствует во временной таблице, но не существует в target, 
добавьте строку в dbo.StateProvince. Если в dbo.StateProvince присутствует такая строка, 
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