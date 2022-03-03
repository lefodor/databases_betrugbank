-- =============================================
-- Author:      Levente Fodor
-- Create date: 2022-02-27
-- Description: db setup
-- 	create db and tables
--  bulk load
-- =============================================

-- ======================================================================================
-- setup db

/****** Object:  Database [betrugbank]    Script Date: 2/27/2022 8:35:29 PM ******/
CREATE DATABASE [betrugbank]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'betrugbank', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\betrugbank.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'betrugbank_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\betrugbank_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [betrugbank].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [betrugbank] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [betrugbank] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [betrugbank] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [betrugbank] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [betrugbank] SET ARITHABORT OFF 
GO

ALTER DATABASE [betrugbank] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [betrugbank] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [betrugbank] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [betrugbank] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [betrugbank] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [betrugbank] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [betrugbank] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [betrugbank] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [betrugbank] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [betrugbank] SET  DISABLE_BROKER 
GO

ALTER DATABASE [betrugbank] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [betrugbank] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [betrugbank] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [betrugbank] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [betrugbank] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [betrugbank] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [betrugbank] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [betrugbank] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [betrugbank] SET  MULTI_USER 
GO

ALTER DATABASE [betrugbank] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [betrugbank] SET DB_CHAINING OFF 
GO

ALTER DATABASE [betrugbank] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [betrugbank] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [betrugbank] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [betrugbank] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [betrugbank] SET QUERY_STORE = OFF
GO

ALTER DATABASE [betrugbank] SET  READ_WRITE 
GO

-- ======================================================================================
-- setup schema
USE [betrugbank]
GO

/****** Object:  Schema [dm]    Script Date: 2/27/2022 8:41:55 PM ******/
CREATE SCHEMA [dm]
GO

-- ======================================================================================
-- create tables
USE [betrugbank]
GO

CREATE TABLE dm.b_cust_acct (
	customer_id int NOT NULL,
	account_number int NOT NULL,
	customer_role varchar(10) NOT NULL,
	CONSTRAINT b_cust_acct_pkey PRIMARY KEY (customer_id, account_number)
);

CREATE TABLE dm.d_account (
	account_number int NOT NULL,
	account_type_id int NOT NULL,
	opening_date_id int NOT NULL,
	closing_date_id int NOT NULL,
	CONSTRAINT d_account_pkey PRIMARY KEY (account_number)
);

