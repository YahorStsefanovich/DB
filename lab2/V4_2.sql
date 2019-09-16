/* a) создайте таблицу dbo.StateProvince с такой же структурой как Person.StateProvince,
 кроме поля uniqueidentifier, не включая индексы, ограничения и триггеры;*/
 CREATE TABLE dbo.StateProvince(
    StateProvinceID [int] IDENTITY(1,1) NOT NULL,
    StateProvinceCode [nchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CountryRegionCode [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    IsOnlyStateProvinceFlag [dbo].[Flag] NOT NULL,
    Name [dbo].[Name] NOT NULL,
    TerritoryID [int] NOT NULL,
    ModifiedDate [datetime] NOT NULL
) ON [PRIMARY];
GO 

/* b) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение UNIQUE для поля Name;*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT NameContraint UNIQUE(Name);
 
/* c) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение для поля CountryRegionCode,
 запрещающее заполнение этого поля цифрами;*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT CountryRegionCodePermitDigit
	CHECK (CountryRegionCode NOT LIKE '%^.*[0-9].*$%');

/*d) используя инструкцию ALTER TABLE, создайте для таблицы dbo.StateProvince ограничение
  DEFAULT для поля ModifiedDate, задайте значение по умолчанию текущую дату и время;*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT DefaultModifiedDate DEFAULT GetDate() FOR ModifiedDate;

/* e) заполните новую таблицу данными из Person.StateProvince. 
  Выберите для вставки только те данные, где имя штата/государства совпадает с именем страны/региона в таблице CountryRegion;*/
INSERT INTO dbo.StateProvince
	SELECT 
		SP.StateProvinceID,
		SP.StateProvinceCode,
		SP.CountryRegionCode,
		SP.IsOnlyStateProvinceFlag,
		SP.Name,
		SP.TerritoryID,
		SP.ModifiedDate
	FROM Person.StateProvince AS SP 
		JOIN Person.CountryRegion AS CR ON SP.CountryRegionCode=CR.CountryRegionCode
			WHERE SP.Name=CR.Name;


/*f) удалите поле IsOnlyStateProvinceFlag, а вместо него создайте новое CountryNum типа int допускающее null значения.*/


