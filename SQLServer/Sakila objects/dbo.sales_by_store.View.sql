USE [Sakila]
GO
/****** Object:  View [dbo].[sales_by_store]    Script Date: 09/05/2021 10:16:59 ንጉሆ ሰዓተ ******/
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
EXEC sys.sp_addextendedproperty @name=N'MS_SSMA_SOURCE', @value=N'sakila.sales_by_store' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'sales_by_store'
GO
