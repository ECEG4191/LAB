USE [master]
GO
/****** Object:  Database [Sakila]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE DATABASE [Sakila]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Movie', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Movie.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Movie_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Movie_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Sakila] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Sakila].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Sakila] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Sakila] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Sakila] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Sakila] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Sakila] SET ARITHABORT OFF 
GO
ALTER DATABASE [Sakila] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Sakila] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Sakila] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Sakila] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Sakila] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Sakila] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Sakila] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Sakila] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Sakila] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Sakila] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Sakila] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Sakila] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Sakila] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Sakila] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Sakila] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Sakila] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Sakila] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Sakila] SET RECOVERY FULL 
GO
ALTER DATABASE [Sakila] SET  MULTI_USER 
GO
ALTER DATABASE [Sakila] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Sakila] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Sakila] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Sakila] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Sakila] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Sakila', N'ON'
GO
ALTER DATABASE [Sakila] SET QUERY_STORE = OFF
GO
USE [Sakila]
GO
/****** Object:  Schema [m2ss]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE SCHEMA [m2ss]
GO
/****** Object:  UserDefinedFunction [dbo].[enum2str$film$rating]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[enum2str$film$rating] 
( 
   @setval tinyint
)
RETURNS nvarchar(max)
AS 
   BEGIN
      RETURN 
         CASE @setval
            WHEN 1 THEN 'G'
            WHEN 2 THEN 'PG'
            WHEN 3 THEN 'PG-13'
            WHEN 4 THEN 'R'
            WHEN 5 THEN 'NC-17'
            ELSE ''
         END
   END
GO
/****** Object:  UserDefinedFunction [dbo].[get_customer_balance]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   READS SQL DATA.
*   M2SS0003: The following SQL clause was ignored during conversion: DETERMINISTIC.
*   M2SS0134: Conversion of following Comment(s) is not supported : OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
*   THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
*      1) RENTAL FEES FOR ALL PREVIOUS RENTALS
*      2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
*      3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
*      4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
*
*/

CREATE FUNCTION [dbo].[get_customer_balance] 
( 
   @p_customer_id int,
   @p_effective_date datetime2(0)
)
RETURNS decimal(5, 2)
AS 
   BEGIN

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported : FEES PAID TO RENT THE VIDEOS INITIALLY
      *
      */

      DECLARE
         @v_rentfees decimal(5, 2)

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported : LATE FEES FOR PRIOR RENTALS
      *
      */

      DECLARE
         @v_overfees int

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported : SUM OF PAYMENTS MADE PREVIOUSLY
      *
      */

      DECLARE
         @v_payments decimal(5, 2)

      SELECT @v_rentfees = ISNULL(sum(film.rental_rate), 0)
      FROM dbo.film, dbo.inventory, dbo.rental
      WHERE 
         film.film_id = inventory.film_id AND 
         inventory.inventory_id = rental.inventory_id AND 
         rental.rental_date <= @p_effective_date AND 
         rental.customer_id = @p_customer_id

      SELECT @v_overfees = ISNULL(sum(
         CASE 
            WHEN (((DATEDIFF(DAY, '1900-01-01', rental.return_date) + 693961) - (DATEDIFF(DAY, '1900-01-01', rental.rental_date) + 693961)) > film.rental_duration) THEN (((DATEDIFF(DAY, '1900-01-01', rental.return_date) + 693961) - (DATEDIFF(DAY, '1900-01-01', rental.rental_date) + 693961)) - film.rental_duration)
            ELSE 0
         END), 0)
      FROM dbo.rental, dbo.inventory, dbo.film
      WHERE 
         film.film_id = inventory.film_id AND 
         inventory.inventory_id = rental.inventory_id AND 
         rental.rental_date <= @p_effective_date AND 
         rental.customer_id = @p_customer_id

      SELECT @v_payments = ISNULL(sum(payment.amount), 0)
      FROM dbo.payment
      WHERE payment.payment_date <= @p_effective_date AND payment.customer_id = @p_customer_id

      RETURN @v_rentfees + @v_overfees - @v_payments

   END
GO
/****** Object:  UserDefinedFunction [dbo].[inventory_held_by_customer]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   READS SQL DATA.
*/

CREATE FUNCTION [dbo].[inventory_held_by_customer] 
( 
   @p_inventory_id int
)
RETURNS int
AS 
   BEGIN

      DECLARE
         @v_customer_id int

      SELECT @v_customer_id = rental.customer_id
      FROM dbo.rental
      WHERE rental.return_date IS NULL AND rental.inventory_id = @p_inventory_id

      RETURN @v_customer_id

   END
