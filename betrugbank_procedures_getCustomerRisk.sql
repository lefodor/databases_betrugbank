USE [betrugbank]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Levente Fodor
-- Create date: 2022-03-01
-- Description:	procedure getCustomerRisk2Date for betrugbank db
-- =============================================
CREATE OR ALTER PROCEDURE [dm].[getCustomerRisk2Date]
	-- Add the parameters for the stored procedure here
	@cust_id VARCHAR(5),
	@risk_date VARCHAR(10)
AS

IF @cust_id IS NULL
OR TRY_CAST(@cust_id AS INTEGER) IS NULL
OR TRY_CAST(@cust_id AS INTEGER) < 10000 OR TRY_CAST(@cust_id AS INTEGER) > 99999
	PRINT N'Please enter valid customer_id' ;
ELSE IF TRY_CAST(@risk_date AS DATE) > Getdate()
	PRINT N'Please enter date in past' ;
ELSE
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		SET @cust_id = TRY_CAST(@cust_id AS INTEGER)
		IF TRY_CAST(@risk_date AS DATE) IS NULL
			BEGIN
			SET @risk_date = (SELECT MAX(dd.date) 
								FROM dm.d_date dd
								INNER JOIN dm.f_scoring fs ON fs.date_id = dd.id
								WHERE fs.customer_id = @cust_id
								AND dd.is_end_of_month=1 
								AND dd.date < Getdate() );
			END
		ELSE IF TRY_CAST(@risk_date AS DATE) != EOMONTH(@risk_date,0)
			SET @risk_date = EOMONTH(@risk_date,-1) ;
		ELSE
			SET @risk_date = TRY_CAST(@risk_date AS DATE) ;

		DECLARE @is_risk_date_avail BIT ;
		SET @is_risk_date_avail = (SELECT CASE WHEN dd.id IS NULL THEN 0 ELSE 1 END
									FROM dm.d_date dd
									INNER JOIN dm.f_scoring fs ON fs.date_id = dd.id
									WHERE fs.customer_id = @cust_id
									AND dd.date = @risk_date )
		PRINT @is_risk_date_avail ;
		IF NOT EXISTS (SELECT CASE WHEN dd.id IS NULL THEN 0 ELSE 1 END
						FROM dm.d_date dd
						INNER JOIN dm.f_scoring fs ON fs.date_id = dd.id
						WHERE fs.customer_id = @cust_id
						AND dd.date = @risk_date )
			PRINT  N'No score available for customer as of ' + @risk_date ;
		ELSE
			-- Insert statements for procedure here
			select
			date,
			customer_id,
			customer_type_name,
			exp(intercept + var1 + var2 + var3 + var4) / 
				(1 + exp(intercept + var1 + var2 + var3 + var4)) as pd,
			balance,
			exp(intercept + var1 + var2 + var3 + var4) / 
				(1 + exp(intercept + var1 + var2 + var3 + var4)) * balance as expected_loss
			from
				(
				select
					dd.date,
					dc.customer_type_name,
					dc.country_iso,
					fs.customer_id,
					fs.scorecard_id,
					ds.intercept,
					fs.var1,
					fs.var2,
					fs.var3,
					fs.var4,
					sum(fa.balance) as balance
				from
					dm.f_scoring fs
				inner join dm.d_scorecard ds on
					ds.id = fs.scorecard_id
				inner join dm.d_date dd on
					dd.id = fs.date_id
				inner join dm.d_customer dc on
					dc.id = fs.customer_id
				inner join dm.b_cust_acct bca on
					bca.customer_id = fs.customer_id
				inner join dm.f_account fa on
					fa.account_number = bca.account_number
				inner join dm.d_account da on
					da.account_number = fa.account_number
				inner join dm.d_account_type dat on
					dat.id = da.account_type_id
				where
					dd.date = @risk_date
					and dc.id = @cust_id 
				group by
					dd.date,
					dc.customer_type_name,
					dc.country_iso,
					fs.customer_id,
					fs.scorecard_id,
					ds.intercept,
					fs.var1,
					fs.var2,
					fs.var3,
					fs.var4 ) v ;
	END
GO

-- ======================================================================================
-- test code
USE [betrugbank]
GO

DECLARE @cust_id int
DECLARE @risk_date date

EXECUTE [dm].[getCustomerRisk2Date] 
   @cust_id='20001',
   @risk_date='2021-04-30'
GO

EXECUTE [dm].[getCustomerRisk2Date] 
   @cust_id='20001',
   @risk_date='2030-04-30'
GO

EXECUTE [dm].[getCustomerRisk2Date] 
   @cust_id='20001',
   @risk_date=NULL
GO

EXECUTE [dm].[getCustomerRisk2Date] 
   @cust_id='20001',
   @risk_date='2021-04-11'
GO

EXECUTE [dm].[getCustomerRisk2Date] 
   @cust_id=10001,
   @risk_date='2021-03-30'
GO