CREATE TABLE dm.d_account_type (
	id int identity(1,1) NOT NULL,
	shortname varchar(5) NOT NULL,
	"name" varchar(32) NOT NULL,
	CONSTRAINT d_account_type_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_booking_code (
	id int identity(1,1) NOT NULL,
	booking_code varchar(2) NOT NULL,
	booking_name varchar(32) NOT NULL,
	CONSTRAINT d_booking_code_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_customer (
	id int NOT NULL,
	customer_type_code varchar(2) NOT NULL,
	customer_type_name varchar(32) NOT NULL,
	scorecard_id int NOT NULL,
	company_registration_number varchar(32) NULL,
	country_iso varchar(32) NOT NULL,
	education varchar(32) NULL,
	date_of_birth date NULL,
	first_name varchar(32) NULL,
	family_name varchar(32) NULL,
	CONSTRAINT d_customer_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_date (
	id int identity(1,1) NOT NULL PRIMARY KEY,
	date_year int NOT NULL,
	date_month int NOT NULL,
	date_day int NOT NULL,
	"date" date NOT NULL,
	is_end_of_month BIT NOT NULL
);

CREATE TABLE dm.d_interest_rate (
	id int identity(1,1) NOT NULL,
	"name" varchar(10) NOT NULL,
	interest_rate decimal(18,5) NOT NULL,
	CONSTRAINT d_interest_rate_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_scorecard (
	id int identity(1,1) NOT NULL,
	scorecard_name varchar(32) NOT NULL,
	intercept decimal(18,5) NOT NULL,
	var1 decimal(18,5) NOT NULL,
	var2 decimal(18,5) NOT NULL,
	var3 decimal(18,5) NOT NULL,
	var4 decimal(18,5) NOT NULL,
	CONSTRAINT d_scorecard_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.f_account (
	date_id int NOT NULL,
	account_number int NOT NULL,
	interest_rate_id int NULL,
	balance numeric NULL,
	CONSTRAINT f_account_pkey PRIMARY KEY (date_id, account_number)
);

CREATE TABLE dm.f_arrears (
	date_id int NOT NULL,
	account_number int NOT NULL,
	arrears numeric NULL,
	CONSTRAINT f_arrears_pkey PRIMARY KEY (date_id, account_number)
);

CREATE TABLE dm.f_expected_payment (
	date_id int NOT NULL,
	end_of_month date NOT NULL,
	account_number int NOT NULL,
	expected_payment numeric NULL,
	effective_payment numeric NULL,
	CONSTRAINT f_expected_payment_pkey PRIMARY KEY (date_id, account_number)
);

CREATE TABLE dm.f_scoring (
	date_id int NOT NULL,
	customer_id int NOT NULL,
	scorecard_id int NOT NULL,
	var1 decimal(18,5) NULL,
	var2 decimal(18,5) NULL,
	var3 decimal(18,5) NULL,
	var4 decimal(18,5) NULL,
	CONSTRAINT f_scoring_pkey PRIMARY KEY (date_id, customer_id)
);

CREATE TABLE dm.f_transactions (
	id int NOT NULL,
	date_id int NULL,
	account_number int NULL,
	booking_code_id int NULL,
	amount numeric NULL,
	CONSTRAINT f_transactions_pkey PRIMARY KEY (id)
);

-- ======================================================================================
-- bulk load files
USE [betrugbank]
GO

BULK INSERT dm.b_cust_acct
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\b_cust_acct.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_account
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_account.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_account_type
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_account_type.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_booking_code
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_booking_code.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_customer
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_customer.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_date
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_date.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_interest_rate
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_interest_rate.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.d_scorecard
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\d_scorecard.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.f_account
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\f_account.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.f_arrears
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\f_arrears.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.f_expected_payment
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\f_expected_payment.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.f_scoring
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\f_scoring.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

BULK INSERT dm.f_transactions
FROM 'C:\Users\leven\projects\szeuni\databases\betrugbank\db\f_transactions.csv'
WITH
(
		FIELDTERMINATOR=';',
		ROWTERMINATOR='\n',
		DATAFILETYPE = 'char',
        FIRSTROW=2
);
GO

-- ======================================================================================
-- add foreign keys
USE [betrugbank]
GO

-- ----------------------------------------- dm.b_cust_acct -----------------------------
ALTER TABLE dm.b_cust_acct WITH CHECK ADD CONSTRAINT b_cust_acct_account_number_fkey FOREIGN KEY (account_number) 
REFERENCES dm.d_account(account_number)
GO

ALTER TABLE dm.b_cust_acct WITH CHECK ADD CONSTRAINT b_cust_acct_customer_id_fkey FOREIGN KEY (customer_id) 
REFERENCES dm.d_customer(id)
GO

ALTER TABLE [dm].[b_cust_acct] CHECK CONSTRAINT [b_cust_acct_account_number_fkey]
GO

ALTER TABLE [dm].[b_cust_acct] CHECK CONSTRAINT [b_cust_acct_customer_id_fkey]
GO

-- ----------------------------------------- dm.d_account -------------------------------
ALTER TABLE dm.d_account WITH CHECK ADD CONSTRAINT d_account_account_type_id_fkey FOREIGN KEY (account_type_id) 
REFERENCES dm.d_account_type(id)
GO

ALTER TABLE [dm].[d_account] CHECK CONSTRAINT [d_account_account_type_id_fkey]
GO

-- ----------------------------------------- dm.d_customer ------------------------------
ALTER TABLE dm.d_customer WITH CHECK ADD CONSTRAINT d_customer_scorecard_id_fkey FOREIGN KEY (scorecard_id) 
REFERENCES dm.d_scorecard(id)
GO

ALTER TABLE [dm].[d_customer] CHECK CONSTRAINT [d_customer_scorecard_id_fkey]
GO

-- ----------------------------------------- dm.f_account -------------------------------
ALTER TABLE dm.f_account WITH CHECK ADD CONSTRAINT f_account_account_number_fkey FOREIGN KEY (account_number) 
REFERENCES dm.d_account(account_number)
GO

ALTER TABLE dm.f_account WITH CHECK ADD CONSTRAINT f_account_date_id_fkey FOREIGN KEY (date_id) 
REFERENCES dm.d_date(id)
GO

ALTER TABLE dm.f_account WITH CHECK ADD CONSTRAINT f_account_interest_rate_id_fkey FOREIGN KEY (interest_rate_id) 
REFERENCES dm.d_interest_rate(id)
GO

ALTER TABLE [dm].[f_account] CHECK CONSTRAINT [f_account_account_number_fkey]
GO

ALTER TABLE [dm].[f_account] CHECK CONSTRAINT [f_account_date_id_fkey]
GO

ALTER TABLE [dm].[f_account] CHECK CONSTRAINT [f_account_interest_rate_id_fkey]
GO

-- ----------------------------------------- dm.f_transactions --------------------------
ALTER TABLE dm.f_transactions WITH CHECK ADD CONSTRAINT f_transactions_account_number_fkey FOREIGN KEY (account_number) 
REFERENCES dm.d_account(account_number)
GO

ALTER TABLE dm.f_transactions WITH CHECK ADD CONSTRAINT f_transactions_booking_code_id_fkey FOREIGN KEY (booking_code_id) 
REFERENCES dm.d_booking_code(id)
GO

ALTER TABLE dm.f_transactions WITH CHECK ADD CONSTRAINT f_transactions_date_id_fkey FOREIGN KEY (date_id) 
REFERENCES dm.d_date(id)
GO

ALTER TABLE [dm].[f_transactions] CHECK CONSTRAINT [f_transactions_account_number_fkey]
GO

ALTER TABLE [dm].[f_transactions] CHECK CONSTRAINT [f_transactions_booking_code_id_fkey]
GO

ALTER TABLE [dm].[f_transactions] CHECK CONSTRAINT [f_transactions_date_id_fkey]
GO

-- ----------------------------------------- dm.f_expected_payment ----------------------
ALTER TABLE dm.f_expected_payment WITH CHECK ADD CONSTRAINT f_expected_payment_account_number_fkey FOREIGN KEY (account_number) 
REFERENCES dm.d_account(account_number)
GO

ALTER TABLE dm.f_expected_payment WITH CHECK ADD CONSTRAINT f_expected_payment_date_id_fkey FOREIGN KEY (date_id) 
REFERENCES dm.d_date(id)
GO

ALTER TABLE [dm].[f_expected_payment] CHECK CONSTRAINT [f_expected_payment_account_number_fkey]
GO

ALTER TABLE [dm].[f_expected_payment] CHECK CONSTRAINT [f_expected_payment_date_id_fkey]
GO

-- ----------------------------------------- dm.f_arrears -------------------------------
ALTER TABLE dm.f_arrears WITH CHECK ADD CONSTRAINT f_arrears_account_number_fkey FOREIGN KEY (account_number) 
REFERENCES dm.d_account(account_number) 
GO

ALTER TABLE dm.f_arrears WITH CHECK ADD CONSTRAINT f_arrears_date_id_fkey FOREIGN KEY (date_id) 
REFERENCES dm.d_date(id)
GO

ALTER TABLE [dm].[f_arrears] CHECK CONSTRAINT [f_arrears_account_number_fkey]
GO

ALTER TABLE [dm].[f_arrears] CHECK CONSTRAINT [f_arrears_date_id_fkey]
GO

-- ----------------------------------------- dm.f_scoring -------------------------------
ALTER TABLE dm.f_scoring WITH CHECK ADD CONSTRAINT f_scoring_customer_id_fkey FOREIGN KEY (customer_id) 
REFERENCES dm.d_customer(id)
GO

ALTER TABLE dm.f_scoring WITH CHECK ADD CONSTRAINT f_scoring_date_id_fkey FOREIGN KEY (date_id) 
REFERENCES dm.d_date(id)
GO

ALTER TABLE dm.f_scoring WITH CHECK ADD CONSTRAINT f_scoring_scorecard_id_fkey FOREIGN KEY (scorecard_id) 
REFERENCES dm.d_scorecard(id)
GO

ALTER TABLE [dm].[f_scoring] CHECK CONSTRAINT [f_scoring_customer_id_fkey]
GO

ALTER TABLE [dm].[f_scoring] CHECK CONSTRAINT [f_scoring_date_id_fkey]
GO

ALTER TABLE [dm].[f_scoring] CHECK CONSTRAINT [f_scoring_scorecard_id_fkey]
GO

-- ======================================================================================
-- add constraints
USE [betrugbank]
GO

ALTER TABLE [dm].[b_cust_acct]  WITH CHECK ADD  CONSTRAINT [CK_b_cust_acct_account_number] CHECK  (([account_number]>=(10000000) AND [account_number]<=(99999999)))
GO

ALTER TABLE [dm].[b_cust_acct] CHECK CONSTRAINT [CK_b_cust_acct_account_number]
GO

ALTER TABLE [dm].[b_cust_acct]  WITH CHECK ADD  CONSTRAINT [CK_b_cust_acct_customer_id] CHECK  (([customer_id]>=(10000) AND [customer_id]<=(99999)))
GO

ALTER TABLE [dm].[b_cust_acct] CHECK CONSTRAINT [CK_b_cust_acct_customer_id]
GO

ALTER TABLE [dm].[b_cust_acct]  WITH CHECK ADD  CONSTRAINT [CK_b_cust_acct_customer_role] CHECK  (([customer_role] like 'owner' OR [customer_role] like 'coowner[0-9][0-9]'))
GO

ALTER TABLE [dm].[b_cust_acct] CHECK CONSTRAINT [CK_b_cust_acct_customer_role]
GO

ALTER TABLE [dm].[d_customer]  WITH CHECK ADD  CONSTRAINT [CK_d_customer_customer_id] CHECK  (([id]>=(10000) AND [id]<=(99999)))
GO

ALTER TABLE [dm].[d_customer] CHECK CONSTRAINT [CK_d_customer_customer_id]
GO

ALTER TABLE [dm].[f_scoring]  WITH CHECK ADD  CONSTRAINT [CK_f_scoring_customer_id] CHECK  (([customer_id]>=(10000) AND [customer_id]<=(99999)))
GO

ALTER TABLE [dm].[f_scoring] CHECK CONSTRAINT [CK_f_scoring_customer_id]
GO

ALTER TABLE [dm].[d_account]  WITH CHECK ADD  CONSTRAINT [CK_d_account_account_number] CHECK  (([account_number]>=(10000000) AND [account_number]<=(99999999)))
GO

ALTER TABLE [dm].[d_account] CHECK CONSTRAINT [CK_d_account_account_number]
GO

ALTER TABLE [dm].[f_account]  WITH CHECK ADD  CONSTRAINT [CK_f_account_account_number] CHECK  (([account_number]>=(10000000) AND [account_number]<=(99999999)))
GO

ALTER TABLE [dm].[f_account] CHECK CONSTRAINT [CK_f_account_account_number]
GO

ALTER TABLE [dm].[f_arrears]  WITH CHECK ADD  CONSTRAINT [CK_f_arrears_account_number] CHECK  (([account_number]>=(10000000) AND [account_number]<=(99999999)))
GO

ALTER TABLE [dm].[f_arrears] CHECK CONSTRAINT [CK_f_arrears_account_number]
GO

ALTER TABLE [dm].[f_expected_payment]  WITH CHECK ADD  CONSTRAINT [CK_f_expected_payment_account_number] CHECK  (([account_number]>=(10000000) AND [account_number]<=(99999999)))
GO

ALTER TABLE [dm].[f_expected_payment] CHECK CONSTRAINT [CK_f_expected_payment_account_number]
GO

ALTER TABLE [dm].[f_transactions]  WITH CHECK ADD  CONSTRAINT [CK_f_transactions_account_number] CHECK  (([account_number]>=(10000000) AND [account_number]<=(99999999)))
GO

ALTER TABLE [dm].[f_transactions] CHECK CONSTRAINT [CK_f_transactions_account_number]
GO

/*
drop table dm.b_cust_acct;
drop table dm.d_account;
drop table dm.d_account_type;
drop table dm.d_booking_code;
drop table dm.d_customer;
drop table dm.d_date;
drop table dm.d_interest_rate;
drop table dm.d_scorecard;
drop table dm.f_account;
drop table dm.f_arrears;
drop table dm.f_expected_payment;
drop table dm.f_scoring;
drop table dm.f_transactions;
*/