CREATE TABLE dm.b_cust_acct (
	customer_id int4 NOT NULL,
	account_number int4 NOT NULL,
	customer_role bpchar(10) NOT NULL,
	CONSTRAINT b_cust_acct_pkey PRIMARY KEY (account_number),
	CONSTRAINT b_cust_acct_account_number_fkey FOREIGN KEY (account_number) REFERENCES dm.d_account(account_number),
	CONSTRAINT b_cust_acct_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES dm.d_customer(id)
);

CREATE TABLE dm.d_account (
	account_number int4 NOT NULL,
	account_type_id int4 NOT NULL,
	opening_date_id int4 NOT NULL,
	closing_date_id int4 NOT NULL,
	CONSTRAINT d_account_pkey PRIMARY KEY (account_number),
	CONSTRAINT d_account_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES dm.d_account_type(id)
);

CREATE TABLE dm.d_account_type (
	id serial4 NOT NULL,
	shortname varchar(5) NOT NULL,
	"name" varchar(32) NOT NULL,
	CONSTRAINT d_account_type_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_booking_code (
	id serial4 NOT NULL,
	booking_code varchar(2) NOT NULL,
	booking_name varchar(32) NOT NULL,
	CONSTRAINT d_booking_code_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_customer (
	id int4 NOT NULL,
	customer_type_code varchar(2) NOT NULL,
	customer_type_name varchar(32) NOT NULL,
	scorecard_id int4 NOT NULL,
	company_registration_number varchar(32) NOT NULL,
	country_iso varchar(32) NOT NULL,
	education varchar(32) NULL,
	date_of_birth date NULL,
	first_name varchar(32) NULL,
	family_name varchar(32) NULL,
	CONSTRAINT d_customer_pkey PRIMARY KEY (id),
	CONSTRAINT d_customer_scorecard_id_fkey FOREIGN KEY (scorecard_id) REFERENCES dm.d_scorecard(id)
);

CREATE TABLE dm.d_date (
	id serial4 NOT NULL,
	date_year int4 NOT NULL,
	date_month int4 NOT NULL,
	date_day int4 NOT NULL,
	"date" date NOT NULL,
	is_end_of_month bool NOT NULL,
	CONSTRAINT d_date_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_interest_rate (
	id serial4 NOT NULL,
	"name" varchar(10) NOT NULL,
	interest_rate numeric NOT NULL,
	CONSTRAINT d_interest_rate_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.d_scorecard (
	id serial4 NOT NULL,
	scorecard_name varchar(32) NOT NULL,
	intercept numeric NOT NULL,
	var1 numeric NOT NULL,
	var2 numeric NOT NULL,
	var3 numeric NOT NULL,
	var4 numeric NOT NULL,
	CONSTRAINT d_scorecard_pkey PRIMARY KEY (id)
);

CREATE TABLE dm.f_account (
	date_id int4 NOT NULL,
	account_number int4 NOT NULL,
	interest_rate_id int4 NULL,
	balance int4 NULL,
	CONSTRAINT f_account_pkey PRIMARY KEY (date_id, account_number),
	CONSTRAINT f_account_account_number_fkey FOREIGN KEY (account_number) REFERENCES dm.d_account(account_number),
	CONSTRAINT f_account_date_id_fkey FOREIGN KEY (date_id) REFERENCES dm.d_date(id),
	CONSTRAINT f_account_interest_rate_id_fkey FOREIGN KEY (interest_rate_id) REFERENCES dm.d_interest_rate(id)
);

CREATE TABLE dm.f_arrears (
	date_id int4 NOT NULL,
	account_number int4 NOT NULL,
	arrears numeric NULL,
	CONSTRAINT f_arrears_pkey PRIMARY KEY (date_id, account_number),
	CONSTRAINT f_arrears_account_number_fkey FOREIGN KEY (account_number) REFERENCES dm.d_account(account_number),
	CONSTRAINT f_arrears_date_id_fkey FOREIGN KEY (date_id) REFERENCES dm.d_date(id)
);

CREATE TABLE dm.f_expected_payment (
	date_id int4 NOT NULL,
	end_of_month date NOT NULL,
	account_number int4 NOT NULL,
	expected_payment numeric NULL,
	effective_payment numeric NULL,
	CONSTRAINT f_expected_payment_pkey PRIMARY KEY (date_id, account_number),
	CONSTRAINT f_expected_payment_account_number_fkey FOREIGN KEY (account_number) REFERENCES dm.d_account(account_number),
	CONSTRAINT f_expected_payment_date_id_fkey FOREIGN KEY (date_id) REFERENCES dm.d_date(id)
);

CREATE TABLE dm.f_scoring (
	date_id int4 NOT NULL,
	customer_id int4 NOT NULL,
	scorecard_id int4 NOT NULL,
	var1 numeric NULL,
	var2 numeric NULL,
	var3 numeric NULL,
	var4 numeric NULL,
	CONSTRAINT f_scoring_pkey PRIMARY KEY (date_id, customer_id),
	CONSTRAINT f_scoring_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES dm.d_customer(id),
	CONSTRAINT f_scoring_date_id_fkey FOREIGN KEY (date_id) REFERENCES dm.d_date(id),
	CONSTRAINT f_scoring_scorecard_id_fkey FOREIGN KEY (scorecard_id) REFERENCES dm.d_scorecard(id)
);

CREATE TABLE dm.f_transactions (
	id int4 NOT NULL,
	date_id int4 NULL,
	account_number int8 NULL,
	booking_code_id int4 NULL,
	amount int8 NULL,
	CONSTRAINT f_transactions_pkey PRIMARY KEY (id),
	CONSTRAINT f_transactions_account_number_fkey FOREIGN KEY (account_number) REFERENCES dm.d_account(account_number),
	CONSTRAINT f_transactions_booking_code_id_fkey FOREIGN KEY (booking_code_id) REFERENCES dm.d_booking_code(id),
	CONSTRAINT f_transactions_date_id_fkey FOREIGN KEY (date_id) REFERENCES dm.d_date(id)
);