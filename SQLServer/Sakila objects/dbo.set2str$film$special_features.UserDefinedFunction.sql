USE [Sakila]
GO
/****** Object:  UserDefinedFunction [dbo].[set2str$film$special_features]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[set2str$film$special_features] 
( 
   @setval binary(1)
)
RETURNS nvarchar(max)
AS 
   BEGIN

      IF (@setval IS NULL)
         RETURN NULL

      DECLARE
         @rv nvarchar(max)

      SET @rv = ''

      DECLARE
         @setval_bi bigint

      SET @setval_bi = @setval

      IF (@setval_bi & 0x1 = 0x1)
         SET @rv = @rv + ',' + 'Trailers'

      IF (@setval_bi & 0x2 = 0x2)
         SET @rv = @rv + ',' + 'Commentaries'

      IF (@setval_bi & 0x4 = 0x4)
         SET @rv = @rv + ',' + 'Deleted Scenes'

      IF (@setval_bi & 0x8 = 0x8)
         SET @rv = @rv + ',' + 'Behind the Scenes'

      IF (@rv = '')
         RETURN ''

      RETURN SUBSTRING(@rv, 2, LEN(@rv) - 1)

   END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'set2str$film$special_features'
GO
