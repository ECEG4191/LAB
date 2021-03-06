USE [Sakila]
GO
/****** Object:  UserDefinedFunction [dbo].[str2enum$film$rating]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[str2enum$film$rating] 
( 
   @setval nvarchar(max)
)
RETURNS tinyint
AS 
   BEGIN
      RETURN 
         CASE @setval
            WHEN 'G' THEN 1
            WHEN 'PG' THEN 2
            WHEN 'PG-13' THEN 3
            WHEN 'R' THEN 4
            WHEN 'NC-17' THEN 5
            ELSE 0
         END
   END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'str2enum$film$rating'
GO
