/* a) �������� ������� dbo.StateProvince � ����� �� ���������� ��� Person.StateProvince, 
 ����� ���� uniqueidentifier, �� ������� �������, ����������� � ��������;*/
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

/* b) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� UNIQUE ��� ���� Name;*/
ALTER TABLE dbo.stateprovince
    ADD CONSTRAINT namecontraint UNIQUE (NAME);

/* c) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� ��� ���� CountryRegionCode,
 ����������� ���������� ����� ���� �������;*/
ALTER TABLE dbo.stateprovince
    ADD CONSTRAINT countryregioncodepermitdigit CHECK ( countryregioncode NOT LIKE
                                                        '%^.*[0-9].*$%' );

/*d) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.StateProvince ����������� 
  DEFAULT ��� ���� ModifiedDate, ������� �������� �� ��������� ������� ���� � �����;*/
ALTER TABLE dbo.stateprovince
    ADD CONSTRAINT defaultmodifieddate DEFAULT Getdate() FOR modifieddate;

/* e) ��������� ����� ������� ������� �� Person.StateProvince.  
  �������� ��� ������� ������ �� ������, ��� ��� �����/����������� ��������� � ������ ������/������� � ������� CountryRegion;*/
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

/*f) ������� ���� IsOnlyStateProvinceFlag, � ������ ���� �������� ����� CountryNum ���� int ����������� null ��������.*/
ALTER TABLE dbo.stateprovince
    DROP COLUMN isonlystateprovinceflag;

ALTER TABLE dbo.stateprovince
    ADD countrynum INT NULL;