GO
/****** Object:  UserDefinedFunction [dbo].[inventory_in_stock]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   READS SQL DATA.
*/

CREATE FUNCTION [dbo].[inventory_in_stock] 
( 
   @p_inventory_id int
)
RETURNS smallint
AS 
   BEGIN

      DECLARE
         @v_rentals int

      DECLARE
         @v_out int

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported : AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
      *   FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED
      *
      */

      SELECT @v_rentals = count_big(*)
      FROM dbo.rental
      WHERE rental.inventory_id = @p_inventory_id

      IF @v_rentals = 0
         /*
         *   SSMA informational messages:
         *   M2SS0052: BOOLEAN literal was converted to SMALLINT literal
         */

         RETURN 1

      SELECT @v_out = count_big(rental.rental_id)
      FROM 
         dbo.inventory 
            LEFT JOIN dbo.rental 
            ON inventory.inventory_id = rental.inventory_id
      WHERE inventory.inventory_id = @p_inventory_id AND rental.return_date IS NULL

      IF @v_out > 0
         /*
         *   SSMA informational messages:
         *   M2SS0052: BOOLEAN literal was converted to SMALLINT literal
         */

         RETURN 0
      ELSE 
         /*
         *   SSMA informational messages:
         *   M2SS0052: BOOLEAN literal was converted to SMALLINT literal
         */

         RETURN 1

      RETURN NULL

   END
