USE [master]
GO
/****** Object:  Database [School]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
CREATE DATABASE [School]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'UniversityData', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\UniversityData.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'UniversityData_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\UniversityData_log.ldf' , SIZE = 139264KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [School] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [School].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [School] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [School] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [School] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [School] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [School] SET ARITHABORT OFF 
GO
ALTER DATABASE [School] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [School] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [School] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [School] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [School] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [School] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [School] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [School] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [School] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [School] SET  DISABLE_BROKER 
GO
ALTER DATABASE [School] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [School] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [School] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [School] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [School] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [School] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [School] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [School] SET RECOVERY FULL 
GO
ALTER DATABASE [School] SET  MULTI_USER 
GO
ALTER DATABASE [School] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [School] SET DB_CHAINING OFF 
GO
ALTER DATABASE [School] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [School] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [School] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'School', N'ON'
GO
ALTER DATABASE [School] SET QUERY_STORE = OFF
GO
USE [School]
GO
/****** Object:  Table [dbo].[advisor]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[advisor](
	[s_ID] [varchar](5) NOT NULL,
	[i_ID] [varchar](5) NULL,
PRIMARY KEY CLUSTERED 
(
	[s_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[classroom]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[classroom](
	[building] [varchar](15) NOT NULL,
	[room_number] [varchar](7) NOT NULL,
	[capacity] [numeric](4, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[building] ASC,
	[room_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[course]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[course](
	[course_id] [varchar](8) NOT NULL,
	[title] [varchar](50) NULL,
	[dept_name] [varchar](20) NULL,
	[credits] [numeric](2, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[course_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[department]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[department](
	[dept_name] [varchar](20) NOT NULL,
	[building] [varchar](15) NULL,
	[budget] [numeric](12, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[dept_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[instructor]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[instructor](
	[ID] [varchar](5) NOT NULL,
	[name] [varchar](20) NOT NULL,
	[dept_name] [varchar](20) NULL,
	[salary] [numeric](8, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[prereq]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[section]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[student]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[student](
	[ID] [varchar](5) NOT NULL,
	[name] [varchar](20) NOT NULL,
	[dept_name] [varchar](20) NULL,
	[tot_cred] [numeric](3, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[takes]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[takes](
	[ID] [varchar](5) NOT NULL,
	[course_id] [varchar](8) NOT NULL,
	[sec_id] [varchar](8) NOT NULL,
	[semester] [varchar](6) NOT NULL,
	[year] [numeric](4, 0) NOT NULL,
	[grade] [varchar](2) NULL,
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
/****** Object:  Table [dbo].[teaches]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[time_slot]    Script Date: 09/05/2021 10:29:11 ንጉሆ ሰዓተ ******/
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
ALTER TABLE [dbo].[advisor]  WITH CHECK ADD FOREIGN KEY([i_ID])
REFERENCES [dbo].[instructor] ([ID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[advisor]  WITH CHECK ADD FOREIGN KEY([s_ID])
REFERENCES [dbo].[student] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[course]  WITH CHECK ADD FOREIGN KEY([dept_name])
REFERENCES [dbo].[department] ([dept_name])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[instructor]  WITH CHECK ADD FOREIGN KEY([dept_name])
REFERENCES [dbo].[department] ([dept_name])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[prereq]  WITH CHECK ADD FOREIGN KEY([course_id])
REFERENCES [dbo].[course] ([course_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[prereq]  WITH CHECK ADD FOREIGN KEY([prereq_id])
REFERENCES [dbo].[course] ([course_id])
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD FOREIGN KEY([building], [room_number])
REFERENCES [dbo].[classroom] ([building], [room_number])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD FOREIGN KEY([course_id])
REFERENCES [dbo].[course] ([course_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[student]  WITH CHECK ADD FOREIGN KEY([dept_name])
REFERENCES [dbo].[department] ([dept_name])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[takes]  WITH CHECK ADD FOREIGN KEY([course_id], [sec_id], [semester], [year])
REFERENCES [dbo].[section] ([course_id], [sec_id], [semester], [year])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[takes]  WITH CHECK ADD FOREIGN KEY([ID])
REFERENCES [dbo].[student] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[teaches]  WITH CHECK ADD FOREIGN KEY([course_id], [sec_id], [semester], [year])
REFERENCES [dbo].[section] ([course_id], [sec_id], [semester], [year])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[teaches]  WITH CHECK ADD FOREIGN KEY([ID])
REFERENCES [dbo].[instructor] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[course]  WITH CHECK ADD CHECK  (([credits]>(0)))
GO
ALTER TABLE [dbo].[department]  WITH CHECK ADD CHECK  (([budget]>(0)))
GO
ALTER TABLE [dbo].[instructor]  WITH CHECK ADD CHECK  (([salary]>(29000)))
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD CHECK  (([semester]='Summer' OR [semester]='Spring' OR [semester]='Winter' OR [semester]='Fall'))
GO
ALTER TABLE [dbo].[section]  WITH CHECK ADD CHECK  (([year]>(1701) AND [year]<(2100)))
GO
ALTER TABLE [dbo].[student]  WITH CHECK ADD CHECK  (([tot_cred]>=(0)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([end_hr]>=(0) AND [end_hr]<(24)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([end_min]>=(0) AND [end_min]<(60)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([start_hr]>=(0) AND [start_hr]<(24)))
GO
ALTER TABLE [dbo].[time_slot]  WITH CHECK ADD CHECK  (([start_min]>=(0) AND [start_min]<(60)))
GO
USE [master]
GO
ALTER DATABASE [School] SET  READ_WRITE 
GO
