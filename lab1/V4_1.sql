CREATE DATABASE YahorStsefanovich;
USE YahorStsefanovich;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders
(
    OrderNum INT NULL
);
GO

BACKUP DATABASE YahorStsefanovich TO "backup";
GO

USE master;
GO

DROP DATABASE YahorStsefanovich;
GO

RESTORE DATABASE YahorStsefanovich FROM "backup";
GO