GO
/****** Object:  UserDefinedFunction [dbo].[norm_enum$film$rating]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[norm_enum$film$rating] 
( 
   @setval nvarchar(max)
)
RETURNS nvarchar(max)
AS 
   BEGIN
      RETURN dbo.enum2str$film$rating(dbo.str2enum$film$rating(@setval))
   END
GO
/****** Object:  UserDefinedFunction [dbo].[norm_set$film$special_features]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[norm_set$film$special_features] 
( 
   @setval varchar(max)
)
RETURNS varchar(max)
AS 
   BEGIN
      RETURN dbo.set2str$film$special_features(dbo.str2set$film$special_features(@setval))
   END
GO
/****** Object:  UserDefinedFunction [dbo].[set2str$film$special_features]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[set2str$film$special_features] 
( 
   @setval binary(1)
)
RETURNS nvarchar(max)
AS 
   BEGIN

      IF (@setval IS NULL)
         RETURN NULL

      DECLARE
         @rv nvarchar(max)

      SET @rv = ''

      DECLARE
         @setval_bi bigint

      SET @setval_bi = @setval

      IF (@setval_bi & 0x1 = 0x1)
         SET @rv = @rv + ',' + 'Trailers'

      IF (@setval_bi & 0x2 = 0x2)
         SET @rv = @rv + ',' + 'Commentaries'

      IF (@setval_bi & 0x4 = 0x4)
         SET @rv = @rv + ',' + 'Deleted Scenes'

      IF (@setval_bi & 0x8 = 0x8)
         SET @rv = @rv + ',' + 'Behind the Scenes'

      IF (@rv = '')
         RETURN ''

      RETURN SUBSTRING(@rv, 2, LEN(@rv) - 1)

   END
GO
/****** Object:  UserDefinedFunction [dbo].[str2enum$film$rating]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[str2enum$film$rating] 
( 
   @setval nvarchar(max)
)
RETURNS tinyint
AS 
   BEGIN
      RETURN 
         CASE @setval
            WHEN 'G' THEN 1
            WHEN 'PG' THEN 2
            WHEN 'PG-13' THEN 3
            WHEN 'R' THEN 4
            WHEN 'NC-17' THEN 5
            ELSE 0
         END
   END
GO
/****** Object:  UserDefinedFunction [dbo].[str2set$film$special_features]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[str2set$film$special_features] 
( 
   @setval nvarchar(max)
)
RETURNS binary(1)
AS 
   BEGIN

      IF (@setval IS NULL)
         RETURN NULL

      SET @setval = ',' + @setval + ','

      RETURN 
         CASE 
            WHEN @setval LIKE '%,Trailers,%' THEN 0x1
            ELSE CAST(0 AS BIGINT)
         END | 
         CASE 
            WHEN @setval LIKE '%,Commentaries,%' THEN 0x2
            ELSE CAST(0 AS BIGINT)
         END | 
         CASE 
            WHEN @setval LIKE '%,Deleted Scenes,%' THEN 0x4
            ELSE CAST(0 AS BIGINT)
         END | 
         CASE 
            WHEN @setval LIKE '%,Behind the Scenes,%' THEN 0x8
            ELSE CAST(0 AS BIGINT)
         END

   END
GO
/****** Object:  Table [dbo].[actor]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[actor](
	[actor_id] [int] IDENTITY(201,1) NOT NULL,
	[first_name] [nvarchar](45) NOT NULL,
	[last_name] [nvarchar](45) NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_actor_actor_id] PRIMARY KEY CLUSTERED 
(
	[actor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[address]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[address](
	[address_id] [int] IDENTITY(606,1) NOT NULL,
	[address] [nvarchar](50) NOT NULL,
	[address2] [nvarchar](50) NULL,
	[district] [nvarchar](20) NOT NULL,
	[city_id] [int] NOT NULL,
	[postal_code] [nvarchar](10) NULL,
	[phone] [nvarchar](20) NOT NULL,
	[location] [geometry] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_address_address_id] PRIMARY KEY CLUSTERED 
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[category]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[category](
	[category_id] [tinyint] IDENTITY(17,1) NOT NULL,
	[name] [nvarchar](25) NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_category_category_id] PRIMARY KEY CLUSTERED 
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[city]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[country]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[country](
	[country_id] [int] IDENTITY(110,1) NOT NULL,
	[country] [nvarchar](50) NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_country_country_id] PRIMARY KEY CLUSTERED 
(
	[country_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[customer]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer](
	[customer_id] [int] IDENTITY(600,1) NOT NULL,
	[store_id] [tinyint] NOT NULL,
	[first_name] [nvarchar](45) NOT NULL,
	[last_name] [nvarchar](45) NOT NULL,
	[email] [nvarchar](50) NULL,
	[address_id] [int] NOT NULL,
	[active] [smallint] NOT NULL,
	[create_date] [datetime2](0) NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_customer_customer_id] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[film]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[film](
	[film_id] [int] IDENTITY(1001,1) NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
	[release_year] [smallint] NULL,
	[language_id] [tinyint] NOT NULL,
	[original_language_id] [tinyint] NULL,
	[rental_duration] [tinyint] NOT NULL,
	[rental_rate] [decimal](4, 2) NOT NULL,
	[length] [int] NULL,
	[replacement_cost] [decimal](5, 2) NOT NULL,
	[rating] [nvarchar](5) NULL,
	[special_features] [nvarchar](54) NULL,
	[last_update] [datetime] NOT NULL,
	[ssma$rowid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_film_film_id] PRIMARY KEY CLUSTERED 
(
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UK_film_ssma$rowid] UNIQUE NONCLUSTERED 
(
	[ssma$rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[film_actor]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[film_actor](
	[actor_id] [int] NOT NULL,
	[film_id] [int] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_film_actor_actor_id] PRIMARY KEY CLUSTERED 
(
	[actor_id] ASC,
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[film_category]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[payment]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[rental]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rental](
	[rental_id] [int] IDENTITY(16050,1) NOT NULL,
	[rental_date] [datetime2](0) NOT NULL,
	[inventory_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[return_date] [datetime2](0) NULL,
	[staff_id] [tinyint] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_rental_rental_id] PRIMARY KEY CLUSTERED 
(
	[rental_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [rental$rental_date] UNIQUE NONCLUSTERED 
(
	[rental_date] ASC,
	[inventory_id] ASC,
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View01]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View01]
AS
SELECT dbo.actor.first_name AS actor_first_name, dbo.actor.last_name AS actor_last_name, dbo.film.title AS film_title, dbo.film.description AS film_description, dbo.film.release_year AS film_release_year, 
                  dbo.film.rental_duration AS film_rental_duration, dbo.film.rental_rate AS film_rental_rate, dbo.film.length AS film_length, dbo.film.replacement_cost AS film_replacement, dbo.film.rating AS film_rating, dbo.category.name AS Catategory, 
                  dbo.city.city AS costomer_city, dbo.country.country AS customer_country, dbo.customer.first_name AS customer_first_name, dbo.customer.last_name AS customer_last_name, dbo.customer.email AS customer_email, 
                  dbo.address.postal_code AS customer_postal_code, dbo.address.phone AS customer_phone, dbo.address.address AS customer_address, dbo.address.address2 AS customer_address2, dbo.address.district AS customer_district, 
                  dbo.rental.rental_date, dbo.payment.amount, dbo.payment.payment_date
FROM     dbo.actor INNER JOIN
                  dbo.film_actor INNER JOIN
                  dbo.film ON dbo.film_actor.film_id = dbo.film.film_id ON dbo.actor.actor_id = dbo.film_actor.actor_id INNER JOIN
                  dbo.film_category ON dbo.film.film_id = dbo.film_category.film_id INNER JOIN
                  dbo.category ON dbo.film_category.category_id = dbo.category.category_id CROSS JOIN
                  dbo.payment INNER JOIN
                  dbo.country INNER JOIN
                  dbo.city INNER JOIN
                  dbo.address ON dbo.city.city_id = dbo.address.city_id ON dbo.country.country_id = dbo.city.country_id INNER JOIN
                  dbo.customer ON dbo.address.address_id = dbo.customer.address_id ON dbo.payment.customer_id = dbo.customer.customer_id INNER JOIN
                  dbo.rental ON dbo.payment.rental_id = dbo.rental.rental_id AND dbo.customer.customer_id = dbo.rental.customer_id
GO
/****** Object:  View [dbo].[customer_list]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   ALGORITHM =  UNDEFINED.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   SQL SECURITY DEFINER.
*/

