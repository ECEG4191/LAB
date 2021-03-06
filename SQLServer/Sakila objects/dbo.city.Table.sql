USE [Sakila]
GO
/****** Object:  Table [dbo].[city]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[city](
	[city_id] [int] IDENTITY(601,1) NOT NULL,
	[city] [nvarchar](50) NOT NULL,
	[country_id] [int] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_city_city_id] PRIMARY KEY CLUSTERED 
(
	[city_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_country_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_country_id] ON [dbo].[city]
(
	[country_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[city] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[city]  WITH NOCHECK ADD  CONSTRAINT [city$fk_city_country] FOREIGN KEY([country_id])
REFERENCES [dbo].[country] ([country_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[city] CHECK CONSTRAINT [city$fk_city_country]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'city'
GO
