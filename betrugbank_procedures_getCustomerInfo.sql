USE [betrugbank]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Levente Fodor
-- Create date: 2022-03-01
-- Description:	procedure getCustomerInfo for betrugbank db
-- =============================================
CREATE OR ALTER PROCEDURE [dm].[getCustomerInfo]
	-- Add the parameters for the stored procedure here
	@cust_id VARCHAR(5)
AS

IF @cust_id IS NULL
OR TRY_CAST(@cust_id AS INTEGER) IS NULL
OR TRY_CAST(@cust_id AS INTEGER) < 10000 OR TRY_CAST(@cust_id AS INTEGER) > 99999
	PRINT N'Please enter valid customer_id' ;
ELSE
	BEGIN
	SET @cust_id = TRY_CAST(@cust_id AS INTEGER)

	IF @cust_id IN (SELECT DISTINCT id FROM [dm].[d_customer])
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

		-- Insert statements for procedure here
		SELECT customer_type_name, 
			country_iso, 
			date_of_birth,
			education,
			first_name,
			family_name
		FROM [dm].[d_customer]
		WHERE id = @cust_id
	END
	ELSE
		PRINT N'Customer ' + CONVERT(VARCHAR(5), @cust_id) + N' does not exist'
	END
	GO

-- ======================================================================================
-- test code
USE [betrugbank]
GO

DECLARE @cust_id int

EXECUTE [dm].[getCustomerInfo] 
   @cust_id='10001'
GO

EXECUTE [dm].[getCustomerInfo] 
   @cust_id=10000
GO

EXECUTE [dm].[getCustomerInfo] 
   @cust_id=jhg
GO