CREATE VIEW [dbo].[customer_list] (
   [ID], 
   [name], 
   [address], 
   [zip code], 
   [phone], 
   [city], 
   [country], 
   [notes], 
   [SID])
AS 
   SELECT 
      cu.customer_id AS ID, 
      cu.first_name + N' ' + cu.last_name AS name, 
      a.address AS address, 
      a.postal_code AS [zip code], 
      a.phone AS phone, 
      city.city AS city, 
      country.country AS country, 
      CASE 
         WHEN (cu.active <> 0) THEN N'active'
         ELSE N''
      END AS notes, 
      cu.store_id AS SID
   FROM (((dbo.customer  AS cu 
      INNER JOIN dbo.address  AS a 
      ON ((cu.address_id = a.address_id))) 
      INNER JOIN dbo.city 
      ON ((a.city_id = city.city_id))) 
      INNER JOIN dbo.country 
      ON ((city.country_id = country.country_id)))
GO
/****** Object:  Table [dbo].[inventory]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
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
/****** Object:  View [dbo].[sales_by_film_category]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   ALGORITHM =  UNDEFINED.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   SQL SECURITY DEFINER.
*/

CREATE VIEW [dbo].[sales_by_film_category] ([category], [total_sales])
AS 
   SELECT TOP (9223372036854775807) c.name AS category, sum(p.amount) AS total_sales
   FROM (((((dbo.payment  AS p 
      INNER JOIN dbo.rental  AS r 
      ON ((p.rental_id = r.rental_id))) 
      INNER JOIN dbo.inventory  AS i 
      ON ((r.inventory_id = i.inventory_id))) 
      INNER JOIN dbo.film  AS f 
      ON ((i.film_id = f.film_id))) 
      INNER JOIN dbo.film_category  AS fc 
      ON ((f.film_id = fc.film_id))) 
      INNER JOIN dbo.category  AS c 
      ON ((fc.category_id = c.category_id)))
   GROUP BY c.name
      ORDER BY total_sales DESC
GO
/****** Object:  Table [dbo].[staff]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
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
/****** Object:  Table [dbo].[store]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[store](
	[store_id] [tinyint] IDENTITY(3,1) NOT NULL,
	[manager_staff_id] [tinyint] NOT NULL,
	[address_id] [int] NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_store_store_id] PRIMARY KEY CLUSTERED 
(
	[store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [store$idx_unique_manager] UNIQUE NONCLUSTERED 
(
	[manager_staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[sales_by_store]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   ALGORITHM =  UNDEFINED.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   SQL SECURITY DEFINER.
*/

