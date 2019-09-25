/* Вывести значения полей [BusinessEntityID], [Name], [AccountNumber]
из таблицы [Purchasing].[Vendor] в виде xml, сохраненного в переменную.
Создать хранимую процедуру, возвращающую таблицу, 
заполненную из xml переменной представленного вида. 
Вызвать эту процедуру для заполненной на первом шаге переменной.*/
IF OBJECT_ID('dbo.vendorToXML', 'P') IS NOT NULL
    DROP PROCEDURE dbo.vendorToXML;
GO

CREATE PROCEDURE [dbo].vendorToXML @xmlForVendors XML
AS
BEGIN
    IF object_id('tempdb.#resultTable') IS NULL
        BEGIN
            CREATE TABLE #resultTable
            (
                [BusinessEntityID] int,
                [Name]             nvarchar(50),
                [AccountNumber]    nvarchar(15)
            )
        END;

    INSERT #resultTable
    SELECT [BusinessEntityID] = Node.Data.value('(ID)[1]', 'INT')
         , [Name]             = Node.Data.value('(Name)[1]', 'NAME')
         , [AccountNumber]    = Node.Data.value('(AccountNumber)[1]', 'AccountNumber')
    FROM @xmlForVendors.nodes('/Vendors/Vendor') Node(Data)

    SELECT * FROM #resultTable;
END;

    IF OBJECT_ID('[dbo].getResultTable', 'P') IS NOT NULL
        DROP PROCEDURE getResultTable;
GO

CREATE PROCEDURE [dbo].getResultTable
AS
BEGIN
    DECLARE @vendorsFromXML XML;
    SELECT @vendorsFromXML = (
        SELECT [BusinessEntityID] AS ID, [Name], [AccountNumber]
        FROM [Purchasing].[Vendor]
        FOR XML RAW ('Vendor'), TYPE, ELEMENTS, ROOT ('Vendors')
    );
    EXEC [dbo].vendorToXML @vendorsFromXML;
END;
GO

EXEC getResultTable;
