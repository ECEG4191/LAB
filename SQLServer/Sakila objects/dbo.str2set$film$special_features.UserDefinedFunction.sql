USE [Sakila]
GO
/****** Object:  UserDefinedFunction [dbo].[str2set$film$special_features]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[str2set$film$special_features] 
( 
   @setval nvarchar(max)
)
RETURNS binary(1)
AS 
   BEGIN

      IF (@setval IS NULL)
         RETURN NULL

      SET @setval = ',' + @setval + ','

      RETURN 
         CASE 
            WHEN @setval LIKE '%,Trailers,%' THEN 0x1
            ELSE CAST(0 AS BIGINT)
         END | 
         CASE 
            WHEN @setval LIKE '%,Commentaries,%' THEN 0x2
            ELSE CAST(0 AS BIGINT)
         END | 
         CASE 
            WHEN @setval LIKE '%,Deleted Scenes,%' THEN 0x4
            ELSE CAST(0 AS BIGINT)
         END | 
         CASE 
            WHEN @setval LIKE '%,Behind the Scenes,%' THEN 0x8
            ELSE CAST(0 AS BIGINT)
         END

   END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'str2set$film$special_features'
GO