CREATE VIEW [dbo].[sales_by_store] ([store], [manager], [total_sales])
AS 
   /*
   *   SSMA warning messages:
   *   M2SS0104: Non aggregated column COUNTRY is aggregated with Min(..) in Select, Orderby and Having clauses.
   *   M2SS0104: Non aggregated column CITY is aggregated with Min(..) in Select, Orderby and Having clauses.
   *   M2SS0104: Non aggregated column CITY is aggregated with Min(..) in Select, Orderby and Having clauses.
   *   M2SS0104: Non aggregated column COUNTRY is aggregated with Min(..) in Select, Orderby and Having clauses.
   *   M2SS0104: Non aggregated column FIRST_NAME is aggregated with Min(..) in Select, Orderby and Having clauses.
   *   M2SS0104: Non aggregated column LAST_NAME is aggregated with Min(..) in Select, Orderby and Having clauses.
   */

   SELECT TOP (9223372036854775807) min(c.city) + N',' + min(cy.country) AS store, min(m.first_name) + N' ' + min(m.last_name) AS manager, sum(p.amount) AS total_sales
   FROM (((((((dbo.payment  AS p 
      INNER JOIN dbo.rental  AS r 
      ON ((p.rental_id = r.rental_id))) 
      INNER JOIN dbo.inventory  AS i 
      ON ((r.inventory_id = i.inventory_id))) 
      INNER JOIN dbo.store  AS s 
      ON ((i.store_id = s.store_id))) 
      INNER JOIN dbo.address  AS a 
      ON ((s.address_id = a.address_id))) 
      INNER JOIN dbo.city  AS c 
      ON ((a.city_id = c.city_id))) 
      INNER JOIN dbo.country  AS cy 
      ON ((c.country_id = cy.country_id))) 
      INNER JOIN dbo.staff  AS m 
      ON ((s.manager_staff_id = m.staff_id)))
   GROUP BY s.store_id
      ORDER BY min(cy.country), min(c.city)
GO
/****** Object:  View [dbo].[staff_list]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   ALGORITHM =  UNDEFINED.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   SQL SECURITY DEFINER.
*/

CREATE VIEW [dbo].[staff_list] (
   [ID], 
   [name], 
   [address], 
   [zip code], 
   [phone], 
   [city], 
   [country], 
   [SID])
AS 
   SELECT 
      s.staff_id AS ID, 
      s.first_name + N' ' + s.last_name AS name, 
      a.address AS address, 
      a.postal_code AS [zip code], 
      a.phone AS phone, 
      city.city AS city, 
      country.country AS country, 
      s.store_id AS SID
   FROM (((dbo.staff  AS s 
      INNER JOIN dbo.address  AS a 
      ON ((s.address_id = a.address_id))) 
      INNER JOIN dbo.city 
      ON ((a.city_id = city.city_id))) 
      INNER JOIN dbo.country 
      ON ((city.country_id = country.country_id)))
