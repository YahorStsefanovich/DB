/*a) Создайте представление VIEW, отображающее данные из таблиц Production.ProductModel,
 Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription.
 Сделайте невозможным просмотр исходного кода представления. 
 Создайте уникальный кластерный индекс в представлении по полям ProductModelID,CultureID.*/
CREATE VIEW dbo.ProductModelClusterView
    WITH ENCRYPTION, SCHEMABINDING
AS
SELECT C.CultureID,
       C.Name             AS C_Name,
       C.ModifiedDate     AS C_ModifiedDate,
       PM.CatalogDescription,
       PM.Instructions,
       PM.Name            AS PM_Name,
       PM.ProductModelID,
       PM.ModifiedDate    AS PM_ModifiedDate,
       PD.Description,
       PD.ProductDescriptionID,
       PD.rowguid,
       PD.ModifiedDate    AS PD_ModifiedDate,
       PMPDC.ModifiedDate AS PMPDC_ModifiedDate
FROM Production.ProductModel AS PM
         JOIN Production.ProductModelProductDescriptionCulture AS PMPDC
              ON PM.ProductModelID = PMPDC.ProductModelID
         JOIN Production.Culture AS C
              ON C.CultureID = PMPDC.CultureID
         JOIN Production.ProductDescription AS PD
              ON PD.ProductDescriptionID = PMPDC.ProductDescriptionID;
GO

CREATE UNIQUE CLUSTERED INDEX PRODUCT_MODEL_INDX
    ON dbo.ProductModelClusterView (ProductModelID, CultureID);
GO


/*b) Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE.
 Каждый триггер должен выполнять соответствующие операции в таблицах Production.ProductModel,
 Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription.
 Обновление не должно происходить в таблице Production.ProductModelProductDescriptionCulture. 
 Удаление строк из таблиц Production.ProductModel, Production.Culture и
 Production.ProductDescription производите только в том случае, если удаляемые 
 строки больше не ссылаются на Production.ProductModelProductDescriptionCulture.*/
CREATE TRIGGER OnInsertIntoProductModelVIew
    ON dbo.ProductModelClusterView
    INSTEAD OF
        INSERT AS
BEGIN
    INSERT INTO Production.Culture(CultureID, Name)
    SELECT CultureID, C_Name
    FROM inserted;
    INSERT INTO Production.ProductModel(Name)
    SELECT PM_Name
    FROM inserted;
-- Get Next ID From Production.ProductDescription
    INSERT INTO Production.ProductDescription([Description])
    SELECT [Description]
    FROM inserted;
-- Get Generated Ids from tables
    INSERT INTO Production.ProductModelProductDescriptionCulture(CultureID, ProductModelID, ProductDescriptionID)
    VALUES ((SELECT CultureID FROM inserted),
            IDENT_CURRENT('Production.ProductModel'),
            IDENT_CURRENT('Production.ProductDescription'));
END;
GO

CREATE TRIGGER OnUpdateProductModelVIew
    ON dbo.ProductModelClusterView
    INSTEAD OF
        UPDAtE
    AS
BEGIN
    UPDATE Production.Culture
    SET Name         = (SELECT C_Name FROM inserted),
        ModifiedDate = GETDATE()
    WHERE Name = (SELECT C_Name FROM deleted);
    UPDATE Production.ProductModel
    SET Name         = (SELECT PM_Name FROM inserted),
        ModifiedDate = GETDATE()
    WHERE Name = (SELECT PM_Name FROM deleted)
    UPDATE Production.ProductDescription
    SET [Description] = (SELECT [Description] FROM inserted),
        ModifiedDate  = GETDATE()
    WHERE [Description] = (SELECT [Description] FROM deleted)
END;
GO

CREATE TRIGGER OnDeleteFromProductModelVIew
    ON dbo.ProductModelClusterView
    INSTEAD OF
        DELETE
    AS
BEGIN
    -- Get Id's of deleted entities
    DECLARE @CultureID NCHAR(6);
    DECLARE @ProductDescriptionID [int];
    DECLARE @ProductModelID [int];
    SELECT @CultureID = CultureID,
           @ProductDescriptionID = ProductDescriptionID,
           @ProductModelID = ProductModelID
    FROM deleted;

--
    Delete Culture
    FROM ProductModelProductDescriptionCulture
    IF @CultureID NOT IN (SELECT CultureID FROM Production.ProductModelProductDescriptionCulture)
        BEGIN
            DELETE
            FROM Production.Culture
            WHERE CultureID = @CultureID;
        END;

--
    Delete ProductDescription
    FROM ProductModelProductDescriptionCulture
    IF @ProductDescriptionID NOT IN
       (SELECT ProductDescriptionID FROM Production.ProductModelProductDescriptionCulture)
        BEGIN
            DELETE
            FROM Production.ProductDescription
            WHERE ProductDescriptionID = @ProductDescriptionID;
        END;

--
    Delete ProductModel
    FROM ProductModelProductDescriptionCulture
    IF @ProductModelID NOT IN (SELECT ProductModelID FROM Production.ProductModelProductDescriptionCulture)
        BEGIN
            DELETE
            FROM Production.ProductModel
            WHERE ProductModelID = @ProductModelID;
        END;
END;
GO

/*c) Вставьте новую строку в представление, указав новые данные для ProductModel,
 Culture и ProductDescription. Триггер должен добавить новые строки в таблицы Production.ProductModel,
 Production.ProductModelProductDescriptionCulture, Production.Culture и Production.ProductDescription.
 Обновите вставленные строки через представление. Удалите строки.*/
INSERT INTO dbo.ProductModelClusterView(CultureID, C_Name, PM_Name, [ Description])
VALUES ('EPL', 'English Prenier Ligue', 'Foolball', 'We are going to the Wembely');

UPDATE dbo.ProductModelClusterView
SET C_Name        = 'BundesLigue',
    PM_Name       = 'BasketBall',
    [Description] = 'Super Deutschland'
WHERE CultureID = 'EPL'
  AND ProductModelID = IDENT_CURRENT('Production.ProductModel')
  AND ProductDescriptionID = IDENT_CURRENT('Production.ProductDescription');

DELETE
FROM dbo.ProductModelClusterView
WHERE CultureID = 'EPL'
  AND ProductModelID = IDENT_CURRENT('Production.ProductModel')
  AND ProductDescriptionID = IDENT_CURRENT('Production.ProductDescription');