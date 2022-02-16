--select * from generate_series(2018, 2021) as t(year);

select 23456789 as account_number
, (random()*100 + 1)::INT 
from generate_series(2018, 2021) as t(year) ;

select row_number() over (order by date) as id
	, extract(year from date) as date_year
	, extract(month from date) as date_month
	, extract(day from date) as date_day
	, date::date
from generate_series('1900-01-01'::date,'2050-12-31'::date, '1 day'::interval) as t(date);

select * from dm.d_interest_rate where interest_rate = (select max(interest_rate)/5 from dm.d_interest_rate);

select *, extract(day from date) as test 
, (date_trunc('MONTH', date) + INTERVAL '1 MONTH - 1 day')::DATE
from dm.d_date 
where date in ('2021-03-31' ,'2021-04-29', '2021-04-30', '2021-05-30');
-- 44285, 44315, 44345

select cust, sum(1) from(
select cust, generate_series(1,100) as amt
from 
(select distinct id as cust from dm.d_customer order by 1) as t
) t group by 1 order by 1;

select 
from (select distinct id as cust from dm.d_customer)

select 
	concat(10001, ( random()* 2 + 1 )::INT, '00') as account_number
	,
	case
		when amt < 0 then '05'
		else concat(0, ( random()* 3 + 1 )::INT )
	end as booking_code
	,
	trunc(((random()* 100000 + 1) * sign(amt))::decimal, 2) as amount
from
	generate_series(-1000, 9000) as t(amt)
where
	amt != 0

 
select booking_code, sum(amount), sum(1)
from( 
	select 
	concat(10001, ( random()*2+1 )::INT, '00') as account_number
	, case when amt < 0 then '05' else concat(0, ( random()*3+1 )::INT ) end as booking_code
	, trunc(((random()*100000 + 1) * sign(amt))::decimal,2) as amount
	from generate_series(-1000,9000) as t(amt) 
	where amt != 0
	union all
	select 
	concat(10002, ( random()*2+1 )::INT, '00') as account_number
	, case when amt < 0 then '05' else concat(0, ( random()*3+1 )::INT ) end as booking_code
	, trunc(((random()*100000 + 1) * sign(amt))::decimal,2) as amount
	from generate_series(-1000,9000) as t(amt) 
	where amt != 0
	union all
	select 
	concat(10003, ( random()*2+1 )::INT, '00') as account_number
	, case when amt < 0 then '05' else concat(0, ( random()*3+1 )::INT ) end as booking_code
	, trunc(((random()*100000 + 1) * sign(amt))::decimal,2) as amount
	from generate_series(-1000,9000) as t(amt) 
	where amt != 0
) t group by 1 order by 1;


select *
from 
( select row_number() over (order by s1) id, s1 from generate_series(1,10) s1 ) s1
full join 
( select row_number() over (order by s2) id, s2 from generate_series(11,20) s2 ) s2
on s1.id=s2.id;


select (date_trunc('month', dd.date) + interval '1 month - 1 day')::date as end_of_month
	, ftr.account_number
	, ftr.amount
	, sum(ftr.amount) over (partition by ftr.account_number, (date_trunc('month', dd.date) + interval '1 month - 1 day') order by ftr.account_number, (date_trunc('month', dd.date) + interval '1 month - 1 day')) as balance
from dm.f_transactions ftr
inner join dm.d_date dd 
on ftr.date_id = dd.id
order by 3,2 


select (date_trunc('month', dd.date) + interval '1 month - 1 day')::date as end_of_month
	, ftr.account_number
	, sum(ftr.amount) as balance
from dm.f_transactions ftr
inner join dm.d_date dd 
on ftr.date_id = dd.id
group by 1,2 order by 2,1;










