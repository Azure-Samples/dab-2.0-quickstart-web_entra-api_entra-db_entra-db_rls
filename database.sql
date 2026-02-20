IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TodoDb')
    CREATE DATABASE [TodoDb];
GO

USE [TodoDb];
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Todos')
BEGIN
    CREATE TABLE [dbo].[Todos] (
        [TodoId]    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Title]     NVARCHAR(200) NOT NULL,
        [DueDate]   DATE NOT NULL,
        [Owner]     NVARCHAR(128) NOT NULL DEFAULT 'anonymous',
        [Completed] BIT NOT NULL DEFAULT 0
    );

    INSERT INTO [dbo].[Todos] ([Title], [DueDate], [Owner], [Completed])
    VALUES
        (N'Learn Data API Builder', DATEADD(DAY, 7, GETDATE()), 'anonymous', 0),
        (N'Deploy to Azure', DATEADD(DAY, 14, GETDATE()), 'anonymous', 0),
        (N'Build something awesome', DATEADD(DAY, 30, GETDATE()), 'anonymous', 0);
END;

-- Row-Level Security: restrict access to rows where Owner matches the database user
IF NOT EXISTS (SELECT * FROM sys.objects WHERE name = 'UserFilterPredicate' AND type = 'IF')
BEGIN
    EXEC('
        CREATE FUNCTION dbo.UserFilterPredicate(@OwnerId sysname)
        RETURNS TABLE WITH SCHEMABINDING AS 
        RETURN SELECT 1 AS IsVisible WHERE @OwnerId = SUSER_SNAME();
    ');
END;

IF NOT EXISTS (SELECT * FROM sys.security_policies WHERE name = 'UserFilterPolicy')
BEGIN
    EXEC('
        CREATE SECURITY POLICY UserFilterPolicy
        ADD FILTER PREDICATE dbo.UserFilterPredicate(Owner) ON dbo.Todos
        WITH (STATE = ON);
    ');
END;
