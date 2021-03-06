USE [Sakila]
GO
/****** Object:  Table [dbo].[payment]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payment](
	[payment_id] [int] IDENTITY(16050,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[staff_id] [tinyint] NOT NULL,
	[rental_id] [int] NULL,
	[amount] [decimal](5, 2) NOT NULL,
	[payment_date] [datetime2](0) NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_payment_payment_id] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [fk_payment_rental]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [fk_payment_rental] ON [dbo].[payment]
(
	[rental_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_customer_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_customer_id] ON [dbo].[payment]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_staff_id]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_staff_id] ON [dbo].[payment]
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payment] ADD  DEFAULT (NULL) FOR [rental_id]
GO
ALTER TABLE [dbo].[payment] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[payment]  WITH NOCHECK ADD  CONSTRAINT [payment$fk_payment_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customer] ([customer_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [payment$fk_payment_customer]
GO
ALTER TABLE [dbo].[payment]  WITH NOCHECK ADD  CONSTRAINT [payment$fk_payment_rental] FOREIGN KEY([rental_id])
REFERENCES [dbo].[rental] ([rental_id])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [payment$fk_payment_rental]
GO
ALTER TABLE [dbo].[payment]  WITH NOCHECK ADD  CONSTRAINT [payment$fk_payment_staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
ALTER TABLE [dbo].[payment] CHECK CONSTRAINT [payment$fk_payment_staff]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'payment'
GO
