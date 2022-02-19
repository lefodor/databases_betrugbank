-- =============================================
-- Author:      Levente Fodor
-- Create date: 2022-02-13
-- Description: data generator
-- 	reset schema and generate random data
-- =============================================

-- reset schema
drop schema if exists dm cascade;
create schema if not exists dm;

-- ----------------------------------------- dm.d_date ----------------------------------
create table dm.d_date (
	id serial primary key,
	date_year int not null,
	date_month int not null,
	date_day int not null,
	date date not null,
	is_end_of_month bool not null
);

insert into dm.d_date(id, date_year, date_month, date_day, date, is_end_of_month)
values(-1, 1001, 1, 1, '1001-01-01'::date, FALSE);

insert into dm.d_date
select * 
	, case when date = (date_trunc('month', date) + interval '1 month - 1 day')::date 
			then true else false end as is_end_of_month
	--, ( date_trunc('MONTH', date) + interval '2 month - 1 day' ) :: date as next_date
from (
select row_number() over (order by date) as id
	, extract(year from date) as date_year
	, extract(month from date) as date_month
	, extract(day from date) as date_day
	, date::date
from generate_series('1900-01-01'::date,'2050-12-31'::date, '1 day'::interval) as t(date) ) t

-- ----------------------------------------- dm.d_interest rate -------------------------
create table dm.d_interest_rate (
	id serial primary key,
	name varchar(10) not null,
	interest_rate decimal not null
) ;

insert into dm.d_interest_rate (id, name, interest_rate)
values (-1, 'unknown', 0) ;

insert into dm.d_interest_rate
select row_number() over (order by interest_rate) as id
	, cast((interest_rate::decimal)/10000 as varchar(10)) as name
	, (interest_rate::decimal)/10000 as interest_rate
from generate_series(1,10000) as t(interest_rate);

-- ----------------------------------------- dm.d_account_type --------------------------
--drop table dm.d_account_type;
create table dm.d_account_type (
	id serial primary key,
	shortname varchar(5) not null,
	name varchar(32) not null
);

insert into dm.d_account_type (id, shortname, name)
values
(1,'D', 'bankaccount'),
(2,'S', 'savingaccount'),
(3,'HL', 'housingloan'),
(4,'PL', 'personalloan'),
(5,'CL', 'creditloan');

-- ----------------------------------------- dm.d_customer ------------------------------
create table dm.d_customer (
	id int primary key,
	customer_type_code varchar(2) not null,
	customer_type_name varchar(32) not null,
	company_registration_number varchar(32) not null,
	country_iso varchar(32) not null,
	education varchar(32),
	date_of_birth date,
	first_name varchar(32),
	family_name varchar(32)
);

insert into dm.d_customer (
id
, customer_type_code
, customer_type_name
, company_registration_number
, country_iso
, education
, date_of_birth
, first_name
, family_name
)
values
(10001, '01', 'private individual', 'unknown', 'HU', 'university', '1984-12-01', 'levente','fodor'),
(10002, '01', 'private individual', 'unknown', 'HU', null, '1990-06-30', 'levente','fodor2'),
(10003, '01', 'private individual', 'unknown', 'HU', 'secondary', '2016-04-02', 'mark','fodor'),
(20001, '02', 'micro-sme', '01-11-111111', 'HU', 'unknown', '2016-03-06', 'lebeton','ozlak'),
(20002, '02', 'micro-sme', '01-22-222222', 'GB', 'unknown', '2010-08-07', 'error','page'),
(20003, '02', 'micro-sme', '01-33-333333', 'DE', 'unknown', '2009-12-08', 'okos','ba'),
(20004, '02', 'micro-sme', '01-44-444444', 'AT', 'unknown', '2011-11-09', 'keine','ahnung'),
(30001, '03', 'corporate', '08-01-111111', 'US', 'unknown', '2000-01-06', 'id','software'),
(30002, '03', 'corporate', '08-02-222222', 'US', 'unknown', '2018-02-28', 'jp','moogen'),
(30003, '03', 'corporate', '08-03-333333', 'CN', 'unknown', '2019-12-08', 'import','export'),
(40001, '04', 'government', '00-10-345678', 'HU', 'unknown', '2000-01-06', 'el','emel'),
(40002, '04', 'government', '00-10-340000', 'AT', 'unknown', '2015-02-28', 'gruess','dich');

-- ----------------------------------------- dm.d_booking_code --------------------------
create table dm.d_booking_code (
	id serial primary key,
	booking_code varchar(2) not null,
	booking_name varchar(32) not null
);

insert into dm.d_booking_code (id, booking_code, booking_name)
values
(1, '01', 'loanrepayment'),
(2, '02', 'interest'),
(3, '03', 'fee'),
(4, '04', 'deposit'),
(5, '05', 'purchase');

-- ----------------------------------------- dm.d_account -------------------------------
create table dm.d_account (
	account_number int primary key,
	account_type_id int not null,
	opening_date_id int not null,
	closing_date_id int not null
);

insert into dm.d_account
select account_number
	, ( random() * (5-1) + 1) :: int as account_type_id
	, ( random() * (43000-38000) + 38000) :: int as opening_date_id
	, case when ( random() * (1-0) + 1) :: int = 1 then -1 else ( random() * (55100-44800) + 44800) :: int end as closing_date_id
from dm.tmp_cust_acct ;

