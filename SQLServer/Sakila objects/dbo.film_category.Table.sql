USE [Sakila]
GO
/****** Object:  Table [dbo].[film_category]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[film_category](
	[film_id] [int] NOT NULL,
	[category_id] [tinyint] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_film_category_film_id] PRIMARY KEY CLUSTERED 
(
	[film_id] ASC,
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [fk_film_category_category]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [fk_film_category_category] ON [dbo].[film_category]
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[film_category] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[film_category]  WITH NOCHECK ADD  CONSTRAINT [film_category$fk_film_category_category] FOREIGN KEY([category_id])
REFERENCES [dbo].[category] ([category_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[film_category] CHECK CONSTRAINT [film_category$fk_film_category_category]
GO
ALTER TABLE [dbo].[film_category]  WITH NOCHECK ADD  CONSTRAINT [film_category$fk_film_category_film] FOREIGN KEY([film_id])
REFERENCES [dbo].[film] ([film_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[film_category] CHECK CONSTRAINT [film_category$fk_film_category_film]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film_category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'film_category'
GO
