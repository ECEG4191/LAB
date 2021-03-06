USE [School]
GO
/****** Object:  Table [dbo].[section]    Script Date: 09/05/2021 10:15:57 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[section](
	[course_id] [varchar](8) NOT NULL,
	[sec_id] [varchar](8) NOT NULL,
	[semester] [varchar](6) NOT NULL,
	[year] [numeric](4, 0) NOT NULL,
	[building] [varchar](15) NULL,
	[room_number] [varchar](7) NULL,
	[time_slot_id] [varchar](4) NULL,
PRIMARY KEY CLUSTERED 
(
	[course_id] ASC,
	[sec_id] ASC,
	[semester] ASC,
	[year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD FOREIGN KEY([building], [room_number])
REFERENCES [dbo].[classroom] ([building], [room_number])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD FOREIGN KEY([course_id])
REFERENCES [dbo].[course] ([course_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD CHECK  (([semester]='Summer' OR [semester]='Spring' OR [semester]='Winter' OR [semester]='Fall'))
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD CHECK  (([year]>(1701) AND [year]<(2100)))
GO
