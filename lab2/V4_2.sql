/* a) создайте таблицу dbo.StateProvince с такой же структурой как Person.StateProvince, 
 кроме поля uniqueidentifier, не включая индексы, ограничения и триггеры;*/
CREATE TABLE dbo.stateprovince
(
    stateprovinceid [INT] IDENTITY(1, 1) NOT NULL,
    stateprovincecode [NCHAR](3) COLLATE sql_latin1_general_cp1_ci_as NOT
        NULL,
    countryregioncode [NVARCHAR](3) COLLATE sql_latin1_general_cp1_ci_as
        NOT NULL,
    isonlystateprovinceflag [dbo].[FLAG] NOT NULL,
    NAME [dbo].[NAME] NOT NULL,
    territoryid [INT] NOT NULL,
    modifieddate [DATETIME] NOT NULL
) ON [PRIMARY];

go 

/* b) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение UNIQUE для поля Name;*/
ALTER TABLE dbo.stateprovince
    ADD CONSTRAINT namecontraint UNIQUE (NAME);

/* c) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение для поля CountryRegionCode,
 запрещающее заполнение этого поля цифрами;*/
ALTER TABLE dbo.stateprovince
    ADD CONSTRAINT countryregioncodepermitdigit CHECK ( countryregioncode NOT LIKE
                                                        '%^.*[0-9].*$%' );

/*d) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение 
  DEFAULT для поля ModifiedDate, задайте значение по умолчанию текущую дату и время;*/
ALTER TABLE dbo.stateprovince
    ADD CONSTRAINT defaultmodifieddate DEFAULT Getdate() FOR modifieddate;

/* e) заполните новую таблицу данными из Person.StateProvince.  
  Выберите для вставки только те данные, где имя штата/государства совпадает с именем страны/региона в таблице CountryRegion;*/
INSERT INTO dbo.stateprovince
SELECT SP.stateprovincecode,
       SP.countryregioncode,
       SP.isonlystateprovinceflag,
       SP.NAME,
       SP.territoryid,
       SP.modifieddate
FROM person.stateprovince AS SP
         JOIN person.countryregion AS CR
              ON SP.countryregioncode = CR.countryregioncode
WHERE SP.NAME = CR.NAME;

/*f) удалите поле IsOnlyStateProvinceFlag, а вместо него создайте новое CountryNum типа int допускающее null значения.*/
ALTER TABLE dbo.stateprovince
    DROP COLUMN isonlystateprovinceflag;

ALTER TABLE dbo.stateprovince
    ADD countrynum INT NULL;