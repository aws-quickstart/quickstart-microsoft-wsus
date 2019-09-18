USE [SUSDB]
GO

CREATE NONCLUSTERED INDEX [nclLocalizedPropertyID] ON [dbo].[tbLocalizedPropertyForRevision]
(
     [LocalizedPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


-- Create custom index in tbRevisionSupersedesUpdate
CREATE NONCLUSTERED INDEX [nclSupercededUpdateID] ON [dbo].[tbRevisionSupersedesUpdate] 
( 
     [SupersededUpdateID] ASC 
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

DECLARE @DatabaseName SYSNAME   = DB_NAME()
DECLARE @TableName VARCHAR(256) 
--DECLARE @FILLFACTOR INT = 85
DECLARE @SQL NVARCHAR(MAX) =
 
 'DECLARE curAllIndex CURSOR FOR SELECT TABLE_SCHEMA +
 ''.'' + TABLE_NAME AS TABLENAME  
 FROM ' + @DatabaseName + '.INFORMATION_SCHEMA.TABLES WHERE
 TABLE_TYPE = ''BASE TABLE'''  
 
BEGIN 
  EXEC sp_executeSQL @SQL  
  OPEN curAllIndex
  FETCH NEXT FROM curAllIndex INTO @TableName  
  WHILE (@@FETCH_STATUS = 0) 
  BEGIN  
       /* -- For using FillFactor setting. 
	   SET @DynamicSQL = 'ALTER INDEX ALL ON ' + @TableName +  
	   ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR,@FILLFACTOR) + ')' 
	   */
	   SET @SQL = 'ALTER INDEX ALL ON ' + @TableName +  
	   ' REBUILD ' 
       PRINT @SQL       
       EXEC sp_executeSQL @SQL 
       FETCH NEXT FROM curAllIndex INTO @TableName  
   END   
   CLOSE curAllIndex  
   DEALLOCATE curAllIndex 
END