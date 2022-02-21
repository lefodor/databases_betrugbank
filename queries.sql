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
select dc.customer_type_name
	, sum(fa.balance) as balance
from dm.f_account fa
inner join dm.d_date dd on dd.id = fa.date_id
inner join dm.d_customer dc on dc.id = fa.customer_id
where dd.date='2021-04-30'
group by dc.customer_type_name ;

-- ----------------------------------------- q#06 ----------------------------------
select dc.country_iso
	, count(distinct dc.id) as cnt_customer
	, sum(fa.balance) as sum_balance
from dm.f_account fa
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
select dd.date
	, avg(exp(ds.intercept + fs.var1 + fs.var2 + fs.var3 + fs.var4) / (1 + exp(ds.intercept + fs.var1 + fs.var2 + fs.var3 + fs.var4))) as prob
from dm.f_scoring fs
inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
inner join dm.d_date dd on dd.id = fs.date_id 
where dd.date>='2021-03-31' and dd.date<='2021-05-31'
group by dd.date;

-- ----------------------------------------- q#09 ----------------------------------
select dc.customer_type_name
	, avg(exp(ds.intercept + fs.var1 + fs.var2 + fs.var3 + fs.var4) / (1 + exp(ds.intercept + fs.var1 + fs.var2 + fs.var3 + fs.var4))) as prob
from dm.f_scoring fs
inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
inner join dm.d_customer dc on dc.id = fs.customer_id
inner join dm.d_date dd on dd.id = fs.date_id 
where dd.date='2021-04-30'
group by dc.customer_type_name;

-- ----------------------------------------- q#10 ----------------------------------
select dc.country_iso
	, avg(exp(ds.intercept + fs.var1 + fs.var2 + fs.var3 + fs.var4) / (1 + exp(ds.intercept + fs.var1 + fs.var2 + fs.var3 + fs.var4))) as prob
from dm.f_scoring fs
inner join dm.d_scorecard ds on ds.id = fs.scorecard_id
inner join dm.d_customer dc on dc.id = fs.customer_id
inner join dm.d_date dd on dd.id = fs.date_id 
where dd.date='2021-04-30'
group by dc.country_iso;

-- =================================================================================