-- ----------------------------------------- dm.f_transactions --------------------------
/*
create table dm.f_transactions (
	id serial primary key,
	date_id int not null,
	account_number bigint not null,
	booking_code varchar(2) not null,
	amount bigint
);

create table dm.tmp_cust_acct (
	customer_id int,
	account_number int primary key
);

insert into dm.tmp_cust_acct (customer_id, account_number)
values 
(10001, 11456789),
(10001, 13555562),
(10002, 65678754),
(10003, 98875556),
(20001, 59949923),
(20001, 20766825),
(20001, 20068630),
(20002, 13241579),
(20002, 61833390),
(20003, 84642257),
(20004, 23512496),
(20004, 82501707),
(20004, 79299653),
(20004, 47523436),
(30001, 91697692),
(30001, 19222816),
(30001, 11348330),
(30002, 33516327),
(30003, 38510071),
(40001, 84039601),
(40001, 97007074),
(40002, 67224356),
(40002, 49564892)

create or replace function RandomGet()
returns int
language plpgsql
as
$$
declare
	rand int;
	n int;
	date_id int ;
begin
	select floor(random()* (4-0) + 1) into rand ;
	select case 
			when rand = 1 then 44286
			when rand = 2 then 44296
			when rand = 3 then 44316
			when rand = 4 then 44347
			end into n;
	select distinct nth_value(id, n) over()
	into date_id
	from dm.d_date;
return date_id;
end;
$$;


truncate table dm.f_transactions ;
insert into dm.f_transactions
select row_number() over (order by amt) as id
, RandomGet() as date_id
, account_number
, case when amt < 0 then '05' else concat(0, ( random()*3+1 )::INT ) end as booking_code
, trunc(((random()*100000 + 1) * sign(amt))::decimal,2) as amount
from 
(select distinct customer_id, account_number from dm.tmp_cust_acct order by 1) as c
cross join generate_series(-50,150) as t(amt) ;
*/

-- ----------------------------------------- dm.f_account -------------------------------
create table dm.f_account (
	date_id int not null,
	account_number int not null,
	customer_id int,
	interest_rate_id int,
	balance int
) ;
alter table dm.f_account add primary key ( date_id, account_number );

insert into dm.f_account
select 
	acct.date_id
	, acct.account_number
	, acct.customer_id
	, acct.interest_rate_id
	, acct.ob + cb.cum_balance_delta as balance
from (
select tmp.account_number
	, tmp.customer_id
	, da.account_type_id
	, case 
		when da.account_type_id = 1  then ( random() * (25-1) + 1 ) :: int
		when da.account_type_id = 2  then ( random() * (200-100) + 100 ) :: int
		when da.account_type_id = 3  then ( random() * (1000-500) + 500 ) :: int
		when da.account_type_id = 4  then ( random() * (5000-1500) + 1500 ) :: int
		when da.account_type_id = 5  then ( random() * (8000-6000) + 6000 ) :: int
		end as interest_rate_id
	, case 
		when snap = 0 then 44285
		when snap = 1 then 44315
		when snap = 2 then 44346 end as date_id
	, ( case 
		when snap = 0 then '2021-03-31'
		when snap = 1 then '2021-04-30'
		when snap = 2 then '2021-05-31' end ) :: date as date
	, tmp.ob
from ( select *, ( random() * (20000000) - 10000000 ) :: int as ob from dm.tmp_cust_acct ) tmp
inner join dm.d_account da on da.account_number = tmp.account_number
inner join dm.d_account_type dat on da.account_type_id = dat.id 
cross join (select snap from generate_series(0,2) as snap) s
) acct
left join 
( select distinct (date_trunc('month', dd.date) + interval '1 month - 1 day')::date as end_of_month
	, ftr.account_number
	, sum(case when (date_trunc('month', dd.date) + interval '1 month - 1 day')::date = '2021-03-31' 
				then 0 
				else ftr.amount end) 
				over (partition by ftr.account_number order by ftr.account_number, (date_trunc('month', dd.date) + interval '1 month - 1 day')::date) as cum_balance_delta
from dm.f_transactions ftr
inner join dm.d_date dd 
on ftr.date_id = dd.id ) as cb on cb.account_number = acct.account_number and cb.end_of_month = acct.date
order by 2,1 ;

-- ----------------------------------------- dm.f_expected_payment ----------------------
create table dm.f_expected_payment (
	date_id int not null,
	end_of_month date not null,
	account_number int not null,
	expected_payment numeric,
	effective_payment numeric
);
alter table dm.f_expected_payment add primary key ( date_id, account_number );

insert into dm.f_expected_payment
select dde.id as date_id
	, end_of_month
	, account_number
	, expected_payment
	, effective_payment
from(
	select (date_trunc('month', dd.date) + interval '1 month - 1 day')::date as end_of_month
		, ftr.account_number
		, ( sum(ftr.amount) + sign(greatest(0,random() - 0.8)) * ((random() * (98) + 2) :: int) * 1000 ) :: int as expected_payment
		, sum(ftr.amount) as effective_payment
	from dm.f_transactions ftr
	inner join dm.d_date dd 
	on ftr.date_id = dd.id 
	group by 1,2 ) arrears 
	inner join dm.d_date dde
	on dde.date = arrears.end_of_month
order by 2,3;

-- ----------------------------------------- dm.f_arrears -------------------------------
create table dm.f_arrears (
	date_id int not null,
	account_number int not null,
	arrears numeric
);
alter table dm.f_arrears add primary key ( date_id, account_number );

insert into dm.f_arrears
select date_id
	, account_number
	, expected_payment - effective_payment as arrears
from dm.f_expected_payment
where expected_payment - effective_payment != 0;
