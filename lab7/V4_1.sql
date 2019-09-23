/* ������� �������� ����� [BusinessEntityID], [Name], [AccountNumber]
�� ������� [Purchasing].[Vendor] � ���� xml, ������������ � ����������.
������� �������� ���������, ������������ �������, 
����������� �� xml ���������� ��������������� ����. 
������� ��� ��������� ��� ����������� �� ������ ���� ����������.*/
IF OBJECT_ID('dbo.vendorToXML', 'P') IS NOT NULL
    DROP PROCEDURE dbo.vendorToXML;
GO

CREATE PROCEDURE [dbo].vendorToXML @xmlForVendors XML
AS
BEGIN
    SELECT [BusinessEntityID] = Node.Data.value('(ID)[1]', 'INT')
         , [Name]             = Node.Data.value('(Name)[1]', 'NAME')
         , [AccountNumber]    = Node.Data.value('(AccountNumber)[1]', 'AccountNumber')
    FROM @xmlForVendors.nodes('/Vendors/Vendor') Node(Data)
END;

DECLARE @vendorsFromXML XML;
SELECT @vendorsFromXML = (
    SELECT [BusinessEntityID] AS ID, [Name], [AccountNumber]
    FROM [Purchasing].[Vendor]
    FOR XML RAW ('Vendor'), TYPE, ELEMENTS, ROOT ('Vendors')
);

    EXEC [dbo].vendorToXML @vendorsFromXML;
GO