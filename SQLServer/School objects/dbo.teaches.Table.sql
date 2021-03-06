USE [School]
GO
/****** Object:  Table [dbo].[teaches]    Script Date: 09/05/2021 10:15:57 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[teaches](
	[ID] [varchar](5) NOT NULL,
	[course_id] [varchar](8) NOT NULL,
	[sec_id] [varchar](8) NOT NULL,
	[semester] [varchar](6) NOT NULL,
	[year] [numeric](4, 0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[course_id] ASC,
	[sec_id] ASC,
	[semester] ASC,
	[year] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[teaches]  WITH CHECK ADD FOREIGN KEY([course_id], [sec_id], [semester], [year])
REFERENCES [dbo].[section] ([course_id], [sec_id], [semester], [year])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[teaches]  WITH CHECK ADD FOREIGN KEY([ID])
REFERENCES [dbo].[instructor] ([ID])
ON DELETE CASCADE
GO
