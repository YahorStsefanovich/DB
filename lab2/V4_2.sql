/* a) �������� ������� dbo.StateProvince � ����� �� ���������� ��� Person.StateProvince,
 ����� ���� uniqueidentifier, �� ������� �������, ����������� � ��������;*/
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

/* b) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� UNIQUE ��� ���� Name;*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT NameContraint UNIQUE(Name);
 
/* c) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� ��� ���� CountryRegionCode,
 ����������� ���������� ����� ���� �������;*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT CountryRegionCodePermitDigit
	CHECK (CountryRegionCode NOT LIKE '%^.*[0-9].*$%');

/*d) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince �����������
  DEFAULT ��� ���� ModifiedDate, ������� �������� �� ��������� ������� ���� � �����;*/
ALTER TABLE dbo.StateProvince ADD CONSTRAINT DefaultModifiedDate DEFAULT GetDate() FOR ModifiedDate;

/* e) ��������� ����� ������� ������� �� Person.StateProvince. 
  �������� ��� ������� ������ �� ������, ��� ��� �����/����������� ��������� � ������ ������/������� � ������� CountryRegion;*/
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


/*f) ������� ���� IsOnlyStateProvinceFlag, � ������ ���� �������� ����� CountryNum ���� int ����������� null ��������.*/


