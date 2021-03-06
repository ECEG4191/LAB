USE [Sakila]
GO
/****** Object:  Table [dbo].[staff]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[staff](
	[staff_id] [tinyint] IDENTITY(3,1) NOT NULL,
	[first_name] [nvarchar](45) NOT NULL,
	[last_name] [nvarchar](45) NOT NULL,
	[address_id] [int] NOT NULL,
	[picture] [varbinary](max) NULL,
	[email] [nvarchar](50) NULL,
	[store_id] [tinyint] NOT NULL,
	[active] [smallint] NOT NULL,
	[username] [nvarchar](16) NOT NULL,
	[password] [nvarchar](40) NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_staff_staff_id] PRIMARY KEY CLUSTERED 
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_address_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_address_id] ON [dbo].[staff]
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_store_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_store_id] ON [dbo].[staff]
(
	[store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT (NULL) FOR [email]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT (NULL) FOR [password]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[staff]  WITH NOCHECK ADD  CONSTRAINT [staff$fk_staff_address] FOREIGN KEY([address_id])
REFERENCES [dbo].[address] ([address_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[staff] CHECK CONSTRAINT [staff$fk_staff_address]
GO
ALTER TABLE [dbo].[staff]  WITH NOCHECK ADD  CONSTRAINT [staff$fk_staff_store] FOREIGN KEY([store_id])
REFERENCES [dbo].[store] ([store_id])
GO
ALTER TABLE [dbo].[staff] CHECK CONSTRAINT [staff$fk_staff_store]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.staff' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'staff'
GO