GO
/****** Object:  Table [dbo].[film_text]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[film_text](
	[film_id] [smallint] NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
 CONSTRAINT [PK_film_text_film_id] PRIMARY KEY CLUSTERED 
(
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[language]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[language](
	[language_id] [tinyint] IDENTITY(7,1) NOT NULL,
	[name] [nchar](20) NOT NULL,
	[last_update] [datetime] NOT NULL,
 CONSTRAINT [PK_language_language_id] PRIMARY KEY CLUSTERED 
(
	[language_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_actor_last_name]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_actor_last_name] ON [dbo].[actor]
(
	[last_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_city_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_city_id] ON [dbo].[address]
(
	[city_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_country_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_country_id] ON [dbo].[city]
(
	[country_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_address_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_address_id] ON [dbo].[customer]
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_store_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_store_id] ON [dbo].[customer]
(
	[store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_last_name]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_last_name] ON [dbo].[customer]
(
	[last_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_language_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_language_id] ON [dbo].[film]
(
	[language_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_original_language_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_original_language_id] ON [dbo].[film]
(
	[original_language_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_title]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_title] ON [dbo].[film]
(
	[title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_film_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_film_id] ON [dbo].[film_actor]
(
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [fk_film_category_category]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [fk_film_category_category] ON [dbo].[film_category]
(
	[category_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_film_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_film_id] ON [dbo].[inventory]
(
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_store_id_film_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_store_id_film_id] ON [dbo].[inventory]
(
	[store_id] ASC,
	[film_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [fk_payment_rental]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [fk_payment_rental] ON [dbo].[payment]
(
	[rental_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_customer_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_customer_id] ON [dbo].[payment]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_staff_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_staff_id] ON [dbo].[payment]
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_customer_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_customer_id] ON [dbo].[rental]
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_inventory_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_inventory_id] ON [dbo].[rental]
(
	[inventory_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_staff_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_staff_id] ON [dbo].[rental]
(
	[staff_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_address_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_address_id] ON [dbo].[staff]
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_store_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_store_id] ON [dbo].[staff]
(
	[store_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_fk_address_id]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
CREATE NONCLUSTERED INDEX [idx_fk_address_id] ON [dbo].[store]
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[actor] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[address] ADD  DEFAULT (NULL) FOR [address2]
GO
ALTER TABLE [dbo].[address] ADD  DEFAULT (NULL) FOR [postal_code]
GO
ALTER TABLE [dbo].[address] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[category] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[city] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[country] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[customer] ADD  DEFAULT (NULL) FOR [email]
GO
ALTER TABLE [dbo].[customer] ADD  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[customer] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (NULL) FOR [release_year]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (NULL) FOR [original_language_id]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT ((3)) FOR [rental_duration]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT ((4.99)) FOR [rental_rate]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (NULL) FOR [length]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT ((19.99)) FOR [replacement_cost]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (N'G') FOR [rating]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (NULL) FOR [special_features]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[film] ADD  DEFAULT (newid()) FOR [ssma$rowid]
GO
ALTER TABLE [dbo].[film_actor] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[film_category] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[inventory] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[language] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[payment] ADD  DEFAULT (NULL) FOR [rental_id]
GO
ALTER TABLE [dbo].[payment] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[rental] ADD  DEFAULT (NULL) FOR [return_date]
GO
ALTER TABLE [dbo].[rental] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT (NULL) FOR [email]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT (NULL) FOR [password]
GO
ALTER TABLE [dbo].[staff] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[store] ADD  DEFAULT (getdate()) FOR [last_update]
GO
ALTER TABLE [dbo].[address]  WITH NOCHECK ADD  CONSTRAINT [address$fk_address_city] FOREIGN KEY([city_id])
REFERENCES [dbo].[city] ([city_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[address] CHECK CONSTRAINT [address$fk_address_city]
GO
ALTER TABLE [dbo].[city]  WITH NOCHECK ADD  CONSTRAINT [city$fk_city_country] FOREIGN KEY([country_id])
REFERENCES [dbo].[country] ([country_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[city] CHECK CONSTRAINT [city$fk_city_country]
GO
ALTER TABLE [dbo].[customer]  WITH NOCHECK ADD  CONSTRAINT [customer$fk_customer_address] FOREIGN KEY([address_id])
REFERENCES [dbo].[address] ([address_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[customer] CHECK CONSTRAINT [customer$fk_customer_address]
GO
ALTER TABLE [dbo].[customer]  WITH NOCHECK ADD  CONSTRAINT [customer$fk_customer_store] FOREIGN KEY([store_id])
REFERENCES [dbo].[store] ([store_id])
GO
ALTER TABLE [dbo].[customer] CHECK CONSTRAINT [customer$fk_customer_store]
GO
ALTER TABLE [dbo].[film]  WITH NOCHECK ADD  CONSTRAINT [film$fk_film_language] FOREIGN KEY([language_id])
REFERENCES [dbo].[language] ([language_id])
GO
ALTER TABLE [dbo].[film] CHECK CONSTRAINT [film$fk_film_language]
GO
ALTER TABLE [dbo].[film]  WITH NOCHECK ADD  CONSTRAINT [film$fk_film_language_original] FOREIGN KEY([original_language_id])
REFERENCES [dbo].[language] ([language_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[film] CHECK CONSTRAINT [film$fk_film_language_original]
GO
ALTER TABLE [dbo].[film_actor]  WITH NOCHECK ADD  CONSTRAINT [film_actor$fk_film_actor_actor] FOREIGN KEY([actor_id])
REFERENCES [dbo].[actor] ([actor_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[film_actor] CHECK CONSTRAINT [film_actor$fk_film_actor_actor]
GO
ALTER TABLE [dbo].[film_actor]  WITH NOCHECK ADD  CONSTRAINT [film_actor$fk_film_actor_film] FOREIGN KEY([film_id])
REFERENCES [dbo].[film] ([film_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[film_actor] CHECK CONSTRAINT [film_actor$fk_film_actor_film]
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
ALTER TABLE [dbo].[rental]  WITH NOCHECK ADD  CONSTRAINT [rental$fk_rental_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customer] ([customer_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[rental] CHECK CONSTRAINT [rental$fk_rental_customer]
GO
ALTER TABLE [dbo].[rental]  WITH NOCHECK ADD  CONSTRAINT [rental$fk_rental_inventory] FOREIGN KEY([inventory_id])
REFERENCES [dbo].[inventory] ([inventory_id])
GO
ALTER TABLE [dbo].[rental] CHECK CONSTRAINT [rental$fk_rental_inventory]
GO
ALTER TABLE [dbo].[rental]  WITH NOCHECK ADD  CONSTRAINT [rental$fk_rental_staff] FOREIGN KEY([staff_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
ALTER TABLE [dbo].[rental] CHECK CONSTRAINT [rental$fk_rental_staff]
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
ALTER TABLE [dbo].[store]  WITH NOCHECK ADD  CONSTRAINT [store$fk_store_address] FOREIGN KEY([address_id])
REFERENCES [dbo].[address] ([address_id])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[store] CHECK CONSTRAINT [store$fk_store_address]
GO
ALTER TABLE [dbo].[store]  WITH NOCHECK ADD  CONSTRAINT [store$fk_store_staff] FOREIGN KEY([manager_staff_id])
REFERENCES [dbo].[staff] ([staff_id])
GO
ALTER TABLE [dbo].[store] CHECK CONSTRAINT [store$fk_store_staff]
GO
/****** Object:  StoredProcedure [dbo].[film_in_stock]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   READS SQL DATA.
*/

