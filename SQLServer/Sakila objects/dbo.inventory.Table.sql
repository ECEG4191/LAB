USE [Sakila]
GO
/****** Object:  Table [dbo].[inventory]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[inventory](
	[inventory_id] [int] IDENTITY(4582,1) NOT NULL,
	[film_id] [int] NOT NULL,
	[store_id] [tinyint] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_inventory_inventory_id] PRIMARY KEY CLUSTERED 
(
	[inventory_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_film_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_film_id] ON [dbo].[inventory]
(
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_store_id_film_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_store_id_film_id] ON [dbo].[inventory]
(
	[store_id] ASC,
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[inventory] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[inventory]  WITH NOCHECK ADD  CONSTRAINT [inventory$fk_inventory_film] FOREIGN KEY([film_id])
REFERENCES [dbo].[film] ([film_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [inventory$fk_inventory_film]
GO
ALTER TABLE [dbo].[inventory]  WITH NOCHECK ADD  CONSTRAINT [inventory$fk_inventory_store] FOREIGN KEY([store_id])
REFERENCES [dbo].[store] ([store_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[inventory] CHECK CONSTRAINT [inventory$fk_inventory_store]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.inventory' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'inventory'
GO
