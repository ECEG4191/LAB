USE [School]
GO
/****** Object:  Table [dbo].[time_slot]    Script Date: 09/05/2021 10:15:57 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[time_slot](
	[time_slot_id] [varchar](4) NOT NULL,
	[day] [varchar](1) NOT NULL,
	[start_hr] [numeric](2, 0) NOT NULL,
	[start_min] [numeric](2, 0) NOT NULL,
	[end_hr] [numeric](2, 0) NULL,
	[end_min] [numeric](2, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[time_slot_id] ASC,
	[day] ASC,
	[start_hr] ASC,
	[start_min] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([end_hr]>=(0) AND [end_hr]<(24)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([end_min]>=(0) AND [end_min]<(60)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([start_hr]>=(0) AND [start_hr]<(24)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([start_min]>=(0) AND [start_min]<(60)))
GO
