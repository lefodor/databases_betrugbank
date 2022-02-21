-- =============================================
-- Author:      Levente Fodor
-- Create date: 2022-02-21
-- Description: queries
-- 	Queries for database betrugbank
-- =============================================

-- ----------------------------------------- q#01 ----------------------------------
select distinct country_iso 
from dm.d_customer; 

-- ----------------------------------------- q#02 ----------------------------------
select count(distinct account_number)
from dm.d_account

-- ----------------------------------------- q#03 ----------------------------------
select end_of_month
	, sum(effective_payment) as effective_payments
from dm.f_expected_payment
group by end_of_month
order by end_of_month;

-- ----------------------------------------- q#04 ----------------------------------
select end_of_month
	, sum(expected_payment) as expected_payments
from dm.f_expected_payment
group by end_of_month
order by end_of_month;

-- =================================================================================
-- ----------------------------------------- q#05 ----------------------------------
-- deposit type product balance
select dc.customer_type_name
	, sum(balance) as exposure
from dm.f_account fa
inner join dm.d_account da on da.account_number = fa.account_number 
inner join dm.d_account_type dat on dat.id = da.account_type_id 
inner join dm.d_date dd on dd.id = fa.date_id
inner join dm.d_customer dc on dc.id = fa.customer_id 
where dat.id in (1,2)
and dd.date='2021-04-30'
group by dc.customer_type_name ;

-- loan type product balance
select dc.customer_type_name
	, sum(balance) as exposure
from dm.f_account fa
inner join dm.d_account da on da.account_number = fa.account_number 
inner join dm.d_account_type dat on dat.id = da.account_type_id 
inner join dm.d_date dd on dd.id = fa.date_id
inner join dm.d_customer dc on dc.id = fa.customer_id 
where dat.id not in (1,2)
and dd.date='2021-04-30'
group by dc.customer_type_name ;

-- ----------------------------------------- q#06 ----------------------------------
select dc.country_iso
	, count( distinct case when dat.name in ('bankaccount','savingaccount') then fa.customer_id else null end ) as cnt_deposit_customers
	, sum( case when dat.name in ('bankaccount','savingaccount') then balance else 0 end ) as sum_deposit
from dm.f_account fa
inner join dm.d_account da on da.account_number = fa.account_number 
inner join dm.d_account_type dat on dat.id = da.account_type_id 
inner join dm.d_date dd on dd.id = fa.date_id
inner join dm.d_customer dc on dc.id = fa.customer_id 
where dd.date='2021-04-30'
group by dc.country_iso ;

-- ----------------------------------------- q#07 ----------------------------------
select dc.id as customer_id
	, sum(far.arrears) as sum_arrears
from dm.f_account fa
inner join dm.f_arrears far on far.date_id = fa.date_id and far.account_number = fa.account_number
inner join dm.d_date dd on dd.id = fa.date_id
inner join dm.d_customer dc on dc.id = fa.customer_id
where dd.date>='2021-03-31' and dd.date<='2021-05-31'
group by dc.id ;

-- ----------------------------------------- q#08 ----------------------------------
select date
	, avg(exp(intercept + var1 + var2 + var3 + var4) / (1 + exp(intercept + var1 + var2 + var3 + var4))) as prob
from (
select distinct dd.date, dc.customer_type_name, dc.country_iso, ds.intercept, fs.*
from dm.f_scoring fs
inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
inner join dm.d_date dd on dd.id = fs.date_id 
inner join dm.f_account fa on fa.customer_id = fs.customer_id and fa.date_id = fs.date_id
inner join dm.d_account da on da.account_number = fa.account_number
inner join dm.d_account_type dat on dat.id = da.account_type_id 
inner join dm.d_customer dc on dc.id = fs.customer_id
where dd.date>='2021-03-31' and dd.date<='2021-05-31'
and dat.name not in('bankaccount','savingaccount')) v
group by date;

-- ----------------------------------------- q#09 ----------------------------------
select customer_type_name
	, avg(exp(intercept + var1 + var2 + var3 + var4) / (1 + exp(intercept + var1 + var2 + var3 + var4))) as prob
from (
select distinct dd.date, dc.customer_type_name, dc.country_iso, ds.intercept, fs.*
from dm.f_scoring fs
inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
inner join dm.d_date dd on dd.id = fs.date_id 
inner join dm.f_account fa on fa.customer_id = fs.customer_id and fa.date_id = fs.date_id
inner join dm.d_account da on da.account_number = fa.account_number
inner join dm.d_account_type dat on dat.id = da.account_type_id 
inner join dm.d_customer dc on dc.id = fs.customer_id
where dd.date='2021-04-30'
and dat.name not in('bankaccount','savingaccount')) v
group by customer_type_name;

-- ----------------------------------------- q#10 ----------------------------------
select country_iso
	, avg(exp(intercept + var1 + var2 + var3 + var4) / (1 + exp(intercept + var1 + var2 + var3 + var4))) as prob
from (
select distinct dd.date, dc.customer_type_name, dc.country_iso, ds.intercept, fs.*
from dm.f_scoring fs
inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
inner join dm.d_date dd on dd.id = fs.date_id 
inner join dm.f_account fa on fa.customer_id = fs.customer_id and fa.date_id = fs.date_id
inner join dm.d_account da on da.account_number = fa.account_number
inner join dm.d_account_type dat on dat.id = da.account_type_id 
inner join dm.d_customer dc on dc.id = fs.customer_id
where dd.date='2021-04-30'
and dat.name not in('bankaccount','savingaccount')) v
group by country_iso;

-- ----------------------------------------- q#11 ----------------------------------
select date
	, sum( balance * ( exp(intercept + var1 + var2 + var3 + var4) / (1 + exp(intercept + var1 + var2 + var3 + var4))) ) /
		sum( balance ) as prob_wgt
from (
	select distinct dd.date, dc.customer_type_name, dc.country_iso, ds.intercept, fs.*
	, (select sum(balance) 
		from  dm.f_account fa2
		where fa2.date_id = fa.date_id and fa2.customer_id = fa.customer_id
		group by date_id, customer_id
		) as balance
	from dm.f_scoring fs
	inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
	inner join dm.d_date dd on dd.id = fs.date_id 
	inner join dm.f_account fa on fa.customer_id = fs.customer_id and fa.date_id = fs.date_id
	inner join dm.d_account da on da.account_number = fa.account_number
	inner join dm.d_account_type dat on dat.id = da.account_type_id 
	inner join dm.d_customer dc on dc.id = fs.customer_id
	where dd.date>='2021-03-31' and dd.date<='2021-05-31'
	and dat.name not in('bankaccount','savingaccount') ) v
group by date;

-- ----------------------------------------- q#12 ----------------------------------

-- ----------------------------------------- q#13 ----------------------------------

-- =================================================================================
