USE [School]
GO
/****** Object:  Table [dbo].[prereq]    Script Date: 09/05/2021 10:15:57 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[prereq](
	[course_id] [varchar](8) NOT NULL,
	[prereq_id] [varchar](8) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[course_id] ASC,
	[prereq_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[prereq]  WITH CHECK ADD FOREIGN KEY([course_id])
REFERENCES [dbo].[course] ([course_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[prereq]  WITH CHECK ADD FOREIGN KEY([prereq_id])
REFERENCES [dbo].[course] ([course_id])
GO