CREATE PROCEDURE [dbo].[film_in_stock]  
   @p_film_id int,
   @p_store_id int,
   @p_film_count int  OUTPUT
AS 
   BEGIN

      SET  XACT_ABORT  ON

      SET  NOCOUNT  ON

      SET @p_film_count = NULL

      SELECT inventory.inventory_id
      FROM dbo.inventory
      WHERE 
         inventory.film_id = @p_film_id AND 
         inventory.store_id = @p_store_id AND 
         dbo.inventory_in_stock(inventory.inventory_id) <> 0

      /* 
      *   SSMA error messages:
      *   M2SS0201: MySQL standard function FOUND_ROWS is not supported in current SSMA version

      SELECT @p_film_count = FOUND_ROWS
      */



   END
GO
/****** Object:  StoredProcedure [dbo].[film_not_in_stock]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   READS SQL DATA.
*/

CREATE PROCEDURE [dbo].[film_not_in_stock]  
   @p_film_id int,
   @p_store_id int,
   @p_film_count int  OUTPUT
AS 
   BEGIN

      SET  XACT_ABORT  ON

      SET  NOCOUNT  ON

      SET @p_film_count = NULL

      SELECT inventory.inventory_id
      FROM dbo.inventory
      WHERE 
         inventory.film_id = @p_film_id AND 
         inventory.store_id = @p_store_id AND 
         NOT dbo.inventory_in_stock(inventory.inventory_id) <> 0

      /* 
      *   SSMA error messages:
      *   M2SS0201: MySQL standard function FOUND_ROWS is not supported in current SSMA version

      SELECT @p_film_count = FOUND_ROWS
      */



   END
GO
/****** Object:  StoredProcedure [dbo].[rewards_report]    Script Date: 09/05/2021 10:29:59 ንጉሆ ሰዓተ ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
*   SSMA informational messages:
*   M2SS0003: The following SQL clause was ignored during conversion:
*   DEFINER = `root`@`localhost`.
*   M2SS0003: The following SQL clause was ignored during conversion:
*   READS SQL DATA.
*   M2SS0003: The following SQL clause was ignored during conversion: COMMENT 'Provides a customizable report on best customers'.
*/

CREATE PROCEDURE [dbo].[rewards_report]  
   @min_monthly_purchases tinyint,
   @min_dollar_amount_purchased decimal(10, 2),
   @count_rewardees int  OUTPUT
