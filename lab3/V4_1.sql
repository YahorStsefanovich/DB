/*a) добавьте в таблицу dbo.StateProvince поле CountryRegionName типа nvarchar(50);*/
ALTER TABLE dbo.stateprovince
    ADD countryregionname NVARCHAR(50);
go

/*b) объявите табличную переменную с такой же структурой как dbo.StateProvince 
и заполните ее данными из dbo.StateProvince. 
Заполните поле CountryRegionName данными из Person.CountryRegion поля Name;*/
DECLARE @STATEPROVINCEVAR TABLE
                          (
                              stateprovinceid   [INT]                                              NOT NULL,
                              stateprovincecode [NCHAR](3) COLLATE sql_latin1_general_cp1_ci_as    NOT NULL,
                              countryregioncode [NVARCHAR](3) COLLATE sql_latin1_general_cp1_ci_as NOT NULL,
                              NAME              [dbo].[NAME]                                       NOT NULL,
                              territoryid       [INT]                                              NOT NULL,
                              modifieddate      [DATETIME]                                         NOT NULL,
                              countryregionname [NVARCHAR](50)
                          );
INSERT INTO @StateProvinceVar
SELECT SP.stateprovinceid,
       SP.stateprovincecode,
       SP.countryregioncode,
       SP.NAME,
       SP.territoryid,
       SP.modifieddate,
       CR.NAME AS CountryRegionName
FROM [dbo].[stateprovince] AS SP
         JOIN person.countryregion AS CR
              ON SP.countryregioncode = CR.countryregioncode;

/*c) обновите поле CountryRegionName в dbo.StateProvince данными из табличной переменной;*/
UPDATE dbo.stateprovince
SET countryregionname = V.countryregionname
FROM @StateProvinceVar AS V
WHERE stateprovince.stateprovinceid = V.stateprovinceid;

/*d) удалите штаты из dbo.StateProvince, которые отсутствуют в таблице Person.Address;*/DELETE
                                                                                        FROM dbo.stateprovince
                                                                                        WHERE stateprovinceid NOT IN
                                                                                              (
                                                                                                  SELECT stateprovinceid
                                                                                                  FROM person.address
                                                                                              );

/*e) удалите поле CountryRegionName из таблицы, удалите все созданные ограничения и значения по умолчанию.*/
ALTER TABLE dbo.stateprovince
    DROP CONSTRAINT countryregioncodepermitdigit,
        defaultmodifieddate,
        COLUMN countryregionname;

/*f) удалите таблицу dbo.StateProvince.*/
DROP TABLE dbo.stateprovince;