AS 
   /*
   *   SSMA informational messages:
   *   M2SS0003: The following SQL clause was ignored during conversion:
   *   proc : .
   */

   BEGIN

      SET  XACT_ABORT  ON

      SET  NOCOUNT  ON

      SET @count_rewardees = NULL

      DECLARE
         @last_month_start date

      DECLARE
         @last_month_end date

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported :  Some sanity checks... 
      *
      */

      IF @min_monthly_purchases = 0
         BEGIN

            SELECT N'Minimum monthly purchases parameter must be > 0'

            GOTO proc$leave

         END

      IF @min_dollar_amount_purchased = 0.00
         BEGIN

            SELECT N'Minimum monthly dollar amount purchased parameter must be > $0.00'

            GOTO proc$leave

         END

      SET @last_month_start = dateadd(month, -1, CAST(getdate() AS DATE))

      /* 
      *   SSMA error messages:
      *   M2SS0201: MySQL standard function STR_TO_DATE is not supported in current SSMA version

      SET @last_month_start = STR_TO_DATE((CAST(year(@last_month_start) AS varchar(50))) + (N'-') + (CAST(datepart(MONTH, @last_month_start) AS varchar(50))) + (N'-01'), '%Y-%m-%d')
      */



      SET @last_month_end = DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, CAST('1900-01-01' AS DATE), @last_month_start) + 1, CAST('1900-01-01' AS DATE)))

      CREATE TABLE #tmpCustomer
      (
         customer_id int NOT NULL PRIMARY KEY
      )

      INSERT #tmpCustomer(customer_id)
         SELECT p.customer_id
         FROM dbo.payment  AS p
         WHERE p.payment_date BETWEEN @last_month_start AND @last_month_end
         GROUP BY p.customer_id
         HAVING sum(p.amount) > @min_dollar_amount_purchased AND count_big(p.customer_id) > @min_monthly_purchases
            ORDER BY p.customer_id

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported :  Populate OUT parameter with count of found customers 
      *
      */

      SELECT @count_rewardees = count_big(*)
      FROM #tmpCustomer

      /*
      *   SSMA informational messages:
      *   M2SS0134: Conversion of following Comment(s) is not supported : 
      *           Output ALL customer information of matching rewardees.
      *           Customize output as needed.
      *       
      *
      */

      SELECT 
         c.customer_id, 
         c.store_id, 
         c.first_name, 
         c.last_name, 
         c.email, 
         c.address_id, 
         c.active, 
         c.create_date, 
         c.last_update
      FROM 
         #tmpCustomer  AS t 
            INNER JOIN dbo.customer  AS c 
            ON t.customer_id = c.customer_id

      DROP TABLE #tmpCustomer

   END
   proc$leave:
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film_in_stock' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'film_in_stock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film_not_in_stock' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'film_not_in_stock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.rewards_report' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'PROCEDURE',@level1name=N'rewards_report'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'enum2str$film$rating'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.get_customer_balance' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'get_customer_balance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.inventory_held_by_customer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'inventory_held_by_customer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.inventory_in_stock' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'inventory_in_stock'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'norm_enum$film$rating'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'norm_set$film$special_features'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'set2str$film$special_features'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'str2enum$film$rating'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'str2set$film$special_features'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.actor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'actor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'address'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'city'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'country'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.customer' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'customer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'film'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film_actor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'film_actor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film_category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'film_category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.film_text' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'film_text'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.inventory' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'inventory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.language' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'language'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.payment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'payment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.rental' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'rental'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.staff' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'staff'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.store' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'store'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.customer_list' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'customer_list'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.sales_by_film_category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'sales_by_film_category'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.sales_by_store' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'sales_by_store'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.staff_list' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'staff_list'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[18] 4[25] 2[13] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "actor"
            Begin Extent = 
               Top = 3
               Left = 4
               Bottom = 166
               Right = 198
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "film_actor"
            Begin Extent = 
               Top = 11
               Left = 259
               Bottom = 152
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "film"
            Begin Extent = 
               Top = 8
               Left = 511
               Bottom = 171
               Right = 691
            End
            DisplayFlags = 280
            TopColumn = 9
         End
         Begin Table = "film_category"
            Begin Extent = 
               Top = 12
               Left = 747
               Bottom = 129
               Right = 941
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "category"
            Begin Extent = 
               Top = 7
               Left = 990
               Bottom = 148
               Right = 1135
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "payment"
            Begin Extent = 
               Top = 221
               Left = 1087
               Bottom = 384
               Right = 1281
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "country"
            Begin Extent = 
               Top = 370
               Left = 1304
               Bottom = 511
               Right = 1465
            End
            DisplayFlags ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View01'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 280
            TopColumn = 0
         End
         Begin Table = "city"
            Begin Extent = 
               Top = 7
               Left = 1191
               Bottom = 170
               Right = 1346
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "address"
            Begin Extent = 
               Top = 179
               Left = 648
               Bottom = 342
               Right = 842
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "customer"
            Begin Extent = 
               Top = 379
               Left = 878
               Bottom = 542
               Right = 1072
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "rental"
            Begin Extent = 
               Top = 356
               Left = 288
               Bottom = 519
               Right = 482
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 52
         Width = 284
         Width = 1200
         Width = 1200
         Width = 2832
         Width = 9180
         Width = 1728
         Width = 1872
         Width = 1560
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1728
         Width = 1848
         Width = 1848
         Width = 1872
         Width = 2928
         Width = 2604
         Width = 1932
         Width = 1932
         Width = 1200
         Width = 2208
         Width = 2484
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 2580
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View01'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View01'
GO
USE [master]
GO
ALTER DATABASE [Sakila] SET  READ_WRITE 
GO
